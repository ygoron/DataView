//
//  ReportViewController.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-03-01.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import "ReportViewController.h"
#import "BIExportReport.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "Document.h"
#import "Session.h"
#import "WebiAppDelegate.h"
#import "TitleLabel.h"



@interface ReportViewController ()


@end


@implementation ReportViewController{
    UIActivityIndicatorView *spinner;
    NSString *exportFilePath;
    TitleLabel *titleLabel;
    UIGestureRecognizer *tapper;
    
}

//@synthesize navigationBar;
//@synthesize actionButton;
//@synthesize actionSheet=_actionSheet;
//@synthesize picVisible;
//@synthesize reportHtmlString;

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
    spinner.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    //    spinner.center = CGPointMake(self.webView.bounds.size.width / 2.0f, self.webView.bounds.size.height / 2.0f);
    //    spinner.center = CGPointMake(160, 240);
    NSLog(@"Title:%@",self.report.name);
    //    self.navigationBar.topItem.title=self.report.name;
    
    titleLabel=[[TitleLabel alloc] initWithFrame:CGRectZero];
    //    self.navigationBar.topItem.titleView=titelLabel;
    self.navigationItem.titleView=titleLabel;
    
    
    self.webView.delegate=self;
    [self.view addSubview:spinner];
    
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                               target:self
                                                                               action:@selector(performAction:)];
    [barButton setTintColor:[UIColor whiteColor]];
    
    tapper = [[UITapGestureRecognizer alloc]init];
    [self.view addGestureRecognizer:tapper];
    tapper.delegate=self;
    
    self.actionButton = barButton;
    self.navigationItem.rightBarButtonItem=barButton;
    
    self.picVisible = NO;
    
    [self.actionButton setEnabled:NO];
    
    if (_url){
        [self loadWebViewWithUrl:_url];
    }else
        if (_isRefreshDocument==YES){
            [self refreshDocument];
        }else{
            
            if (_isOpenWholeDocument==NO) {
                //        titelLabel.text=self.report.name;
                //        [titelLabel sizeToFit];
                [self loadWebViewWithReport:self.report];
            }
            else {
                //        titelLabel.text=_document.name;
                //        [titelLabel sizeToFit];
                
                
                [self loadWebViewWithDocument:_document];
                
            }
        }
    
}

-(void) refreshDocument
{
    
    [spinner startAnimating];
    BIRefreshDocument *refreshDoc=[[BIRefreshDocument alloc] init];
    refreshDoc.delegate=self;
    [refreshDoc refreshDocument:_document withPrompts:_webiPrompts];
    
}

-(void) biRefreshDocument:(BIRefreshDocument *)biRefreshDocument isSuccess:(BOOL)isSuccess withMessage:(NSString *)message
{
    NSLog("Document Refreshed. isSuccess: %d. Message:%@",isSuccess,message);
    [spinner stopAnimating];
    if (isSuccess==NO){
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failed",nil) message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
    }else{
        [spinner startAnimating];
        _exportFormat=FormatPDF;
        [self loadWebViewWithDocument:_document];
    }
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    NSLog(@"preferredStatusBarStyle");
    //    return UIStatusBarStyleLightContent;
    return UIStatusBarStyleDefault;
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"View will appear with title:%@",_titleText);
    titleLabel.text=_titleText;
    [titleLabel sizeToFit];
}
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"Start Loading");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [self.actionButton setEnabled:NO];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //    [self.navigationController setNavigationBarHidden:YES animated:YES];
    NSLog(@"Finish ViewDidFinishLoad");
    if (_isOpenWholeDocument==NO)
        NSLog(@"View Loaded Title:%@",self.report.name);
    else
        NSLog(@"View Loaded Title:%@",self.document.name);
    self.webView.scalesPageToFit=YES;
    self.webView.contentMode = UIViewContentModeScaleAspectFit;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    [self.actionButton setEnabled:YES];
    
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


-(void) loadWebViewWithUrl:(NSURL *) url{
    [spinner startAnimating];
    NSLog (@"Load Web View For Format:%d",_exportFormat);
    BIExportReport *exportReport=[[BIExportReport alloc]init];
    exportReport.delegate=self;
    exportReport.exportFormat=_exportFormat;
    exportReport.biSession=_currentSession;
    exportReport.isExportWithUrl=YES;
    //       appDelegate.activeSession.cmsToken=nil; // Fixed Error - The requested URL is not found
    //    [exportReport exportReport:report withFormat:FormatHTML];
    [exportReport exportEntityWithUrl:url withFormat:_exportFormat forSession:_currentSession];
}


-(void) loadWebViewWithReport:(Report *) report{
    [spinner startAnimating];
    NSLog (@"Load Web View For Format:%d",_exportFormat);
    WebiAppDelegate *appDelegate= (id)[[UIApplication sharedApplication] delegate];
    BIExportReport *exportReport=[[BIExportReport alloc]init];
    exportReport.delegate=self;
    exportReport.exportFormat=_exportFormat;
    exportReport.biSession=appDelegate.activeSession;
    //       appDelegate.activeSession.cmsToken=nil; // Fixed Error - The requested URL is not found
    //    [exportReport exportReport:report withFormat:FormatHTML];
    [exportReport exportReport:report withFormat:_exportFormat];
}

