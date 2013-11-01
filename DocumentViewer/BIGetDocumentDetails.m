//
//  BIGetDocumentDetails.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-02-26.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import "BIGetDocumentDetails.h"
#import "Document.h"
#import "Session.h"
#import "BI4RestConstants.h"
#import "WebiAppDelegate.h"
#import "BILogoff.h"


@implementation BIGetDocumentDetails
{
    BIConnector *connector;
    WebiAppDelegate *appDelegate;
}
@synthesize connectorError;
@synthesize boxiError;
@synthesize delegate;
@synthesize biSession;
@synthesize context;
@synthesize isInstance;


# pragma mark getDocumentDetailsForDocument

-(id) init{
    if ((self = [super init])) {
        self.isInstance=NO;
    }
    return self;
}
-(void) getDocumentDetailForDocument:(Document *)document withToken:(NSString *)cmsToken
{
    self.currentToken=cmsToken;
    self.biSession=document.session;
    self.document=document;
    self.document.session.cmsToken=cmsToken;
    self.biSession.cmsToken=cmsToken;
    appDelegate = (id)[[UIApplication sharedApplication] delegate];
    
    
    if (isInstance==NO){
        [self processHttpRequestForSession:document];
    }else{
        [self.delegate biGetDocumentDetails:self isSuccess:YES document:self.document];
    }
    
}
-(void) getDocumentDetailForDocument:(Document *)document{
    
    NSLog (@"Get Documents for Session Started. Document id %@,name%@ session:%@",document.id,document.name,document.session.name);
    appDelegate = (id)[[UIApplication sharedApplication] delegate];
    self.currentToken=document.session.cmsToken;
    
    self.biSession=document.session;
    self.document=document;
    if (isInstance==NO){
        // Get Token First
        if (self.biSession.cmsToken==nil || [appDelegate.globalSettings.autoLogoff boolValue]==YES){
            NSLog(@"CMS Token is NULL - create new one");
            connector=[[BIConnector alloc]init];
            connector.delegate=self;
            [connector getCmsTokenWithSession:self.biSession];
        }else{
            NSLog(@"CMS Token is NOT NULL - Process With Existing Token");
            [self processHttpRequestForSession:document];
            
        }
    }else{
        [self.delegate biGetDocumentDetails:self isSuccess:YES document:self.document];
    }
    
    
}

#pragma mark Updated Token (if neccessary)

-(void) biConnector:(BIConnector *)biConnector didCreateCmsToken:(NSString *)cmsToken forSession:(Session *)session{
    NSLog (@"Return From Get CMS Token");
    if(cmsToken!=nil){
        NSLog(@"Token Receieved:%@",cmsToken);
        self.currentToken=cmsToken;
        self.document.session.cmsToken=cmsToken;
        self.biSession.cmsToken=cmsToken;
        [self processHttpRequestForSession:self.document];
        
    }else if (biConnector.connectorError!=nil){
        self.connectorError=biConnector.connectorError ;
        [self.delegate biGetDocumentDetails:self isSuccess:NO document:nil];
        
    }else if (biConnector.boxiError!=nil){
        self.boxiError=biConnector.boxiError;
        [self.delegate biGetDocumentDetails:self isSuccess:NO document:nil];
        
    }else{
        [self.delegate biGetDocumentDetails:self isSuccess:NO document:nil];
    }
    
}

