//
//  BIGetScheduleDetail.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-03-04.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import "BIGetScheduleDetail.h"
#import "BI4RestConstants.h"
#import "ScheduleDetails.h"
#import "WebiAppDelegate.h"
#import "BILogoff.h"



@implementation BIGetScheduleDetail

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



#pragma mark GetScheduleDetails
-(void) geScheduleDetailForDocument: (Document *) document {
    
    NSLog (@"Get ScheduleDetails for Document id %@",document.id);
    
    appDelegate = (id)[[UIApplication sharedApplication] delegate];
    self.currentToken=document.session.cmsToken;
    
    if (document.session==nil) {
        NSLog(@"Restore Session");
        document.session=appDelegate.activeSession;
        document.session.cmsToken=nil;
    }
    self.biSession=document.session;
    self.document=document;
    
    
    // Get Token First
    if (self.biSession.cmsToken==nil){
        NSLog(@"CMS Token is NULL - create new one");
        connector=[[BIConnector alloc]init];
        connector.delegate=self;
        [connector getCmsTokenWithSession:self.biSession];
    }else{
        NSLog(@"CMS Token is NOT NULL - Process With Existing Token");
        [self processHttpRequestForSession:document];
        
    }
    
    
}

#pragma mark Updated Token (if neccessary)

-(void) biConnector:(BIConnector *)biConnector didCreateCmsToken:(NSString *)cmsToken forSession:(Session *)session{
    NSLog (@"Return From Get CMS Token");
    if(cmsToken!=nil){
        NSLog(@"Token Receieved:%@",cmsToken);
        self.currentToken=cmsToken;
        [self processHttpRequestForSession:self.document];
        
    }else if (biConnector.connectorError!=nil){
        self.connectorError=biConnector.connectorError ;
        [self.delegate biGetScheduleDetails:self isSuccess:NO scheduleDetails:nil];
        
    }else if (biConnector.boxiError!=nil){
        self.boxiError=biConnector.boxiError;
        [self.delegate biGetScheduleDetails:self isSuccess:NO scheduleDetails:nil];
        
    }else{
        [self.delegate biGetScheduleDetails:self isSuccess:NO scheduleDetails:nil];
    }
    
}


-(void) processHttpRequestForSession: (Document*) document{
    NSLog(@"GetDocument Details processHttpRequestForSession");
    self.biSession=document.session;
    //    NSString *cmsToken=[[NSString alloc] initWithFormat:@"%@%@%@",@"\"",document.session.cmsToken,@"\""];
    NSString *cmsToken=[[NSString alloc] initWithFormat:@"%@%@%@",@"\"",self.currentToken,@"\""];
    NSMutableURLRequest *request = [NSMutableURLRequest  requestWithURL:[self getScheduleDetailsURL:document]];
    NSLog(@"Process with URL: %@",[request URL]);
    NSLog(@"Token:%@",cmsToken);
    
    NSLog(@"Timeout Preference Value:%@",appDelegate.globalSettings.networkTimeout);
    [request setTimeoutInterval:[appDelegate.globalSettings.networkTimeout doubleValue ]];
    
    
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:cmsToken forHTTPHeaderField:SAP_HTTP_TOKEN];
    (void)[[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}

# pragma mark getDocuments URL

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
            [self.delegate biGetScheduleDetails:self isSuccess:NO scheduleDetails:nil];
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
    [self.delegate biGetScheduleDetails:self isSuccess:NO scheduleDetails:nil];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading");
    NSLog(@"Succeeded! Received %d bytes of data",[responseData length]);
#ifdef Trace
    NSString *receivedString = [[NSString alloc]  initWithData:responseData
                                                      encoding:NSUTF8StringEncoding];
    int length=([receivedString length])<MAX_DISPLAY_HTTP_STRING?[receivedString length]:MAX_DISPLAY_HTTP_STRING;
    NSLog(@"Get Schedule Details  Data:%@%@",[receivedString substringToIndex:length],@"..." );
#endif
    
    BOOL isSucess=YES;
    
    // convert to JSON
    NSError *myError = nil;
    NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&myError];
    NSMutableArray *scheduleDetailsArray=[[NSMutableArray alloc] init];
    
    
    NSLog(@"Result:%@",responseDic);
    NSLog(@"All keys:%@",[responseDic allKeys]);
    ScheduleDetails *scheduleDetails;
    
    if ([[responseDic allKeys] containsObject:JSON_RESP_ERROR_CODE]){
        self.boxiError=[responseDic objectForKey:JSON_RESP_ERROR_MESSAGE];
        isSucess=NO;
    }
    else{
        scheduleDetails=[[ScheduleDetails alloc] init];
        self.boxiError=nil;
        responseDic=[responseDic objectForKey:@"schedules"];
        
        if ([responseDic isKindOfClass:[NSDictionary class]]){
            NSLog(@"All keys:%@",[responseDic allKeys]);
            
            
            NSDictionary *schedule= [responseDic objectForKey:@"schedule"];
            
            NSLog(@"Kind of:%@",[responseDic class]);
            if ([schedule isKindOfClass:[NSArray class]]){
                NSLog(@"Array!");
                
                NSArray *schedules=[responseDic objectForKey:@"schedule"];
                for (NSDictionary *scheduleJson in schedules) {
                    NSLog(@"Id:%@",[scheduleJson objectForKey:@"id"]);
                    [scheduleDetailsArray addObject:[self getScheduleDetailsFromJson:scheduleJson forDocument:self.document]];
                }
                
            }else{
                NSLog(@"Not Array!");
                NSLog(@"Id:%@",[schedule  objectForKey:@"id"]);
                NSDictionary *scheduleJson =[responseDic objectForKey:@"schedule"];
                [scheduleDetailsArray addObject:[self getScheduleDetailsFromJson:scheduleJson forDocument:self.document]];
                
            }
            
            
        }
        
        
    }
    
    if ([self.boxiError isEqualToString:BOXI_TOKEN_ERROR]){
        NSLog(@"Token Expired - Create new One and try again");
        connector=[[BIConnector alloc]init];
        connector.delegate=self;
        [connector getCmsTokenWithSession:self.biSession];
    }else{
        [self.delegate biGetScheduleDetails:self isSuccess:YES scheduleDetails:scheduleDetailsArray];
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

#pragma mark getSchedule Details

-(ScheduleDetails *) getScheduleDetailsFromJson:(NSDictionary*) jsonString forDocument:(Document *) document{
    ScheduleDetails *scheduleDetails=[[ScheduleDetails alloc]init];
    scheduleDetails.scheduleId =[[jsonString objectForKey:@"id"] integerValue];
    scheduleDetails.scheduleName =[jsonString objectForKey:@"name"];
    if ([[jsonString objectForKey:@"status"] isKindOfClass:[NSDictionary class]]){
//        NSLog(@"4.1 SP1 Response");
        NSDictionary *statusDic=[jsonString objectForKey:@"status"];
        scheduleDetails.scheduleStatus =[statusDic objectForKey:@"$"];
        
    }else{
//        NSLog(@"4.0 Response");
        scheduleDetails.scheduleStatus =[jsonString objectForKey:@"status"];
    }
    scheduleDetails.scheduleFormat =[jsonString objectForKey:@"format"];
    NSDictionary *formatDic=[jsonString objectForKey:@"format"];
    scheduleDetails.scheduleFormat=[formatDic objectForKey:@"@type"];
    scheduleDetails.document=document;
    NSLog(@"Format Parsed:%@",scheduleDetails.scheduleFormat);
    
    return scheduleDetails;
}


@end
