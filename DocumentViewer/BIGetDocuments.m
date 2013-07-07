//
//  BIGetDocuments.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-02-22.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import "BIGetDocuments.h"
#import "BI4RestConstants.h"
#import "Document.h"
#import "WebiAppDelegate.h"
#import "BILogoff.h"
#import "GlobalPreferencesConstants.h"

@implementation BIGetDocuments

{
    BOOL isUseCache;
    BIConnector *_connector;
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



#pragma mark getDocuments for Session

-(void)getDocumentsForSession:(Session *)session withLimit:(int)newLimit withOffset:(int)newOffset{
    
    NSLog (@"Get Documents for Session %@ Started",session.name);
    isUseCache=YES;
    appDelegate = (id)[[UIApplication sharedApplication] delegate];
    self.currentToken=session.cmsToken;
    
    self.biSession=session;
    self.limit=newLimit;
    self.offset=newOffset;
    // Get Token First
    if (session.cmsToken==nil || session.password==nil){
        NSLog(@"CMS Token is NULL - create new one");
        //        BIConnector *connector=[[BIConnector alloc]init];
        _connector=[[BIConnector alloc]init];
        _connector.delegate=self;
        [_connector getCmsTokenWithSession:session];
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
        [self.delegate biGetDocuments:self isSuccess:NO documents:nil];
        
    }else if (biConnector.boxiError!=nil){
        self.boxiError=biConnector.boxiError;
        [self.delegate biGetDocuments:self isSuccess:NO documents:nil];
        
    }else{
        [self.delegate biGetDocuments:self isSuccess:NO documents:nil];
    }
    
}

# pragma mark Get Documents

-(void) processHttpRequestForSession: (Session*) session{
    NSLog(@"Get Documents processHttpRequestForSession");
    self.biSession=session;
    //    NSString *cmsToken=[[NSString alloc] initWithFormat:@"%@%@%@",@"\"",session.cmsToken,@"\""];
    NSString *cmsToken=[[NSString alloc] initWithFormat:@"%@%@%@",@"\"",self.currentToken,@"\""];
    isUseCache=NO;
    
    NSMutableURLRequest *request = [NSMutableURLRequest  requestWithURL:[self getDocumentsURL:session]];
    //    if (isUseCache){
    //        NSLog(@"Use Cache");
    //        [request setCachePolicy:NSURLRequestUseProtocolCachePolicy];
    //    }
    //    else{
    //        NSLog(@"Ignore Cache");
    //        [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    //    }
    NSLog(@"Process with URL: %@",[request URL]);
    NSLog(@"Token:%@",cmsToken);
    
    
    NSLog(@"Timeout Preference Value:%@",appDelegate.globalSettings.networkTimeout);
    [request setTimeoutInterval:[appDelegate.globalSettings.networkTimeout doubleValue ]];
    
    
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    //    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:cmsToken forHTTPHeaderField:SAP_HTTP_TOKEN];
    [request setValue:[NSString stringWithFormat:@"%d", self.offset]  forHTTPHeaderField:HEADER_SAP_OFFSET];
    [request setValue:[NSString stringWithFormat:@"%d", self.limit]  forHTTPHeaderField:HEADER_SAP_LIMIT];
    //    [request setValue:[NSString stringWithFormat:@"%d", 0] forHTTPHeaderField:@"Content-Length"];
    (void)[[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}

# pragma mark getDocuments URL

-(NSURL *) getDocumentsURL: (Session *) session {
    NSLog (@"GetDocuments URL Session Name:%@",session);
    NSURL *getDocumentsURL;
    NSString *host=[NSString stringWithFormat: @"%@:%@",session.cmsName,session.port] ;
    if ([session.isHttps integerValue]==1){
        getDocumentsURL=[[NSURL alloc]initWithScheme:@"https" host:host path:[NSString stringWithFormat:@"%@%@",session.webiRestSDKBase,getDocumentsPathPoint]];
    }
    else{
        getDocumentsURL=[[NSURL alloc]initWithScheme:@"http" host:host path:[NSString stringWithFormat:@"%@%@",session.webiRestSDKBase,getDocumentsPathPoint]];
    }
    NSLog(@"URL:%@",getDocumentsURL);
    NSString *urlString=  [[NSString alloc] initWithFormat:@"%@%@%d%@%d", [getDocumentsURL absoluteString],@"?limit=",self.limit,@"&offset=",self.offset];
    
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
            [details setValue:[NSString stringWithFormat:@"%@%d",NSLocalizedString(@"Server Error:",nil),statusCode]  forKey:NSLocalizedDescriptionKey];
            
            connectorError =[NSError errorWithDomain:NSLocalizedString(@"Failed",nil) code:statusCode userInfo:details];
            [self.delegate biGetDocuments:self isSuccess:NO documents:nil] ;
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
    [self.delegate biGetDocuments:self isSuccess:NO documents:nil] ;
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
    
    NSMutableArray *documents=[[NSMutableArray alloc] init];
    
    
    
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
            
            responseDic=[responseDic objectForKey:@"documents"];
            
            if ([responseDic isKindOfClass:[NSDictionary class]]){
                NSLog(@"All keys:%@",[responseDic allKeys]);
                
                
                if ([[responseDic objectForKey:@"document"] isKindOfClass:[NSArray class]]){
                    NSArray *docs=[responseDic objectForKey:@"document"];
                    
                    for (NSDictionary *doc in docs) {
                        
                        NSLog(@"Id:%@",[doc objectForKey:@"id"]);
                        Document *document=[self setDocumentProperties:doc];
                        NSLog(@"Document Name:%@, Description:%@",document.name,document.descriptiontext);
                        [documents addObject:document];
                        isUseCache=YES;
                        
                        
                    }
                }else{
                    NSDictionary *doc=[responseDic objectForKey:@"document"];
                    NSLog(@"Id:%@",[doc objectForKey:@"id"]);
                    Document *document=[self setDocumentProperties:doc];
                    [documents addObject:document];
                    isUseCache=YES;
                    
                    
                }
                
                //                NSArray *existingDocs=[[NSArray alloc]initWithArray:[[biSession documents] allObjects]];
                //                NSMutableArray *tempArray=[[NSMutableArray alloc] initWithArray:temps];
                //
                
                //                [tempArray addObjectsFromArray:temps];
                
                biSession.documents=[NSSet setWithArray:documents];
                //                biSession.documents=[NSSet setWithArray:resultDocArray];
                //                NSLog(@"Added %d documents. Current Number of documents in session %d",newDocArray.count,biSession.documents.count);
                
            }
        }
        
    }
    
    if ([self.boxiError isEqualToString:BOXI_TOKEN_ERROR]){
        NSLog(@"Token Expired - Create new One and try again");
        isUseCache=NO;
        BIConnector *connector=[[BIConnector alloc]init];
        connector.delegate=self;
        [connector getCmsTokenWithSession:self.biSession];
    }else{
        [self.delegate biGetDocuments:self isSuccess:isSucess documents:documents];
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
-(Document *) setDocumentProperties:  (NSDictionary *) doc {
    Document *document = [NSEntityDescription
                          insertNewObjectForEntityForName:@"Document"
                          inManagedObjectContext:context];
    document.session=biSession;
    document.id=[doc objectForKey:@"id"];
    document.name=[doc objectForKey:@"name"];
    document.state=[doc objectForKey:@"state"];
    document.cuid=[doc objectForKey:@"cuid"];
    document.folderid=[doc objectForKey:@"folderId"];
    if ([doc objectForKey:@"description"]!=nil) document.descriptiontext=[doc objectForKey:@"description"];
    return document;
    
}


@end
