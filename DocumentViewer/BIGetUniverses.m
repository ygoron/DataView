//
//  BIGetUniverses.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-03-30.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import "BIGetUniverses.h"
#import "BI4RestConstants.h"
#import "WebiAppDelegate.h"
#import "BILogoff.h"


@implementation BIGetUniverses

{
    BOOL isUseCache;
    BIConnector *connector;
    WebiAppDelegate *appDelegate;
}


@synthesize connectorError;
@synthesize boxiError;
@synthesize delegate;
@synthesize biSession;
@synthesize context;
@synthesize limit;
@synthesize offset;
@synthesize currentToken;

#pragma mark getUniverses for Session

-(void) getUniversesForSession:(Session *)session withLimit:(int)newLimit withOffset:(int)newOffset{
    
    NSLog (@"Get Universes for Session %@ Started",session.name);
    isUseCache=YES;
    
    appDelegate = (id)[[UIApplication sharedApplication] delegate];
    self.currentToken=session.cmsToken;

    self.biSession=session;
    self.limit=newLimit;
    self.offset=newOffset;
    // Get Token First
    if (session.cmsToken==nil){
        NSLog(@"CMS Token is NULL - create new one");
        connector=[[BIConnector alloc]init];
        connector.delegate=self;
        [connector getCmsTokenWithSession:session];
    }else{
        NSLog(@"CMS Token is NOT NULL - Process With Existing Token");
        [self processHttpRequestForSession:session];
        
    }
    
}



-(void) biConnector:(BIConnector *)biConnector didCreateCmsToken:(NSString *)cmsToken forSession:(Session *)session{
    NSLog (@"Return From Get CMS Token");
    if(cmsToken!=nil){
        NSLog(@"Token Receieved:%@",cmsToken);
        self.currentToken=cmsToken;
        [self processHttpRequestForSession:session];
        
    }else if (biConnector.connectorError!=nil){
        self.connectorError=biConnector.connectorError ;
        [self.delegate getUniverses:self isSuccess:NO universes:nil];
        
    }else if (biConnector.boxiError!=nil){
        self.boxiError=biConnector.boxiError;
        [self.delegate getUniverses:self isSuccess:NO universes:nil];
        
    }else{
        [self.delegate getUniverses:self isSuccess:NO universes:nil];
    }
    
}

# pragma mark Get Documents

