IF OBJECT_ID ('z_IUQ_Temp_Index_Keys', 'U') IS NOT NULL


DROP TABLE z_IUQ_Temp_Index_Keys;


IF OBJECT_ID ('zIUQ_Temp_Index_Usage', 'U') IS NOT NULL


DROP TABLE zIUQ_Temp_Index_Usage


-- Generate list of indexes with key list


create table z_IUQ_Temp_Index_Keys(


[F_Obj_ID] [int] NOT NULL,


[F_Obj_Name] [nvarchar] (128) NULL,


[F_Ind_ID] [int] NOT NULL,


[Index_Column_ID] [int] NOT NULL,


[Index_Key] [nvarchar] (128) NULL,


[Index_Key_List] [nvarchar] (MAX) NULL,


CONSTRAINT [z_IUQ_TempPK] PRIMARY KEY(


[F_Obj_ID],


[F_Ind_ID],


[Index_Column_ID]


)


)


Insert into z_IUQ_Temp_Index_Keys


select


object_id,


object_name(object_id),


index_id,


Index_Column_ID,


index_col(object_name(object_id),index_id,Index_Column_ID),


''


from sys.index_columns


go


-- populate key string


declare IndexCursor cursor FOR


select F_Obj_ID, F_Ind_ID from z_IUQ_Temp_Index_Keys


FOR UPDATE of Index_Key_List


declare @ObjID int


declare @IndID int


DECLARE @KeyString VARCHAR(MAX)


set @KeyString = NULL


open IndexCursor


set nocount on


fetch next from IndexCursor into @ObjID, @IndID


while @@fetch_status = 0 begin


SET @KeyString = ''


SELECT @KeyString = COALESCE(@KeyString, '') + Index_Key + ', '


FROM z_IUQ_Temp_Index_Keys


where F_Obj_ID = @ObjID and F_Ind_ID = @IndID


ORDER BY F_Ind_ID, Index_Column_ID


SET @KeyString = LEFT(@KeyString,LEN(@KeyString) - 2)


update z_IUQ_Temp_Index_Keys


set Index_Key_List = @KeyString


where current of IndexCursor


fetch next from IndexCursor into @ObjID, @IndID


end;


close IndexCursor;


deallocate IndexCursor;


-- Generate list of Index usage


create table zIUQ_Temp_Index_Usage(


[F_Table_Name] [nvarchar](128) NOT NULL,


[F_Ind_ID] [int] NOT NULL,


[F_Index_Name] [nvarchar](128) NULL,


[No_Of_Updates] [int] NULL,


[User_Reads] [int] NULL,


[Last_Used_For_Reads] [datetime] NULL,


[Index_Type] [nvarchar](56) NOT NULL,


[last_user_seek] [datetime] NULL,


[last_user_scan] [datetime] NULL,


[last_user_lookup] [datetime] NULL,


[Index_Keys] [nvarchar] (255) NULL


)


insert into zIUQ_Temp_Index_Usage


select


object_name(US.object_id) Table_Name,


US.index_id Index_ID,


SI.name Index_Name,


US.user_updates No_Of_Updates,


US.user_seeks + US.user_scans + US.user_lookups User_Reads,


case


when (ISNULL(US.last_user_seek,'00:00:00.000') >= ISNULL(US.last_user_scan,'00:00:00.000')) and (ISNULL(US.last_user_seek,'00:00:00.000') >= ISNULL(US.last_user_lookup,'00:00:00.000')) then US.last_user_seek


when (ISNULL(US.last_user_scan,'00:00:00.000') >= ISNULL(US.last_user_seek,'00:00:00.000')) and (ISNULL(US.last_user_scan,'00:00:00.000') >= ISNULL(US.last_user_lookup,'00:00:00.000')) then US.last_user_scan


else US.last_user_lookup


end as Last_Used_For_Reads,


SI.type_desc Index_Type,


US.last_user_seek,


US.last_user_scan,


US.last_user_lookup,


''


from sys.dm_db_index_usage_stats US, sys.indexes SI where SI.object_id = US.object_id and SI.index_id = US.index_id


order by No_Of_Updates desc


go


-- Select and join the two tables.


select


TIU.F_Table_Name Table_Name,


--TIU.F_Ind_ID Index_ID,


--TIU.F_Index_Name Index_Name,


TIK.Index_Key_List,


TIU.No_Of_Updates,


TIU.User_Reads,


case


when TIU.User_Reads = 0 then TIU.No_Of_Updates


else TIU.No_Of_Updates / TIU.User_Reads


end as Cost_Benefit,


TIU.Last_Used_For_Reads,


TIU.Index_Type


from zIUQ_Temp_Index_Usage TIU, z_IUQ_Temp_Index_Keys TIK where TIK.F_Obj_Name = TIU.F_Table_Name and TIK.F_Ind_ID = TIU.F_Ind_ID and TIK.Index_Column_ID = 1


and TIU.F_Table_Name not in ('zIUQ_Temp_Index_Usage','z_IUQ_Temp_Index_Keys')


order by No_Of_Updates desc


--order by Cost_Benefit desc

