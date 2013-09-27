//
//  OpenDocumentViewController.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-05-19.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import "OpenDocumentViewController.h"
#import "TitleLabel.h"
#import "BI4RestConstants.h"
#import "Session.h"
#import "WebiAppDelegate.h"
#import "BILogoff.h"
#import "Utils.h"

@interface OpenDocumentViewController ()

@end

@implementation OpenDocumentViewController
{
    UIActivityIndicatorView *spinner;
    WebiAppDelegate *appDelegate;
    BILogoff *biLogoff;
    BOOL isBTokenFound;
    BOOL isGetWebiView;
    NSNumber *actdId;
    NSNumber *objectID;
    UIGestureRecognizer *tapper;

    
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    TitleLabel *titelLabel=[[TitleLabel alloc] initWithFrame:CGRectZero];
    titelLabel.text=self.title;
    self.navigationItem.titleView = titelLabel;
    [titelLabel sizeToFit];
    _webiView.delegate=self;
    isGetWebiView=NO;
    spinner = [[UIActivityIndicatorView alloc]  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin);
    spinner.center = CGPointMake(_webiView.bounds.size.width / 2.0f, _webiView.bounds.size.height / 2.0f);
    [self.view addSubview:spinner];
    
    
    UIBarButtonItem *refreshButton         = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                              target:self
                                              action:@selector(initLoadRequest)];
    
    
//    UIBarButtonItem *closeButton         = [[UIBarButtonItem alloc]
//                                              initWithBarButtonSystemItem:UIBarButtonSystemItemDone
//                                              target:self
//                                              action:@selector(closeView)];

    self.navigationItem.rightBarButtonItems =[NSArray arrayWithObjects:refreshButton, nil];
//    self.navigationItem.leftBarButtonItems=[NSArray arrayWithObjects:closeButton, nil];
    
    appDelegate = (id)[[UIApplication sharedApplication] delegate];
    
    tapper = [[UITapGestureRecognizer alloc]init];
    [self.view addGestureRecognizer:tapper];
    tapper.delegate=self;
    
    NSLog(@"Is AutoLogoff %@",appDelegate.globalSettings.autoLogoff);
    //    if ([appDelegate.globalSettings.autoLogoff boolValue]==YES) [self createCmsTokenForSession:_currentSession];
    //    else [self reloadOpenDocView];
    
    
    //    }else{
    //
    //        BILogoff *biLogoff=[[BILogoff alloc] init];
    //        biLogoff.biSession=_currentSession;
    //        //        //    [biLogoff logoffSessionSync:_currentSession withToken:_cmsToken];
    //        [biLogoff logoffSession:_currentSession withToken:_cmsToken];
    //        [self createCmsTokenForSession:_currentSession];
    //
    //    }
    //
    
    [self initLoadRequest];
    
    
}
-(UIStatusBarStyle)preferredStatusBarStyle{
    NSLog(@"preferredStatusBarStyle");
    //    return UIStatusBarStyleLightContent;
    return UIStatusBarStyleDefault;
}

-(void) closeView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void) initLoadRequest
{
    if (_isOpenDocumentManager==NO){
        
        biLogoff=[[BILogoff alloc] init];
        biLogoff.delegate=self;
        biLogoff.biSession=_currentSession;
//        [biLogoff logoffSessionSync:_currentSession withToken:_cmsToken];
        
        
        [biLogoff logoffSession:_currentSession withToken:_cmsToken];
    }else{
        [spinner startAnimating];
        NSLog(@"Using OpenDocument Manager");
        isGetWebiView=YES;
        if (_openDocUrl==nil)
            [self getOpenDocumentUrl];
        else
            [self getWebiViewWithUrl:_openDocUrl];
        
        
    }
    
    //    BILogoff *biLogoff=[[BILogoff alloc] init];
    //    //    biLogoff.biSession=_currentSession;
    //    [biLogoff logoffSessionSync:_currentSession withToken:_cmsToken];
    //    [self createCmsTokenForSession:_currentSession];
    
}
-(void) biLogoff:(BILogoff *)biLogoff didLogoff:(BOOL)isSuccess
    {
        NSLog(@"OpenDoc Logoff");
        [self createCmsTokenForSession:_currentSession];
        
    }
