//
//  SessionDetailViewController.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-02-17.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Session.h"
#import "BIConnector.h"
#import "BILogoff.h"


@class SessionDetailViewController;

@protocol SessionDetailsViewControllerDelegate <NSObject>
- (void)sessionDetailViewControllerDidCancel:(SessionDetailViewController *)controller;
- (void)sessionDetailsViewController:(SessionDetailViewController *)controller didAddSession:(Session *) session ;
- (void)sessionDetailsViewController:(SessionDetailViewController *)controller didUpdateSession:(Session *) session atIndex:(NSIndexPath *) indexPath;
@end


@interface SessionDetailViewController : UITableViewController <BIConnectorDelegate,BILogoffDelegate>


@property (nonatomic, strong) NSMutableArray *allSessions;
@property (nonatomic,strong) Session *editedSession;
@property (nonatomic,strong,getter = theNewSession) Session *newSession;
@property (nonatomic,strong) NSIndexPath *editedIndexPath;

@property (strong, nonatomic) IBOutlet UITextField *sessionNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *sessionWCATextField;
@property (strong, nonatomic) IBOutlet UITextField *sessionUserNameTextField;
@property (strong, nonatomic) IBOutlet UITextField *sessionUserPasswordTextField;
@property (strong, nonatomic) IBOutlet UISegmentedControl *sessionSegmentedControl;
@property (strong, nonatomic) IBOutlet UISwitch *sessionHttpsSwitchControl;
@property (strong, nonatomic) IBOutlet UISwitch *sessionIsEnbaledSwitchControl;
@property (strong, nonatomic) IBOutlet UITextField *sessionPortControl;

@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UILabel *labelServerName;
@property (strong, nonatomic) IBOutlet UILabel *labelUserName;
@property (strong, nonatomic) IBOutlet UILabel *labelPassword;
@property (strong, nonatomic) IBOutlet UILabel *labelHTTPS;
@property (strong, nonatomic) IBOutlet UILabel *labelPort;
@property (strong, nonatomic) IBOutlet UILabel *labelDefault;
@property (strong, nonatomic) IBOutlet UITableView *labelTestConnection;

@property (nonatomic, weak) id <SessionDetailsViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL isNewSessionTestedOK;

-(void) disableOtherSession:(Session *) defaultSession WithAllSessions:(NSMutableArray *) allSessions;
- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;
-(void)saveSession;
-(void) testConnection;
-(void) cutsomizeTextField: (UITextField *) textField;
-(BOOL) isNameAlreadyExistWithName: (NSString *) name WithSessions:(NSMutableArray *) existingSessions;

@end
