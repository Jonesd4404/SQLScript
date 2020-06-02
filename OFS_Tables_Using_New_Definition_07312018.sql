/*
OrderID
OrderSystem
OrderDate
OrderStatus
ShipDate
OrderLocationNo
OriginLocationNo
OrderItemStatus
ShippingFee
ItemCode
WeightOz
TrackingNo
FinalPostage
PostageActive
RefundDate
RefundMsg
MailClass
MailPieceShape
PostalService
*/

USE [OFS]

select 
h.OrderID,
--h.OrderNo,
h.OrderSystem,
h.OrderDate,
osc.OrderStatus,
h.ShipDate,
--h.OrderCustomerID,
--sm.ShipName,
--h.MarketName,
--h.MarketOrderID,
--h.MarketID,
h.OrderLocationNo,
--h.LastDateModified[OrderLastDateModified],
--h.LastUserModified[OrderLastUserModified],
h.OriginLocationNo,
--d.ItemID,
isc.OrderItemStatus,
--d.price,
d.ShippingFee,
--d.LocationNo,
--d.ISBN,
--d.UPC,
--d.EAN,
--d.MarketSKU,
d.ItemCode,
--d.SKUExtension,
--d.Title,
--d.Author,
--d.Subject,
d.WeightOz,
--d.ShelfProxyID,
--d.MarketOrderItemID,
--d.FacilityID,
--d.ListingInstanceID,
--d.LastDateModified[ItemLastDateModified],
--d.LastUserModified[ItemLastUserModified],
--agv.VarName[ProblemStatus],
--d.Category,
--d.ItemTax,
--d.ShippingTax,
sl.TrackingNo,
sl.FinalPostage,
--sl.TransactionID,
--sl.TransactionDate,
--sl.WeightOZ,
sl.Active[PostageActive],
rh.RefundDate, 
--rh.IsApproved, 
rh.RefundMsg,
--sl.LocationNo, 
--sl.name,
--sl.Company,
--sl.Address1,
--sl.Address2,
--sl.City,
--sl.State,
--sl.Postalcode,
--sl.Phone,
sl.MailClass,
sl.MailPieceShape,
--sl.InsuredMail,
ps.ServiceName[PostalService]
--sl.Binding
--INTO DEJ_OFS_NEW
INTO DEJ_OFS_July_2018_Only
from ofs..order_header h
	join ofs..Order_StatusCodes osc
		on osc.OrderStatusID = h.Status
	join ofs..Order_ShipMethods sm
		on sm.ShipMethodID = h.ShipMethodID
	join ofs..Order_Detail d
		on h.orderid = d.orderid
	join ofs..Order_Item_StatusCodes isc
		on isc.OrderItemStatusID = d.Status
	left join ofs..App_GlobalVariables agv
		on agv.GlobalSettingID = 4
		and agv.GlobalVarID = d.ProblemStatusID
	join ofs..Order_PostageMapping opm
		on opm.LocationNo = d.LocationNo 
		and opm.OrderID = d.OrderID
	join PostageService..Shipping_Labels sl
		on sl.LabelID = opm.LabelID
	left join PostageService..App_PostalService ps
		on ps.PostalID = sl.PostalID
	left join PostageService..Shipping_RefundHIstory rh
		on rh.LabelID = sl.LabelID
where h.OrderDate >= '7/1/2018'
and h.orderdate < '8/1/2018'
order by h.OrderID, d.ItemID