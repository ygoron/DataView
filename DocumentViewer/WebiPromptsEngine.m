//
//  WebiPrompts.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-09-29.
//  Copyright (c) 2013 APOS Systems. All rights reserved.
//

#import "WebiPromptsEngine.h"
#import "BIConnector.h"
#import "WebiAppDelegate.h"
#import "BI4RestConstants.h"
#import "Document.h"
#import "BILogoff.h"
#import "WebiPrompt.h"
#import "WebiPromptAnswer.h"
#import "WebiPromptInfo.h"
#import "WebiPromptLov.h"
#import "WebiPromptLovInterval.h"
#import "SharedUtils.h"

@implementation WebiPromptsEngine

{
    BIConnector *connector;
    WebiAppDelegate *appDelegate;
    NSString * __currentToken;
    Document *__document;
    Session *__biSession;
    NSError *__connectorError;
    NSString *__boxiError;
    NSMutableData *responseData;
    WebiPrompt *__webiPrompt;
    BOOL __isRefreshPrompt;
}

-(void) refreshPromptForPrompt:(WebiPrompt *)webiPrompt forDocument:(Document *)document
{
    
    __isRefreshPrompt=YES;
    __webiPrompt=webiPrompt;
    
    NSLog (@"Refresh Prompt id: %d,",webiPrompt.promptId);
    
    appDelegate = (id)[[UIApplication sharedApplication] delegate];
    __currentToken=document.session.cmsToken;
    __biSession=document.session;
    __document=document;
    // Get Token First
    if (document.session.cmsToken==nil || [appDelegate.globalSettings.autoLogoff boolValue]==YES){
        NSLog(@"CMS Token is NULL - create new one");
        connector=[[BIConnector alloc]init];
        connector.delegate=self;
        [connector getCmsTokenWithSession:document.session];
    }else{
        NSLog(@"CMS Token is NOT NULL - Process With Existing Token");
        [self processHttpRequestForPrompt:__webiPrompt forDocument:(Document *) __document];
        
    }
    
    
}
-(void) getPrompts:(Document *)document withToken:(NSString *)cmsToken
{
    NSLog (@"Get Prompts for Document:%@ With Token: %@",document.name,cmsToken);
    appDelegate = (id)[[UIApplication sharedApplication] delegate];
    
    __currentToken=cmsToken;
    __biSession=__document.session;
    __document=document;
    __document.session.cmsToken=cmsToken;
    __biSession.cmsToken=cmsToken;
    [self processHttpRequestForDocument:document];
}
-(void) getPrompts:(Document *)document
{
    
    
    NSLog (@"Get Prompts for Document:%@",document.name);
    
    appDelegate = (id)[[UIApplication sharedApplication] delegate];
    __currentToken=document.session.cmsToken;
    
    __biSession=document.session;
    __document=document;
    // Get Token First
    if (document.session.cmsToken==nil || [appDelegate.globalSettings.autoLogoff boolValue]==YES){
        NSLog(@"CMS Token is NULL - create new one");
        connector=[[BIConnector alloc]init];
        connector.delegate=self;
        [connector getCmsTokenWithSession:document.session];
    }else{
        NSLog(@"CMS Token is NOT NULL - Process With Existing Token");
        [self processHttpRequestForDocument:document];
        
    }
    
}

