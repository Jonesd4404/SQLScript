USE [HPB_HistoricalDaily]
GO

/****** Object:  View [dbo].[vwSIPSSIH]    Script Date: 4/20/2019 10:42:04 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/*09/16/18 0000000074	S	3000147011	8    	Claude at the Beach
 removed the old code...07/24/17

	--and DataUpdateKey not in (496123565,496189893)
	--and  left(itemcode,1) = '1'
	and left(itemcode,1) <> '0' --12/14/10/ZB
	and itemcode <> '\\='  -- failing with convert error 02/23/11
	and len(itemcode) = 20 -- like '%018544100402%' failing with overflow error 04/12/11
	and itemcode <> '11366947230006990000' --overflow error 09/25/11/B 0000000147	S	0000461159	00004
	and itemcode <> 'the bobbsey twins on' --RTHOMAS - Job was failing this item was the cause. 
	--May I recommend:
	--and isnumeric(itemcode) = 1
	and itemcode <> '10040065100033100209' --02/09/12
	and itemcode <> '150000000000000000pz' --07/19/12
	and itemcode <> '97806710268755039997' --07/20/12
	and itemcode <> '1112PM30FM-P00039989' --11/09/12
	and itemcode <> '97805535835715079905' --10/14/13
	and itemcode <> '19195461000007990000' --05/05/14 0000000008	S	0001330815	00001 19195461000007990000
	and itemCode <> '10308896290006990000' --08/29/14 0000000070	S	0001812681	00004
	and itemcode <> '99000000830395034959' --10/06/14 0000000109	S	2000018142	4    
	and itemcode <> '9900000000103.755970' --10/14/14 0000000019	S	3000093260'
	and itemcode <> '99000000000089134.64' --12/29/14 0000000162	S	1000036374	16  
	and itemcode <> '9900000000119412003.' --12/31/14 0000000028	S	1000020003	1  
	and itemcode <> '99000000012005707072' --01/11/15 0000000083	S	1000073033 0
	and itemcode <> '990000000000562.0146' --02/20/15 0000000080	S	2000003163	3
	and itemcode <> '99000000000000001.00' --04/06/15 0000000059	S	2000014503 0
	and itemcode <> '99001238122123815122' --04/08/15 0000000024	S	3000038184 1
	and itemcode <> '99000000066354257056' --05/04/15 0000000050	S	2000041263	1
	and itemcode <> '99000000003110427337' --05/31/15 0000000057	S	2000064362 0
	and itemcode <> '99000000006130650387' --06/05/15 0000000063	S	2000002005	104  	UNKNOWN ITEMS1404265
	and itemcode <> '99000000013256966410' --06/09/15 0000000165	S	2000014114	11 
	and itemcode <> '99000000031398183426' --07/30/15 0000000222	S	2000009233  6 
	and itemcode <> '99000000342117878669' --08/09/15 0000000037	S	3000042738	0  
	and itemcode <> '99000000008761418524' --08/11/15 0000000052	S	1000068177	0   
	and itemcode <> '99000000796019798242' --08/11/15 0000000222	S	1000012165	2    
	and itemcode <> '990000000001.5892384' --08/23/15 0000000057	S	1000051368	5  
	and itemcode <> '99000000883929151684' --08/23/15 0000000222	S	1000013898	0  
	and itemcode <> '99000000086162147036' --08/28/15 0000000222	S	1000014528	1       
	and itemcode <> '99000000085392132225' --09/08/15 0000000065	S	1000197062	0  
	and itemcode <> '99000000014709771736' --09/29/15 0000000080	S	3000018918	0 (DG)
	and itemcode <> '99000000013110033997' --10/05/15 0000000199	S	3000055765	1 (DG)
	and itemcode <> '99000000005136522602' --10/12/15 0000000033	S	3000029415	7 (DG)
	and itemcode <> '99000000012563318540' --12/03/15 0000000019	S	2000203594	0
	and itemcode <> '99000000013765737611' --12/15/15 0000000013	S	3000080330	7
	and itemcode <> '99000014495144956275' --01/04/16 0000000027	S	1000046408	0
	and itemcode <> '990000000000000000.0' --01/11/16 0000000165	S	1000045134	2
	and itemcode <> '99000000013765474211' --02/02/16 0000000012	S	1000068978	11
	and itemcode <> '99000001502377777682' --02/27/16 0000000018	S	1000061500	6 
	and itemcode <> '99000000786309062764' --02/27/16 0000000083	S	2000123446	23
	and itemcode <> '99000000015301491291' --03/01/16 0000000153	S	1000110282	0 
	and itemcode <> '99000000015284795691' --03/07/16 0000000153	S	1000111075	3 
	and itemcode <> '99000000015130520284' --03/14/16 0000000040	S	1000057770	2
	and itemcode <> '99000155037155037482' --03/20/16 0000000052	S	2000022087	0
	and itemcode <> '990000000013.9290785' --04/09/16 0000000077	S	4000122164	4   
	and itemcode <> '99000000001.35151139' --04/09/16 0000000138	S	4000070873	22  
	and itemcode <> '99000000014714971936' --04/28/16 0000000084	S	3000049106	0    
	and itemcode <> '990000000001.6753492' --05/16/16 0000000163	S	1000125448	5   
	and itemcode <> '99000000012673358711' --05/19/16 0000000206	S	1000099149	1    
	and itemcode <> '99000000015724330911' --06/10/16 0000000076	S	1000111007	1 
	and itemcode <> '99000000016029588832' --06/21/16 0000000061	S	4000026934	3
	and itemcode <> '99000000012218886130' --07/04/16 0000000093	S	1000124514	2
	and itemcode <> '99000010144905100586' --07/11/16 0000000088	S	1000138237	4
	and itemcode <> '99000000004119115053' --09/02/16 0000000163	S	1000145957	0 
	and itemcode <> '9900000000011.902862' --10/24/16 0000000161	S	1000092286	3
	and itemcode <> '99000000010180340499' --11/17/16 0000000084	S	2000149912	0
	and itemcode <> '99000000000176.25972' --12/20/16 0000000220	S	1000098833	11
	and itemcode <> '99000000179179609664' --01/14/17 0000000037	S	1000093779	0    
	and itemcode <> '99000000017842626389' --02/10/17 0000000084	S	3000072406	2
	and itemcode <> '99000000018183213210' --02/17/17 0000000106	S	3000195723	2  
	and itemcode <> '99000000012805021524' --05/17/17 0000000144	S	1000151650	4       
	and itemcode <> '99000001023102323596' --06/16/17 0000000053	S	3000088124	4 
	and itemcode <> '99000010195952100321' --06/25/17 0000000084	S	2000184295	10
	and itemcode <> '150000000000000000pz' --06/25/17 0000000052	S	3000100565	1 and 0000000069	S	2000267895	0
	and itemcode <> '99000000013292105326' --07/01/17 0000000224	S	3000034269	3    
	and itemcode <> '99000000019193303603' --07/24/17 0000000084	S	1000196050	0 
	and right(ItemCode,18) 	<> '040065100033100209' --02/09/12
	and right(ItemCode,18) <> '0000000000000000pz' --07/19/12
	and right(ItemCode,18) <> '806710268755039997' --07/20/12
	and right(ItemCode,18) <> '12PM30FM-P00039989' --11/09/12
	and right(ItemCode,18) <> '805535835715079905' --10/14/13
	and right(ItemCode,18) <> '195461000007990000' --05/05/14 0000000008	S	0001330815	00001 19195461000007990000
	and right(ItemCode,18) <> '308896290006990000' --08/29/14 0000000070	S	0001812681	00004
	and right(ItemCode,18) <> '000000830395034959' --10/06/14 0000000109	S	2000018142	4    
	and right(ItemCode,18) <> '00000000103.755970' --10/14/14 0000000019	S	3000093260'
	and right(ItemCode,18) <> '000000000089134.64' --12/29/14 0000000162	S	1000036374	16  
	and right(ItemCode,18) <> '00000000119412003.' --12/31/14 0000000028	S	1000020003	1  
	and right(ItemCode,18) <> '000000012005707072' --01/11/15 0000000083	S	1000073033 0
	and right(ItemCode,18) <> '0000000000562.0146' --02/20/15 0000000080	S	2000003163	3
	and right(ItemCode,18) <> '000000000000001.00' --04/06/15 0000000059	S	2000014503 0
	and right(ItemCode,18) <> '001238122123815122' --04/08/15 0000000024	S	3000038184 1
	and right(ItemCode,18) <> '000000066354257056' --05/04/15 0000000050	S	2000041263	1
	and right(ItemCode,18) <> '000000003110427337' --05/31/15 0000000057	S	2000064362 0
	and right(ItemCode,18) <> '000000006130650387' --06/05/15 0000000063	S	2000002005	104  	UNKNOWN ITEMS1404265
	and right(ItemCode,18) <> '000000013256966410' --06/09/15 0000000165	S	2000014114	11 
	and right(ItemCode,18) <> '000000031398183426' --07/30/15 0000000222	S	2000009233  6 
	and right(ItemCode,18) <> '000000342117878669' --08/09/15 0000000037	S	3000042738	0  
	and right(ItemCode,18) <> '000000008761418524' --08/11/15 0000000052	S	1000068177	0   
	and right(ItemCode,18) <> '000000796019798242' --08/11/15 0000000222	S	1000012165	2    
	and right(ItemCode,18) <> '0000000001.5892384' --08/23/15 0000000057	S	1000051368	5  
	and right(ItemCode,18) <> '000000883929151684' --08/23/15 0000000222	S	1000013898	0  
	and right(ItemCode,18) <> '000000086162147036' --08/28/15 0000000222	S	1000014528	1       
	and right(ItemCode,18) <> '000000085392132225' --09/08/15 0000000065	S	1000197062	0  
	and right(ItemCode,18) <> '000000014709771736' --09/29/15 0000000080	S	3000018918	0 (DG)
	and right(ItemCode,18) <> '000000013110033997' --10/05/15 0000000199	S	3000055765	1 (DG)
	and right(ItemCode,18) <> '000000005136522602' --10/12/15 0000000033	S	3000029415	7 (DG)
	and right(ItemCode,18) <> '000000012563318540' --12/03/15 0000000019	S	2000203594	0
	and right(ItemCode,18) <> '000000013765737611' --12/15/15 0000000013	S	3000080330	7
	and right(ItemCode,18) <> '000014495144956275' --01/04/16 0000000027	S	1000046408	0
	and right(ItemCode,18) <> '0000000000000000.0' --01/11/16 0000000165	S	1000045134	2
	and right(ItemCode,18) <> '000000013765474211' --02/02/16 0000000012	S	1000068978	11
	and right(ItemCode,18) <> '000001502377777682' --02/27/16 0000000018	S	1000061500	6 
	and right(ItemCode,18) <> '000000786309062764' --02/27/16 0000000083	S	2000123446	23
	and right(ItemCode,18) <> '000000015301491291' --03/01/16 0000000153	S	1000110282	0 
	and right(ItemCode,18) <> '000000015284795691' --03/07/16 0000000153	S	1000111075	3 
	and right(ItemCode,18) <> '000000015130520284' --03/14/16 0000000040	S	1000057770	2
	and right(ItemCode,18) <> '000155037155037482' --03/20/16 0000000052	S	2000022087	0
	and right(ItemCode,18) <> '0000000013.9290785' --04/09/16 0000000077	S	4000122164	4   
	and right(ItemCode,18) <> '000000001.35151139' --04/09/16 0000000138	S	4000070873	22  
	and right(ItemCode,18) <> '000000014714971936' --04/28/16 0000000084	S	3000049106	0    
	and right(ItemCode,18) <> '0000000001.6753492' --05/16/16 0000000163	S	1000125448	5   
	and right(ItemCode,18) <> '000000012673358711' --05/19/16 0000000206	S	1000099149	1    
	and right(ItemCode,18) <> '000000015724330911' --06/10/16 0000000076	S	1000111007	1 
	and right(ItemCode,18) <> '000000016029588832' --06/21/16 0000000061	S	4000026934	3
	and right(ItemCode,18) <> '000000012218886130' --07/04/16 0000000093	S	1000124514	2
	and right(ItemCode,18) <> '000010144905100586' --07/11/16 0000000088	S	1000138237	4
	and right(ItemCode,18) <> '000000004119115053' --09/02/16 0000000163	S	1000145957	0 
	and right(ItemCode,18) <> '00000000011.902862' --10/24/16 0000000161	S	1000092286	3
	and right(ItemCode,18) <> '000000010180340499' --11/17/16 0000000084	S	2000149912	0
	and right(ItemCode,18) <> '000000000176.25972' --12/20/16 0000000220	S	1000098833	11
	and right(ItemCode,18) <> '000000179179609664' --01/14/17 0000000037	S	1000093779	0    
	and right(ItemCode,18) <> '000000017842626389' --02/10/17 0000000084	S	3000072406	2
	and right(ItemCode,18) <> '000000018183213210' --02/17/17 0000000106	S	3000195723	2  
	and right(ItemCode,18) <> '000000012805021524' --05/17/17 0000000144	S	1000151650	4       
	and right(ItemCode,18) <> '000001023102323596' --06/16/17 0000000053	S	3000088124	4 
	and right(ItemCode,18) <> '000010195952100321' --06/25/17 0000000084	S	2000184295	10
	and right(ItemCode,18) <> '0000000000000000pz' --06/25/17 0000000052	S	3000100565	1 and 0000000069	S	2000267895	0
	and right(ItemCode,18) <> '000000013292105326' --07/01/17 0000000224	S	3000034269	3    
	and right(ItemCode,18) <> '000000019193303603' --07/24/17 0000000084	S	1000196050	0 
	
	--and isnumeric(itemcode) = 1


990000000000\7480948*/
CREATE VIEW [dbo].[vwSIPSSIH]
AS
SELECT     LocationID, XactionType, SalesXactionId, LineNumber, Description, DiscountAmt, DiscountPct, DiscountPrice, ExtendedAmt, ISBN, IsReturn, IsTaxable, ItemCode, 
                      NonTaxableAmt, ODPCCode, ODPCFlag, Quantity, RegisterPrice, ReturnCode, SalesTax, TaxableAmt, Title, UnitPrice, DataUpdateKey, CONVERT(int, RIGHT(ItemCode, 
                      18)) AS SipsItemCode
