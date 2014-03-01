//
//  ReportPreviewController.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2/24/2014.
//  Copyright (c) 2014 APOS Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Session.h"
#import "BIExportReport.h"

@interface ReportPreviewController : UIViewController  <BIExportReportDelegate,UIWebViewDelegate,UIGestureRecognizerDelegate>

@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) Session *currentSession;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@end