-(void) processHttpRequestForSession: (Document*) document{
    NSLog(@"GetDocument Details processHttpRequestForSession");
    self.biSession=document.session;
    //    NSString *cmsToken=[[NSString alloc] initWithFormat:@"%@%@%@",@"\"",document.session.cmsToken,@"\""];
    NSString *cmsToken=[[NSString alloc] initWithFormat:@"%@%@%@",@"\"",self.currentToken,@"\""];
    NSMutableURLRequest *request = [NSMutableURLRequest  requestWithURL:[self getDocumentsURL:document]];
    NSLog(@"Process with URL: %@",[request URL]);
    NSLog(@"Token:%@",cmsToken);
    
    NSLog(@"Timeout Preference Value:%@",appDelegate.globalSettings.networkTimeout);
    [request setTimeoutInterval:[appDelegate.globalSettings.networkTimeout doubleValue ]];
    
    [request setHTTPMethod:@"GET"];
    NSLog(@"Getting Document Details");
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:cmsToken forHTTPHeaderField:SAP_HTTP_TOKEN];
    (void)[[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}

# pragma mark getDocuments URL

-(NSURL *) getDocumentsURL: (Document *) document{
    NSLog (@"GetDocuments URL For Document id:%@",document.id);
    NSURL *getDocumentsURL;
    NSString *host=[NSString stringWithFormat: @"%@:%@",document.session.cmsName,document.session.port] ;
    if ([document.session.isHttps integerValue]==1){
        getDocumentsURL=[[NSURL alloc]initWithScheme:@"https" host:host path:[NSString stringWithFormat:@"%@%@%@%@",document.session.webiRestSDKBase,getDocumentsPathPoint,@"/",document.id]];
    }
    else{
        getDocumentsURL=[[NSURL alloc]initWithScheme:@"http" host:host path:[NSString stringWithFormat:@"%@%@%@%@",document.session.webiRestSDKBase,getDocumentsPathPoint,@"/",document.id]];
    }
    NSLog(@"URL:%@",getDocumentsURL);
    return  getDocumentsURL;
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
            [details setValue:[NSString stringWithFormat:@"%@%d",NSLocalizedString(@"Server Error:",nil),statusCode]  forKey:NSLocalizedDescriptionKey];
            NSLog(@"Description:%@",[details description]);
            connectorError =[NSError errorWithDomain:@"Failed" code:statusCode userInfo:details];
            [self.delegate biGetDocumentDetails:self isSuccess:NO document:nil] ;
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
    [self.delegate biGetDocumentDetails:self isSuccess:NO document:nil] ;
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
    
    
    if ([[responseDic allKeys] containsObject:JSON_RESP_ERROR_CODE]){
        self.boxiError=[responseDic objectForKey:JSON_RESP_ERROR_MESSAGE];
        isSucess=NO;
    }
    else{
        self.boxiError=nil;
        responseDic=[responseDic objectForKey:@"document"];
        
        NSLog(@"Id:%@",[responseDic objectForKey:@"id"]);
        self.document.createdby=[responseDic objectForKey:@"createdBy"];
        self.document.cuid=[responseDic objectForKey:@"cuid"];
        self.document.folderid=[responseDic objectForKey:@"folderId"];
        self.document.id=[responseDic objectForKey:@"id"];
        self.document.lastauthor=[responseDic objectForKey:@"lastAuthor"];
        self.document.name=[responseDic objectForKey:@"name"];
        self.document.path=[responseDic objectForKey:@"path"];
        self.document.refreshonopen=[responseDic objectForKey:@"refreshOnOpen"];
        self.document.scheduled=[responseDic objectForKey:@"scheduled"];
        self.document.size=[responseDic objectForKey:@"size"];
        self.document.state=[responseDic objectForKey:@"state"];
        
        NSDateFormatter *dateFormtter=[[NSDateFormatter alloc] init];
        [dateFormtter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSzzzz"];
        self.document.updated=[dateFormtter dateFromString:[responseDic objectForKey:@"updated"]];
        NSLog(@"Date:%@",self.document.updated);
        
        
    }
    
    if ([self.boxiError isEqualToString:BOXI_TOKEN_ERROR]){
        NSLog(@"Token Expired - Create new One and try again");
        connector=[[BIConnector alloc]init];
        connector.delegate=self;
        [connector getCmsTokenWithSession:self.biSession];
    }else{
        [self.delegate biGetDocumentDetails:self isSuccess:YES document:self.document];
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
