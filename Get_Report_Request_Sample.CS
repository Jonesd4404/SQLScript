String accessKeyId = "YourSecretKey";
String secretAccessKey = "YourSecretAccessKey";
MarketplaceWebServiceConfig config = new MarketplaceWebServiceConfig();
config.ServiceURL = "https://mws.amazonservices.com";
const string applicationName = "ApplicationName";
const string applicationVersion = "0.1a";
 
      MarketplaceWebServiceClient service =
      new MarketplaceWebServiceClient(
             accessKeyId,
             secretAccessKey,
             applicationName,
             applicationVersion,
             config);
 
const string merchantId = "YourMerchantID";
const string marketplaceId = "YourMarketplaceID";
 
RequestReportRequest reportRequestRequest = new RequestReportRequest();
reportRequestRequest.Merchant = merchantId;
reportRequestRequest.Marketplace = marketplaceId;
reportRequestRequest.ReportType = "_GET_FLAT_FILE_ACTIONABLE_ORDER_DATA_";
 
RequestReportResponse requestResponse = service.RequestReport(reportRequestRequest);
Thread.Sleep(15000);     //wait 15 seconds for order to process
 
GetReportListRequest listRequest = new GetReportListRequest();
listRequest.Merchant = merchantId;
listRequest.Marketplace = marketplaceId;
GetReportListResponse listResponse = service.GetReportList(listRequest);
 
GetReportListResult getReportListResult = listResponse.GetReportListResult;
List<ReportInfo> reportInfoList = getReportListResult.ReportInfo;
ReportInfo myReportInfo = reportInfoList[0];
 
GetReportRequest reportRequest = new GetReportRequest();
reportRequest.Merchant = merchantId;
reportRequest.Marketplace = marketplaceId;
 
String source = path + "\\XMLReport.xml";
reportRequest.ReportId = myReportInfo.ReportId;
reportRequest.Report = File.Open(source, FileMode.Create, FileAccess.ReadWrite);
service.GetReport(reportRequest);
 
GetReportRequestListRequest reportRequestListRequest = new GetReportRequestListRequest();
reportRequestListRequest.Marketplace = marketplaceId;
reportRequestListRequest.Merchant = merchantId;
List<ReportRequestInfo> myListzz = new List<ReportRequestInfo>();
 
GetReportRequestListResponse reportRequestListResponse = new GetReportRequestListResponse();
reportRequestListResponse = service.GetReportRequestList(reportRequestListRequest);
GetReportRequestListResult reportRequestListResult = new GetReportRequestListResult();
reportRequestListResult = reportRequestListResponse.GetReportRequestListResult;
myListzz = reportRequestListResult.ReportRequestInfo;
 
while (myListzz[0].ReportProcessingStatus.ToString() != "_DONE_")
     {
           lblStatus.Text = "Waiting for Report";
           Thread.Sleep(61000);
           reportRequestListResponse = service.GetReportRequestList(reportRequestListRequest);
           reportRequestListResult = reportRequestListResponse.GetReportRequestListResult;
           myListzz = reportRequestListResult.ReportRequestInfo;
      }

Hopefully this example will help others trying to do something sim