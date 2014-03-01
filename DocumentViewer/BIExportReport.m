//
//  BIExportReport.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-03-01.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import "BIExportReport.h"
#import "Document.h"
#import "BI4RestConstants.h"
#import "WebiAppDelegate.h"
#import "BILogoff.h"

@implementation BIExportReport
{
    BIConnector *connector;
    WebiAppDelegate *appDelegate;
    BOOL _isDocument;
    NSURL *_url;
}

@synthesize connectorError;
@synthesize boxiError;
@synthesize delegate;
@synthesize biSession;
@synthesize context;

#pragma mark Export With URL

# pragma mark getExportReport URL

+(NSURL *) getExportReportURLForDocumentId: (int) documentId withReportId: (int) reportId withSession:(Session *) session{
    NSLog (@"Export Report URL For Report id:%d",reportId);
    NSURL *getExportReportUrl;
    NSString *host=[NSString stringWithFormat: @"%@:%@",session.cmsName,session.port] ;
    if ([session.isHttps integerValue]==1){
        getExportReportUrl=[[NSURL alloc]initWithScheme:@"https" host:host path:[NSString stringWithFormat:@"%@%@%@%d%@%d",session.webiRestSDKBase,getDocumentsPathPoint,@"/",documentId,@"/reports/",reportId]];
    }
    else{
        getExportReportUrl=[[NSURL alloc]initWithScheme:@"http" host:host path:[NSString stringWithFormat:@"%@%@%@%d%@%d",session.webiRestSDKBase,getDocumentsPathPoint,@"/",documentId,@"/reports/",reportId]];
        
    }
    NSLog(@"URL:%@",getExportReportUrl);
    return  getExportReportUrl;
}

-(void) exportEntityWithUrl:(NSURL *)url withFormat:(ReportExportFormat)format forSession:(Session *)currentSession
{
    _isExportWithUrl=YES;
    _isDocument=NO;
    appDelegate = (id)[[UIApplication sharedApplication] delegate];
    _currentToken=currentSession.cmsToken;
    _exportFormat=format;
    _url=url;
    
    if (currentSession.cmsToken==nil){
        
        NSLog(@"CMS Token is NULL - create new one");
        connector=[[BIConnector alloc]init];
        connector.delegate=self;
        [connector getCmsTokenWithSession:currentSession];
    }else{
        NSLog(@"CMS Token is NOT NULL - Process With Existing Token");
        [self processHttpRequestForUrl:url];
        
    }
    
    
}

#pragma mark Export Report
-(void) exportReport:(Report *)report withFormat:(ReportExportFormat)format{
    NSLog(@"Export report ID:%@ With Session:%@",report.id,report.document.session.name);
    
    _isDocument=NO;
    appDelegate = (id)[[UIApplication sharedApplication] delegate];
    self.currentToken=self.biSession.cmsToken;
    
    //    self.biSession=report.document.session;
    report.document.session=self.biSession;
    self.report=report;
    self.exportFormat=format;
    // Get Token First
    if (report.document.session.cmsToken==nil){
        //        if (report.document.session.cmsToken==nil){
        NSLog(@"CMS Token is NULL - create new one");
        connector=[[BIConnector alloc]init];
        connector.delegate=self;
        [connector getCmsTokenWithSession:report.document.session];
    }else{
        NSLog(@"CMS Token is NOT NULL - Process With Existing Token");
        [self processHttpRequestForSession:report];
        
    }
    
}


-(void) exportDocument:(Document *)document withFormat:(ReportExportFormat)format
{
    NSLog(@"Export Document ID:%@ With Session:%@",document.id, document.session.name);
    _isDocument=YES;
    
    appDelegate = (id)[[UIApplication sharedApplication] delegate];
    _currentToken=self.biSession.cmsToken;
    
    document.session=self.biSession;
    _document=document;
    _exportFormat=format;
    // Get Token First
    if (document.session.cmsToken==nil){
        NSLog(@"CMS Token is NULL - create new one");
        connector=[[BIConnector alloc]init];
        connector.delegate=self;
        [connector getCmsTokenWithSession:document.session];
    }else{
        NSLog(@"CMS Token is NOT NULL - Process With Existing Token");
        [self processHttpRequestForSessionWithDocument:document];
        
    }
    
    
}
#pragma mark getToken Completed

-(void) biConnector:(BIConnector *)biConnector didCreateCmsToken:(NSString *)cmsToken forSession:(Session *)session{
    NSLog (@"Return From Get CMS Token");
    if(cmsToken!=nil){
        NSLog(@"Token Receieved:%@",cmsToken);
        self.currentToken=cmsToken;
        
        if (_isDocument==NO){
            if (_isExportWithUrl==YES)
                [self processHttpRequestForUrl:_url];
            else
                [self processHttpRequestForSession:self.report];
        }
        else
            [self processHttpRequestForSessionWithDocument:_document];
        
        
    }else if (biConnector.connectorError!=nil){
        self.connectorError=biConnector.connectorError ;
        [self.delegate biExportReport:self isSuccess:NO html:nil];
        
    }else if (biConnector.boxiError!=nil){
        self.boxiError=biConnector.boxiError;
        [self.delegate biExportReport:self isSuccess:NO html:nil];
        
    }else{
        [self.delegate biExportReport:self isSuccess:NO html:nil];
    }
    
}



