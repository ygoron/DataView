//
//  MobileBIService.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-09-01.
//  Copyright (c) 2013 APOS Systems. All rights reserved.
//

#import "MobileBIService.h"
#import "Session.h"
#import "WebiAppDelegate.h"
#import "BI4RestConstants.h"
#import "MobileSession.h"
#import "NSData+Base64.h"
#import "SSZipArchive.h"


@implementation MobileBIService

{
    NSMutableData *responseData;
    NSURL *baseMobilServiceUrl;
    int functionCode;
    MobileSession *mobileSession;
    NSMutableString *currentStringValue;
    NSString *mobileSessionStatus;
}


-(void) initMobileWithSession:(Session *)session
{
    NSURL *logonUrl = [self getMobileServiceUrlWithSession:session];
    functionCode=MOBILE_FUNCTION_LOGON;
    
    NSString *device =[self getDevice];
    
    NSString *bodyString=[[NSString alloc] initWithFormat:@"requestSrc=%@&data=<LogonCredentials username=\"%@\" password=\"%@\" cms=\"%@\" auth=\"%@\" fetchUserInfo=\"true\" fetchSerializedSession=\"true\" lang=\"en\" />&message=CredentialsMessage",device,session.userName,session.password,session.cmsName,session.authType];
    
    NSLog(@"Data to Send:%@",bodyString);
    
    NSData *httpBody=[bodyString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc] initWithURL:logonUrl];
    
    WebiAppDelegate *appDelegate = (id)[[UIApplication sharedApplication] delegate];
    appDelegate.mobileService=self;
    [request setTimeoutInterval:[appDelegate.globalSettings.networkTimeout doubleValue ]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:httpBody];
    
    (void)[[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    
}

-(void) getDashboardWithCUID:(NSString *)cuid WithMobileSession:(MobileSession *)currentMobileSession
{
    functionCode=MOBILE_FUNCTION_GET_DASHBOARD;
    
    if (mobileSession!=nil){
        
        NSString *tempUrl=[[NSString alloc] initWithFormat:@"%@%@",[baseMobilServiceUrl absoluteString],@"?handler=Xcelsius"];
        NSURL *newUrl=[[NSURL alloc] initWithString:tempUrl];
        
        NSString *device =[self getDevice];
        NSString *bodyString=[[NSString alloc] initWithFormat:@"requestSrc=%@&data=<artifact id=\"%@\" outputDataType=\"PDF\" freshCopy=\"true\" fetchLatestInstance=\"false\" />&message=GetRawDocumentContentMessage&handler=Xcelsius",device,cuid];
        
        NSData *httpBody=[bodyString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSMutableURLRequest *request=[[NSMutableURLRequest alloc] initWithURL:newUrl];
        
        WebiAppDelegate *appDelegate = (id)[[UIApplication sharedApplication] delegate];
        appDelegate.mobileService=self;
        [request setTimeoutInterval:[appDelegate.globalSettings.networkTimeout doubleValue ]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
        [request setHTTPBody:httpBody];
        
        (void)[[NSURLConnection alloc] initWithRequest:request delegate:self];
        
        
        
    }else{
        [_delegate DashboardReceived:self isSuccess:NO WithFileLocation:nil WithError:NSLocalizedString(@"Failed", nil) WithZipFile:nil WithFolder:nil];
        NSLog(@"Mobile Session is nil");
    }
}
-(NSString *) getDevice
{
    UIUserInterfaceIdiom idiom = [[UIDevice currentDevice] userInterfaceIdiom];
    NSString *device;
    if (idiom == UIUserInterfaceIdiomPad) {
        device=@"ipad";
    }else{
        device=@"iphone";
    }
    return device;
}
-(NSURL *) getMobileServiceUrlWithSession: (Session *) session
{
    
    NSURL *url;
    NSString *host=[NSString stringWithFormat: @"%@:%@",session.cmsName,session.mobileBIServicePort] ;
    NSLog(@"Host:%@",host);
    
    if ([session.isHttps integerValue]==1){
        url=[[NSURL alloc]initWithScheme:@"https" host:host path:[NSString stringWithFormat:@"%@",session.mobileBIServiceBase]];
    }
    else{
        url=[[NSURL alloc]initWithScheme:@"http" host:host path:[NSString stringWithFormat:@"%@",session.mobileBIServiceBase]];
    }
    NSLog(@"URL:%@",url);
    
    baseMobilServiceUrl=url;
    return url;
    
}
-(void) mobileLogoff

{
    functionCode=MOBILE_FUNCTION_LOGOFF;
    NSString *device =[self getDevice];
    NSString *bodyString=[[NSString alloc] initWithFormat:@"requestSrc=%@&data=<LogoffMessage />&message=LogoffMessage",device];
    
    NSLog(@"Data to Send:%@",bodyString);
    
    NSData *httpBody=[bodyString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc] initWithURL:baseMobilServiceUrl];
    
    WebiAppDelegate *appDelegate = (id)[[UIApplication sharedApplication] delegate];
    
    [request setTimeoutInterval:[appDelegate.globalSettings.networkTimeout doubleValue ]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:httpBody];
    
    (void)[[NSURLConnection alloc] initWithRequest:request delegate:self];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"didReceiveResponse from URL %@",[response URL]);
    
    if ([response respondsToSelector:@selector(statusCode)])
    {
        _statusCode = [((NSHTTPURLResponse *)response) statusCode];
        responseData = [[NSMutableData alloc] init];
        
        
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"BI Mobile Service Call didFailWithError %@",[error localizedDescription]);
    _connectorError =[[NSError alloc] init];
    _connectorError=error;
    [_delegate sessionReceived:self isSuccess:NO WithMobileSession:nil];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connectionDidFinishLoading");
    NSLog(@"Succeeded! Received %d bytes of data",[responseData length]);
    
    NSString *receivedString = [[NSString alloc]  initWithData:responseData
                                                      encoding:NSUTF8StringEncoding];
    //    int length=([receivedString length])<MAX_DISPLAY_HTTP_STRING?[receivedString length]:MAX_DISPLAY_HTTP_STRING;
    NSLog(@"Mobile Service Data:%@",receivedString);
    if (functionCode== MOBILE_FUNCTION_LOGON){
        
        NSXMLParser *xmlParser=[[NSXMLParser alloc] initWithData:responseData];
        
        [xmlParser setDelegate:self];
        BOOL isParseSuccess=[xmlParser parse];
        NSLog(@"Is Parse Success:%d",isParseSuccess);
        if ([mobileSessionStatus isEqualToString:@"success"]){
            [_delegate sessionReceived:self isSuccess:YES WithMobileSession:mobileSession];
            
        }else
            
            [_delegate sessionReceived:self isSuccess:NO WithMobileSession:nil];
        
    }
    else if (functionCode==MOBILE_FUNCTION_LOGOFF)
        [_delegate logoffCompleted:self isSuccess:YES];
    
    else if (functionCode==MOBILE_FUNCTION_GET_DASHBOARD){
        NSLog(@"Process Get DashBoard");
        
        NSString *zipFile ;
        NSArray *paths =       NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
        NSString *documentsPath = [paths objectAtIndex:0];
        NSError *error;
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        zipFile = [documentsPath stringByAppendingPathComponent:@"dashboard.zip"];
        NSString *dashboardFolder = [documentsPath stringByAppendingPathComponent:@"dashboard"];
        NSString *htmlFile=@"dashboard.html";
        
        
        if (zipFile!=nil){
            if([fileMgr fileExistsAtPath:zipFile]) {
                NSLog(@"File Exist:%@",zipFile);
                if ([fileMgr removeItemAtPath:zipFile error:&error] != YES){
                    NSLog(@"Unable to delete file: %@%@", zipFile,[error localizedDescription]);
                    [_delegate DashboardReceived:self isSuccess:NO WithFileLocation:nil WithError:[error localizedDescription] WithZipFile:nil WithFolder:nil];
                }
                else{
                    NSLog(@"File %@ - deleted",zipFile);
                    
                }
            }else{
                NSLog(@"File does not exist:%@",zipFile);
            }
        }
        
        error=nil;
        
        //        [responseData writeToFile:filePath atomically:YES ];
        [responseData writeToFile:zipFile options:NSDataWritingAtomic error:&error];
        
        if (!error){
            NSLog(@"File Created:%@",zipFile);
            
            
            if([fileMgr fileExistsAtPath:dashboardFolder]) {
                NSLog(@"Folder Exist:%@",dashboardFolder);
                if ([fileMgr removeItemAtPath:dashboardFolder error:&error] != YES){
                    NSLog(@"Unable to delete Folder: %@%@", dashboardFolder,[error localizedDescription]);
                    [_delegate DashboardReceived:self isSuccess:NO WithFileLocation:nil WithError:[error localizedDescription]WithZipFile:zipFile WithFolder:nil];
                }
                else{
                    NSLog(@"Folder %@ - deleted",dashboardFolder);
                    
                }
            }else{
                NSLog(@"Folder does not exist:%@",dashboardFolder);
            }
            
            
            NSString *zipPath = zipFile;
            [SSZipArchive unzipFileAtPath:zipPath toDestination:dashboardFolder];
            NSLog(@"File Unzipped");
            
            NSArray * directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dashboardFolder error:&error];
            
            NSLog(@"Fidning runtime_");
            NSString *folderName;
            for (NSString *fileName in directoryContents) {
                NSLog(@"File/Dir:%@",fileName);
                if([fileName hasPrefix:@"runtime_"]){
                    NSLog(@"Found File Name:%@",fileName);
                    folderName=fileName;
                    break;
                }
            }
            
            if (folderName){
                
                NSString *file_1js=[[dashboardFolder stringByAppendingPathComponent:folderName] stringByAppendingPathComponent:@"file_1.js"];
                if ([fileMgr fileExistsAtPath:file_1js]){
                    NSLog(@"File %@ Found!",file_1js);
                }else{
                    [_delegate DashboardReceived:self isSuccess:NO WithFileLocation:nil WithError:[error localizedDescription] WithZipFile:zipFile WithFolder:dashboardFolder];
                }
                
                
                NSLog(@"Replace Session");
                
                error=nil;
                NSString *fileContentString = [NSString stringWithContentsOfFile:file_1js
                                                                        encoding:NSUTF8StringEncoding
                                                                           error:&error];
                
                if (fileContentString) {
                    NSString *replacementString=[[NSString alloc] initWithFormat:@"this._ceSerializedSession =\"%@\";",mobileSession.serializedSession];
                    NSString *replacedString = [fileContentString stringByReplacingOccurrencesOfString:MOBILE_JS_STRING_TO_RERPLACE                                                                                   withString:replacementString];
                    error=nil;
                    
                    [replacedString writeToFile:file_1js atomically:YES encoding:NSUTF8StringEncoding error:&error];
                    if (error){
                        NSLog(@"Error Writing to File:%@",file_1js);
                        [_delegate DashboardReceived:self isSuccess:NO WithFileLocation:nil WithError:[error localizedDescription] WithZipFile:zipFile WithFolder:dashboardFolder];
                    }else{
                        [_delegate DashboardReceived:self isSuccess:YES WithFileLocation:[dashboardFolder stringByAppendingPathComponent:htmlFile] WithError:nil WithZipFile:zipFile WithFolder:dashboardFolder];
                    }
                }else{
                    NSLog(@"Cant Read File %@",file_1js);
                    [_delegate DashboardReceived:self isSuccess:NO WithFileLocation:nil WithError:[error localizedDescription] WithZipFile:zipFile WithFolder:dashboardFolder];
                    
                    
                }
            }else{
                NSLog(@"Cound find folder: %@",folderName);
                [_delegate DashboardReceived:self isSuccess:NO WithFileLocation:nil WithError:NSLocalizedString(@"Failed", nil) WithZipFile:zipFile   WithFolder:dashboardFolder];
            }
        }else{
            NSLog(@"Can't create file %@",zipFile);
            [_delegate DashboardReceived:self isSuccess:NO WithFileLocation:nil WithError:[error localizedDescription] WithZipFile:nil WithFolder:nil];
            
        }
        
        
    }
    
    
}


