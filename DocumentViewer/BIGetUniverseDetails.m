//
//  BIGetUniverseDetails.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-03-30.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import "BIGetUniverseDetails.h"
#import "WebiAppDelegate.h"
#import "BILogoff.h"

@implementation BIGetUniverseDetails
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

-(void) getUniverseDetails:(Universe *)universe
{
    
    NSLog (@"Get Universe Details for Session Started. Universe id %d,name%@ session:%@",universe.universeId,universe.name,universe.session.name);
    appDelegate = (id)[[UIApplication sharedApplication] delegate];
    self.currentToken=universe.session.cmsToken;
    
    self.biSession=universe.session;
    
    _universe=universe;
    // Get Token First
    if (self.biSession.cmsToken==nil){
        NSLog(@"CMS Token is NULL - create new one");
        connector=[[BIConnector alloc]init];
        connector.delegate=self;
        [connector getCmsTokenWithSession:self.biSession];
    }else{
        NSLog(@"CMS Token is NOT NULL - Process With Existing Token");
        [self processHttpRequestForSession:universe];
        
    }
    
}

#pragma mark Updated Token (if neccessary)

-(void) biConnector:(BIConnector *)biConnector didCreateCmsToken:(NSString *)cmsToken forSession:(Session *)session{
    NSLog (@"Return From Get CMS Token");
    if(cmsToken!=nil){
        NSLog(@"Token Receieved:%@",cmsToken);
        self.currentToken=cmsToken;
        [self processHttpRequestForSession:_universe];
        
    }else if (biConnector.connectorError!=nil){
        self.connectorError=biConnector.connectorError ;
        [self.delegate getUniverseDetails:self isSuccess:NO WithUniverseDetails:nil];
        
    }else if (biConnector.boxiError!=nil){
        self.boxiError=biConnector.boxiError;
        [self.delegate getUniverseDetails:self isSuccess:NO WithUniverseDetails:nil];
    }else{
        [self.delegate getUniverseDetails:self isSuccess:NO WithUniverseDetails:nil];
    }
    
}

-(void) processHttpRequestForSession: (Universe*) universe{
    NSLog(@"Get Universe Details processHttpRequestForSession");
    self.biSession=universe.session;
//    NSString *cmsToken=[[NSString alloc] initWithFormat:@"%@%@%@",@"\"",universe.session.cmsToken,@"\""];
    NSString *cmsToken=[[NSString alloc] initWithFormat:@"%@%@%@",@"\"",self.currentToken,@"\""];
    NSMutableURLRequest *request = [NSMutableURLRequest  requestWithURL:[self getUniverseDetailsURL:universe]];
    NSLog(@"Process with URL: %@",[request URL]);
    NSLog(@"Token:%@",cmsToken);
    
    NSLog(@"Timeout Preference Value:%@",appDelegate.globalSettings.networkTimeout);
    [request setTimeoutInterval:[appDelegate.globalSettings.networkTimeout doubleValue ]];

    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:cmsToken forHTTPHeaderField:SAP_HTTP_TOKEN];
    (void)[[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}

# pragma mark getUniverseDetails URL

-(NSURL *) getUniverseDetailsURL: (Universe *) universe{
    NSLog (@"Get Universe Details URL For Universe id:%d",universe.universeId);
    NSURL *getUniverseDetailsURL;
    NSString *host=[NSString stringWithFormat: @"%@:%@",universe.session.cmsName,universe.session.port] ;
    if ([universe.session.isHttps integerValue]==1){
        getUniverseDetailsURL=[[NSURL alloc]initWithScheme:@"https" host:host path:[NSString stringWithFormat:@"%@%@%@%d",universe.session.webiRestSDKBase,getUniversesPathPoint,@"/",universe.universeId]];
    }
    else{
        getUniverseDetailsURL=[[NSURL alloc]initWithScheme:@"http" host:host path:[NSString stringWithFormat:@"%@%@%@%d",universe.session.webiRestSDKBase,getUniversesPathPoint,@"/",universe.universeId]];
    }
    NSLog(@"URL:%@",getUniverseDetailsURL);
    return  getUniverseDetailsURL;
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
            NSLog(@"Description:%@",[details description]);
            connectorError =[NSError errorWithDomain:@"Failed" code:statusCode userInfo:details];
            [self.delegate getUniverseDetails:self isSuccess:NO WithUniverseDetails:nil];
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
    [self.delegate getUniverseDetails:self isSuccess:NO WithUniverseDetails:nil];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading");
    NSLog(@"Succeeded! Received %d bytes of data",[responseData length]);
#ifdef Trace
    NSString *receivedString = [[NSString alloc]  initWithData:responseData
                                                      encoding:NSUTF8StringEncoding];
    int length=([receivedString length])<MAX_DISPLAY_HTTP_STRING?[receivedString length]:MAX_DISPLAY_HTTP_STRING;
    NSLog(@"Get Documents Detail  Data:%@%@",[receivedString substringToIndex:length],@"..." );
#endif
    
    BOOL isSucess=YES;
    
    // convert to JSON
    NSError *myError = nil;
    NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&myError];
    
    NSLog(@"Result:%@",responseDic);
    NSLog(@"All keys:%@",[responseDic allKeys]);
    
    NSMutableArray *returnObjects=[[NSMutableArray alloc] init];
    
    
    if ([[responseDic allKeys] containsObject:JSON_RESP_ERROR_CODE]){
        self.boxiError=[responseDic objectForKey:JSON_RESP_ERROR_MESSAGE];
        isSucess=NO;
    }
    else{
        self.boxiError=nil;
        
        if ([responseDic isKindOfClass:[NSDictionary class]]){
            
            responseDic=[responseDic objectForKey:@"universe"];
            
            if ([responseDic isKindOfClass:[NSDictionary class]]){
                NSLog(@"All keys:%@",[responseDic allKeys]);
                
                
                NSDictionary *outline=[responseDic objectForKey:@"outline"];
                
                if ([outline objectForKey:@"folder"]!=nil){
                    if ([[outline objectForKey:@"folder"] isKindOfClass:[NSArray class]]){
                        NSLog(@"Processing folder arrays");
                        
                        NSArray *folders=[outline objectForKey:@"folder"];
                        [returnObjects addObjectsFromArray:folders];
                        NSLog(@"Folder Count:%d",returnObjects.count);
                    }else{
                        NSDictionary *folder=[outline objectForKey:@"folder"];
                        NSLog(@"Processing Single Folder");
                        [returnObjects addObject:folder];
                        
                    }
                } if ([outline objectForKey:@"item"]!=nil){
                    NSLog(@"Processing top level items");
                    
                    if ([[outline objectForKey:@"item"] isKindOfClass:[NSArray class]]){
                        NSLog(@"Processing items arrays");
                        
                        NSArray *items=[outline objectForKey:@"item"];
                        [returnObjects addObjectsFromArray:items];
                        NSLog(@"Items Count:%d",returnObjects.count);
                    }else{
                        NSDictionary *item =[outline objectForKey:@"item"];
                        NSLog(@"Processing Single Item");
                        [returnObjects addObject:item];
                        
                    }
                    
                    
                }
                
            }
        }
        
    }
    
    if ([self.boxiError isEqualToString:BOXI_TOKEN_ERROR]){
        NSLog(@"Token Expired - Create new One and try again");
        connector=[[BIConnector alloc]init];
        connector.delegate=self;
        [connector getCmsTokenWithSession:self.biSession];
    }else{
        [self.delegate getUniverseDetails:self isSuccess:isSucess WithUniverseDetails:returnObjects];
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