-(void) reloadOpenDocView
{
    
    if (_isGetOpenDocRequired==NO)
        [self loadOpenDocumentWithUrl:_openDocUrl];
    else [self getOpenDocumentUrl];
    
}


-(NSURL *)getLogonWebiViewDoWithOpenDocUrl: (NSURL *) url WithBttoken: (NSString *) bttoken
{
    
    NSLog(@"Generate 4.0 http://win-eiggairfoum:8080/BOE/OpenDocument/1308030928/AnalyticalReporting/WebiView.do?");
    
    
    //    NSString *webiViewUrl=[NSString stringWithFormat:@"http://win-eiggairfoum:8080/BOE/OpenDocument/1308030928/AnalyticalReporting/WebiView.do?bypassLatestInstance=true&cafWebSesInit=true&bttoken=%@&appKind=OpenDocument&appCUID=AZXgyG8_ue9OtYITUhGG.wg&service=/OpenDocument/appService.do&loc=en&pvl=en_US&actId=4070&objIds=113483&containerId=110231&isApplication=true&trustedAuthErrorMsg=&pref=maxOpageU=10;maxOpageUt=200;maxOpageC=10;tz=America/New_York;mUnit=inch;showFilters=true;smtpFrom=true;promptForUnsavedData=true;&streamContent=true",bttoken];
    
    
    
    
    NSString *webiViewUrl=[NSString stringWithFormat:@"http://win-eiggairfoum:8080/BOE/OpenDocument/1308030928/AnalyticalReporting/WebiView.do?bypassLatestInstance=true&cafWebSesInit=true&appKind=OpenDocument&appCUID=AZXgyG8_ue9OtYITUhGG.wg&service=%%2FOpenDocument%%2FappService.do&loc=en&pvl=en_US&actId=4070&objIds=113483&containerId=110231&bttoken=%@&isApplication=true&trustedAuthErrorMsg=&pref=maxOpageU%%3D10%%3BmaxOpageUt%%3D200%%3BmaxOpageC%%3D10%%3Btz%%3DAmerica%%2FNew_York%%3BmUnit%%3Dinch%%3BshowFilters%%3Dtrue%%3BsmtpFrom%%3Dtrue%%3BpromptForUnsavedData%%3Dtrue%%3B",bttoken];
    
    //    if (_currentSession.isHttps==[NSNumber numberWithBool:YES])
    //        webiViewUrl=[NSString stringWithFormat:@"https://%@:%d/BOE/OpenDocument/1308030928/AnalyticalReporting/WebiView.do?bypassLatestInstance=true&cafWebSesInit=true&streamContent=true&bttoken=%@&objIds=113483&service=/OpenDocument/appService.do",url.host,[url.port intValue],bttoken];
    //
    //
    //
    //    else
    //        webiViewUrl=[NSString stringWithFormat:@"http://%@:%d/BOE/OpenDocument/1308030928/AnalyticalReporting/WebiView.do?bypassLatestInstance=true&cafWebSesInit=true&streamContent=true&bttoken=%@&objIds=113483&service=/OpenDocument/appService.do",url.host,[url.port intValue],bttoken];
    //
    return [[NSURL alloc] initWithString:webiViewUrl];
    
}


