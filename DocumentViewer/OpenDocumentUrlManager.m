//
//  OpenDocumentUrlManager.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-08-23.
//  Copyright (c) 2013 APOS Systems. All rights reserved.
//

#import "OpenDocumentUrlManager.h"
#import "BrowserMainViewController.h"
#import "BI4RestConstants.h"
#import "BILogoff.h"

@implementation OpenDocumentUrlManager
{
    BISDKCall *biGetOpenDocUrl;
    UIWebView *_webView;
    NSURL *openDocUrl;
    NSMutableData *responseData;
    
}

-(void) getBTToken
{
    
    [self getOpenDocumentUrl];
    
}

-(void) processHttpRequestWithUrl: (NSURL *) url
{
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc] initWithURL:url];
    
    
    
    //    NSString *postString=@"&appName=Open+Document&cms=WIN-EIGGAIRFOUM&authType=secEnterprise&useLogonToken=true&cms=WIN-EIGGAIRFOUM&authType=secEnterprise&isFromLogonPage=true&backUrl=/opendoc/openDocument.jsp?appKind=OpenDocument&appKind=OpenDocument&useLogonToken=true&username=admin&password=apos123";
    
    
//   NSString *postString=[NSString stringWithFormat:@"qryStr=appKind=OpenDocument&appCUID=AZXgyG8_ue9OtYITUhGG.wg&service=/OpenDocument/appService.do&&backContext=/OpenDocument&backUrl=/opendoc/openDocument.jsp?iDocID=AboJe6x3iXRLip4RFwr1.iQ&sIDType=CUID&isApplication=true&appCUID=AZXgyG8_ue9OtYITUhGG.wg&trustedAuthErrorMsg=&appKind=OpenDocument&appKind=OpenDocument&backUrlParents=1&appName=Open+Document&prodName=SAP+BusinessObjects+Business+Intelligence+platform&cmsVisible=false&cms=WIN-EIGGAIRFOUM:6400&authenticationVisible=false&authType=secEnterprise&sso=false&sm=false&smAuth=secLDAP&sapSSOPrimary=false&persistCookies=true&useLogonToken=true&cmsVisible=false&cms=WIN-EIGGAIRFOUM:6400&authenticationVisible=false&authType=secEnterprise&isFromLogonPage=true&appName=Open Document&prodName=SAP BusinessObjects Business Intelligence platform&sessionCookie=true&backUrl=/opendoc/openDocument.jsp?iDocID=AboJe6x3iXRLip4RFwr1.iQ&sIDType=CUID&isApplication=true&appCUID=AZXgyG8_ue9OtYITUhGG.wg&trustedAuthErrorMsg=&appKind=OpenDocument&appKind=OpenDocument&backUrlParents=1&backContext=/OpenDocument&persistCookies=true&useLogonToken=true&service=/OpenDocument/appService.do&appKind=OpenDocument&loc=&username=admin&password=apos123"];
    
    
        NSString *postString=@"qryStr=appKind%3DOpenDocument%26appCUID%3DAZXgyG8_ue9OtYITUhGG.wg%26service%3D%252FOpenDocument%252FappService.do%26%26backContext%3D%252FOpenDocument%26backUrl%3D%252Fopendoc%252FopenDocument.jsp%253FiDocID%253DAboJe6x3iXRLip4RFwr1.iQ%2526sIDType%253DCUID%2526isApplication%253Dtrue%2526appCUID%253DAZXgyG8_ue9OtYITUhGG.wg%2526trustedAuthErrorMsg%253D%2526appKind%253DOpenDocument%2526appKind%253DOpenDocument%26backUrlParents%3D1%26appName%3DOpen%2BDocument%26prodName%3DSAP%2BBusinessObjects%2BBusiness%2BIntelligence%2Bplatform%26cmsVisible%3Dfalse%26cms%3DWIN-EIGGAIRFOUM%253A6400%26authenticationVisible%3Dfalse%26authType%3DsecEnterprise%26sso%3Dfalse%26sm%3Dfalse%26smAuth%3DsecLDAP%26sapSSOPrimary%3Dfalse%26persistCookies%3Dtrue%26useLogonToken%3Dtrue&cmsVisible=false&cms=WIN-EIGGAIRFOUM%3A6400&authenticationVisible=false&authType=secEnterprise&isFromLogonPage=true&appName=Open+Document&prodName=SAP+BusinessObjects+Business+Intelligence+platform&sessionCookie=true&backUrl=%2Fopendoc%2FopenDocument.jsp%3FiDocID%3DAboJe6x3iXRLip4RFwr1.iQ%26sIDType%3DCUID%26isApplication%3Dtrue%26appCUID%3DAZXgyG8_ue9OtYITUhGG.wg%26trustedAuthErrorMsg%3D%26appKind%3DOpenDocument%26appKind%3DOpenDocument&backUrlParents=1&backContext=%2FOpenDocument&persistCookies=true&useLogonToken=true&service=%2FOpenDocument%2FappService.do&appKind=OpenDocument&loc=&username=admin&password=apos123";
    
