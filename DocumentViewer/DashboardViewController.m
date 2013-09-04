//
//  DashboardViewController.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-09-02.
//  Copyright (c) 2013 APOS Systems. All rights reserved.
//

#import "DashboardViewController.h"
#import "WebiAppDelegate.h"
#import "MobileSession.h"
#import "TitleLabel.h"

@interface DashboardViewController ()

@end

@implementation DashboardViewController
{
    UIActivityIndicatorView *spinner;
    WebiAppDelegate  *appDelegate;
    NSString *_zipFile;
    NSString *_dashboardFolder;
    NSString *_htmlFile;
    
    
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)loadDashBoard
{
    [spinner startAnimating];
    if (appDelegate.mobileService==nil){
        NSLog(@"Create New Mobile Service");
        appDelegate.mobileService=[[MobileBIService alloc] init];
        appDelegate.mobileService.delegate=self;
        [appDelegate.mobileService initMobileWithSession:appDelegate.activeSession];
        
        
    }
    else if (appDelegate.mobileSession){
        NSLog(@"Re-Use Session");
        [appDelegate.mobileService getDashboardWithCUID:_dashboardCuid WithMobileSession:appDelegate.mobileSession];
    }else{
        appDelegate.mobileService.delegate=self;
        [appDelegate.mobileService initMobileWithSession:appDelegate.activeSession];
        
        
    }
    
}
-(void) sessionReceived:(MobileBIService *)mobileService isSuccess:(BOOL)isSuccess WithMobileSession:(MobileSession *)mobileSession
{
    NSLog(@"Is Session Received:%d",isSuccess);
    
    NSLog(@"Logon Token:%@",mobileSession.logonToken);
    NSLog(@"Product Version:%@",mobileSession.productVersion);
    appDelegate.mobileSession=mobileSession;
    [mobileService getDashboardWithCUID:_dashboardCuid WithMobileSession:mobileSession];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate= (id)[[UIApplication sharedApplication] delegate];
    
    
    TitleLabel *titelLabel=[[TitleLabel alloc] initWithFrame:CGRectZero];
    titelLabel.text=self.title;
    self.navigationItem.titleView = titelLabel;
    [titelLabel sizeToFit];
    
    spinner = [[UIActivityIndicatorView alloc]  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin);
    spinner.center = CGPointMake(_webiView.bounds.size.width / 2.0f, _webiView.bounds.size.height / 2.0f);
    [self.view addSubview:spinner];
    
    
    UIBarButtonItem *refreshButton         = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                              target:self
                                              action:@selector(loadDashBoard)];
    _webiView.delegate=self;
    _webiView.scalesPageToFit=YES;

    self.navigationItem.rightBarButtonItems =[NSArray arrayWithObjects:refreshButton, nil];
    
    
    // Do any additional setup after loading the view from its nib.
    [self loadDashBoard];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self deletFileWithPath:_zipFile];
    [self deletFileWithPath:_dashboardFolder];

    appDelegate.mobileSession=nil;
    [appDelegate.mobileService mobileLogoff];


}
-(void) deletFileWithPath: (NSString *) filePath
{
    if (filePath!=nil){
        NSError *error;
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        if ([fileMgr removeItemAtPath:filePath error:&error] != YES)
            NSLog(@"Unable to delete file: %@: %@",filePath, [error localizedDescription]);
        else{
            NSLog(@"File %@ - deleted",filePath);
        }
    }
    
    
}
//-(void) viewDidDisappear:(BOOL)animated
//{
//    [super viewDidDisappear:animated];
//    appDelegate.mobileSession=nil;
//    [appDelegate.mobileService mobileLogoff];
//}
-(void)logoffCompleted:(MobileBIService *)currentMobileService isSuccess:(BOOL)isSuccess
{
    NSLog(@"Logoff Completed. Is Success=%d",isSuccess);
    appDelegate.mobileService=nil;
    appDelegate.mobileSession=nil;
}
-(void) DashboardReceived:(MobileBIService *)mobileService isSuccess:(BOOL)isSuccess WithFileLocation:(NSString *)filePath WithError:(NSString *)error WithZipFile:(NSString *)zipFile WithFolder:(NSString *)folderName
{
    NSLog(@"DashBoard Received with Success=%d",isSuccess);
    _htmlFile=filePath;
    _zipFile=zipFile;
    _dashboardFolder=folderName;
    if (isSuccess==YES){
        NSLog(@"Display html:%@",filePath);
        [_webiView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:filePath]]];
            [TestFlight passCheckpoint:@"Dashboard received with Success"];
    }
    else{
            [spinner stopAnimating];
        [TestFlight passCheckpoint:@"Dashboard Failed"];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"Dashboard Failed",nil) message:error delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
    }
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"Webi View Start Load");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

-(void) webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"Webi View finish Load");
    [spinner stopAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if ([[webView stringByEvaluatingJavaScriptFromString:@"document.readyState"] isEqualToString:@"complete"]) {
        NSLog(@"Web View Fully Finished Loading");
    }
    
}
@end
