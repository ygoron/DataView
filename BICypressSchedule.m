//
//  BICypressSchedule.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-05-20.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import "BICypressSchedule.h"
#import "BIConnector.h"
#import "WebiAppDelegate.h"
#import "BI4RestConstants.h"
#import "ScheduleUrl.h"
#import "BILogoff.h"

@implementation BICypressSchedule


{
    BIConnector *_connector;
    NSURL *url;
    BOOL isScheduleRequest;
}

-(void) getScheduleFormsWithUrl: (NSURL *) scheduleFormUrl forSession: (Session *) session
{
    url=scheduleFormUrl;
    
    _currentToken=session.cmsToken;
    _biSession=session;
    isScheduleRequest=NO;
    // Get Token First
    if (session.cmsToken==nil || session.password==nil){
        NSLog(@"CMS Token is NULL - create new one");
        _connector=[[BIConnector alloc]init];
        _connector.delegate=self;
        [_connector getCmsTokenWithSession:session];
    }else{
        NSLog(@"CMS Token is NOT NULL - Process With Existing Token");
        [self processHttpRequestForScheduleForms];
    }
}

-(void) scheduleWithUrl: (NSURL *) scheduleUrl withData:(NSDictionary *) scheduleDataForm forSession:(Session *) session
{
    
    url=scheduleUrl;
    
    _currentToken=session.cmsToken;
    _biSession=session;
    isScheduleRequest=YES;
    // Get Token First
    if (session.cmsToken==nil || session.password==nil){
        NSLog(@"CMS Token is NULL - create new one");
        _connector=[[BIConnector alloc]init];
        _connector.delegate=self;
        [_connector getCmsTokenWithSession:session];
    }else{
        NSLog(@"CMS Token is NOT NULL - Process With Existing Token");
        [self processHttpRequestForScheduleObjectWithData:scheduleDataForm];
    }
    
}

#pragma mark getCmsToken
-(void) biConnector:(BIConnector *)biConnector didCreateCmsToken:(NSString *)cmsToken forSession:(Session *)session{
    NSLog (@"Return From Get CMS Token");
    if(cmsToken!=nil){
        NSLog(@"Token Receieved:%@",cmsToken);
        _currentToken=cmsToken;
        [self processHttpRequestForScheduleForms];
        
    }else if (biConnector.connectorError!=nil){
        _connectorError=biConnector.connectorError ;
        [self.delegate availableSchedules:self withUrls:nil isSuccess:NO];
        
    }else if (biConnector.boxiError!=nil){
        self.boxiError=biConnector.boxiError;
        [self.delegate availableSchedules:self withUrls:nil isSuccess:NO];
        
    }else
        [self.delegate availableSchedules:self withUrls:nil isSuccess:NO];
}

-(void) processHttpRequestForScheduleObjectWithData: (NSDictionary *) dataDic
{
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest  requestWithURL:url];
    
    NSString *cmsToken=[[NSString alloc] initWithFormat:@"%@%@%@",@"\"",_currentToken,@"\""];
    
    NSLog(@"Process with URL: %@",[request URL]);
    NSLog(@"Token:%@",cmsToken);
    
    if([NSJSONSerialization isValidJSONObject:dataDic])
    {
        jsonData = [NSJSONSerialization dataWithJSONObject: dataDic options:0 error:nil];
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"JSON String %@",jsonString);
    }
    
    NSLog(@"Request Timeout is Set to %f",request.timeoutInterval);
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody: jsonData];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:cmsToken forHTTPHeaderField:SAP_HTTP_TOKEN];
    [request setValue:[NSString stringWithFormat:@"%d", [jsonData length]] forHTTPHeaderField:@"Content-Length"];
    (void)[[NSURLConnection alloc] initWithRequest:request delegate:self ];
    
}
-(void) processHttpRequestForScheduleForms
{
    
    NSMutableURLRequest *request;
    request = [NSMutableURLRequest  requestWithURL:url];
    
    NSString *cmsToken=[[NSString alloc] initWithFormat:@"%@%@%@",@"\"",_currentToken,@"\""];
    
    NSLog(@"Process with URL: %@",[request URL]);
    NSLog(@"Token:%@",cmsToken);
    
    WebiAppDelegate *appDelegate = (id)[[UIApplication sharedApplication] delegate];
    NSLog(@"Timeout Preference Value:%@",appDelegate.globalSettings.networkTimeout);
    [request setTimeoutInterval:[appDelegate.globalSettings.networkTimeout doubleValue ]];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:cmsToken forHTTPHeaderField:SAP_HTTP_TOKEN];
    (void)[[NSURLConnection alloc] initWithRequest:request delegate:self];
    
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
            
            _connectorError =[NSError errorWithDomain:@"Failed" code:statusCode userInfo:details];
            if (isScheduleRequest==NO)
                [self.delegate availableSchedules:self withUrls:nil isSuccess:NO];
            else
                [self.delegate scheduleResult:self withData:nil withUrl:url isSuccess:NO];
            
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
    NSLog(@"BI Cypress Call didFailWithError %@",[error localizedDescription]);
    _connectorError =[[NSError alloc] init];
    _connectorError=error;
    if (isScheduleRequest==NO)
        [self.delegate availableSchedules:self withUrls:nil isSuccess:NO];
    else
        [self.delegate scheduleResult:self withData:nil withUrl:url isSuccess:NO];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading");
    NSLog(@"Succeeded! Received %d bytes of data",[responseData length]);
    NSString *receivedString = [[NSString alloc]  initWithData:responseData
                                                      encoding:NSUTF8StringEncoding];
