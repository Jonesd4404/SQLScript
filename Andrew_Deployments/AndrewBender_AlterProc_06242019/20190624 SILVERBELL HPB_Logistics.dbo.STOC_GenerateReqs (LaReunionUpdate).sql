/*
	=============================================
	Author:		Joey B.
	Description:	Generates new requisitions for active locations once reqs are consolidated to POs
	Modfificatin:	Created: 06/29/2012 - JB - Initial stored procedure
					Updated: 06/24/2019 - ALB- Add exception for LaReunion
	=============================================
*/
ALTER PROCEDURE [dbo].[STOC_GenerateReqs]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- ** Release all locks 
	UPDATE HPB_Logistics.dbo.STOC_Reorder_Control
		SET	 Locked = 'N'
			,LockedBy = NULL
			,LockedDate = NULL
	WHERE Locked = 'Y'
		AND VendorID <> 'WHPBSUPPLY'

	-- ** Get all store locations
	CREATE TABLE #locs 
	(
		 locationno CHAR(5)
		,locationname CHAR(30)
		,locationID CHAR(10)
	)

	BEGIN
		INSERT #locs
			SELECT	 locationno
					,DistrictCode
					,locationid
			FROM HPB_Prime.dbo.Locations
			WHERE retailstore = 'y'
				AND isnumeric(locationno) = 1
				AND STATUS = 'A'
				AND CAST(locationno AS INT) BETWEEN 1 AND 200
				OR STATUS = 'A'
				AND UserInt1 = 1
				AND locationno != '00888'
			ORDER BY LocationNo
	END

	-- ** Get reorderable vendors
	CREATE TABLE #rVendors 
	(
		 vendorID VARCHAR(20)
		,NextOrderDate DATETIME
	)

	BEGIN
		INSERT HPB_Logistics.dbo.STOC_Vendors
		SELECT DISTINCT 
			 VendorID
			,[Name]
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
		FROM HPB_Prime.dbo.VendorMaster WITH (NOLOCK)
		WHERE isnull(ltrim(rtrim(userchar30)), '') <> ''
			AND UserChar15 IN ('STOC')
			AND vendorid NOT IN (	SELECT DISTINCT VendorID
									FROM HPB_Logistics.dbo.STOC_Vendors
								)

		INSERT #rVendors
			SELECT DISTINCT 
				 v.vendorid
				,(	SELECT DISTINCT TOP 1 RequisitionDueDate
					FROM HPB_Logistics.dbo.STOC_Reorder_Control
					WHERE VendorID = v.VendorID
				 ) AS [NextOrderDate]
			FROM HPB_Logistics.dbo.STOC_Vendors v WITH (NOLOCK)
	END

	-- ** Put all vendors into a cross join with locations
	CREATE TABLE #reorderReqs 
	(
		 locationno CHAR(5)
		,vendorid VARCHAR(30)
	)
	CREATE CLUSTERED INDEX [IDX_ROITEMS_RU] ON #reorderReqs ( [locationno] ,[vendorid] )

	INSERT INTO #reorderReqs
		SELECT	 lc.locationno
				,v.vendorID
		FROM #locs lc
			CROSS JOIN #rVendors v

	-- ** Delete out non-supply reorder locations
	/*
	DELETE
	FROM #reorderReqs
	WHERE VendorID != 'WHPBSUPPLY'
		AND LocationNo IN (	SELECT LocationNo
							FROM HPB_Prime.dbo.Locations
							WHERE UserInt1 = 1)
	*/
	-- ** Updated to exclude location 452 (La Reunion) 
	DELETE
	FROM #reorderReqs
	WHERE VendorID != 'WHPBSUPPLY'
		AND LocationNo IN (	SELECT LocationNo
							FROM HPB_Prime.dbo.Locations
							WHERE UserInt1 = 1
								AND LocationNo NOT IN ('00452'))

	-- ** Insert any missing Locations into locations table
	INSERT INTO HPB_Logistics.dbo.STOC_Locations
	SELECT	 locationno
			,locationID
			,'N'
			,GETDATE()
	FROM #locs
	WHERE locationno NOT IN ( SELECT locationno FROM HPB_Logistics.dbo.STOC_Locations )
		AND locationID NOT IN ( SELECT locationID FROM HPB_Logistics.dbo.STOC_Locations )

	-- ** Turn off any stores that have been set to inactive
	UPDATE sl
		SET	 sl.Active = 'N'
	FROM HPB_Logistics.dbo.STOC_Locations sl
		INNER JOIN HPB_Prime.dbo.Locations l 
			ON sl.LocationID = l.LocationID
	WHERE l.STATUS = 'I'

	-- ** Insert any missing Store/Vendor records
	INSERT INTO HPB_Logistics.dbo.STOC_Reorder_Control (StoreNo,VendorID)
		SELECT	 rr.locationno
				,rr.vendorid
		FROM #reorderReqs rr
			INNER JOIN HPB_Logistics.dbo.STOC_Locations sl 
				ON rr.locationno = sl.locationno
			LEFT JOIN HPB_Logistics.dbo.STOC_Reorder_Control src 
				ON rr.locationno = src.storeno
		WHERE (isnull(src.storeno, '') = '' AND isnull(src.vendorid, '') = '' AND sl.Active = 'Y' )
			OR (	NOT EXISTS (	SELECT DISTINCT vendorid
									FROM HPB_Logistics.dbo.STOC_Reorder_Control
									WHERE vendorid = rr.vendorid
										AND StoreNo = rr.locationno
								)
					AND sl.Active = 'Y')
		GROUP BY rr.locationno ,rr.vendorid
		ORDER BY rr.vendorid ,rr.locationno

	-- ** Join with SEQ requisitionheader to delete consolidated orders
	UPDATE src
		SET	 src.requisitionno = NULL
			,src.STATUS = NULL
			,src.requisitiondate = NULL
			,src.requisitionduedate = NULL
	FROM HPB_Logistics.dbo.STOC_Reorder_Control src
	WHERE STATUS IN ('99')
		OR src.requisitionno IN (	SELECT requisitionno
									FROM OPENDATASOURCE ('SQLOLEDB','Data Source=sequoia;User ID=stocuser;Password=Xst0c5').HPB_db.dbo.requisitionheader
									WHERE (
												( ponumber IS NOT NULL AND requestby <> 'VOID' )
												OR (ponumber IS NULL AND requestby = 'VOID' )
										  )
										AND requisitionno = src.requisitionno
								 )

	-- ** Put Store/Vendor records that need a new req into temp table
	CREATE TABLE #NewReqs 
	(
		 ID INT identity(1, 1)
		,locationno CHAR(5)
		,vendorid VARCHAR(30)
	)
	CREATE CLUSTERED INDEX [IDX_ROITEMS_RU] ON #NewReqs ( [locationno] ,[vendorid] )

	INSERT INTO #NewReqs
		SELECT	 src.StoreNo
				,src.VendorID
		FROM HPB_Logistics.dbo.STOC_Reorder_Control src
			INNER JOIN HPB_Logistics.dbo.STOC_Locations sl 
				ON src.storeno = sl.locationno
			INNER JOIN #rVendors v 
				ON src.VendorID = v.VendorID
		WHERE sl.active = 'Y'
			AND src.requisitionno IS NULL

	-- ** Loop thru temp table and get new values
	DECLARE @loop INT

	SET @loop = ( SELECT MAX(ID) FROM #NewReqs )

	WHILE isnull(@loop, 0) > 0
		BEGIN
			DECLARE @sRet CHAR(6)
			DECLARE @newReqNo CHAR(6)

			EXEC OPENDATASOURCE ( 'SQLOLEDB' ,'Data Source=sequoia;User ID=stocuser;Password=Xst0c5' ).HPB_db.dbo.STOC_GetNextRequisitionNo @sRet = @newReqNo OUTPUT 
			UPDATE src
			SET	 src.requisitionno = @newReqNo
				,src.STATUS = 10
				,src.requisitiondate = GETDATE()
				,src.requisitionduedate = ( SELECT dbo.FN_STOC_GetNextOrderDate(src.vendorid))
			FROM HPB_Logistics.dbo.STOC_Reorder_Control src
			WHERE src.vendorid = (	SELECT vendorid FROM #NewReqs WHERE ID = @loop )
				AND src.storeno = (	SELECT locationno FROM #NewReqs WHERE ID = @loop )
			SET @loop = @loop - 1
		END

	---** End of loop
	DROP TABLE #locs
	DROP TABLE #rVendors
	DROP TABLE #reorderReqs
	DROP TABLE #NewReqs
END