-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    if ([elementName isEqualToString:@"Result"]){
        if (!mobileSession)
            mobileSession =[[MobileSession alloc] init];
        mobileSessionStatus=[attributeDict objectForKey:@"status"];
        NSLog(@"Status:%@",mobileSessionStatus);
        return;
    }
    if ([elementName isEqualToString:@"logon"] && [mobileSessionStatus isEqualToString:@"success"]){
        mobileSession.logonToken=[attributeDict objectForKey:@"logonToken"];
        mobileSession.wcaToken=[attributeDict objectForKey:@"wcaToken"];
        mobileSession.bSerializedSession=[attributeDict objectForKey:@"bSerializedSession"];
        
        NSData *plainTextData = [NSData  dataFromBase64String: mobileSession.bSerializedSession];
        NSString *convertedString = [[NSString alloc] initWithData:plainTextData encoding:NSUTF8StringEncoding];
        NSLog(@"Decoded String:%@",convertedString);
        mobileSession.serializedSession=convertedString;
    }
    if ([elementName isEqualToString:@"version"] && [mobileSessionStatus isEqualToString:@"success"]){
        mobileSession.productVersion=[attributeDict objectForKey:@"productVersion"];
    }
    
}
-(void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (!currentStringValue){
        currentStringValue=[[NSMutableString alloc]initWithCapacity:50];
    }
    [currentStringValue appendString:string];
}

@end
