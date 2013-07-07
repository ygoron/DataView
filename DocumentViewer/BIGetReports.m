//
//  BIGetReports.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-02-28.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import "BIGetReports.h"
#import "Document.h"
#import "Report.h"
#import "BI4RestConstants.h"
#import "WebiAppDelegate.h"
#import "BILogoff.h"



@implementation BIGetReports
{
    BIConnector *connector;
    WebiAppDelegate *appDelegate;
}

@synthesize connectorError;
@synthesize boxiError;
@synthesize delegate;
@synthesize biSession;
@synthesize context;
@synthesize currentToken;


#pragma mark getReportsForDocument

-(void) getReportsForDocument:(Document *)document{
    
    NSLog (@"Get Reports for Document:%@",document.name);
    
    appDelegate = (id)[[UIApplication sharedApplication] delegate];
    self.currentToken=document.session.cmsToken;
    
    self.biSession=document.session;
    self.document=document;
    // Get Token First
    if (document.session.cmsToken==nil || [appDelegate.globalSettings.autoLogoff boolValue]==YES){
        NSLog(@"CMS Token is NULL - create new one");
        connector=[[BIConnector alloc]init];
        connector.delegate=self;
        [connector getCmsTokenWithSession:document.session];
    }else{
        NSLog(@"CMS Token is NOT NULL - Process With Existing Token");
        [self processHttpRequestForSession:document];
        
    }
    
}

#pragma mark getToken Completed

-(void) biConnector:(BIConnector *)biConnector didCreateCmsToken:(NSString *)cmsToken forSession:(Session *)session{
    NSLog (@"Return From Get CMS Token");
    if(cmsToken!=nil){
        NSLog(@"Token Receieved:%@",cmsToken);
        self.currentToken=cmsToken;
        [self processHttpRequestForSession:self.document];
        
    }else if (biConnector.connectorError!=nil){
        self.connectorError=biConnector.connectorError ;
        [self.delegate biGetReports:self isSuccess:NO reports:nil];
        
    }else if (biConnector.boxiError!=nil){
        self.boxiError=biConnector.boxiError;
        [self.delegate biGetReports:self isSuccess:NO reports:nil];
        
    }else{
        [self.delegate biGetReports:self isSuccess:NO reports:nil];
    }
    
}

# pragma mark Get Reports

