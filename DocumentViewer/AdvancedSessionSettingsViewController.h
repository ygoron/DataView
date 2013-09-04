//
//  AdvancedSessionSettingsViewController.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-04-20.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Session.h"

@interface AdvancedSessionSettingsViewController : UITableViewController
@property (strong, nonatomic) IBOutlet UITextField *textfieldOpenDocHost;
@property (strong, nonatomic) IBOutlet UITextField *textFieldOpenDocPort;
@property (strong, nonatomic) IBOutlet UITextField *textFieldRESTBase;
@property (strong, nonatomic) IBOutlet UITextField *textFieldRESTWebiBase;
@property (strong, nonatomic) IBOutlet UITextField *textFieldMobiPath;
@property (strong, nonatomic) IBOutlet UITextField *textFieldMobiPort;
@property (strong, nonatomic) IBOutlet UITextField *textCmsNameEx;

@property (strong, nonatomic) Session *session;
@end
