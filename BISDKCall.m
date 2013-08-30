//
//  BISDKCall.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-05-03.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import "BISDKCall.h"
#import "WebiAppDelegate.h"
#import "BI4RestConstants.h"
#import "CypressResponseHeader.h"
#import "BILogoff.h"
#import "InfoObject.h"
#import "GlobalPreferencesConstants.h"

@implementation BISDKCall
{
    BIConnector *_connector;
    NSURL *_urlChildren;
    NSURL *_urlSelectdObject;
    BOOL isChildren;
}



#pragma mark get Selected Object
-(void) getSelectedObjectForSession:(Session *)session withUrl:(NSURL *)url{
    
    NSLog(@"Get Selected Object with URL %@ using Cypress call",url);
    _urlSelectdObject=url;
    isChildren=NO;
    [self tokenHandler:session];
    
}

#pragma mark get  Objects with URL

-(void) getObjectsForSession:(Session *)session withUrl:(NSURL *)url
{
    NSLog(@"Get Children Objects with URL %@ using Cypress call",url);
    _urlChildren=url;
    isChildren=YES;
    [self tokenHandler:session];
}

-(void) tokenHandler:(Session *)session
{
    self.currentToken=session.cmsToken;
    self.biSession=session;
    // Get Token First
    if (session.cmsToken==nil || session.password==nil){
        NSLog(@"CMS Token is NULL - create new one");
        //        BIConnector *connector=[[BIConnector alloc]init];
        _connector=[[BIConnector alloc]init];
        _connector.delegate=self;
        [_connector getCmsTokenWithSession:session];
    }else{
        NSLog(@"CMS Token is NOT NULL - Process With Existing Token");
        [self processHttpRequest];
        
    }
    
    
}
-(void) biConnector:(BIConnector *)biConnector didCreateCmsToken:(NSString *)cmsToken forSession:(Session *)session{
    NSLog (@"Return From Get CMS Token");
    if(cmsToken!=nil){
        NSLog(@"Token Receieved:%@",cmsToken);
        self.currentToken=cmsToken;
        [self processHttpRequest];
        
    }else if (biConnector.connectorError!=nil){
        self.connectorError=biConnector.connectorError ;
        if (isChildren==YES)
            [self.delegate cypressCallForChildren:self withResponse:nil isSuccess:NO withChildrenObjects:nil];
        else
            [self.delegate cypressCallSelectedObject:self withResponse:nil isSuccess:NO withObject:nil];
        
    }else if (biConnector.boxiError!=nil){
        self.boxiError=biConnector.boxiError;
        if (isChildren==YES)
            [self.delegate cypressCallForChildren:self withResponse:nil isSuccess:NO withChildrenObjects:nil];
        else
            [self.delegate cypressCallSelectedObject:self withResponse:nil isSuccess:NO withObject:nil];
        
    }else{
        if (isChildren)
            [self.delegate cypressCallForChildren:self withResponse:nil isSuccess:NO withChildrenObjects:nil];
        else
            [self.delegate cypressCallSelectedObject:self withResponse:nil isSuccess:NO withObject:nil];
    }
    
}

#pragma mark Get Http Request for children
-(void) processHttpRequest
{
    NSMutableURLRequest *request;
    if (isChildren==YES){
        NSLog(@"processHttpRequest for Children Objects %@",_urlChildren);
        request = [NSMutableURLRequest  requestWithURL:_urlChildren];
    }else{
        NSLog(@"processHttpRequest for Selected Object %@",_urlSelectdObject);
        request = [NSMutableURLRequest  requestWithURL:_urlSelectdObject];
        
    }
    
    
    NSString *cmsToken=[[NSString alloc] initWithFormat:@"%@%@%@",@"\"",self.currentToken,@"\""];
    
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
        _statusCode = [((NSHTTPURLResponse *)response) statusCode];
        //        if (statusCode  ==404)
        //        {
        //            [connection cancel];  // stop connecting; no more delegate messages
        //            NSLog(@"didReceiveResponse statusCode with %i", statusCode);
        //
        //            NSMutableDictionary* details = [NSMutableDictionary dictionary];
        //            [details setValue:[NSString stringWithFormat:@"%@%d",@"Server Error: ",statusCode]  forKey:NSLocalizedDescriptionKey];
        //
        //            _connectorError =[NSError errorWithDomain:@"Failed" code:statusCode userInfo:details];
        //            [self.delegate cypressCallForChildren:self withResponse:nil isSuccess:NO withChildrenObjects:nil];
        //        }
        //        else{
        //            responseData = [[NSMutableData alloc] init];
        //        }
        responseData = [[NSMutableData alloc] init];
        
        
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"BI Cypress Call didFailWithError %@",[error localizedDescription]);
    _connectorError =[[NSError alloc] init];
    _connectorError=error;
    if (isChildren==YES)
        [self.delegate cypressCallForChildren:self withResponse:nil isSuccess:NO withChildrenObjects:nil];
    else
        [self.delegate cypressCallSelectedObject:self withResponse:nil isSuccess:NO withObject:nil];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading");
    NSLog(@"Succeeded! Received %d bytes of data",[responseData length]);
    