-(void) loadOpenDocumentWithUrl:(NSURL *)url
{
    
    [spinner startAnimating];
    NSMutableURLRequest *request;
    
    NSLog(@"Open Document URL: %@",[_openDocUrl absoluteString]);
    NSLog(@"Open Document URL: %@",[url absoluteString]);
    request = [NSMutableURLRequest  requestWithURL:url];
    
    
    //    if ([_infoObject.type isEqualToString:@"CrystalReport"]){
    //
    //        NSString *crViewer;
    //        if ([_currentSession.isHttps boolValue]==YES){
    //
    //            crViewer=[NSString stringWithFormat:@"%@%@%@%@%@%d%@%@%@%@",@"https://",url.host,@":",url.port,@"/BOE/CrystalReports/viewrpt.cwr?id=",_infoObject.objectId,@"&export_fmt=u2fpdf%3a0&Cmd=export&dpi=96&apsuser=",_currentSession.userName,@"&apspassword=",_currentSession.password];
    //
    //        }else{
    //            crViewer=[NSString stringWithFormat:@"%@%@%@%@%@%d%@%@%@%@",@"http://",url.host,@":",url.port,@"/BOE/CrystalReports/viewrpt.cwr?id=",_infoObject.objectId,@"&export_fmt=u2fpdf%3a0&Cmd=export&dpi=96&apsuser=",_currentSession.userName,@"&apspassword=",_currentSession.password];
    //
    //        }
    //
    ////        if ([_currentSession.isHttps boolValue]==YES){
    ////
    ////            crViewer=[NSString stringWithFormat:@"%@%@%@%@%@%d%@%@%@%@",@"https://",url.host,@":",url.port,@"/BOE/CrystalReports/viewrpt.cwr?id=",_infoObject.objectId,@"&apsuser=",_currentSession.userName,@"&apspassword=",_currentSession.password];
    ////
    ////        }else{
    ////            crViewer=[NSString stringWithFormat:@"%@%@%@%@%@%d%@%@%@%@",@"http://",url.host,@":",url.port,@"/BOE/CrystalReports/viewrpt.cwr?id=",_infoObject.objectId,@"&apsuser=",_currentSession.userName,@"&apspassword=",_currentSession.password];
    ////
    ////        }
    //
    //        NSLog(@"New CWR URL:%@",crViewer);
    //        NSURL *crViewerUrl=[NSURL URLWithString:crViewer];
    //        request = [NSMutableURLRequest  requestWithURL:crViewerUrl];
    //    }else{
    //        //        NSLog(@"Open Document URL: %@",[_openDocUrl absoluteString]);
    //        //        NSLog(@"Open Document URL: %@",[url absoluteString]);
    //        //        request = [NSMutableURLRequest  requestWithURL:url];
    //
    //        //    NSString *encodedToken=[_cmsToken stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //        //    NSString *newUrlString=@"http://win-eiggairfoum:8080/BOE/CrystalReports/viewrpt.cwr?id=67794&export_fmt=u2fpdf%3a0&Cmd=export&dpi=96";
    //
    //        NSString *urlString=[NSString stringWithFormat:@"%@%@",[url absoluteString],@"&sOutputFormat=H"];
    //        NSLog(@"URL:%@",urlString);
    //        NSURL *newURL=[NSURL URLWithString:urlString];
    //        request = [NSMutableURLRequest  requestWithURL:newURL];
    //
    //    }
    
    [request setHTTPMethod:@"GET"];
    [request setValue:_cmsToken forHTTPHeaderField:SAP_HTTP_TOKEN];
    [_webiView loadRequest:request];
    
    //        [self hackIntoOpenDocWithUrl:url];
    
}

