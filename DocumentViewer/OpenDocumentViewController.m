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

@interface OpenDocumentViewController ()

@end

@implementation OpenDocumentViewController
{
    UIActivityIndicatorView *spinner;
    WebiAppDelegate *appDelegate;
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
    
    spinner = [[UIActivityIndicatorView alloc]  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin);
    spinner.center = CGPointMake(_webiView.bounds.size.width / 2.0f, _webiView.bounds.size.height / 2.0f);
    [self.view addSubview:spinner];
    
    
    UIBarButtonItem *refreshButton         = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                              target:self
                                              action:@selector(reloadOpenDocView)];
    
    self.navigationItem.rightBarButtonItems =[NSArray arrayWithObjects:refreshButton, nil];
    appDelegate = (id)[[UIApplication sharedApplication] delegate];
    
    NSLog(@"Is AutoLogoff %@",appDelegate.globalSettings.autoLogoff);
    //    if ([appDelegate.globalSettings.autoLogoff boolValue]==YES) [self createCmsTokenForSession:_currentSession];
    //    else [self reloadOpenDocView];
    
    
    BILogoff *biLogoff=[[BILogoff alloc] init];
    biLogoff.biSession=_currentSession;
//    [biLogoff logoffSessionSync:_currentSession withToken:_cmsToken];
    [biLogoff logoffSession:_currentSession withToken:_cmsToken];
    [self createCmsTokenForSession:_currentSession];
    
    
    
    
}

-(void) reloadOpenDocView
{
    if (_isGetOpenDocRequired==NO)
        [self loadOpenDocumentWithUrl:_openDocUrl];
    else [self getOpenDocumentUrl];
    
}
-(void) loadOpenDocumentWithUrl:(NSURL *)url
{
 
    [spinner startAnimating];
    NSMutableURLRequest *request;
    
    if ([_infoObject.type isEqualToString:@"CrystalReport"]){
        
        NSString *crViewer;
        if ([_currentSession.isHttps boolValue]==YES){
            
            crViewer=[NSString stringWithFormat:@"%@%@%@%@%@%d%@%@%@%@",@"https://",url.host,@":",url.port,@"/BOE/CrystalReports/viewrpt.cwr?id=",_infoObject.objectId,@"&export_fmt=u2fpdf%3a0&Cmd=export&dpi=96&apsuser=",_currentSession.userName,@"&apspassword=",_currentSession.password];
            
        }else{
            crViewer=[NSString stringWithFormat:@"%@%@%@%@%@%d%@%@%@%@",@"http://",url.host,@":",url.port,@"/BOE/CrystalReports/viewrpt.cwr?id=",_infoObject.objectId,@"&export_fmt=u2fpdf%3a0&Cmd=export&dpi=96&apsuser=",_currentSession.userName,@"&apspassword=",_currentSession.password];
            
        }
        NSLog(@"New CWR URL:%@",crViewer);
        NSURL *crViewerUrl=[NSURL URLWithString:crViewer];
        request = [NSMutableURLRequest  requestWithURL:crViewerUrl];
    }else{
//        NSLog(@"Open Document URL: %@",[_openDocUrl absoluteString]);
//        NSLog(@"Open Document URL: %@",[url absoluteString]);
//        request = [NSMutableURLRequest  requestWithURL:url];
        
        //    NSString *encodedToken=[_cmsToken stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        //    NSString *newUrlString=@"http://win-eiggairfoum:8080/BOE/CrystalReports/viewrpt.cwr?id=67794&export_fmt=u2fpdf%3a0&Cmd=export&dpi=96";
        
        NSString *urlString=[NSString stringWithFormat:@"%@%@",[url absoluteString],@"&sOutputFormat=H"];
        NSLog(@"URL:%@",urlString);
        NSURL *newURL=[NSURL URLWithString:urlString];
        request = [NSMutableURLRequest  requestWithURL:newURL];
        
    }
    
    [request setHTTPMethod:@"GET"];
    [request setValue:_cmsToken forHTTPHeaderField:SAP_HTTP_TOKEN];
    
    [_webiView loadRequest:request];

}

-(void) getOpenDocumentUrl
{
    
    BISDKCall *biGetOpenDocUrl=[[BISDKCall alloc]init];
    biGetOpenDocUrl.delegate=self;
    biGetOpenDocUrl.biSession=_currentSession;
    biGetOpenDocUrl.isFilterByUserName=NO;
    [biGetOpenDocUrl getSelectedObjectForSession:_currentSession withUrl:_openDocUrl];
    
}
-(void) createCmsTokenForSession:(Session *)session
{
    BIConnector *biConnector=[[BIConnector alloc]init];
    biConnector.delegate=self;
    [biConnector getCmsTokenWithSession:session];
}
-(void)biConnector:(BIConnector *)biConnector didCreateCmsToken:(NSString *)cmsToken forSession:(Session *)session
{
    NSLog(@"Token Created");
    _cmsToken=cmsToken;
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
            [self loadOpenDocumentWithUrl:receivedObject.openDoc];
        }else{
            NSLog(@"Open Document URL is Null. Try to build opendocument URL based on Advanced Settings");
            NSString *openDocumentURL;
            if (_currentSession.isHttps==[NSNumber numberWithBool:YES])
                openDocumentURL=[NSString stringWithFormat:@"https://%@:%@/BOE/OpenDocument/opendoc/openDocument.jsp?iDocID=%d",_currentSession.opendocServer,_currentSession.opendocPort,receivedObject.objectId];
            else  openDocumentURL=[NSString stringWithFormat:@"http://%@:%@/BOE/OpenDocument/opendoc/openDocument.jsp?iDocID=%d",_currentSession.opendocServer,_currentSession.opendocPort,receivedObject.objectId];
            
            NSURL *url=[NSURL URLWithString:openDocumentURL];
            NSLog(@"Created Open Doc: %@",[url absoluteString]);
            [self loadOpenDocumentWithUrl:url];
            
            
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

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
 
}
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [spinner stopAnimating];
    NSLog(@"Webi View Loaded Title");
    _webiView.scalesPageToFit=YES;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
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
        BILogoff *biLogoff=[[BILogoff alloc] init];
//        [biLogoff logoffSessionSync:session withToken:_cmsToken];
        [biLogoff logoffSession:session withToken:_cmsToken];
        NSLog(@"Logoff Session:%@",session.name);
    }
    
    
}

@end
