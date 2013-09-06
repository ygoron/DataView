//
//  BIScheduleDocument.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-03-18.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import "BIScheduleDocument.h"
#import "Document.h"
#import "ScheduleStatus.h"
#import "BI4RestConstants.h"
#import "Format.h"
#import "FormatExcel.h"
#import "FormatPDF.h"
#import "FormatWebi.h"
#import "WebiAppDelegate.h"
#import "BILogoff.h"



@implementation BIScheduleDocument

{
    NSData *jsonData;
    NSString *jsonString;
    BIConnector *connector;
    WebiAppDelegate *appDelegate;

}

@synthesize connectorError;
@synthesize boxiError;
@synthesize delegate;
@synthesize biSession;
@synthesize destination;
@synthesize format;
@synthesize currentToken;

#pragma mark schedule document

-(void) scheduleDocument:(Document *)document withDestination:(Destination *)scheduleDestination withFormat:(Format *)scheduleFormat{
    
    NSLog (@"Schedule Document id %@",document.id);
    appDelegate = (id)[[UIApplication sharedApplication] delegate];
    self.currentToken=document.session.cmsToken;
    self.biSession=document.session;
    if (document.session==nil){
        NSLog(@"Restore Session");
        self.biSession=appDelegate.activeSession;
        document.session=appDelegate.activeSession;
        self.biSession.cmsToken=nil;
    }

    
    self.document=document;
    self.destination=scheduleDestination;
    self.format=scheduleFormat;
    // Get Token First
    if (self.biSession.cmsToken==nil){
        NSLog(@"CMS Token is NULL - create new one");
        connector=[[BIConnector alloc]init];
        connector.delegate=self;
        [connector getCmsTokenWithSession:self.biSession];
    }else{
        NSLog(@"CMS Token is NOT NULL - Process With Existing Token");
        [self processHttpRequestForSession:document withDestination:destination];
        
    }
    
}

#pragma mark Updated Token (if neccessary)

-(void) biConnector:(BIConnector *)biConnector didCreateCmsToken:(NSString *)cmsToken forSession:(Session *)session{
    NSLog (@"Return From Get CMS Token");
    if(cmsToken!=nil){
        NSLog(@"Token Receieved:%@",cmsToken);
        self.currentToken=cmsToken;
        [self processHttpRequestForSession:self.document withDestination:self.destination];
        
    }else if (biConnector.connectorError!=nil){
        self.connectorError=biConnector.connectorError ;
        ScheduleStatus *scheduleStatus=[[ScheduleStatus alloc] init];
        scheduleStatus.code=biConnector.connectorError.code;
        scheduleStatus.message=[biConnector.connectorError localizedDescription];
        [self.delegate biScheduleDocument:self isSuccess:NO withScheduleStatus:scheduleStatus];
        
    }else if (biConnector.boxiError!=nil){
        self.connectorError=biConnector.connectorError ;
        ScheduleStatus *scheduleStatus=[[ScheduleStatus alloc] init];
        scheduleStatus.code=biConnector.connectorError.code;
        scheduleStatus.message=[biConnector.connectorError localizedDescription];
        [self.delegate biScheduleDocument:self isSuccess:NO withScheduleStatus:scheduleStatus];
        
    }else{
        self.connectorError=biConnector.connectorError ;
        ScheduleStatus *scheduleStatus=[[ScheduleStatus alloc] init];
        scheduleStatus.code=biConnector.connectorError.code;
        scheduleStatus.message=[biConnector.connectorError localizedDescription];
        [self.delegate biScheduleDocument:self isSuccess:NO withScheduleStatus:scheduleStatus];
    }
    
}


#pragma mark call SAP REST

