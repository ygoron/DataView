//
//  ReportViewController.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-03-01.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import "ReportViewController.h"
#import "BIExportReport.h"
#import "TitleLabel.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "Document.h"
#import "Session.h"
#import "WebiAppDelegate.h"


@interface ReportViewController ()


@end


@implementation ReportViewController{
    UIActivityIndicatorView *spinner;
    ReportExportFormat exportFormat;
    NSString *exportFilePath;
}

@synthesize navigationBar;
@synthesize actionButton;
@synthesize actionSheet=_actionSheet;
@synthesize picVisible;
@synthesize reportHtmlString;

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
    NSLog(@"Web View Loaded");
    
    spinner = [[UIActivityIndicatorView alloc]  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin);
    spinner.center = CGPointMake(self.webView.bounds.size.width / 2.0f, self.webView.bounds.size.height / 2.0f);
    //    spinner.center = CGPointMake(160, 240);
    NSLog(@"Title:%@",self.report.name);
    //    self.navigationBar.topItem.title=self.report.name;
    
    TitleLabel *titelLabel=[[TitleLabel alloc] initWithFrame:CGRectZero];
//    self.navigationBar.topItem.titleView=titelLabel;
    self.navigationItem.titleView=titelLabel;
    titelLabel.text=self.report.name;
    [titelLabel sizeToFit];
    
    
    self.webView.delegate=self;
    [self.view addSubview:spinner];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                               target:self
                                                                               action:@selector(performAction:)];
    
    
    self.actionButton = barButton;
    self.navigationItem.rightBarButtonItem=barButton;
    
    self.picVisible = NO;
    
    [self loadWebView:self.report];
    
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"View Loaded Title:%@",self.report.name);
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) loadWebView:(Report *) report{
    [spinner startAnimating];
    WebiAppDelegate *appDelegate= (id)[[UIApplication sharedApplication] delegate];
    BIExportReport *exportReport=[[BIExportReport alloc]init];
    exportReport.delegate=self;
    exportReport.biSession=appDelegate.activeSession;
    //    [exportReport exportReport:report withFormat:FormatHTML];
    [exportReport exportReport:report withFormat:FormatPDF];
}

