//
//  ReportPreviewController.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2/24/2014.
//  Copyright (c) 2014 APOS Systems. All rights reserved.
//

#import "ReportPreviewController.h"
#import "TitleLabel.h"

@interface ReportPreviewController ()

@end

@implementation ReportPreviewController
{
    UIActivityIndicatorView *spinner;
    NSString *exportFilePath;
    TitleLabel *titleLabel;
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
    
    spinner = [[UIActivityIndicatorView alloc]  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin);
    spinner.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    
    titleLabel=[[TitleLabel alloc] initWithFrame:CGRectZero];
    //    self.navigationBar.topItem.titleView=titelLabel;
    self.navigationItem.titleView=titleLabel;
    
    
    self.webView.delegate=self;
    [self.view addSubview:spinner];

    
    tapper = [[UITapGestureRecognizer alloc]init];
    [self.view addGestureRecognizer:tapper];
    tapper.delegate=self;

    [self getHtmlContent];
}

-(void) getHtmlContent{
    //TODO Use BIExportReport
    BIExportReport *exportReport=[[BIExportReport alloc] init];
    [exportReport exportEntityWithUrl:_url withFormat:FormatHTML forSession:_currentSession];
}
-(void) biExportReportExternalFormat:(BIExportReport *)biExportReport isSuccess:(BOOL)isSuccess filePath:(NSString *)filePath WithFormat:(ReportExportFormat)format
{
    NSLog(@"Ignore");
}
-(void)biExportReport:(BIExportReport *)biExportReport isSuccess:(BOOL)isSuccess html:(NSString *)htmlString
{
 
    [spinner stopAnimating];
    
    if (isSuccess==YES){
        NSLog(@"Documents Received");
        [self.webView loadHTMLString:htmlString baseURL:nil];
        
        
        
    }else{
        if (biExportReport.connectorError!=nil){
            UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Load Report Failed",nil) message:[biExportReport.connectorError localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",@"OK on alert window") otherButtonTitles:nil, nil];
            [alert show];
            
        }else if (biExportReport.boxiError!=nil){
            UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Load Report Failed in BI",nil) message:biExportReport.boxiError delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil, nil];
            [alert show];
            
        } else{
            UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Load Report Failed",nil) message:NSLocalizedString(@"Server Error",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil, nil];
            [alert show];
            
        }
        
    }
    
    

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"Start Loading");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"Finish ViewDidFinishLoad");
    self.webView.scalesPageToFit=YES;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    NSString* errorString = [NSString stringWithFormat:
                             @"<html><center><font size=+5 color='blue'>An error occurred:<br>%@</font></center></html>",
                             error.localizedDescription];
    [self.webView loadHTMLString:errorString baseURL:nil];
}


@end