-(void) processHttpRequestForSession: (Document*) document withDestination:(Destination *)destination {
    NSLog(@"Schedule Document processHttpRequestForSession");
    self.biSession=document.session;
//    NSString *cmsToken=[[NSString alloc] initWithFormat:@"%@%@%@",@"\"",document.session.cmsToken,@"\""];
    NSString *cmsToken=[[NSString alloc] initWithFormat:@"%@%@%@",@"\"",self.currentToken,@"\""];
    NSMutableURLRequest *request = [NSMutableURLRequest  requestWithURL:[self getScheduleDetailsURL:document]];
    NSLog(@"Process with URL: %@",[request URL]);
    NSLog(@"Token:%@",cmsToken);
    
//    NSArray *keys = [NSArray arrayWithObjects:@"name", @"format",@"destination", nil];
//    NSArray *objects = [NSArray arrayWithObjects:document.name, @"PDF",@"inbox", nil];
//    
//    NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
//    
//    if([NSJSONSerialization isValidJSONObject:jsonDictionary])
//    {
//        jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:nil];
//        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
//        NSLog(@"JSON String %@",jsonString);
//    }
    

    NSString *destinationString=@"webi";
    
    if (format.formatExcel!=nil) destinationString=@"xls";
        else     if (format.formatPdf!=nil) destinationString=@"pdf";
    
    NSDictionary *jsonScheduleDetails=[NSDictionary dictionaryWithObjectsAndKeys:document.name,@"name",[NSDictionary dictionaryWithObjectsAndKeys:destinationString,@"@type", nil],@"format",nil];
    NSDictionary *jsonSchedule= [NSDictionary dictionaryWithObjectsAndKeys:jsonScheduleDetails,@"schedule",nil ];
    jsonData=[NSJSONSerialization dataWithJSONObject:jsonSchedule options:0 error:nil];
    jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"JSON String %@",jsonString);
    
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: jsonData];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:[NSString stringWithFormat:@"%d", [jsonString length]] forHTTPHeaderField:@"Content-Length"];
    [request setValue:cmsToken forHTTPHeaderField:SAP_HTTP_TOKEN];
    
    (void)[[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}

# pragma mark Schedule Document URL

-(NSURL *) getScheduleDetailsURL: (Document *) document{
    NSLog (@"getScheduleDetailsURL URL For Document id:%@",document.id);
    NSURL *scheduleDetailsUrl;
    NSString *host=[NSString stringWithFormat: @"%@:%@",document.session.cmsName,document.session.port] ;
    if ([document.session.isHttps integerValue]==1){
        scheduleDetailsUrl=[[NSURL alloc]initWithScheme:@"https" host:host path:[NSString stringWithFormat:@"%@%@%@%@%@",document.session.webiRestSDKBase,getDocumentsPathPoint,@"/",document.id,@"/schedules"]];
    }
    else{
        scheduleDetailsUrl=[[NSURL alloc]initWithScheme:@"http" host:host path:[NSString stringWithFormat:@"%@%@%@%@%@",document.session.webiRestSDKBase,getDocumentsPathPoint,@"/",document.id,@"/schedules"]];
    }
    NSLog(@"URL:%@",scheduleDetailsUrl);
    return  scheduleDetailsUrl;
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
            [details setValue:[NSString stringWithFormat:@"%@%d",@"Server Error: ",statusCode]  forKey:NSLocalizedDescriptionKey];
            
            connectorError =[NSError errorWithDomain:@"Failed" code:statusCode userInfo:details];
            
            ScheduleStatus *scheduleStatus=[[ScheduleStatus alloc] init];
            scheduleStatus.code=statusCode;
            scheduleStatus.message=[connectorError localizedDescription];
            [self logoOffIfNeeded];
            [self.delegate biScheduleDocument:self isSuccess:NO withScheduleStatus:scheduleStatus];
            
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
    ScheduleStatus *scheduleStatus=[[ScheduleStatus alloc] init];
    scheduleStatus.code=[error code];
    scheduleStatus.message=[connectorError localizedDescription];
    [self.delegate biScheduleDocument:self isSuccess:NO withScheduleStatus:scheduleStatus];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading");
    NSLog(@"Succeeded! Received %d bytes of data",[responseData length]);

#ifdef Trace
    NSString *receivedString = [[NSString alloc]  initWithData:responseData
                                                      encoding:NSUTF8StringEncoding];
    int length=([receivedString length])<MAX_DISPLAY_HTTP_STRING?[receivedString length]:MAX_DISPLAY_HTTP_STRING;
    NSLog(@"Schedule Document  Data:%@%@",[receivedString substringToIndex:length],@"..." );
#endif
    
    BOOL isSucess=YES;
    
    // convert to JSON
    NSError *myError = nil;
    NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&myError];
    
    
    NSLog(@"Result:%@",responseDic);
    NSLog(@"All keys:%@",[responseDic allKeys]);
    ScheduleStatus *scheduleStatus;
    scheduleStatus=[[ScheduleStatus alloc] init];

    
    if ([[responseDic allKeys] containsObject:JSON_RESP_ERROR_CODE]){
        self.boxiError=[responseDic objectForKey:JSON_RESP_ERROR_MESSAGE];
        scheduleStatus.message=self.boxiError;
        scheduleStatus.code=-1;
        isSucess=NO;
    }
    else{
        self.boxiError=nil;
        
        responseDic=[responseDic objectForKey:@"success"];
        if (responseDic!=nil){
            if ([responseDic isKindOfClass:[NSDictionary class]]){
                            NSLog(@"All keys:%@",[responseDic allKeys]);
                scheduleStatus.message=[responseDic objectForKey:@"message"];
                scheduleStatus.newInstanceId=[[responseDic objectForKey:@"id"] integerValue] ;
                scheduleStatus.code=0;
            }
            
        }else{
            scheduleStatus.code=-1;
            scheduleStatus.message=@"Failed to create Instance";
        }
        
        
    }
    
    if ([self.boxiError isEqualToString:BOXI_TOKEN_ERROR]){
        NSLog(@"Token Expired - Create new One and try again");
        connector=[[BIConnector alloc]init];
        connector.delegate=self;
        [connector getCmsTokenWithSession:self.biSession];
    }else{
//        [self.delegate biScheduleDocument:self isSuccess:YES withScheduleStatus:scheduleStatus];
        [self.delegate biScheduleDocument:self isSuccess:isSucess withScheduleStatus:scheduleStatus];
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




@end
