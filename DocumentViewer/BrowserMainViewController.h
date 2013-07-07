//
//  BrowserMainViewController.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-05-01.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Session.h"

@interface BrowserMainViewController : UITableViewController

+(NSURL *) buildUrlFromSession: (Session *) session forEntity:(NSString *) entity withPageSize: (int) pageSize;
@end