-(void) loadWebViewWithDocument:(Document *) document{
    [spinner startAnimating];
    NSLog (@"Load Web View For Format:%d",_exportFormat);
    WebiAppDelegate *appDelegate= (id)[[UIApplication sharedApplication] delegate];
    BIExportReport *exportReport=[[BIExportReport alloc]init];
    exportReport.delegate=self;
    exportReport.exportFormat=_exportFormat;
    //    appDelegate.activeSession.cmsToken=nil; // Fixed Error - The requested URL is not found
    
    exportReport.biSession=appDelegate.activeSession;
    //    [exportReport exportReport:report withFormat:FormatHTML];
    NSLog(@"Document Name:%@",document.name);
    [exportReport exportDocument:document withFormat:_exportFormat];
}

-(void)biExportReportExternalFormat:(BIExportReport *)biExportReport isSuccess:(BOOL)isSuccess filePath:(NSString *)filePath WithFormat:(ReportExportFormat)format
{
    [spinner stopAnimating];
    
    exportFilePath=filePath;
    //    exportFormat=FormatPDF;
    _exportFormat=format;
    
    NSURL *url = [NSURL fileURLWithPath:filePath];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [self.webView setUserInteractionEnabled:YES];
    [self.webView setDelegate:self];
    self.webView.scalesPageToFit = YES;
    NSLog(@"Load Request With URL %@",url);
    [self.webView loadRequest:requestObj];
    
}
-(void) biExportReport:(BIExportReport *)biExportReport isSuccess:(BOOL)isSuccess html:(NSString *)htmlString{
    [spinner stopAnimating];
    _exportFormat=FormatHTML;
    
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
            [TestFlight passCheckpoint:@"Save Document"];
            [self saveReport];
            break;
            
            
        case 1:
            [TestFlight passCheckpoint:@"Webi Report Open in Mail"];
            [self openInEmail];
            break;
            
        case 2:
            [TestFlight passCheckpoint:@"Print Webi Report"];
            [self printWebView];
            break;
            
            
        default:
            break;
    }
}

-(void) saveReport
{
    BISaveDocument *saveDocument=[[BISaveDocument alloc] init];
    [saveDocument setDelegate:self];
    [saveDocument saveDocument:_document];
    
}
-(void) biSaveDocument:(BISaveDocument *)biSaveDocument isSuccess:(BOOL)isSuccess withMessage:(NSString *)message
{
    if (isSuccess==NO){
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failed",nil) message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
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
        
        //        [viewController setSubject:[NSString stringWithFormat:@"%@ - APOS BI Viewer Mobile App",self.report.name]];
        [viewController setSubject:[NSString stringWithFormat:@"%@ - APOS BI Viewer Mobile App",(self.report.name==nil)?_titleText:self.report.name]];
        switch (_exportFormat) {
            case FormatHTML:
            {
                if (self.reportHtmlString!=nil){
                    [viewController setMessageBody:self.reportHtmlString isHTML:YES];
                }
            }
                break;
                
            case FormatPDF:
            case FormatEXCEL:
                
            {
                NSLog(@"Sending File:%@",exportFilePath);
                NSURL *pdfURL= [NSURL fileURLWithPath:exportFilePath];
                NSData *data = [NSData dataWithContentsOfURL:pdfURL];
                [viewController addAttachmentData:data mimeType:(_exportFormat==FormatPDF)?@"application/pdf":@"application/vnd.ms-excel" fileName:[NSString stringWithFormat:@"%@%@",(self.report.name==nil)?_titleText:self.report.name,(_exportFormat==FormatPDF)?@".pdf":@".xlsx"]];
                
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
                            otherButtonTitles:NSLocalizedString(@"Save",nil),NSLocalizedString(@"E-mail",nil), NSLocalizedString(@"Print",nil), nil];
        } else {
            _actionSheet = [[UIActionSheet alloc]
                            initWithTitle:nil
                            delegate:self
                            cancelButtonTitle:cancelButtonTitle
                            destructiveButtonTitle:nil
                            otherButtonTitles:NSLocalizedString(@"Save",nil),NSLocalizedString(@"E-mail",nil),nil];
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
    
    if (exportFilePath!=nil){
        NSError *error;
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        if ([fileMgr removeItemAtPath:exportFilePath error:&error] != YES)
            NSLog(@"Unable to delete file: %@", [error localizedDescription]);
        else{
            NSLog(@"File %@ - deleted",exportFilePath);
        }
    }
}

//-(BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
//{
//
//    NSLog(@"Hanlde Single Tap - 0");
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


- (IBAction)closeView:(id)sender {
    NSLog(@"Close Web View");
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
