//
//  BISaveDocument.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-10-28.
//  Copyright (c) 2013 APOS Systems. All rights reserved.
//

#import "BISaveDocument.h"
#import "WebiAppDelegate.h"
#import "Document.h"
#import "BI4RestConstants.h"
#import "BILogoff.h"


@implementation BISaveDocument

{
    BIConnector *connector;
    WebiAppDelegate *appDelegate;
    BOOL _isDocument;
    NSDictionary *__webiPrompts;
    Document *__document;
    NSMutableData *responseData;
    
    
}
#pragma mark Save Document

-(void) saveDocument:(Document *)document
{
    
    NSLog(@"Save Document");
    __document=document;
    appDelegate = (id)[[UIApplication sharedApplication] delegate];
    _currentToken=appDelegate.activeSession.cmsToken;
    
    
    if (_currentToken==nil){
        NSLog(@"CMS Token is NULL - create new one");
        connector=[[BIConnector alloc]init];
        connector.delegate=self;
        [connector getCmsTokenWithSession:document.session];
    }else{
        NSLog(@"CMS Token is NOT NULL - Process With Existing Token");
        [self processHttpRequestSaveDocument:__document];
        
    }
    
}

#pragma mark getToken Completed

-(void) biConnector:(BIConnector *)biConnector didCreateCmsToken:(NSString *)cmsToken forSession:(Session *)session{
    NSLog (@"Return From Get CMS Token");
    if(cmsToken!=nil){
        NSLog(@"Token Receieved:%@",cmsToken);
        _currentToken=cmsToken;
        appDelegate.activeSession.cmsToken=cmsToken;
        [self processHttpRequestSaveDocument:__document];
        
        
    }else if (biConnector.connectorError!=nil){
        self.connectorError=biConnector.connectorError ;
        [self.delegate biSaveDocument:self isSuccess:NO withMessage:_connectorError.localizedDescription ];
        
    }else if (biConnector.boxiError!=nil){
        self.boxiError=biConnector.boxiError;
        [self.delegate biSaveDocument:self isSuccess:NO withMessage:_boxiError ];
        
    }else{
        [self.delegate biSaveDocument:self isSuccess:NO withMessage:NSLocalizedString(@"Server Error", nil)];
    }
    
}

# pragma mark Save Document
-(void) processHttpRequestSaveDocument: (Document *) document
{
    
    NSString *cmsToken=[[NSString alloc] initWithFormat:@"%@%@%@",@"\"",self.currentToken,@"\""];
    NSMutableURLRequest *request = [NSMutableURLRequest  requestWithURL:[self getSaveDocumentUrl:document]];
    NSLog(@"Process with URL: %@",[request URL]);
    NSLog(@"Token:%@",cmsToken);
    
    NSLog(@"Timeout Preference Value:%@",appDelegate.globalSettings.networkTimeout);
    [request setTimeoutInterval:[appDelegate.globalSettings.networkTimeout doubleValue ]];
    [request setHTTPMethod:@"PUT"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:cmsToken forHTTPHeaderField:SAP_HTTP_TOKEN];
    
    (void)[[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    
}

# pragma mark getSaveDocument URL

-(NSURL *) getSaveDocumentUrl: (Document *) document{
    NSLog (@"Refresh Document URL For Report id:%@",document.id);
    NSURL *saveDocumentUrl;
    
    NSString *host=[NSString stringWithFormat: @"%@:%@",appDelegate.activeSession.cmsName,appDelegate.activeSession.port] ;
    if ([appDelegate.activeSession.isHttps integerValue]==1){
        saveDocumentUrl=[[NSURL alloc]initWithScheme:@"https" host:host path:[NSString stringWithFormat:@"%@%@%@%@",appDelegate.activeSession.webiRestSDKBase,getDocumentsPathPoint,@"/",[document.id stringValue]]];
    }
    else{
        saveDocumentUrl=[[NSURL alloc]initWithScheme:@"http" host:host path:[NSString stringWithFormat:@"%@%@%@%@",appDelegate.activeSession.webiRestSDKBase,getDocumentsPathPoint,@"/",[document.id stringValue]]];
        
    }
    NSLog(@"URL:%@",saveDocumentUrl);
    return  saveDocumentUrl;
}

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
            [connector getCmsTokenWithSession:appDelegate.activeSession];
            
        }
        else if (statusCode  !=200 && statusCode  !=500)
        {
            [connection cancel];  // stop connecting; no more delegate messages
            NSLog(@"didReceiveResponse statusCode with %i", statusCode);
            
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:[NSString stringWithFormat:@"%@%d",NSLocalizedString(@"Server Error: ",nil),statusCode]  forKey:NSLocalizedDescriptionKey];
            
            _connectorError =[NSError errorWithDomain:@"Failed" code:statusCode userInfo:details];
            [self.delegate biSaveDocument:self isSuccess:NO withMessage:_connectorError.localizedDescription];
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
    _connectorError =[[NSError alloc] init];
    _connectorError=error;
    [self.delegate biSaveDocument:self isSuccess:NO withMessage:_connectorError.localizedDescription];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Save Document: connectionDidFinishLoading");
    NSLog(@"Save Document Succeeded! Received %d bytes of data",[responseData length]);
    
    NSString *receivedString = [[NSString alloc]  initWithData:responseData
                                                      encoding:NSUTF8StringEncoding];
    
#ifdef Trace
    int length=([receivedString length])<MAX_DISPLAY_HTTP_STRING?[receivedString length]:MAX_DISPLAY_HTTP_STRING;
    NSLog(@"Save Document Data:%@%@",[receivedString substringToIndex:length],@"..." );
#endif
    
    BOOL isSucess=YES;
    NSString *message=[[NSString alloc]init];
    // convert to JSON
    NSError *myError = nil;
    NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&myError];
    
    NSLog(@"Result:%@",responseDic);
    NSLog(@"All keys:%@",[responseDic allKeys]);
    
    
    if ([[responseDic allKeys] containsObject:JSON_RESP_ERROR_CODE]){
        _boxiError=[responseDic objectForKey:JSON_RESP_ERROR_MESSAGE];
        message=   [responseDic objectForKey:@"message"];
        isSucess=NO;
    }
    else{
        responseDic=[responseDic objectForKey:@"success"];
        if ([responseDic isKindOfClass:[NSDictionary class]]){
            message=   [responseDic objectForKey:@"message"];
        }
        
    }
    
    
    if ([_boxiError isEqualToString:BOXI_TOKEN_ERROR]){
        NSLog(@"Token Expired - Create new One and try again");
        connector=[[BIConnector alloc]init];
        connector.delegate=self;
        [connector getCmsTokenWithSession:appDelegate.activeSession];
    }else{
        [self.delegate biSaveDocument:self isSuccess:isSucess withMessage:message];
    }
    
    
    
    
    [self logoOffIfNeeded];
}

-(void) logoOffIfNeeded{
    if ([appDelegate.globalSettings.autoLogoff integerValue]==1){
        if (appDelegate.activeSession!=nil && appDelegate.activeSession.cmsToken!=nil){
            [self logoffWithSession:appDelegate.activeSession];
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
