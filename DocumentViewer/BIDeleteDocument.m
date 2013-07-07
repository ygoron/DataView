//
//  BIDeleteDocument.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-03-23.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import "BIDeleteDocument.h"
#import "ScheduleDetails.h"
#import "Document.h"
#import "BI4RestConstants.h"
#import "DeleteStatus.h"
#import "WebiAppDelegate.h"
#import "BILogoff.h"

@implementation BIDeleteDocument
{
    WebiAppDelegate *appDelegate;
}

@synthesize connectorError;
@synthesize boxiError;
@synthesize delegate;
@synthesize biSession;
@synthesize context;
@synthesize currentToken;


#pragma mark DeleteDocument

-(void)deleteDocument:(int)docId withSession:(Session *)session{
    
    NSLog (@"Delete Document %d Started",docId);
    
    self.biSession=session;
    appDelegate = (id)[[UIApplication sharedApplication] delegate];
    self.currentToken=session.cmsToken;

    
    _docId=docId;
    _isInstance=NO;
    // Get Token First
    if (session.cmsToken==nil){
        NSLog(@"CMS Token is NULL - create new one");
        BIConnector *connector=[[BIConnector alloc]init];
        connector.delegate=self;
        [connector getCmsTokenWithSession:session];
    }else{
        NSLog(@"CMS Token is NOT NULL - Process With Existing Token");
        [self processHttpRequestForDocument:docId];
        
    }
    
    
}
-(void) deleteScheduledInstance:(ScheduleDetails *)instance forDocumentId:(int)docId withSession:(Session *)session
{
    
    NSLog (@"Delete Document Instance %d Started",instance.scheduleId);
    
    self.biSession=session;
    appDelegate = (id)[[UIApplication sharedApplication] delegate];
    self.currentToken=session.cmsToken;

    _docId=docId;
    _isInstance=YES;
    _instanceId=instance.scheduleId;
    // Get Token First
    if (session.cmsToken==nil){
        NSLog(@"CMS Token is NULL - create new one");
        BIConnector *connector=[[BIConnector alloc]init];
        connector.delegate=self;
        [connector getCmsTokenWithSession:session];
    }else{
        NSLog(@"CMS Token is NOT NULL - Process With Existing Token");
        [self processHttpRequestForInstance:_instanceId forDocId:_docId];
        
    }
    
    
}

#pragma mark Token Created

-(void) biConnector:(BIConnector *)biConnector didCreateCmsToken:(NSString *)cmsToken forSession:(Session *)session{
    NSLog (@"Return From Get CMS Token");
    if(cmsToken!=nil){
        NSLog(@"Token Receieved:%@",cmsToken);
        self.currentToken=cmsToken;
        if (_isInstance==YES) [self processHttpRequestForInstance:_instanceId forDocId:_docId];
        else [self processHttpRequestForDocument:_docId];
        
    }else if (biConnector.connectorError!=nil){
        self.connectorError=biConnector.connectorError ;
        DeleteStatus *deleteStatus=[[DeleteStatus alloc] init];
        deleteStatus.code=biConnector.connectorError.code;
        deleteStatus.message=[biConnector.connectorError localizedDescription];
        [self.delegate biDeleteDocument:self isSuccess:NO withDeleteStatus:deleteStatus];
        
    }else if (biConnector.boxiError!=nil){
        self.boxiError=biConnector.boxiError;
        DeleteStatus *deleteStatus=[[DeleteStatus alloc] init];
        deleteStatus.code=-1;
        deleteStatus.message=biConnector.boxiError;
        [self.delegate biDeleteDocument:self isSuccess:NO  withDeleteStatus:deleteStatus];
        
    }else{
        DeleteStatus *deleteStatus=[[DeleteStatus alloc] init];
        deleteStatus.code=biConnector.connectorError.code;
        deleteStatus.message=[biConnector.connectorError localizedDescription];
        [self.delegate biDeleteDocument:self isSuccess:NO withDeleteStatus:deleteStatus];
    }
    
}


# pragma mark delete instances