-(void) processHttpRequestForSession: (Document*) document{
    self.biSession=document.session;
//    NSString *cmsToken=[[NSString alloc] initWithFormat:@"%@%@%@",@"\"",document.session.cmsToken,@"\""];
    NSString *cmsToken=[[NSString alloc] initWithFormat:@"%@%@%@",@"\"",self.currentToken,@"\""];
    NSMutableURLRequest *request = [NSMutableURLRequest  requestWithURL:[self getReportsURL:document]];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    NSLog(@"Process with URL: %@",[request URL]);
    NSLog(@"Token:%@",cmsToken);
    
//    WebiAppDelegate *appDelegate= (id)[[UIApplication sharedApplication] delegate];
    NSLog(@"Timeout Preference Value:%@",appDelegate.globalSettings.networkTimeout);
    [request setTimeoutInterval:[appDelegate.globalSettings.networkTimeout doubleValue ]];
    
    
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:cmsToken forHTTPHeaderField:SAP_HTTP_TOKEN];
    (void)[[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}

# pragma mark getReports URL

-(NSURL *) getReportsURL: (Document *) document{
    NSLog (@"GetReports URL For Document id:%@",document.id);
    NSURL *getDocumentsURL;
    NSString *host=[NSString stringWithFormat: @"%@:%@",document.session.cmsName,document.session.port] ;
    if ([document.session.isHttps integerValue]==1){
        getDocumentsURL=[[NSURL alloc]initWithScheme:@"https" host:host path:[NSString stringWithFormat:@"%@%@%@%@%@",document.session.webiRestSDKBase,getDocumentsPathPoint,@"/",document.id,@"/reports"]];
    }
    else{
        getDocumentsURL=[[NSURL alloc]initWithScheme:@"http" host:host path:[NSString stringWithFormat:@"%@%@%@%@%@",document.session.webiRestSDKBase,getDocumentsPathPoint,@"/",document.id,@"/reports"]];
    }
    NSLog(@"URL:%@",getDocumentsURL);
    return  getDocumentsURL;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"didReceiveResponse from URL %@",[response URL]);
    
    if ([response respondsToSelector:@selector(statusCode)])
    {
        int statusCode = [((NSHTTPURLResponse *)response) statusCode];
        if (statusCode  ==404)
        {
            [connection cancel];  // stop connecting; no more delegate messages
            NSLog(@"didReceiveResponse statusCode with %i", statusCode);
            
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:[NSString stringWithFormat:@"%@%d",NSLocalizedString(@"Server Error: ",nil),statusCode]  forKey:NSLocalizedDescriptionKey];
            
            connectorError =[NSError errorWithDomain:NSLocalizedString(@"Failed",nil) code:statusCode userInfo:details];
            [self.delegate biGetReports:self isSuccess:NO reports:nil];
        }
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
    [self.delegate biGetReports:self isSuccess:NO reports:nil];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading");
    NSLog(@"Succeeded! Received %d bytes of data",[responseData length]);
#ifdef Trace
    NSString *receivedString = [[NSString alloc]  initWithData:responseData
                                                      encoding:NSUTF8StringEncoding];
    NSLog(@"Get Reports  Data:%@",receivedString );
#endif
    
    BOOL isSucess=YES;
    
    NSMutableArray *reports=[[NSMutableArray alloc] init];
    
    // convert to JSON
    NSError *myError = nil;
    NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&myError];
    
    NSLog(@"Result:%@",responseDic);
    NSLog(@"All keys:%@",[responseDic allKeys]);
    
    
    if ([[responseDic allKeys] containsObject:JSON_RESP_ERROR_CODE]){
        self.boxiError=[responseDic objectForKey:JSON_RESP_ERROR_MESSAGE];
        isSucess=NO;
    }
    else{
        self.boxiError=nil;
        responseDic=[responseDic objectForKey:@"reports"];
        
        if ([responseDic isKindOfClass:[NSDictionary class]]){
            NSLog(@"All keys:%@",[responseDic allKeys]);
            
            if ([[responseDic objectForKey:@"report"] isKindOfClass:[NSArray class]]){
                NSLog(@"Array!");
                NSArray *reps=[responseDic objectForKey:@"report"];
                for (NSDictionary *reportJson in reps) {
                    NSLog(@"Id:%@",[reportJson objectForKey:@"id"]);
                    
                    [reports addObject: [self getReportFromJson:reportJson]];
                    self.document.reports=[NSSet setWithArray:reports];
                    
                }
                
            }
            else{
                NSLog(@"Not Array");
                NSDictionary *reportJson=[responseDic objectForKey:@"report"];
                NSLog(@"Id:%@",[reportJson objectForKey:@"id"]);
                [reports addObject: [self getReportFromJson:reportJson]];
                self.document.reports=[NSSet setWithArray:reports];
            }
            
        }
        
    }
    
    if ([self.boxiError isEqualToString:BOXI_TOKEN_ERROR]){
        NSLog(@"Token Expired - Create new One and try again");
        connector=[[BIConnector alloc]init];
        connector.delegate=self;
        [connector getCmsTokenWithSession:self.biSession];
    }else{
        [self.delegate biGetReports:self isSuccess:YES reports:reports];
    }

    [self logoOffIfNeeded];
}

-(void) logoOffIfNeeded{
    if ([appDelegate.globalSettings.autoLogoff integerValue]==1){
        if (self.document.session!=nil && self.document.session.cmsToken!=nil){
            [self logoffWithSession:self.document.session];
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


#pragma mark Create Report Object From Json

-(Report*) getReportFromJson: (NSDictionary*) reportJson{
    
    Report *report = [NSEntityDescription
                      insertNewObjectForEntityForName:@"Report"
                      inManagedObjectContext:context];
    
    report.document=self.document;
    report.id=[reportJson objectForKey:@"id"];
    NSLog(@"Object Id is Set to: %@",[report.id stringValue]);
    report.name=[reportJson objectForKey:@"name"];
    report.reference=[reportJson objectForKey:@"reference"];
    return  report;
    
}

@end
