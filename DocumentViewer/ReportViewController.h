//
//  ReportViewController.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-03-01.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Report.h"
#import "BIExportReport.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface ReportViewController : UIViewController <BIExportReportDelegate,UIWebViewDelegate,
UIActionSheetDelegate,
UIPrintInteractionControllerDelegate,
MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UIWebView *webView;
@property (nonatomic, strong) Report *report;
@property (strong, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, strong) UIBarButtonItem *actionButton;
@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic, assign, getter = isPicVisible) BOOL picVisible;
@property (nonatomic, strong) NSString *reportHtmlString;


- (IBAction)closeView:(id)sender;

@end