#pragma mark Process Http Request for Refreshing Prompts
-(void) processHttpRequestForPrompt: (WebiPrompt *) webiPrompt forDocument:(Document *) document
{
    __biSession=document.session;
    NSString *cmsToken=[[NSString alloc] initWithFormat:@"%@%@%@",@"\"",__currentToken,@"\""];
    NSMutableURLRequest *request = [NSMutableURLRequest  requestWithURL:[self getPromptsUrl:document]];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    NSLog(@"Process with URL: %@",[request URL]);
    NSLog(@"Token:%@",cmsToken);
    
    NSLog(@"Timeout Preference Value:%@",appDelegate.globalSettings.networkTimeout);
    [request setTimeoutInterval:[appDelegate.globalSettings.networkTimeout doubleValue ]];
    
    [request setHTTPMethod:@"PUT"];
    NSLog(@"PUT Method");
    NSString *parameterJsonString=[self buildJSONPromptStringWithPrompts:__webiPrompt];
    [request setHTTPBody: [parameterJsonString dataUsingEncoding:NSUTF8StringEncoding]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:cmsToken forHTTPHeaderField:SAP_HTTP_TOKEN];
    (void)[[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    
    
}

-(NSString *) buildJSONPromptStringWithPrompts: (WebiPrompt *) webiPrompt
{
    
    NSDictionary *order=[NSDictionary dictionaryWithObjectsAndKeys:@"Ascending",@"@order",nil];
    NSDictionary *sort=[NSDictionary dictionaryWithObjectsAndKeys: @"true",@"@refresh",order,@"sort", nil];
    
    NSDictionary *query= [NSDictionary dictionaryWithObjectsAndKeys:[NSDictionary dictionaryWithDictionary:sort],@"query",nil];
    
    NSDictionary *lov=[NSDictionary dictionaryWithObjectsAndKeys:query,@"lov", nil];
    
    NSDictionary *info =[NSDictionary dictionaryWithObjectsAndKeys:lov,@"info", nil];
    
    NSDictionary *answer=[NSDictionary dictionaryWithObjectsAndKeys: [NSString stringWithFormat:@"%d" ,webiPrompt.promptId ],@"id",info,@"answer",nil];
    
    NSDictionary *parameterRefresh=[NSDictionary dictionaryWithObjectsAndKeys:[NSDictionary dictionaryWithDictionary:answer],@"parameter",nil];
    
    NSDictionary *parametersRefresh=[NSDictionary dictionaryWithObjectsAndKeys:parameterRefresh,@"parameters",nil];
    
    if([NSJSONSerialization isValidJSONObject:parametersRefresh]){
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parametersRefresh options:0 error:nil];
        NSString *jsonString = [[NSString alloc]initWithData:	jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"JSON String %@",jsonString);
        return jsonString;
    }
    
    
    return nil;
}

#pragma mark Process Http Request for getting prompts
-(void) processHttpRequestForDocument:(Document *) document
{
    __biSession=document.session;
    NSString *cmsToken=[[NSString alloc] initWithFormat:@"%@%@%@",@"\"",__currentToken,@"\""];
    NSMutableURLRequest *request = [NSMutableURLRequest  requestWithURL:[self getPromptsUrl:document]];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    NSLog(@"Process with URL: %@",[request URL]);
    NSLog(@"Token:%@",cmsToken);
    
    NSLog(@"Timeout Preference Value:%@",appDelegate.globalSettings.networkTimeout);
    [request setTimeoutInterval:[appDelegate.globalSettings.networkTimeout doubleValue ]];
    
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:cmsToken forHTTPHeaderField:SAP_HTTP_TOKEN];
    (void)[[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    
    
}

# pragma mark getPrompts URL

-(NSURL *) getPromptsUrl: (Document *) document{
    NSLog (@"GetReports URL For Document id:%@",document.id);
    NSURL *url;
    NSString *host=[NSString stringWithFormat: @"%@:%@",document.session.cmsName,document.session.port] ;
    if ([document.session.isHttps integerValue]==1){
        url=[[NSURL alloc]initWithScheme:@"https" host:host path:[NSString stringWithFormat:@"%@%@%@%@%@",document.session.webiRestSDKBase,getDocumentsPathPoint,@"/",document.id,@"/parameters"]];
    }
    else{
        url=[[NSURL alloc]initWithScheme:@"http" host:host path:[NSString stringWithFormat:@"%@%@%@%@%@",document.session.webiRestSDKBase,getDocumentsPathPoint,@"/",document.id,@"/parameters"]];
    }
    NSLog(@"URL:%@",url);
    return  url;
}

#pragma mark getToken Completed

-(void) biConnector:(BIConnector *)biConnector didCreateCmsToken:(NSString *)cmsToken forSession:(Session *)session{
    NSLog (@"Return From Get CMS Token");
    if(cmsToken!=nil){
        NSLog(@"Token Receieved:%@",cmsToken);
        __currentToken=cmsToken;
        __document.session.cmsToken=__currentToken;
        if (__isRefreshPrompt==NO){
            [self processHttpRequestForDocument:__document];
        }else{
            [self processHttpRequestForPrompt:__webiPrompt forDocument:(Document *) __document];
        }
        
    }else if (biConnector.connectorError!=nil){
        __connectorError=biConnector.connectorError ;
        if (__isRefreshPrompt==NO)
            [self.delegate didGetPrompts:self isSuccess:NO withPrompts:nil withErrorText:__connectorError.description];
        else
            [self.delegate didRefreshPrompt:self isSuccess:NO refreshedPrompts:nil withErrorText:__connectorError.description];
        
    }else if (biConnector.boxiError!=nil){
        __boxiError=biConnector.boxiError;
        if (__isRefreshPrompt==NO)
            [self.delegate didGetPrompts:self isSuccess:NO withPrompts:nil withErrorText:__boxiError];
        else
            [self.delegate didRefreshPrompt:self isSuccess:NO refreshedPrompts:nil withErrorText:__boxiError];
        
    }else{
        if (__isRefreshPrompt==NO)
            [self.delegate didGetPrompts:self isSuccess:NO withPrompts:nil withErrorText:NSLocalizedString(@"Server Error", nil)];
        else
            [self.delegate didRefreshPrompt:self isSuccess:NO refreshedPrompts:nil withErrorText:NSLocalizedString(@"Server Error", nil)];
    }
    
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
            
            __connectorError =[NSError errorWithDomain:NSLocalizedString(@"Failed",nil) code:statusCode userInfo:details];
            if (__isRefreshPrompt==NO)
                [self.delegate didGetPrompts:self isSuccess:NO withPrompts:nil withErrorText:__connectorError.description];
            else
                [self.delegate didRefreshPrompt:self isSuccess:NO refreshedPrompts:nil withErrorText:__connectorError.description];
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
    __connectorError =[[NSError alloc] init];
    __connectorError=error;
    if (__isRefreshPrompt==NO)
        [self.delegate didGetPrompts:self isSuccess:NO withPrompts:nil withErrorText:__connectorError.description];
    else
        [self.delegate didRefreshPrompt:self isSuccess:NO refreshedPrompts:nil withErrorText:__connectorError.description];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading");
    NSLog(@"Succeeded! Received %d bytes of data",[responseData length]);
#ifdef Trace
    NSString *receivedString = [[NSString alloc]  initWithData:responseData
                                                      encoding:NSUTF8StringEncoding];
    int length=([receivedString length])<MAX_DISPLAY_HTTP_STRING?[receivedString length]:MAX_DISPLAY_HTTP_STRING;
    NSLog(@"Get Parameters Data:%@%@",[receivedString substringToIndex:length],@"..." );
#endif
    
    
    BOOL isSuccess=YES;
    
    NSMutableArray *prompts=[[NSMutableArray alloc] init];
    
    // convert to JSON
    NSError *myError = nil;
    NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&myError];
    
    NSLog(@"Result:%@",responseDic);
    NSLog(@"All keys:%@",[responseDic allKeys]);
    
    
    if ([[responseDic allKeys] containsObject:JSON_RESP_ERROR_CODE]){
        __boxiError=[responseDic objectForKey:JSON_RESP_ERROR_MESSAGE];
        isSuccess=NO;
    }
    else{
        __boxiError=nil;
        responseDic=[responseDic objectForKey:@"parameters"];
        if ([responseDic isKindOfClass:[NSDictionary class]]){
            
            if ([[responseDic objectForKey:@"parameter"] isKindOfClass:[NSArray class]]){
                NSArray *promptsJ=[responseDic objectForKey:@"parameter"];
                for (NSDictionary *promptJ in promptsJ){
                    [prompts addObject:[self getPromptFromJson:promptJ]];
                }
            }else{
                NSDictionary *promptJ=[responseDic objectForKey:@"parameter"];
                if (promptJ) [prompts addObject:[self getPromptFromJson:promptJ]];
            }
            
        }
        
        //        if ([responseDic isKindOfClass:[NSDictionary class]]){
        //            NSLog(@"All keys:%@",[responseDic allKeys]);
        //
        //            if ([[responseDic objectForKey:@"report"] isKindOfClass:[NSArray class]]){
        //                NSLog(@"Array!");
        //                NSArray *reps=[responseDic objectForKey:@"report"];
        //                for (NSDictionary *reportJson in reps) {
        //                    NSLog(@"Id:%@",[reportJson objectForKey:@"id"]);
        //
        //                    [reports addObject: [self getReportFromJson:reportJson]];
        //                    self.document.reports=[NSSet setWithArray:reports];
        //
        //                }
        //
        //            }
        //            else{
        //                NSLog(@"Not Array");
        //                NSDictionary *reportJson=[responseDic objectForKey:@"report"];
        //                NSLog(@"Id:%@",[reportJson objectForKey:@"id"]);
        //                [reports addObject: [self getReportFromJson:reportJson]];
        //                self.document.reports=[NSSet setWithArray:reports];
        //            }
        //
        //        }
        //
    }
    
    if ([__boxiError isEqualToString:BOXI_TOKEN_ERROR]){
        NSLog(@"Token Expired - Create new One and try again");
        connector=[[BIConnector alloc]init];
        connector.delegate=self;
        [connector getCmsTokenWithSession:__biSession];
    }else{
        if (__isRefreshPrompt==NO)
            [self.delegate didGetPrompts:self isSuccess:isSuccess withPrompts:prompts withErrorText:nil];
        else
            [self.delegate didRefreshPrompt:self isSuccess:isSuccess refreshedPrompts:prompts withErrorText:nil];
    }
    
    [self logoOffIfNeeded];
}

-(WebiPrompt *) getPromptFromJson: (NSDictionary*)promptJ
{
    WebiPrompt *webiprompt =[[WebiPrompt alloc] init];
    if ([promptJ objectForKey:@"@dpId"]) webiprompt.dataproviderId=[promptJ objectForKey:@"@dpId"];
    if ([promptJ objectForKey:@"name"]) webiprompt.name=[promptJ objectForKey:@"name"];
    if ([promptJ objectForKey:@"@optional"]) {
        webiprompt.isOptional=[[promptJ objectForKey:@"@optional"] isEqualToString:@"true"]?YES:NO;
    }
    if ([promptJ objectForKey:@"@type"]) webiprompt.type=[promptJ objectForKey:@"@type"];
    if ([promptJ objectForKey:@"id"]) webiprompt.promptId=[[promptJ objectForKey:@"id"] integerValue];
    
    if ([promptJ objectForKey:@"answer"]){
        NSDictionary *answerJ=[promptJ objectForKey:@"answer"];
        WebiPromptAnswer *answer=[[WebiPromptAnswer alloc] init];
        [webiprompt setAnswer:answer];
        if ([answerJ objectForKey:@"@constrained"])
            answer.isConstrained=[[answerJ objectForKey:@"@constrained"] isEqualToString:@"true"]?YES:NO;
        if ([answerJ objectForKey:@"@type"]) answer.type=[answerJ objectForKey:@"@type"];
        
        if ([answerJ objectForKey:@"info"]){
            NSDictionary *infoJ=[answerJ objectForKey:@"info"];
            WebiPromptInfo *info=[[WebiPromptInfo alloc] init];
            if ([infoJ objectForKey:@"@cardinality"]) info.cardinality=[infoJ objectForKey:@"@cardinality"];
            [answer setInfo:info];
            if ([infoJ objectForKey:@"lov"]){
                NSDictionary *lovJ=[infoJ objectForKey:@"lov"];
                WebiPromptLov *lov=[[WebiPromptLov alloc] init];
                [answer.info setLov:lov];
                if ([lovJ objectForKey:@"@hierarchical"]) lov.isHieararchical=[[lovJ objectForKey:@"@hierarchical"] isEqualToString:@"true"]?YES:NO;
                if ([lovJ objectForKey:@"@partial"]) lov.isPartial=[[lovJ objectForKey:@"@partial"] isEqualToString:@"true"]?YES:NO;
                if ([lovJ objectForKey:@"@refreshable"]) lov.isRefreshable=[[lovJ objectForKey:@"@refreshable"] isEqualToString:@"true"]?YES:NO;
                if ([lovJ objectForKey:@"id"]) lov.dpId=[lovJ objectForKey:@"id"];
                
                
                if ([lovJ objectForKey:@"updated"]) {
//                    NSDateFormatter *dateFormtter=[[NSDateFormatter alloc] init];
//                    [dateFormtter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSzzzz"];
//                    lov.updated=[dateFormtter dateFromString:[lovJ objectForKey:@"updated"]];

                    lov.updated=[SharedUtils getDateFromRaylightJSONString:[lovJ objectForKey:@"updated"]];
                    
                    NSLog(@"Date:%@",lov.updated);
                }
                
                
                
                if ([lovJ objectForKey:@"intervals"]){
                    if ([[lovJ objectForKey:@"intervals"] objectForKey:@"interval"]){
                        NSDictionary *intetvalsJ=[[lovJ objectForKey:@"intervals"] objectForKey:@"interval"];
                        if ([intetvalsJ isKindOfClass:[NSArray class]]){
                            NSMutableArray *intervals=[[NSMutableArray alloc] init];
                            [lov setIntervals:intervals];
                            for (NSDictionary *interValJ in intetvalsJ) {
                                if ([interValJ objectForKey:@"@id"]){
                                    WebiPromptLovInterval *interval=[[WebiPromptLovInterval alloc] init];
                                    [intervals addObject:interval];
                                    [interval setIntervalId:[[interValJ objectForKey:@"@id"] integerValue]];
                                    if ([interValJ objectForKey:@"value"]){
                                        NSDictionary *valuesJ=[interValJ objectForKey:@"value"];
                                        if ([valuesJ isKindOfClass:[NSArray class]]){
                                            NSMutableArray *values=[[NSMutableArray alloc] init];
                                            [interval setValues:values];
                                            for (NSString *value in valuesJ) {
                                                [values addObject:[NSString stringWithFormat:@"%@",value]];
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        
                        
                        
                    }
                }
                if ([lovJ objectForKey:@"values"]){
                    if ([[lovJ objectForKey:@"values"] objectForKey:@"value"]){
                        NSMutableArray *values=[[NSMutableArray alloc] init];
                        [lov setValues:values];
                        NSDictionary *valueJ=[[lovJ objectForKey:@"values"] objectForKey:@"value"];
                        
                        if ([valueJ isKindOfClass:[NSArray class]]){
                            for (NSString *value in valueJ) {
                                [values addObject:[NSString stringWithFormat:@"%@",value]];
                            }
                        }else{
                            NSString *value=[[lovJ objectForKey:@"values"] objectForKey:@"value"];
                            [values addObject:[NSString stringWithFormat:@"%@",value]];
                        }
                    }
                }
                
            }
        }
        if ([answerJ objectForKey:@"values"]){
            
            
            if ([[answerJ objectForKey:@"values"] objectForKey:@"value"]){
                NSMutableArray *values=[[NSMutableArray alloc] init];
                [answer setValues:values];
                NSDictionary *valueJ=[[answerJ objectForKey:@"values"] objectForKey:@"value"];
                
                if ([valueJ isKindOfClass:[NSArray class]]){
                    for (NSString *value in valueJ) {
                        [values addObject:[NSString stringWithFormat:@"%@",value]];
                    }
                }else{
                    NSString *value=[[answerJ objectForKey:@"values"] objectForKey:@"value"];
                    [values addObject:[NSString stringWithFormat:@"%@",value]];
                }
            }
            
        }
        
    }
    
    return webiprompt;
    
}
-(void) logoOffIfNeeded{
    if ([appDelegate.globalSettings.autoLogoff integerValue]==1){
        if (__document.session!=nil && __document.session.cmsToken!=nil){
            [self logoffWithSession:__document.session];
        }
    }
    
}
-(void) logoffWithSession:(Session *)session{
    if (session.cmsToken!=nil){
        BILogoff *biLogoff=[[BILogoff alloc] init];
        [biLogoff logoffSession:session withToken:__currentToken];
        NSLog(@"Logoff Session:%@",session.name);
    }
    
    
}

@end