#ifdef Trace
    NSString *receivedString = [[NSString alloc]  initWithData:responseData
                                                      encoding:NSUTF8StringEncoding];
    int length=([receivedString length])<MAX_DISPLAY_HTTP_STRING?[receivedString length]:MAX_DISPLAY_HTTP_STRING;
    NSLog(@"Get Documents  Data:%@%@",[receivedString substringToIndex:length],@"..." );
#endif
    
    NSMutableArray *infoObjects=[[NSMutableArray alloc] init];
    InfoObject *selectedObject=[[InfoObject alloc]init];
    
    CypressResponseHeader *responseHeader= [[CypressResponseHeader alloc]init];
    
    
    BOOL isSucess=YES;
    
    // convert to JSON
    NSError *myError = nil;
    NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&myError];
    
    NSLog(@"Result:%@",responseDic);
    NSLog(@"All keys:%@",[responseDic allKeys]);
    
    
    if ([[responseDic allKeys] containsObject:JSON_RESP_ERROR_CODE]){
        self.boxiError=[responseDic objectForKey:JSON_RESP_ERROR_MESSAGE];
        isSucess=NO;
        NSLog (@"Boxi Error:%@",_boxiError);
    }
    else{
        self.boxiError=nil;
        
        if ([responseDic isKindOfClass:[NSDictionary class]]){
            
            responseHeader.metadata=[NSURL URLWithString:[self parseLevelName:@"__metadata" subLevel:@"uri" withDictionary:responseDic]];
            NSLog(@"Metadata URI:%@",responseHeader.metadata);
            
            
            if ([responseDic objectForKey:@"first"]){
                if ([[responseDic objectForKey:@"first"] isKindOfClass:[NSDictionary class]]){
                    NSDictionary *deferred=[responseDic objectForKey:@"first"];
                    responseHeader.first=[NSURL URLWithString:[self parseLevelName:@"__deferred" subLevel:@"uri" withDictionary:deferred]];
                    NSLog(@"First %@",responseHeader.first);
                }
            }
            if ([responseDic objectForKey:@"last"]){
                if ([[responseDic objectForKey:@"last"] isKindOfClass:[NSDictionary class]]){
                    NSDictionary *deferred=[responseDic objectForKey:@"last"];
                    responseHeader.last=[NSURL URLWithString:[self parseLevelName:@"__deferred" subLevel:@"uri" withDictionary:deferred]];
                    NSLog(@"Last %@",responseHeader.last);
                }
            }
            
            if ([responseDic objectForKey:@"next"]){
                if ([[responseDic objectForKey:@"next"] isKindOfClass:[NSDictionary class]]){
                    NSDictionary *deferred=[responseDic objectForKey:@"next"];
                    responseHeader.next=[NSURL URLWithString:[self parseLevelName:@"__deferred" subLevel:@"uri" withDictionary:deferred]];
                    NSLog(@"Next %@",responseHeader.next);
                }
            }
            
            
            
            
            
            if (isChildren==YES){
                NSLog(@"Process Children");
                if ([responseDic objectForKey:@"entries"]){
                    if ([[responseDic objectForKey:@"entries"] isKindOfClass:[NSArray class]]){
                        NSArray *entries=[responseDic objectForKey:@"entries"];
                        
                        for (NSDictionary *entry in entries) {
                            
                            
                            //                        NSLog(@"Id:%@",[entry objectForKey:@"id"]);
                            
                            InfoObject *infoObject=[[InfoObject alloc]init];
                            infoObject.metaDataUrl=[NSURL URLWithString:[self parseLevelName:@"__metadata" subLevel:@"uri" withDictionary:entry]];
                            if ([entry objectForKey:@"id"]){
                                infoObject.objectId= [[entry objectForKey:@"id"] intValue];
                                NSLog(@"InfoObject Id %d, Name: %@",infoObject.objectId,infoObject.name=[entry objectForKey:@"name"]);
                            }
                            if ([entry objectForKey:@"cuid"]) infoObject.cuid=[entry objectForKey:@"cuid"];
                            if ([entry objectForKey:@"description"]) infoObject.description=[entry objectForKey:@"description"];
                            if ([entry objectForKey:@"name"]) infoObject.name=[entry objectForKey:@"name"];
                            if ([entry objectForKey:@"type"]) infoObject.type=[entry objectForKey:@"type"];
                            if ([infoObject.type isEqualToString:@"Folder"]) infoObject.sortPriority=1;
                            else infoObject.sortPriority=2;
                            
                            if (_isFilterByUserName==YES && [infoObject.name caseInsensitiveCompare:_biSession.userName]!=NSOrderedSame){
                                NSLog(@"Skipping Object with name %@",infoObject.name);
                            }else if([infoObject.name caseInsensitiveCompare: DEFAULT_APOS_SPECIAL_FOLDER]==NSOrderedSame ){
                                NSLog(@"Skipping Special Folder with name %@",infoObject.name);
                            }else
                                [infoObjects addObject:infoObject];
                            
                        }
                        
                    }
                }
            }else{
                NSLog(@"Process Selected Object");
                
                if ([responseDic objectForKey:@"Children"]){
                    if ([[responseDic objectForKey:@"Children"] isKindOfClass:[NSDictionary class]]){
                        NSDictionary *deferred=[responseDic objectForKey:@"Children"];
                        selectedObject.childrenUrl  =[NSURL URLWithString:[self parseLevelName:@"__deferred" subLevel:@"uri" withDictionary:deferred]];
                        NSLog(@"Children URL %@",selectedObject.childrenUrl);
                    }
                }
                
                if ([responseDic objectForKey:@"Scheduling forms"]){
                    if ([[responseDic objectForKey:@"Scheduling forms"] isKindOfClass:[NSDictionary class]]){
                        NSDictionary *deferred=[responseDic objectForKey:@"Scheduling forms"];
                        selectedObject.scheduleFormsUrl=[NSURL URLWithString:[self parseLevelName:@"__deferred" subLevel:@"uri" withDictionary:deferred]];
                        NSLog(@"Schdeuling Forms %@",selectedObject.scheduleFormsUrl);
                    }
                }
                
                if ([responseDic objectForKey:@"openDocument"]){
                    if ([[responseDic objectForKey:@"openDocument"] isKindOfClass:[NSDictionary class]]){
                        NSDictionary *deferred=[responseDic objectForKey:@"openDocument"];
                        selectedObject.openDoc=[NSURL URLWithString:[self parseLevelName:@"__deferred" subLevel:@"uri" withDictionary:deferred]];
                        NSLog(@"Open Doc %@",selectedObject.openDoc);
                    }
                }
                
                if ([responseDic objectForKey:@"latest-instance"]){
                    if ([[responseDic objectForKey:@"latest-instance"] isKindOfClass:[NSDictionary class]]){
                        NSDictionary *deferred=[responseDic objectForKey:@"latest-instance"];
                        selectedObject.latestInstanceUrl=[NSURL URLWithString:[self parseLevelName:@"__deferred" subLevel:@"uri" withDictionary:deferred]];
                        NSLog(@"Open Doc %@",selectedObject.openDoc);
                    }
                }
                
                
                
                
                
                
                if ([responseDic objectForKey:@"id"]) {
                    selectedObject.objectId=[[responseDic objectForKey:@"id"] intValue];
                    NSLog(@"InfoObject Id %d",selectedObject.objectId);
                }
                
                if ([responseDic objectForKey:@"cuid"]) selectedObject.cuid=[responseDic objectForKey:@"cuid"];
                if ([responseDic objectForKey:@"description"]) selectedObject.description=[responseDic objectForKey:@"description"];
                if ([responseDic objectForKey:@"name"]) selectedObject.name=[responseDic objectForKey:@"name"];
                if ([responseDic objectForKey:@"type"]) selectedObject.type=[responseDic objectForKey:@"type"];
            }
            
        }
        
    }
    
    if ([self.boxiError isEqualToString:BOXI_TOKEN_ERROR]){
        NSLog(@"Token Expired - Create new One and try again");
        BIConnector *connector=[[BIConnector alloc]init];
        connector.delegate=self;
        [connector getCmsTokenWithSession:self.biSession];
    }else{
        NSLog(@"Calling Delegates. Is Children? %d",isChildren);
        if (isChildren==YES)
            [self.delegate cypressCallForChildren:self withResponse:responseHeader isSuccess:isSucess withChildrenObjects:infoObjects];
        else{
            [self.delegate cypressCallSelectedObject:self withResponse:responseHeader isSuccess:isSucess withObject:selectedObject];
        }
    }
    
    [self logoOffIfNeeded];
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

@end