# pragma mark Export Document

-(void) processHttpRequestForSessionWithDocument: (Document *) document
{
    
    self.biSession=document.session;
    NSString *cmsToken=[[NSString alloc] initWithFormat:@"%@%@%@",@"\"",self.currentToken,@"\""];
    NSMutableURLRequest *request = [NSMutableURLRequest  requestWithURL:[self getExportDocumentUrl:document]];
    
    NSLog(@"Process with URL: %@",[request URL]);
    NSLog(@"Token:%@",cmsToken);
    
    NSLog(@"Timeout Preference Value:%@",appDelegate.globalSettings.networkTimeout);
    [request setTimeoutInterval:[appDelegate.globalSettings.networkTimeout doubleValue ]];
    
    
    [request setHTTPMethod:@"GET"];
    
    switch (self.exportFormat) {
        case FormatHTML:
            [request setValue:@"text/html" forHTTPHeaderField:@"Accept"];
            NSLog(@"HTML Header");
            break;
        case FormatPDF:
            [request setValue:@"application/pdf" forHTTPHeaderField:@"Accept"];
            NSLog(@"PDF Header");
            break;
            
        case FormatEXCEL:
            [request setValue:@"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" forHTTPHeaderField:@"Accept"];
            NSLog(@"Excel Header");
            break;
            
        default:
            [request setValue:@"text/html" forHTTPHeaderField:@"Accept"];
            break;
    }
    
    [request setValue:cmsToken forHTTPHeaderField:SAP_HTTP_TOKEN];
    (void)[[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}

-(void) processHttpRequestForUrl: (NSURL *) url
{
    
    //    NSString *cmsToken=[[NSString alloc] initWithFormat:@"%@%@%@",@"\"",report.document.session.cmsToken,@"\""];
    NSMutableURLRequest *request = [NSMutableURLRequest  requestWithURL:url];
    //    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    NSLog(@"Process with URL: %@",[request URL]);
    
    NSLog(@"Timeout Preference Value:%@",appDelegate.globalSettings.networkTimeout);
    [request setTimeoutInterval:[appDelegate.globalSettings.networkTimeout doubleValue ]];
    
    
    [request setHTTPMethod:@"GET"];
    //    if (self.exportFormat==FormatHTML)
    
    switch (self.exportFormat) {
        case FormatHTML:
            [request setValue:@"text/html" forHTTPHeaderField:@"Accept"];
            NSLog(@"HTML Header");
            break;
        case FormatPDF:
            [request setValue:@"application/pdf" forHTTPHeaderField:@"Accept"];
            NSLog(@"PDF Header");
            break;
        case FormatEXCEL:
            [request setValue:@"application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" forHTTPHeaderField:@"Accept"];
            NSLog(@"Excel Header");
            break;
            
        default:
            [request setValue:@"text/html" forHTTPHeaderField:@"Accept"];
            break;
    }
    
    NSString *cmsToken=[[NSString alloc] initWithFormat:@"%@%@%@",@"\"",self.currentToken,@"\""];
    NSLog(@"Token:%@",cmsToken);
    [request setValue:cmsToken forHTTPHeaderField:SAP_HTTP_TOKEN];
    (void)[[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}


# pragma mark Export Report

-(void) processHttpRequestForSession: (Report *) report{
    self.biSession=report.document.session;
    [self processHttpRequestForUrl:[self getExportReportURL:report]];
}



# pragma mark getExportDocument URL

-(NSURL *) getExportDocumentUrl: (Document *) document{
    NSLog (@"Export Document URL For Report id:%@",document.id);
    NSURL *getExportDocumentUrl;
    
    NSString *host=[NSString stringWithFormat: @"%@:%@",document.session.cmsName,document.session.port] ;
    if ([document.session.isHttps integerValue]==1){
        getExportDocumentUrl=[[NSURL alloc]initWithScheme:@"https" host:host path:[NSString stringWithFormat:@"%@%@%@%@%@",document.session.webiRestSDKBase,getDocumentsPathPoint,@"/",[document.id stringValue],@"/pages"]];
    }
    else{
        getExportDocumentUrl=[[NSURL alloc]initWithScheme:@"http" host:host path:[NSString stringWithFormat:@"%@%@%@%@%@",document.session.webiRestSDKBase,getDocumentsPathPoint,@"/",[document.id stringValue],@"/pages"]];
        
    }
    NSLog(@"URL:%@",getExportDocumentUrl);
    return  getExportDocumentUrl;
}



# pragma mark getExportReport URL

-(NSURL *) getExportReportURL: (Report *) report{
    NSLog (@"Export Report URL For Report id:%@",report.id);
    NSURL *getExportReportUrl;
    NSString *host=[NSString stringWithFormat: @"%@:%@",report.document.session.cmsName,report.document.session.port] ;
    if ([report.document.session.isHttps integerValue]==1){
        getExportReportUrl=[[NSURL alloc]initWithScheme:@"https" host:host path:[NSString stringWithFormat:@"%@%@%@%@%@%@%@",report.document.session.webiRestSDKBase,getDocumentsPathPoint,@"/",[report.document.id stringValue],@"/reports/",report.id,@"/pages"]];
    }
    else{
        getExportReportUrl=[[NSURL alloc]initWithScheme:@"http" host:host path:[NSString stringWithFormat:@"%@%@%@%@%@%@%@",report.document.session.webiRestSDKBase,getDocumentsPathPoint,@"/",[report.document.id stringValue],@"/reports/",report.id,@"/pages"]];
        
    }
    NSLog(@"URL:%@",getExportReportUrl);
    return  getExportReportUrl;
}


//- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
//    NSLog(@"didReceiveResponse");
//    responseData = [[NSMutableData alloc] init];
//}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"didReceiveResponse from URL %@",[response URL]);
    
    if ([response respondsToSelector:@selector(statusCode)])
    {
        int statusCode = [((NSHTTPURLResponse *)response) statusCode];
        NSLog(@"Status Code:%d",statusCode);
        //        if (statusCode  ==404)
        if (statusCode==401){
            NSLog(@"Token has expired: Create new one");
            connector=[[BIConnector alloc]init];
            connector.delegate=self;
            [connector getCmsTokenWithSession:self.biSession];
            
        }
        else if (statusCode  !=200)
        {
            [connection cancel];  // stop connecting; no more delegate messages
            NSLog(@"didReceiveResponse statusCode with %i", statusCode);
            
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:[NSString stringWithFormat:@"%@%d",@"Server Error: ",statusCode]  forKey:NSLocalizedDescriptionKey];
            
            connectorError =[NSError errorWithDomain:@"Failed" code:statusCode userInfo:details];
            [self.delegate biExportReport:self isSuccess:NO html:nil];        }
        else{
            responseData = [[NSMutableData alloc] init];
        }
        
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"didFailWithError");
    NSLog(@"Connection failed: %@", [error localizedDescription]);
    connectorError =[[NSError alloc] init];
    connectorError=error;
    [self.delegate biExportReport:self isSuccess:NO html:nil];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Export Report: connectionDidFinishLoading");
    NSLog(@"Export Report Succeeded! Received %d bytes of data",[responseData length]);
    NSString *filePath ;
    if (_exportFormat==FormatPDF || _exportFormat==FormatEXCEL){
        NSArray *paths =       NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0];
        NSError *error;
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        if (_exportFormat==FormatPDF){
            filePath = [documentsPath stringByAppendingPathComponent:@"ExportReport.pdf"];
        }
        else if (_exportFormat==FormatEXCEL){
            filePath = [documentsPath stringByAppendingPathComponent:@"ExportReport.xlsx"];
        }
        
        if (filePath!=nil){
            if([fileMgr fileExistsAtPath:filePath]) {
                NSLog(@"File Exist:%@",filePath);
                if ([fileMgr removeItemAtPath:filePath error:&error] != YES)
                    NSLog(@"Unable to delete file: %@%@", filePath,[error localizedDescription]);
                else{
                    NSLog(@"File %@ - deleted",filePath);
                    
                }
            }else{
                NSLog(@"File does not exist:%@",filePath);
            }
        }
        
        [responseData writeToFile:filePath atomically:YES];
        NSLog(@"File Created:%@",filePath);
    }
    
    NSString *receivedString = [[NSString alloc]  initWithData:responseData
                                                      encoding:NSUTF8StringEncoding];
    
#ifdef Trace
    int length=([receivedString length])<MAX_DISPLAY_HTTP_STRING?[receivedString length]:MAX_DISPLAY_HTTP_STRING;
    NSLog(@"Get Reports  Data:%@%@",[receivedString substringToIndex:length],@"..." );
#endif
    
    
    if ([self.boxiError isEqualToString:BOXI_TOKEN_ERROR]){
        NSLog(@"Token Expired - Create new One and try again");
        connector=[[BIConnector alloc]init];
        connector.delegate=self;
        [connector getCmsTokenWithSession:self.biSession];
    }else{
        switch (_exportFormat) {
            case FormatHTML:
                [self.delegate biExportReport:self isSuccess:YES html:receivedString];
                break;
            case FormatPDF:
            case FormatEXCEL:
                [self.delegate biExportReportExternalFormat:self isSuccess:YES filePath:filePath WithFormat:_exportFormat];
        }
    }
    
    [self logoOffIfNeeded];
}

-(void) logoOffIfNeeded{
    if ([appDelegate.globalSettings.autoLogoff integerValue]==1){
        if (self.biSession!=nil && biSession.cmsToken!=nil){
            [self logoffWithSession:self.biSession];
        }
    }
    
}
-(void) logoffWithSession:(Session *)session{
    if (session.cmsToken!=nil){
        BILogoff *biLogoff=[[BILogoff alloc] init];
        [biLogoff logoffSession:session withToken:self.currentToken];
        NSLog(@"Logoff Session:%@",session.name);
    }
    
    
}



@end
