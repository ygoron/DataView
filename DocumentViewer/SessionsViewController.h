//
//  SessionsViewController.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-02-16.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SessionDetailViewController.h"
#import "BILogoff.h"

@interface SessionsViewController : UITableViewController <SessionDetailsViewControllerDelegate,BILogoffDelegate>

@property (nonatomic, strong) NSMutableArray *sessions;
-(void) saveContext;
-(BOOL)isSwitchToDocumentsViewAllowed;
-(void) switchToDocumentListWithRefresh;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *buttonAddSession;



@end
