//
//  BrowserObjectActionsViewController.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-05-17.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BISDKCall.h"
#import "BICypressSchedule.h"
#import <AVFoundation/AVFoundation.h>

@class Session;

@interface BrowserObjectActionsViewController : UITableViewController <CypressSDKDelegate,CypressSDKScheduleDelegate>

@property (nonatomic, strong) NSURL *objectUrl;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) Session *currentSession;
@property (nonatomic,strong) InfoObject *selectedObject;
@property (nonatomic, assign) BOOL isInstance;


-(void) getObjectInfo;

@end