-(void) processHttpRequestForSession: (Session*) session{
    NSLog(@"Get Universe processHttpRequestForSession");
    self.biSession=session;
//    NSString *cmsToken=[[NSString alloc] initWithFormat:@"%@%@%@",@"\"",session.cmsToken,@"\""];
    NSString *cmsToken=[[NSString alloc] initWithFormat:@"%@%@%@",@"\"",self.currentToken,@"\""];
    isUseCache=NO;


    NSMutableURLRequest *request = [NSMutableURLRequest  requestWithURL:[self getUniversesURL:session]];
    if (isUseCache){
        NSLog(@"Use Cache");
        [request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    }
    else{
        NSLog(@"Ignore Cache");
        [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    }
    NSLog(@"Process with URL: %@",[request URL]);
    NSLog(@"Token:%@",cmsToken);

    NSLog(@"Timeout Preference Value:%@",appDelegate.globalSettings.networkTimeout);
    [request setTimeoutInterval:[appDelegate.globalSettings.networkTimeout doubleValue ]];

    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:cmsToken forHTTPHeaderField:SAP_HTTP_TOKEN];
    [request setValue:[NSString stringWithFormat:@"%d", self.offset]  forHTTPHeaderField:HEADER_SAP_OFFSET];
    [request setValue:[NSString stringWithFormat:@"%d", self.limit]  forHTTPHeaderField:HEADER_SAP_LIMIT];
    (void)[[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}

# pragma mark getDocuments URL

-(NSURL *) getUniversesURL: (Session *) session {
    NSLog (@"Get Universes URL Session Name:%@",session);
    NSURL *getUniversesURL;
    NSString *host=[NSString stringWithFormat: @"%@:%@",session.cmsName,session.port] ;
    if ([session.isHttps integerValue]==1){
        getUniversesURL=[[NSURL alloc]initWithScheme:@"https" host:host path:[NSString stringWithFormat:@"%@%@",session.webiRestSDKBase,getUniversesPathPoint]];
    }
    else{
        getUniversesURL=[[NSURL alloc]initWithScheme:@"http" host:host path:[NSString stringWithFormat:@"%@%@",session.webiRestSDKBase,getUniversesPathPoint]];
    }
    NSLog(@"URL:%@",getUniversesURL);
    NSString *urlString=  [[NSString alloc] initWithFormat:@"%@%@%d%@%d", [getUniversesURL absoluteString],@"?limit=",self.limit,@"&offset=",self.offset];
    
    return [[NSURL alloc] initWithString:urlString];
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
            [self.delegate getUniverses:self isSuccess:NO universes:nil];
            isUseCache=NO;
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
    NSLog(@"BIGetDocuments didFailWithError");
    NSLog(@"Connection failed: %@", [error localizedDescription]);
    connectorError =[[NSError alloc] init];
    connectorError=error;
    [self.delegate getUniverses:self isSuccess:NO universes:nil];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading");
    NSLog(@"Succeeded! Received %d bytes of data",[responseData length]);

#ifdef Trace
    NSString *receivedString = [[NSString alloc]  initWithData:responseData
                                                      encoding:NSUTF8StringEncoding];
    int length=([receivedString length])<MAX_DISPLAY_HTTP_STRING?[receivedString length]:MAX_DISPLAY_HTTP_STRING;
    NSLog(@"Get Universes  Data:%@%@",[receivedString substringToIndex:length],@"..." );
#endif
    
    NSMutableArray *universes=[[NSMutableArray alloc] init];
    
    
    
    BOOL isSucess=YES;
    
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
        
        if ([responseDic isKindOfClass:[NSDictionary class]]){
            
            responseDic=[responseDic objectForKey:@"universes"];
            
            if ([responseDic isKindOfClass:[NSDictionary class]]){
                NSLog(@"All keys:%@",[responseDic allKeys]);
                
                
                if ([[responseDic objectForKey:@"universe"] isKindOfClass:[NSArray class]]){
                    NSArray *unvs=[responseDic objectForKey:@"universe"];
                    
                    for (NSDictionary *unv in unvs) {
                        
                        NSLog(@"Id:%@",[unv objectForKey:@"id"]);
                        Universe *universe=[self setUniverseProperties:unv];
                        [universes addObject:universe];
                        isUseCache=YES;
                        
                    }
                }else{
                    NSDictionary *unv=[responseDic objectForKey:@"universe"];
                    NSLog(@"Id:%@",[unv objectForKey:@"id"]);
                    Universe *universe=[self setUniverseProperties:unv];
                    [universes addObject:universe];
                    isUseCache=YES;
                    
                    
                }
                
            }
        }
        
    }
    
    if ([self.boxiError isEqualToString:BOXI_TOKEN_ERROR]){
        NSLog(@"Token Expired - Create new One and try again");
        isUseCache=NO;
        connector=[[BIConnector alloc]init];
        connector.delegate=self;
        [connector getCmsTokenWithSession:self.biSession];
    }else{
        [self.delegate getUniverses:self isSuccess:isSucess universes:universes];
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

-(Universe *) setUniverseProperties:(NSDictionary *) unv{
    Universe *universe=[[Universe alloc] init];
    universe.universeId=[[unv objectForKey:@"id"] intValue];
    universe.type=[unv objectForKey:@"type"];
    universe.name=[unv objectForKey:@"name"];
    universe.cuid=[unv objectForKey:@"cuid"];
    universe.folderId=[[unv objectForKey:@"folderId"] intValue];
    universe.session=biSession;
    return universe;
    
}

@end
