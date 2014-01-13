//
//  XMLRESTProcessor.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-12-01.
//  Copyright (c) 2013 APOS Systems. All rights reserved.
//

#import "XMLRESTProcessor.h"
#import "WebiAppDelegate.h"
#import "BI4RestConstants.h"


@implementation XMLRESTProcessor

{
    BIConnector *connector;
    WebiAppDelegate *appDelegate;
    NSString * __currentToken;
    Session *__biSession;
    NSError *__connectorError;
    NSString *__boxiError;
    NSMutableData *responseData;
    NSString *__method;
    GDataXMLDocument *__xmlDoc;
    NSURL *__url;
    int __opCode;
}

+(NSURL *)getDocumentsUrlWithSession:(Session *)session
{
    NSLog (@"Get Decuments for Session:%@",session);
    NSURL *url;
    NSString *host=[NSString stringWithFormat: @"%@:%@",session.cmsName,session.port] ;
    if ([session.isHttps integerValue]==1){
        url=[[NSURL alloc]initWithScheme:@"https" host:host path:[NSString stringWithFormat:@"%@%@",session.webiRestSDKBase,getDocumentsPathPoint]];
    }
    else{
        url=[[NSURL alloc]initWithScheme:@"http" host:host path:[NSString stringWithFormat:@"%@%@",session.webiRestSDKBase,getDocumentsPathPoint]];
    }
    NSLog(@"Get Documents URL:%@",url);
    return url;
}
+(NSURL *) getDataProvidersUrlWithSession:(Session *)session withDocumentId:(int)documentId
{
    NSURL *url=[self getDocumentsUrlWithSession:session];
    url=[url URLByAppendingPathComponent:[NSString stringWithFormat:@"%d%@",documentId,@"/dataproviders"]];
    NSLog("DataProviders URL:%@",url);
    return url;
}
-(void) submitRequestForUrl:(NSURL *)url withSession:(Session *)session withHttpMethod:(NSString *)method withXmlDoc:(GDataXMLDocument *)doc withOpCode:(int)opCode
{
    
    NSLog(@"Submit Request:");
    NSLog(@"Url:%@",url);
    NSLog(@"Session:%@",session);
    NSLog(@"Method:%@",method);
    __opCode=opCode;
#ifdef Trace
    NSData *xmlData=doc.XMLData;
    NSString *xmlString=[[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    NSLog(@"Xml:%@",xmlString);
#endif
    
    
    appDelegate = (id)[[UIApplication sharedApplication] delegate];
    __currentToken=session.cmsToken;
    __biSession=session;
    __method=method;
    __xmlDoc=doc;
    __url=url;
    
    if (session.cmsToken==nil || [appDelegate.globalSettings.autoLogoff boolValue]==YES){
        NSLog(@"CMS Token is NULL - create new one");
        connector=[[BIConnector alloc]init];
        connector.delegate=self;
        [connector getCmsTokenWithSession:session];
    }else{
        NSLog(@"CMS Token is NOT NULL - Process With Existing Token");
        [self processHttpRequest];
        
    }
    
    
    
}

#pragma mark Process Http Request
-(void) processHttpRequest
{
    
    NSLog(@"Processing Http Request");
    NSString *cmsToken=[[NSString alloc] initWithFormat:@"%@%@%@",@"\"",__currentToken,@"\""];
    NSMutableURLRequest *request = [NSMutableURLRequest  requestWithURL:__url];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    NSLog(@"Process with URL: %@",[request URL]);
    NSLog(@"Token:%@",cmsToken);
    
    NSLog(@"Timeout Preference Value:%@",appDelegate.globalSettings.networkTimeout);
    [request setTimeoutInterval:[appDelegate.globalSettings.networkTimeout doubleValue ]];
    
    [request setHTTPMethod:__method];
    if (__xmlDoc){
        [request setHTTPBody: __xmlDoc.XMLData];
        [request setValue:@"application/xml" forHTTPHeaderField:@"Content-Type"];
    }else{
        NSLog(@"No Data");
    }
    [request setValue:@"application/xml" forHTTPHeaderField:@"Accept"];
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
            [details setValue:[NSString stringWithFormat:@"%@%d",NSLocalizedString(@"Server Error: ",nil),statusCode]  forKey:NSLocalizedDescriptionKey];
            
            __connectorError =[NSError errorWithDomain:NSLocalizedString(@"Failed",nil) code:statusCode userInfo:details];
            [self.delegate finishedProcessing:self isSuccess:NO withReturnedXml:nil withErrorText:__connectorError.description forUrl:__url withMethod:__method withOriginalRequestXml:__xmlDoc withOpCode:__opCode];
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
    
    [self.delegate finishedProcessing:self isSuccess:NO withReturnedXml:nil withErrorText:__connectorError.description forUrl:__url withMethod:__method withOriginalRequestXml:__xmlDoc withOpCode:__opCode];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading");
    NSLog(@"Succeeded! Received %d bytes of data",[responseData length]);
    GDataXMLDocument *returnedXml =[[GDataXMLDocument alloc]initWithData:responseData encoding:NSUTF8StringEncoding error:nil];
    
#ifdef Trace
    
    NSData *xmlData = returnedXml.XMLData;
    NSString *xmlString = [[NSString alloc]  initWithData:xmlData
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"Received XML:%@",xmlString);
#endif
    
    
    NSArray *errorNodes=[returnedXml nodesForXPath:@"/error/*" error:nil];
    if (errorNodes.count>0)
    {
        NSArray *errorMsgNodes=[returnedXml nodesForXPath:@"/error/message" error:nil];
        NSString *errorMessage=nil;
        if (errorNodes.count>0)
            errorMessage=[(GDataXMLElement *)[errorMsgNodes objectAtIndex:0] stringValue];
        [self.delegate finishedProcessing:self isSuccess:NO  withReturnedXml:returnedXml withErrorText:errorMessage forUrl:__url withMethod:__method withOriginalRequestXml:__xmlDoc withOpCode:__opCode];
    }else{
        [self.delegate finishedProcessing:self isSuccess:YES withReturnedXml:returnedXml withErrorText:nil forUrl:__url withMethod:__method withOriginalRequestXml:__xmlDoc withOpCode:__opCode];
    }
}





#pragma mark getToken Completed

-(void) biConnector:(BIConnector *)biConnector didCreateCmsToken:(NSString *)cmsToken forSession:(Session *)session{
    NSLog (@"Return From Get CMS Token");
    if(cmsToken!=nil){
        NSLog(@"Token Receieved:%@",cmsToken);
        __currentToken=cmsToken;
        
        [self processHttpRequest];
        
    }else if (biConnector.connectorError!=nil){
        __connectorError=biConnector.connectorError ;
        [self.delegate finishedProcessing:self isSuccess:NO withReturnedXml:nil withErrorText:__connectorError.description forUrl:__url withMethod:__method withOriginalRequestXml:__xmlDoc withOpCode:__opCode];
        
    }else if (biConnector.boxiError!=nil){
        __boxiError=biConnector.boxiError;
        
        [self.delegate finishedProcessing:self isSuccess:NO withReturnedXml:nil withErrorText:__boxiError forUrl:__url withMethod:__method withOriginalRequestXml:__xmlDoc withOpCode:__opCode];
        
        
    }else{
        
        [self.delegate finishedProcessing:self isSuccess:NO withReturnedXml:nil withErrorText:NSLocalizedString(@"Server Error", nil) forUrl:__url withMethod:__method withOriginalRequestXml:__xmlDoc withOpCode:__opCode];
        
    }
    
}

@end