-(void) getOpenDocumentUrl
{
    
    BISDKCall *biGetOpenDocUrl=[[BISDKCall alloc]init];
    biGetOpenDocUrl.delegate=self;
    biGetOpenDocUrl.biSession=_currentSession;
    biGetOpenDocUrl.isFilterByUserName=NO;
    [biGetOpenDocUrl getSelectedObjectForSession:_currentSession withUrl:_selectedObjectUrl];
    
}
-(void) createCmsTokenForSession:(Session *)session
{
    BIConnector *biConnector=[[BIConnector alloc]init];
    biConnector.delegate=self;
    [biConnector getCmsTokenWithSession:session];
}
-(void)biConnector:(BIConnector *)biConnector didCreateCmsToken:(NSString *)cmsToken forSession:(Session *)session
{
    _cmsToken=cmsToken;
    NSLog(@"Token Created");
    [self reloadOpenDocView];
    
    
}
-(void) cypressCallForChildren:(BISDKCall *)biSDKCall withResponse:(CypressResponseHeader *)response isSuccess:(BOOL)isSuccess withChildrenObjects:(NSArray *)receivedObjects
{
    
}
-(void) cypressCallSelectedObject:(BISDKCall *)biSDKCall withResponse:(CypressResponseHeader *)response isSuccess:(BOOL)isSuccess withObject:(InfoObject *)receivedObject
{
    
    if (isSuccess==YES){
        
        NSLog(@"Got URL:%@",[receivedObject.openDoc absoluteString]);
        if (receivedObject.openDoc){
            if (isGetWebiView==NO)
                [self loadOpenDocumentWithUrl:receivedObject.openDoc];
            else{
                [self getWebiViewWithUrl:receivedObject.openDoc];
            }
        }else{
            NSLog(@"Open Document URL is Null. Try to build opendocument URL based on Advanced Settings");
            NSString *openDocumentURL;
            if (_currentSession.isHttps==[NSNumber numberWithBool:YES])
                openDocumentURL=[NSString stringWithFormat:@"https://%@:%@/BOE/OpenDocument/opendoc/openDocument.jsp?iDocID=%d",_currentSession.opendocServer,_currentSession.opendocPort,receivedObject.objectId];
            else  openDocumentURL=[NSString stringWithFormat:@"http://%@:%@/BOE/OpenDocument/opendoc/openDocument.jsp?iDocID=%d",_currentSession.opendocServer,_currentSession.opendocPort,receivedObject.objectId];
            
            NSURL *url=[NSURL URLWithString:openDocumentURL];
            NSLog(@"Created Open Doc: %@ for Type:%@",[url absoluteString],receivedObject.type);
            
            if (isGetWebiView==NO)
                [self loadOpenDocumentWithUrl:url];
            else
                [self getWebiViewWithUrl:url];
            
            
            
            //            UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"Incorrect Open Document URL" message:[receivedObject.openDoc absoluteString] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            //            [alert show];
            
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

-(void) getWebiViewWithUrl: (NSURL *) url
{
    _openDocUrl=url;
    NSMutableURLRequest *urlRequest=[[NSMutableURLRequest alloc] initWithURL:url];
    [urlRequest setHTTPMethod:@"GET"];
    [urlRequest setValue:_currentSession.cmsToken forHTTPHeaderField:SAP_HTTP_TOKEN];
    isGetWebiView=YES;
    _webiView.delegate=self;
    [_webiView loadRequest:urlRequest];
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
 
//            [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    if (isGetWebiView==NO){
        [spinner stopAnimating];
        _webiView.scalesPageToFit=YES;
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
    }else{
        // Parsing reponse to get btttoken
        
        NSLog(@"Original Open Doc Url:%@",[_openDocUrl absoluteString]);
        NSString *html = [webView stringByEvaluatingJavaScriptFromString: @"document.all[0].innerHTML"];
        NSLog(@"Content:%@",html);
        
        //        NSArray *inQuotes = [html componentsSeparatedByString:@"\""];
        NSArray *lines = [html componentsSeparatedByString:@"\n"];
        //        NSLog(@"URL Component: %@",lines);
        
        for (NSString *line in lines) {
            NSLog(@"Line:%@",line);
            NSRange bttPosition=[line rangeOfString:@"&bttoken" options:NSCaseInsensitiveSearch];
            
            
            
            
            
            
            if (!(bttPosition.location==NSNotFound)){
                
                NSString *bttoken=@"";
                NSArray *inq=[line componentsSeparatedByString:@"&"];
                for (NSString *string in inq) {
                    NSLog(@"String in quotes:%@",string);
                    if ([string hasPrefix:@"bttoken"]) {
                        bttoken=[string substringFromIndex:8];
                        NSLog(@"BTToken Found:%@",bttoken);
                    }
                }
                
                
                
                
                NSArray *inQuotes=[line componentsSeparatedByString:@"\""];
                
                NSURL *url=[[NSURL alloc] initWithString:[inQuotes objectAtIndex:1]];
                NSLog(@"Found URL:%@",url);
                [webView stopLoading];
                
                NSArray *inCommas=[line componentsSeparatedByString:@","];
                
                actdId=[self getNumberFromStringArray:inCommas WithIndex:2 removeString:@"\""];
                objectID=[self getNumberFromStringArray:inCommas WithIndex:3 removeString:@"\""];
                
                if ([actdId intValue]>0 ){
                    
                    NSLog(@"4.0 Code?");
                    
                    //                NSString *appendString=@"&appKind=OpenDocument&loc=en&pvl=en_US&actId=4070&objIds=113483&isApplication=true&streamContent=true";
                    NSString *appendString=[[NSString alloc]initWithFormat: @"&appKind=OpenDocument&loc=en&pvl=en_US&actId=%@&objIds=%@&isApplication=true&streamContent=true",actdId,objectID ];
                    
                    
                    NSString *newUrlString=[NSString stringWithFormat:@"%@://%@:%@%@%@%@",  _openDocUrl.scheme,_openDocUrl.host,_openDocUrl.port,@"/BOE/OpenDocument/1308030928/",[[url absoluteString] substringFromIndex:6],appendString];
                    
                    NSLog("New URL:%@",newUrlString);
                    url=[[NSURL alloc]initWithString:newUrlString];
                    isGetWebiView=NO;
                    NSMutableURLRequest *request=[[NSMutableURLRequest alloc] initWithURL:url];
                    [_webiView loadRequest:request];
                }else{
                    NSLog(@"4.1 Code?");
                    


                    
                    NSString *urlString=[NSString stringWithFormat:@"http://win-bi41rampup:8080/BOE/portal/1308290047/AnalyticalReporting/jsp/common/webiViewFormatInstance.jsp?bypassLatestInstance=true&cafWebSesInit=true&bttoken=%@&opendocTarget=infoviewOpenDocFrame&appKind=InfoView&service=/InfoView/common/appService.do&loc=en&pvl=en_US&ctx=standalone&actId=4469&objIds=7044&containerId=6157&objIdStr=7044&streamContent=true",bttoken];
                    
                    NSLog("New URL:%@",urlString);
                    url=[[NSURL alloc]initWithString:urlString];
                    isGetWebiView=NO;
                    NSMutableURLRequest *request=[[NSMutableURLRequest alloc] initWithURL:url];
                    [_webiView loadRequest:request];
                    
                    
                    
                }
                break;
                
            }
            
        }
        
    }
    
}
-(NSNumber *) getNumberFromStringArray: (NSArray *) strings WithIndex: (int) index removeString: (NSString *) removeString
{
    
    if (index <=[strings count]-1){
        
        if ([strings  objectAtIndex:index]){
            
            NSString *cleanString= [[strings  objectAtIndex:index] stringByReplacingOccurrencesOfString:removeString withString:@""];
            NSScanner *scanner = [NSScanner scannerWithString:cleanString];
            BOOL isNumeric = [scanner scanInteger:NULL] && [scanner isAtEnd];
            
            if (isNumeric==YES) NSLog(@"Found %@. Integer Value:%@",cleanString,[NSNumber numberWithInt:[cleanString integerValue]]);
            return [NSNumber numberWithInt:[cleanString integerValue]];
        }
    }
    return [NSNumber numberWithInt:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setWebiView:nil];
    [super viewDidUnload];
}

-(void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"View Will Disapper - Logoff");
    [self logoffWithSession: _currentSession];
    
}
-(void) logoOffIfNeeded{
    if ([appDelegate.globalSettings.autoLogoff integerValue]==1){
        if (_currentSession!=nil && _currentSession.cmsToken!=nil){
            [self logoffWithSession:_currentSession];
        }
    }
    
}
-(void) logoffWithSession:(Session *)session{
    if (_cmsToken!=nil){
        
        biLogoff=[[BILogoff alloc] init];
        biLogoff.delegate=nil;
        //        [biLogoff logoffSessionSync:session withToken:_cmsToken];
        [biLogoff logoffSession:session withToken:_cmsToken];
        NSLog(@"Logoff Session:%@",session.name);
    }
    
    
}

//-(BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
//{
//        CGPoint point=[touch locationInView:self.webiView];
//    
//
//    NSLog(@"%f",point.y);
//    
//    if (point.y>80) return NO;
//    
//    NSLog(@"Hanlde Single Tap - 0");
//
//    if (self.navigationController.navigationBarHidden==YES){
//        [self.navigationController setNavigationBarHidden:NO animated:YES];
//        //        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//    }else{
//        [self.navigationController setNavigationBarHidden:YES animated:YES];
//        //        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
//    }
//    
//    return YES;
//}


@end