//    NSString *postString=@"appKind=OpenDocument&appCUID=AZXgyG8_ue9OtYITUhGG.wg&service=/OpenDocument/appService.do&&backContext=/OpenDocument&backUrl=/opendoc/openDocument.jsp?iDocID=AboJe6x3iXRLip4RFwr1.iQ&sIDType=CUID&isApplication=true&appCUID=AZXgyG8_ue9OtYITUhGG.wg&trustedAuthErrorMsg=&appKind=OpenDocument&backUrlParents=1&appName=Open Document&prodName=SAP BusinessObjects Business Intelligence platform&cmsVisible=false&cms=WIN-EIGGAIRFOUM:6400&authenticationVisible=false&authType=secEnterprise&sso=false&sm=false&smAuth=secLDAP&sapSSOPrimary=false&persistCookies=true&useLogonToken=true&cmsVisible=false&cms=WIN-EIGGAIRFOUM:6400&authenticationVisible=false&authType=secEnterprise&isFromLogonPage=true&appName=Open Document&prodName=SAP BusinessObjects Business Intelligence platform&sessionCookie=true&backUrl=/opendoc/openDocument.jsp?iDocID=AboJe6x3iXRLip4RFwr1.iQ&sIDType=CUID&isApplication=true&appCUID=AZXgyG8_ue9OtYITUhGG.wg&trustedAuthErrorMsg=&backUrlParents=1&backContext=/OpenDocument&persistCookies=true&useLogonToken=true&service=/OpenDocument/appService.do&appKind=OpenDocument&loc=&username=admin&password=apos123";
    
    
//    NSString *postString=[NSString stringWithFormat:@"&appName=Open+Document&cms=%@&authType=%@&useLogonToken=true&isFromLogonPage=true&backUrl=/opendoc/openDocument.jsp?appKind=OpenDocument&appKind=OpenDocument&useLogonToken=true&username=%@&password=%@",_currentSession.cmsName,_currentSession.authType,_currentSession.userName,_currentSession.password ];
    
    
    
    NSData *postData = [postString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSLog(@"Posting URL=%@,Data: %@",[url absoluteURL], postString);
    
    [request setTimeoutInterval:[_webiAppDelegate.globalSettings.networkTimeout doubleValue ]];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
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

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"BI Cypress Call didFailWithError %@",[error localizedDescription]);
    _connectorError =[[NSError alloc] init];
    _connectorError=error;
    [self.delegate getBTToken:self IsSuccess:NO LogOffUrl:nil withBTToken:nil WithOpenDocURL:nil];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
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
    
    
    NSArray *inQuotes = [receivedString componentsSeparatedByString:@"\""];
    NSLog(@"URL Component: %@",inQuotes);
    
    for (NSString *element in inQuotes) {
        NSRange bttPosition=[element rangeOfString:@"&bttoken" options:NSCaseInsensitiveSearch];
        if (!(bttPosition.location==NSNotFound)){
            NSURL *url=[[NSURL alloc] initWithString:element];
            NSLog(@"Found URL:%@",url);
            
            NSString *bttoken=nil;
            NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc] init];
            NSArray *urlComponents = [element componentsSeparatedByString:@"&"];
            for (NSString *keyValuePair in urlComponents) {
                NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
                NSString *key = [pairComponents objectAtIndex:0];
                NSString *value = [pairComponents objectAtIndex:1];
                
                [queryStringDictionary setObject:value forKey:key];
            }
            bttoken=[queryStringDictionary objectForKey:@"bttoken"];
            if (bttoken){
                [[self delegate] getBTToken:self IsSuccess:YES LogOffUrl:nil withBTToken:bttoken WithOpenDocURL:openDocUrl];
            }else{
                [[self delegate] getBTToken:self IsSuccess:NO LogOffUrl:nil withBTToken:nil WithOpenDocURL:nil];
            }
            
        }
        
    }
    
}


