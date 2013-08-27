//
//  DocumentDetailsViewController.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-02-28.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Document.h"
#import "BIGetDocumentDetails.h"
#import "BIGetReports.h"


@interface DocumentDetailsViewController : UITableViewController <BIGetDocumentDetailsDelegate,BIGetReportsDelegate,UIActionSheetDelegate, BIConnectorDelegate>
@property (nonatomic, strong) Document *document;
@property (nonatomic, assign) BOOL isInstance;
@property (nonatomic, strong) UIBarButtonItem *actionButton;
@property (nonatomic, strong) UIActionSheet *actionSheet;
@property (nonatomic, assign, getter = isPicVisible) BOOL picVisible;
@property (nonatomic, assign) BOOL isExternalFormat;

//-(void) createTokenAndLaunchOpenDocWithSession: (Session *) session forDocumentId:(int) docId;
-(void) createTokenAndLaunchOpenDocWithSession: (Session *) session forDocument:(Document*) document;
//-(void) launchOpenDocWithSession:(Session *) session forDocumentId: (int) id;
-(void) launchOpenDocWithSession:(Session *) session forDocument:(Document*) document;
-(void) logoOffIfNeeded;

@end
