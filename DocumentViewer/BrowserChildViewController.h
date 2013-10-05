//
//  BrowserChildViewController.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-05-09.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BISDKCall.h"
#import "Session.h"
#import "TitleLabel.h"

@interface BrowserChildViewController : UITableViewController <CypressSDKDelegate>
@property (nonatomic, strong) NSURL *urlForChildren;
@property (nonatomic, strong) NSURL *urlForSelectedObject;
@property (nonatomic, strong) NSMutableArray *infoObjects;
@property (nonatomic,strong) InfoObject *selectedObject;
@property (nonatomic,strong) InfoObject *parentObject;
@property (nonatomic, strong) Session *currentSession;
@property (nonatomic, strong) TitleLabel *titleLabel;
@property (nonatomic, assign) BOOL isFilterByUserName;
@property (strong, nonatomic) NSString *displayPath;
@property (nonatomic, assign) BOOL isInstance;
@property (nonatomic, strong) UIStoryboard *myStoryBoard;
@property (nonatomic, assign) BOOL isSupressShowChildrenOfChildren;

-(void) loadObjects;
-(void) reLoadObjects;
-(void) displayHeaderInfoWithInfoObject: (InfoObject *) infoObject;
@end