#ifdef Trace
    int length=([receivedString length])<MAX_DISPLAY_HTTP_STRING?[receivedString length]:MAX_DISPLAY_HTTP_STRING;
    NSLog(@"Get Data:%@%@",[receivedString substringToIndex:length],@"..." );
#endif
    
    // convert to JSON
    NSError *myError = nil;
    NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&myError];
    NSMutableArray *scheduleUrls=[[NSMutableArray alloc] init];
    
    BOOL isSucess=YES;
    
    if (isScheduleRequest==NO){
        
        
        
        
        NSLog(@"Result:%@",responseDic);
        NSLog(@"All keys:%@",[responseDic allKeys]);
        
        if ([[responseDic allKeys] containsObject:JSON_RESP_ERROR_CODE]){
            self.boxiError=[responseDic objectForKey:JSON_RESP_ERROR_MESSAGE];
            isSucess=NO;
        }
        else{
            if ([responseDic objectForKey:@"entries"]){
                if ([[responseDic objectForKey:@"entries"] isKindOfClass:[NSArray class]]){
                    NSArray *entries=[responseDic objectForKey:@"entries"];
                    for (NSDictionary *entry in entries) {
                        NSLog(@"Entry: %@",entry);
                        if ([entry objectForKey:@"__metadata"]){
                            NSDictionary *metadata=[entry objectForKey:@"__metadata"];
                            NSLog(@"Metadata %@",metadata);
                            if ([metadata objectForKey:@"uri"]){
                                NSString *stringUrl=[metadata objectForKey:@"uri"];
                                NSLog(@"Url String:%@",stringUrl);
                                ScheduleUrl *scheduleUrl=[[ScheduleUrl alloc]init];
                                if ([stringUrl hasSuffix:@"now"]){
                                    scheduleUrl.name=@"Now";
                                    scheduleUrl.description=@"Run Report Now";
                                }
                                scheduleUrl.url=[NSURL URLWithString:stringUrl];
                                [scheduleUrls addObject:scheduleUrl];
                            }
                        }
                        
                    }
                    
                }
                
                
            }
            self.boxiError=nil;
            
        }
    }else{
        if (receivedString.length==0) isSucess=YES;
        else isSucess=NO;
    }
    
    
    if ([self.boxiError isEqualToString:BOXI_TOKEN_ERROR]){
        NSLog(@"Token Expired - Create new One and try again");
        BIConnector *connector=[[BIConnector alloc]init];
        connector.delegate=self;
        [connector getCmsTokenWithSession:self.biSession];
    }else{
        if (isScheduleRequest==NO)
            [self.delegate availableSchedules:self withUrls:scheduleUrls isSuccess:isSucess];
        else{
            [self.delegate scheduleResult:self withData:responseDic withUrl:url isSuccess:isSucess];
        }
    }
    
    
    
    
    [self logoOffIfNeeded];
    
    
}

#pragma mark parses level->sublevel dictionary
-(NSString *)parseLevelName:(NSString *)name subLevel:(NSString *)subLevel withDictionary:(NSDictionary *)dictionary
{
    
    if ([dictionary objectForKey:name]){
        if ([[dictionary objectForKey:name] isKindOfClass:[NSDictionary class]]){
            NSDictionary *data=[dictionary objectForKey:name];
            if ([data objectForKey:subLevel]){
                return [data objectForKey:subLevel];
            }
        }
    }
    
    return nil;
}

-(void) logoOffIfNeeded{
    WebiAppDelegate *appDelegate = (id)[[UIApplication sharedApplication] delegate];
    if ([appDelegate.globalSettings.autoLogoff integerValue]==1){
        if (_biSession!=nil && _biSession.cmsToken!=nil){
            [self logoffWithSession:_biSession];
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
