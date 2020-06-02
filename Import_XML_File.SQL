--So, now I can read the XML file Smile
--I removed the namespace and changed the sql script.

DECLARE @x xml

--SELECT @x = T
--FROM OPENROWSET (BULK 'C:\temp\01-06-2016.xml', SINGLE_BLOB) AS Terrorliste(T)

SELECT @x = T
FROM OPENROWSET (BULK 'C:\Amazon\Reports\Amazon_Report_GET_ORDERS_DATA_01182018_11_37_AM', SINGLE_BLOB) AS Testlist(T)

DECLARE @hdoc int
EXEC sp_xml_preparedocument @hdoc OUTPUT, @x

SELECT *
FROM OPENXML (@hdoc, '/export/sanctionEntity/nameAlias', 2)
WITH (
firstName varchar(200)'@firstName',
middleName varchar(200)'@middleName', 
lastName varchar(200)'@lastName',
wholeName varchar(400)'@wholeName',
logicalId varchar(10)'../@logicalId')

EXEC sp_xml_removedocument @hdoc