-(NSURL *)getLogonUrl40WithOpenDocUrl: (NSURL *) url
{
    
    NSLog(@"Generate 4.0 logonObject URL /BOE/OpenDocument/1308030928/PlatformServices/service/app/logon.object HTTP/1.1");
    NSString *logonURL;
    if (_currentSession.isHttps==[NSNumber numberWithBool:YES])
        logonURL=[NSString stringWithFormat:@"https://%@:%d/BOE/OpenDocument/1308030928/PlatformServices/service/app/logon.object",url.host,[url.port intValue]];
    else
        logonURL=[NSString stringWithFormat:@"http://%@:%d/BOE/OpenDocument/1308030928/PlatformServices/service/app/logon.object",url.host,[url.port intValue]];
    
    return [[NSURL alloc] initWithString:logonURL];
    
}
-(void) getWebiViewUrl
{
    NSLog(@"getWebiViewWithCmsToken Started");
    [self getOpenDocumentUrl];
}

-(void) getOpenDocumentUrl
{
    
    biGetOpenDocUrl=[[BISDKCall alloc]init];
    biGetOpenDocUrl.delegate=self;
    biGetOpenDocUrl.biSession=_currentSession;
    biGetOpenDocUrl.isFilterByUserName=NO;
    NSURL *urlSelected=[BrowserMainViewController buildUrlFromSession:_webiAppDelegate.activeSession forEntity:[NSString stringWithFormat:@"%@%d",infoStorePoint,_objectId.intValue ]withPageSize:[_webiAppDelegate.globalSettings.fetchDocumentLimit intValue]];
    
    [biGetOpenDocUrl getSelectedObjectForSession:_currentSession withUrl:urlSelected];
    
}
-(void) cypressCallSelectedObject:(BISDKCall *)biSDKCall withResponse:(CypressResponseHeader *)response isSuccess:(BOOL)isSuccess withObject:(InfoObject *)receivedObject
{
    
    NSLog(@"cypressCallSelectedObject");
    if (isSuccess==YES){
        
        NSLog(@"Got URL:%@",[receivedObject.openDoc absoluteString]);
        if (receivedObject.openDoc){
            //            [self getWebiViewWithUrl:receivedObject.openDoc];
            
            openDocUrl=receivedObject.openDoc;
            NSURL *platformServicesCallUrl=[self getLogonUrl40WithOpenDocUrl:receivedObject.openDoc];
            if (platformServicesCallUrl){
                [self processHttpRequestWithUrl:platformServicesCallUrl];
            }
            
        }else{
            NSLog(@"Open Document URL is Null. Try to build opendocument URL based on Advanced Settings");
            NSString *openDocumentURL;
            if (_currentSession.isHttps==[NSNumber numberWithBool:YES])
                openDocumentURL=[NSString stringWithFormat:@"https://%@:%@/BOE/OpenDocument/opendoc/openDocument.jsp?iDocID=%d",_currentSession.opendocServer,_currentSession.opendocPort,receivedObject.objectId];
            else  openDocumentURL=[NSString stringWithFormat:@"http://%@:%@/BOE/OpenDocument/opendoc/openDocument.jsp?iDocID=%d",_currentSession.opendocServer,_currentSession.opendocPort,receivedObject.objectId];
            
            NSURL *url=[NSURL URLWithString:openDocumentURL];
            NSLog(@"Created Open Doc: %@ for Type:%@",[url absoluteString],receivedObject.type);
            
            [self getWebiViewWithUrl:url];
            
            
            
            
        }
    }    else {
        
        if (biSDKCall.connectorError!=nil){
            UIAlertView *alert= [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Load Open Document URL Failed",nil) message:[biSDKCall.connectorError localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
        }else if (biSDKCall.boxiError!=nil){
            UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Load Open Document URL Failed in BI",nil)message:biSDKCall.boxiError delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil, nil];
            [alert show];
            
        } else{
            UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Load Open Document URL Failed",nil) message:NSLocalizedString(@"Server Error",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil, nil];
            [alert show];
            
        }
    }
    
    
    
}
-(void) cypressCallForChildren:(BISDKCall *)biSDKCall withResponse:(CypressResponseHeader *)response isSuccess:(BOOL)isSuccess withChildrenObjects:(NSArray *)receivedObjects
{
    NSLog(@"cypressCallForChildren");
}


-(void) getWebiViewWithUrl: (NSURL *) url
{
    openDocUrl=url;
    _webView=[[UIWebView alloc] init];
    NSMutableURLRequest *urlRequest=[[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:_webiAppDelegate.activeSession.cmsToken forHTTPHeaderField:SAP_HTTP_TOKEN];
    
    _webView.delegate=self;
    [_webView loadRequest:urlRequest];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"Original Open Doc Url:%@",[openDocUrl absoluteString]);
    NSString *html = [webView stringByEvaluatingJavaScriptFromString: @"document.all[0].innerHTML"];
    NSLog(@"Content:%@",html);
    
    NSArray *inQuotes = [html componentsSeparatedByString:@"\""];
    NSLog(@"URL Component: %@",inQuotes);
    
    for (NSString *element in inQuotes) {
        NSRange bttPosition=[element rangeOfString:@"&bttoken" options:NSCaseInsensitiveSearch];
        if (!(bttPosition.location==NSNotFound)){
            NSURL *url=[[NSURL alloc] initWithString:element];
            NSLog(@"Found URL:%@",url);
            [webView stopLoading];
            
            NSString *bttoken=nil;
            NSMutableDictionary *queryStringDictionary = [[NSMutableDictionary alloc] init];
            NSArray *urlComponents = [element componentsSeparatedByString:@"&"];
            for (NSString *keyValuePair in urlComponents) {
                NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
                NSString *key = [pairComponents objectAtIndex:0];
                NSString *value = [pairComponents objectAtIndex:1];
                
                [queryStringDictionary setObject:value forKey:key];
            }
            bttoken=[queryStringDictionary objectForKey:@"bttoken"];
            
            //           NSString *appendString=@"&appKind=OpenDocument&appCUID=AZXgyG8_ue9OtYITUhGG.wg&service=%2FOpenDocument%2FappService.do&loc=en&pvl=en_US&actId=4070&objIds=113483&containerId=110231&isApplication=true&trustedAuthErrorMsg=&pref=maxOpageU%3D10%3BmaxOpageUt%3D200%3BmaxOpageC%3D10%3Btz%3DAmerica%2FNew_York%3BmUnit%3Dinch%3BshowFilters%3Dtrue%3BsmtpFrom%3Dtrue%3BpromptForUnsavedData%3Dtrue%3B&streamContent=true";
            
            NSString *appendString=@"&appKind=OpenDocument&appCUID=AZXgyG8_ue9OtYITUhGG.wg&service=%2FOpenDocument%2FappService.do&loc=en&pvl=en_US&actId=4070&objIds=113483&containerId=110231&isApplication=true&trustedAuthErrorMsg=&pref=maxOpageU%3D10%3BmaxOpageUt%3D200%3BmaxOpageC%3D10%3Btz%3DAmerica%2FNew_York%3BmUnit%3Dinch%3BshowFilters%3Dtrue%3BsmtpFrom%3Dtrue%3BpromptForUnsavedData%3Dtrue%3B&streamContent=true";
            
            //            WebSesInit=true
            NSString *newString=[url absoluteString];
            newString=[newString stringByReplacingOccurrencesOfString:@"WebSesInit=true" withString:@"WebSesInit=false"];
            url=[[NSURL alloc] initWithString:newString];
            NSString *newUrlString=[NSString stringWithFormat:@"%@://%@:%@%@%@%@",  openDocUrl.scheme,openDocUrl.host,openDocUrl.port,@"/BOE/OpenDocument/1308030928/",[[url absoluteString] substringFromIndex:6],appendString];
            NSLog("New URL:%@",newUrlString);
            url=[[NSURL alloc]initWithString:newUrlString];
            
            //TODO Change
            //               NSURL *logoffUrl=[[NSURL alloc] initWithString:@"http://win-eiggairfoum:8080/BOE/OpenDocument/1308030928/PlatformServices/service/app/logoff.do?sapEPEmbedded=true&appKind=OpenDocument"];
            NSURL *logoffUrl=[[NSURL alloc] initWithString:@"http://win-eiggairfoum:8080/BOE/CMC/1308030928/AnalyticalReporting/Cleanup.do?cafWebSesInit=true&bttoken=null&appKind=OpenDocument"];
            
            [self.delegate openDocHackView:self IsSuccess:YES WithUrl:url LogOffUrl:logoffUrl withBTToken:bttoken] ;
            
            //            NSMutableURLRequest *request=[[NSMutableURLRequest alloc] initWithURL:url];
            //            NSURLResponse *response=nil;
            //            NSError *error =nil;
            //            NSData *responseData=[NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
            //            if (error){
            //                NSLog (@"Error in Response:,%@",error.description);
            //            }else{
            //                NSString* responseString = [[NSString alloc] initWithData:responseData encoding:NSNonLossyASCIIStringEncoding];
            //                NSLog (@"Response String: %@",responseString);
            //            }
            
        }
        
    }
    
    
    
    //    NSUInteger tokenLocation=[html rangeOfString:@"&bttoken="].location;
    //    if (!(tokenLocation==NSNotFound)){
    //        NSLog(@"Found BTToken!. Location: %d",tokenLocation);
    //        [webView stopLoading];
    ////                    [_webView stringByEvaluatingJavaScriptFromString: @"openDocOnLoad()"];
    //        //       NSString *newURL=@" http://win-eiggairfoum:8080/BOE/OpenDocument/1308030928/AnalyticalReporting/WebiView.do?bypassLatestInstance=true&cafWebSesInit=true&bttoken=MDAwRDAPLazZpXWNdXWdjPUpmY1g4QExRQWlBZ1JjOTAEQ&appKind=OpenDocument&appCUID=AZXgyG8_ue9OtYITUhGG.wg&service=%2FOpenDocument%2FappService.do&loc=en&pvl=en_US&actId=4070&objIds=113483&containerId=110231&bttoken=MDAwRDAPLazZpXWNdXWdjPUpmY1g4QExRQWlBZ1JjOTAEQ&isApplication=true&trustedAuthErrorMsg=&pref=maxOpageU%3D10%3BmaxOpageUt%3D200%3BmaxOpageC%3D10%3Btz%3DAmerica%2FNew_York%3BmUnit%3Dinch%3BshowFilters%3Dtrue%3BsmtpFrom%3Dtrue%3BpromptForUnsavedData%3Dtrue%3B&streamContent=true";
    //        //        NSURL *url=[[NSURL alloc] initWithString:newURL];
    //        //        NSURLRequest *newRequest=[[NSURLRequest alloc]initWithURL:url];
    //        //        [webView loadRequest:newRequest];
    //        //
    //    }
    
}

-(void) dealloc
{
    NSLog(@"Dealloc!!");
    [self logoOffIfNeeded];
}

-(void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"View Will Disapper - Logoff");
    [self logoffWithSession: _currentSession];
}
-(void) logoOffIfNeeded{
    if ([_webiAppDelegate.globalSettings.autoLogoff integerValue]==1){
        if (_currentSession!=nil && _currentSession.cmsToken!=nil){
            [self logoffWithSession:_currentSession];
        }
    }
    
}
-(void) logoffWithSession:(Session *)session{
    if (session.cmsToken!=nil){
        BILogoff *biLogoff=[[BILogoff alloc] init];
        //        [biLogoff logoffSessionSync:session withToken:_cmsToken];
        [biLogoff logoffSession:session withToken:session.cmsToken];
        NSLog(@"Logoff Session:%@",session.name);
    }
    
    
}



@end
