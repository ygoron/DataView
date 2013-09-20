//
//  ExtensionPackViewController.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-09-16.
//  Copyright (c) 2013 APOS Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Session.h"
#import "BIConnector.h"
#import "BILogoff.h"
#import "ExtensionPack.h"

@interface ExtensionPackViewController : UITableViewController <BIConnectorDelegate,BILogoffDelegate,ExtensionPackDelegate>


@property (strong, nonatomic) Session *session;
@property (strong, nonatomic) IBOutlet UITextField *textFieldUrl;
@property (strong, nonatomic) IBOutlet UISwitch *switchFieldIsEnabled;


@end
