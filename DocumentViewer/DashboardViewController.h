//
//  DashboardViewController.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-09-02.
//  Copyright (c) 2013 APOS Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MobileBIService.h"


@interface DashboardViewController : UIViewController <UIWebViewDelegate,MobileBiServiceDelegate>

@property (strong, nonatomic) NSString *dashboardCuid;
@property (strong, nonatomic) IBOutlet UIWebView *webiView;

-(void) loadDashBoard;
@end