-(void) processHttpRequestForInstance: (int) instanceId forDocId:(int) docId {
    NSLog(@"Delete Instance processHttpRequestForSession");
//    NSString *cmsToken=[[NSString alloc] initWithFormat:@"%@%@%@",@"\"",self.biSession.cmsToken,@"\""];
    NSString *cmsToken=[[NSString alloc] initWithFormat:@"%@%@%@",@"\"",self.currentToken,@"\""];
    
    NSMutableURLRequest *request = [NSMutableURLRequest  requestWithURL:[self getDeleteInstancetUrl:instanceId forDocId:docId]];
    NSLog(@"Process with URL: %@",[request URL]);
    NSLog(@"Token:%@",cmsToken);
    
    [request setHTTPMethod:@"DELETE"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:cmsToken forHTTPHeaderField:SAP_HTTP_TOKEN];
    (void)[[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}

# pragma mark delete documents

-(void) processHttpRequestForDocument: (int) docId{
    NSLog(@"Delete Documents processHttpRequestForSession");
    NSString *cmsToken=[[NSString alloc] initWithFormat:@"%@%@%@",@"\"",self.biSession.cmsToken,@"\""];
    
    NSMutableURLRequest *request = [NSMutableURLRequest  requestWithURL:[self getDeleteDocumentUrl:docId]];
    NSLog(@"Process with URL: %@",[request URL]);
    NSLog(@"Token:%@",cmsToken);
    
    NSLog(@"Timeout Preference Value:%@",appDelegate.globalSettings.networkTimeout);
    [request setTimeoutInterval:[appDelegate.globalSettings.networkTimeout doubleValue ]];

    [request setHTTPMethod:@"DELETE"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:cmsToken forHTTPHeaderField:SAP_HTTP_TOKEN];
    (void)[[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}

# pragma mark delete Instance URL

-(NSURL *) getDeleteInstancetUrl: (int) instanceId forDocId:(int) docId{
    NSLog (@"Delete Instance %d, URL For Document id:%d",instanceId,docId);
    NSURL *deletDocumentURL;
    NSString *host=[NSString stringWithFormat: @"%@:%@",self.biSession.cmsName,self.biSession.port] ;
    if ([self.biSession.isHttps integerValue]==1){
        deletDocumentURL=[[NSURL alloc]initWithScheme:@"https" host:host path:[NSString stringWithFormat:@"%@%@%@%d%@%d",self.biSession.webiRestSDKBase,getDocumentsPathPoint,@"/",docId,@"/schedules/",instanceId]];
    }
    else{
        deletDocumentURL=[[NSURL alloc]initWithScheme:@"http" host:host path:[NSString stringWithFormat:@"%@%@%@%d%@%d",self.biSession.webiRestSDKBase,getDocumentsPathPoint,@"/",docId,@"/schedules/",instanceId]];
    }
    NSLog(@"URL:%@",deletDocumentURL);
    return  deletDocumentURL;
}


# pragma mark delete Documents URL

-(NSURL *) getDeleteDocumentUrl: (int) docId{
    NSLog (@"Delete Document URL For Document id:%d",docId);
    NSURL *deletDocumentURL;
    NSString *host=[NSString stringWithFormat: @"%@:%@",self.biSession.cmsName,self.biSession.port] ;
    if ([self.biSession.isHttps integerValue]==1){
        deletDocumentURL=[[NSURL alloc]initWithScheme:@"https" host:host path:[NSString stringWithFormat:@"%@%@%@%d",self.biSession.webiRestSDKBase,getDocumentsPathPoint,@"/",docId]];
    }
    else{
        deletDocumentURL=[[NSURL alloc]initWithScheme:@"http" host:host path:[NSString stringWithFormat:@"%@%@%@%d",self.biSession.webiRestSDKBase,getDocumentsPathPoint,@"/",docId]];
    }
    NSLog(@"URL:%@",deletDocumentURL);
    return  deletDocumentURL;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"didReceiveResponse from URL %@",[response URL]);
    
    if ([response respondsToSelector:@selector(statusCode)])
    {
        //        int statusCode = [((NSHTTPURLResponse *)response) statusCode];
        responseData = [[NSMutableData alloc] init];
        //        if (statusCode  ==404)
        //        {
        //            [connection cancel];  // stop connecting; no more delegate messages
        //            NSLog(@"didReceiveResponse statusCode with %i", statusCode);
        //
        //            NSMutableDictionary* details = [NSMutableDictionary dictionary];
        //            [details setValue:[NSString stringWithFormat:@"%@%d",@"Server Error: ",statusCode]  forKey:NSLocalizedDescriptionKey];
        //
        //            connectorError =[NSError errorWithDomain:@"Failed" code:statusCode userInfo:details];
        //
        //            DeleteStatus *deleteStatus=[[DeleteStatus alloc] init];
        //            deleteStatus.code=statusCode;
        //            deleteStatus.message=[connectorError localizedDescription];
        //            [self.delegate biDeleteDocument:self isSuccess:NO withDeleteStatus:deleteStatus];
        //        }
        //        else{
        //            responseData = [[NSMutableData alloc] init];
        //        }
        
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
    DeleteStatus *deleteStatus=[[DeleteStatus alloc] init];
    deleteStatus.code=[error code];
    deleteStatus.message=[connectorError localizedDescription];
    [self.delegate biDeleteDocument:self isSuccess:NO withDeleteStatus:deleteStatus];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading");
    NSLog(@"Succeeded! Received %d bytes of data",[responseData length]);
#ifdef Trace
    NSString *receivedString = [[NSString alloc]  initWithData:responseData
                                                      encoding:NSUTF8StringEncoding];
    int length=([receivedString length])<MAX_DISPLAY_HTTP_STRING?[receivedString length]:MAX_DISPLAY_HTTP_STRING;
#endif
    
    if(_isInstance==YES)
        NSLog(@"Delete Instance  Data:%@%@",[receivedString substringToIndex:length],@"..." );
    else
        NSLog(@"Delete Document  Data:%@%@",[receivedString substringToIndex:length],@"..." );
    
    BOOL isSucess=YES;
    
    // convert to JSON
    NSError *myError = nil;
    NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&myError];
    
    
    NSLog(@"Result:%@",responseDic);
    NSLog(@"All keys:%@",[responseDic allKeys]);
    DeleteStatus *deleteStatus= [[DeleteStatus alloc]init];
    
    if ([[responseDic allKeys] containsObject:JSON_RESP_ERROR_CODE]){
        NSLog(@"Error Code Found");
        self.boxiError=[responseDic objectForKey:JSON_RESP_ERROR_MESSAGE];
        deleteStatus.message=self.boxiError;
        deleteStatus.code=[[responseDic objectForKey:JSON_RESP_ERROR_CODE] integerValue];
        
        isSucess=NO;
    }
    else{
        self.boxiError=nil;
        
        responseDic=[responseDic objectForKey:@"success"];
        if (responseDic!=nil){
            if ([responseDic isKindOfClass:[NSDictionary class]]){
                NSLog(@"All keys:%@",[responseDic allKeys]);
                deleteStatus.message=[responseDic objectForKey:@"message"];
                deleteStatus.code=0;
                isSucess=YES;
            }
            
        }else{
            deleteStatus.code=-1;
            deleteStatus.message=NSLocalizedString(@"Failed to delete document",nil);
            isSucess=NO;
        }
        
        
    }
    
    if ([self.boxiError isEqualToString:BOXI_TOKEN_ERROR] ){
        NSLog(@"Token Expired - Create new One and try again");
        BIConnector *connector=[[BIConnector alloc]init];
        connector.delegate=self;
        [connector getCmsTokenWithSession:self.biSession];
    }else{
        [self.delegate biDeleteDocument:self isSuccess:isSucess withDeleteStatus:deleteStatus];
        [self logoOffIfNeeded];
    }
    

}

-(void) logoOffIfNeeded{
    NSLog(@"AutoLogoff Value:%d",[appDelegate.globalSettings.autoLogoff integerValue]);
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
        session.cmsToken=nil;
        NSLog(@"Logoff Session:%@",session.name);
    }
    
    
}



@end
