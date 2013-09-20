//
//  AboutViewController.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-04-28.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import "AboutViewController.h"
#import "WebiAppDelegate.h"
#import "SessionInfo.h"


@interface AboutViewController ()
    
    @end

@implementation AboutViewController
    {
        BIConnector *connector;
        WebiAppDelegate *appDelegate;
        ExtensionPack *extensionPack;
        
        
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
        // Do any additional setup after loading the view.
        NSLog(@"About Screen Loaded");
        [TestFlight passCheckpoint:@"About Screen"];
        //    NSURL *url=[NSURL URLWithString:@"http://www.apos.com/content/apos-bi-ios-app"];
        //    NSURLRequest *urlRequest=[NSURLRequest requestWithURL:url];
        //    [webPageView loadRequest:urlRequest];
        NSMutableString *aboutText=[[NSMutableString alloc]init];
        
        //    [aboutText appendString:@"APOS BI Mobile Application\n"] ;
        NSString *version=[NSString stringWithFormat:@"%@%@%@%@%@",@"Version ",   [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],@"\nBuild ",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"],@"\n"];
        
        [aboutText appendString:version] ;
        [aboutText appendString:@"\n"];
        //    [aboutText appendString:@"http://www.apos.com\n"];
        //    [aboutText appendString:NSLocalizedString(@"Feedback and support: support@apos.com\n",@"Just Feedback and support. Do not translate email:-)")];
        //    [aboutText appendString:NSLocalizedString(@"Feedback and technical support: ",nil)];
        //    [aboutText appendString:@"support@apos.com\n"];
        //    [aboutText appendString:NSLocalizedString(@"Phone:+1.519.894.2767\n",nil)];
        //    [aboutText appendString:@"\n"];
        //    [aboutText appendString:@"100 Conestoga College Blvd., Suite 1118 Kitchener, ON Canada N2P 2N6\n"];
        //    [aboutText appendString:@"\n"];
        //    [aboutText appendString:NSLocalizedString(@"Developed by ",nil)];
        //    [aboutText appendString:@"Yuri Goron \nygoron@apos.com"];
        
        
        _textViewAboutText.text=aboutText;
        [self loadExtensionPackInfo];
    }
    
-(void) loadExtensionPackInfo
    {
        appDelegate = (id)[[UIApplication sharedApplication] delegate];
        if (appDelegate.activeSession!=nil){
            if ([appDelegate.activeSession.isExtensionPack boolValue]==YES){
                if (appDelegate.activeSession.cmsToken==nil || appDelegate.activeSession.password==nil){
                    NSLog(@"CMS Token is NULL - create new one");
                    connector=[[BIConnector alloc]init];
                    connector.delegate=self;
                    [connector getCmsTokenWithSession:appDelegate.activeSession];

                    
                }else{
                    NSLog(@"CMS Token is NOT NULL - Process With Logoff First");
                    BILogoff *biLogoff=[[BILogoff alloc] init];
                    biLogoff.biSession=appDelegate.activeSession;
                    biLogoff.delegate=self;
//                    [biLogoff logoffSessionSync:appDelegate.activeSession withToken:appDelegate.activeSession.cmsToken];
                    [biLogoff logoffSession:appDelegate.activeSession withToken:appDelegate.activeSession.cmsToken];
                    
                }
                
                
                
            }
        }
        
   
    }
    
#pragma mark Token Created
    
-(void) biConnector:(BIConnector *)biConnector didCreateCmsToken:(NSString *)cmsToken forSession:(Session *)session
    {
        
        session.cmsToken=cmsToken;
        extensionPack =[[ExtensionPack alloc] init];
        extensionPack.delegate=self;
        [extensionPack getExtensionPackInfoWithToken:cmsToken forExtensionPackUrl:session.extensionPackUrl];
    }
    
-(void) ExtensionPack:(ExtensionPack *)extensionPack didGetSessionInfo:(SessionInfo *)extensionPackSessionInfo forToken:(NSString *)cmsToken withError:(NSString *)error withSuccess:(BOOL)isSuccess
    {
        NSLog(@"Returned from Extension is Success %d",isSuccess);
        _textViewAboutText.text=[NSString stringWithFormat:@"%@%@%d%@%@%@",_textViewAboutText.text,NSLocalizedString(@"BI Platform Build:", nil),extensionPackSessionInfo.biPlatformVersion,@"\n",NSLocalizedString(@"Extension Pack Version:", nil),extensionPackSessionInfo.mobileServiceVersion];
        
    }
    
#pragma mark Logoff Completed
    
-(void)biLogoff:(BILogoff *)biLogoff didLogoff:(BOOL)isSuccess{
    NSLog(@"Logoff Success? %d",isSuccess);
    connector=[[BIConnector alloc]init];
    connector.delegate=self;
    [connector getCmsTokenWithSession:appDelegate.activeSession];
    
}
    
- (void)didReceiveMemoryWarning
    {
        [super didReceiveMemoryWarning];
        // Dispose of any resources that can be recreated.
    }
    
- (void)viewDidUnload {
    [self setTextViewAboutText:nil];
    [super viewDidUnload];
}
    @end