FROM         dbo.SIHDaily
WHERE     (DataUpdateKey >
                          (SELECT     LastDataUpdateKey
                            FROM          dbo.SIPSSIHDailyLastUpdate)) AND (LEFT(ItemCode, 1) <> '0') AND (RIGHT(ItemCode, 18) <> '000000019193303603') AND (RIGHT(ItemCode, 18) 
                      <> '0000000000000000pz') AND (ItemCode <> '99000000002491905571') AND (ItemCode <> '99000000002463808586') AND (ItemCode <> '99000000002526392088') 
                      AND (ItemCode <> '99000000002413317866')
					  AND (ItemCode <> '0000000000\7482013')
					  AND (ItemCode <> '000020184205061027')

GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPane1', @value=N'[0E232FF0-B466-11cf-A24F-00AA00A3EFFF, 1.00]
Begin DesignProperties = 
   Begin PaneConfigurations = 
      Begin PaneConfiguration = 0
         NumPanes = 4
         Configuration = "(H (1[40] 4[20] 2[20] 3) )"
      End
      Begin PaneConfiguration = 1
         NumPanes = 3
         Configuration = "(H (1 [50] 4 [25] 3))"
      End
      Begin PaneConfiguration = 2
         NumPanes = 3
         Configuration = "(H (1 [50] 2 [25] 3))"
      End
      Begin PaneConfiguration = 3
         NumPanes = 3
         Configuration = "(H (4 [30] 2 [40] 3))"
      End
      Begin PaneConfiguration = 4
         NumPanes = 2
         Configuration = "(H (1 [56] 3))"
      End
      Begin PaneConfiguration = 5
         NumPanes = 2
         Configuration = "(H (2 [66] 3))"
      End
      Begin PaneConfiguration = 6
         NumPanes = 2
         Configuration = "(H (4 [50] 3))"
      End
      Begin PaneConfiguration = 7
         NumPanes = 1
         Configuration = "(V (3))"
      End
      Begin PaneConfiguration = 8
         NumPanes = 3
         Configuration = "(H (1[56] 4[18] 2) )"
      End
      Begin PaneConfiguration = 9
         NumPanes = 2
         Configuration = "(H (1 [75] 4))"
      End
      Begin PaneConfiguration = 10
         NumPanes = 2
         Configuration = "(H (1[66] 2) )"
      End
      Begin PaneConfiguration = 11
         NumPanes = 2
         Configuration = "(H (4 [60] 2))"
      End
      Begin PaneConfiguration = 12
         NumPanes = 1
         Configuration = "(H (1) )"
      End
      Begin PaneConfiguration = 13
         NumPanes = 1
         Configuration = "(V (4))"
      End
      Begin PaneConfiguration = 14
         NumPanes = 1
         Configuration = "(V (2))"
      End
      ActivePaneConfig = 0
   End
   Begin DiagramPane = 
      Begin Origin = 
         Top = 0
         Left = 0
      End
      Begin Tables = 
         Begin Table = "SIHDaily"
            Begin Extent = 
               Top = 6
               Left = 38
               Bottom = 136
               Right = 213
            End
            DisplayFlags = 280
            TopColumn = 0
         End
      End
   End
   Begin SQLPane = 
   End
   Begin DataPane = 
      Begin ParameterDefaults = ""
      End
      Begin ColumnWidths = 26
         Width = 284
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
         Width = 1500
      End
   End
   Begin CriteriaPane = 
      Begin ColumnWidths = 11
         Column = 1440
         Alias = 900
         Table = 1170
         Output = 720
         Append = 1400
         NewValue = 1170
         SortType = 1350
         SortOrder = 1410
         GroupBy = 1350
         Filter = 1350
         Or = 1350
         Or = 1350
         Or = 1350
      End
   End
End
' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwSIPSSIH'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_DiagramPaneCount', @value=1 , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'VIEW',@level1name=N'vwSIPSSIH'
GO