-(void)biExportReportPdf:(BIExportReport *)biExportReport isSuccess:(BOOL)isSuccess filePath:(NSString *)filePath{
    [spinner stopAnimating];

    exportFilePath=filePath;
    exportFormat=FormatPDF;

    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.webView setUserInteractionEnabled:YES];
    [self.webView setDelegate:self];
    self.webView.scalesPageToFit = YES;
    [self.webView loadRequest:requestObj];
    
}
-(void) biExportReport:(BIExportReport *)biExportReport isSuccess:(BOOL)isSuccess html:(NSString *)htmlString{
    [spinner stopAnimating];
    exportFormat=FormatHTML;
    
    if (isSuccess==YES){
        NSLog(@"Documents Received");
        self.reportHtmlString=htmlString;
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

- (void)performAction:(id)sender {
    
    NSLog(@"Perform Action");
    
    if ([self.actionSheet isVisible]) {
        [self.actionSheet dismissWithClickedButtonIndex:-1 animated:NO];
        
    } else if ([self isPicVisible]) {
        UIPrintInteractionController *pc = [UIPrintInteractionController sharedPrintController];
        [pc dismissAnimated:YES];
        self.picVisible = NO;
        
    } else {
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            
            [self.actionSheet showFromBarButtonItem:self.actionButton animated:NO];
            
        } else {
            
            [self.actionSheet showInView:[self view]];
        }
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (buttonIndex) {
            //        case 0:
            //            [self openInBrowser];
            //            break;
            
        case 0:
            [TestFlight passCheckpoint:@"Webi Report Open in Mail"];
            [self openInEmail];
            break;
            
        case 1:
            [TestFlight passCheckpoint:@"Print Webi Report"];
            [self printWebView];
            break;
            
            
        default:
            break;
    }
}

-(void) openInSafari
{
    Session *session=self.report.document.session;
    int documentId=[self.report.document.id intValue];
    
    NSString *encodedToken=[session.cmsToken stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Simple Token:%@",session.cmsToken);
    NSLog(@"Encoded Token:%@",encodedToken);
    NSString *openDocumentURL=[NSString stringWithFormat:@"http://%@:%@/BOE/OpenDocument/opendoc/openDocument.jsp?token=%@&iDocID=%d&sViewer=html&sOutputFormat=H",session.cmsName,session.port,encodedToken,documentId];
    NSURL *url=[NSURL URLWithString:openDocumentURL];
    NSLog(@"URL: %@", url);
    if (url) {
        [[UIApplication sharedApplication] openURL:url];
    }
    
}

// Basic Printing
- (void)printWebView
{
    
    UIPrintInteractionController *pc = [UIPrintInteractionController sharedPrintController];
    
    UIPrintInfo *printInfo = [UIPrintInfo printInfo];
    printInfo.outputType = UIPrintInfoOutputGeneral;
    printInfo.jobName = self.report.name;
    pc.printInfo = printInfo;
    
    pc.showsPageRange = YES;
    
    UIViewPrintFormatter *formatter = [self.webView viewPrintFormatter];
    pc.printFormatter = formatter;
    
    UIPrintInteractionCompletionHandler completionHandler =
    ^(UIPrintInteractionController *printController, BOOL completed, NSError *error) {
        if(!completed && error){
            NSLog(@"Print failed - domain: %@ error code %u", error.domain, error.code);
        }
    };
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [pc presentFromBarButtonItem:self.actionButton animated:YES completionHandler:completionHandler];
    } else {
        [pc presentAnimated:YES completionHandler:completionHandler];
    }
}

- (void)openInBrowser {
    
    NSURL *url = [[self.webView request] URL];
    
    if (url) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void)openInEmail {
    
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *viewController = [[MFMailComposeViewController alloc] init];
        viewController.mailComposeDelegate = self;
        
        [viewController setSubject:[NSString stringWithFormat:@"%@ - APOS BI Viewer Mobile App",self.report.name]];
        switch (exportFormat) {
            case FormatHTML:
            {
                if (self.reportHtmlString!=nil){
                    [viewController setMessageBody:self.reportHtmlString isHTML:YES];
                }
            }
                break;
                
            case FormatPDF:
                
            {
                NSLog(@"Sending File:%@",exportFilePath);
                NSURL *pdfURL= [NSURL fileURLWithPath:exportFilePath];
                NSData *data = [NSData dataWithContentsOfURL:pdfURL];
                [viewController addAttachmentData:data mimeType:@"application/pdf" fileName:[NSString stringWithFormat:@"%@%@",_report.name,@".pdf"]];
                
            }
                break;
            default:
                break;
        }
        
//        [self presentModalViewController:viewController animated:YES];
        [self presentViewController:viewController animated:YES completion:nil];
    }
}


- (UIActionSheet *)actionSheet {
    
    if (_actionSheet == nil) {
        
        NSString *cancelButtonTitle = NSLocalizedString(@"Cancel",nil);
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            cancelButtonTitle = nil;
        }
        
        if ([UIPrintInteractionController isPrintingAvailable]) {
            _actionSheet = [[UIActionSheet alloc]
                            initWithTitle:nil
                            delegate:self
                            cancelButtonTitle:cancelButtonTitle
                            destructiveButtonTitle:nil
                            otherButtonTitles:NSLocalizedString(@"E-mail",nil), NSLocalizedString(@"Print",nil), nil];
        } else {
            _actionSheet = [[UIActionSheet alloc]
                            initWithTitle:nil
                            delegate:self
                            cancelButtonTitle:cancelButtonTitle
                            destructiveButtonTitle:nil
                            otherButtonTitles:NSLocalizedString(@"E-mail",nil),nil];
        }
    }
    
    return _actionSheet;
}


- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
//	[self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)printInteractionControllerDidPresentPrinterOptions:(UIPrintInteractionController *)printInteractionController {
    self.picVisible = YES;
}

- (void)printInteractionControllerDidDismissPrinterOptions:(UIPrintInteractionController *)printInteractionController {
    self.picVisible = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.webView stopLoading];
    self.webView.delegate = nil;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        if ([self isPicVisible]) {
            UIPrintInteractionController *pc = [UIPrintInteractionController sharedPrintController];
            [pc dismissAnimated:animated];
            self.picVisible = NO;
        }
        
        if ([self.actionSheet isVisible]) {
            [self.actionSheet dismissWithClickedButtonIndex:-1 animated:NO];
        }
    }
}


- (IBAction)closeView:(id)sender {
    NSLog(@"Close Web View");
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
