//
//  OpenDocumentViewController.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-05-19.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BISDKCall.h"
#import "BILogoff.h"



@interface OpenDocumentViewController : UIViewController <UIWebViewDelegate,CypressSDKDelegate,BIConnectorDelegate,BILogoffDelegate>
@property (nonatomic,strong) NSURL *openDocUrl;
@property (nonatomic,strong) NSURL *selectedObjectUrl;
@property (nonatomic,strong) NSURL *logoffUrl;
@property (nonatomic, assign) BOOL isGetOpenDocRequired;
@property (nonatomic, strong) NSNumber *objectId;
@property (nonatomic, assign) BOOL isOpenDocumentManager;
@property (strong, nonatomic) InfoObject *infoObject;
@property (strong, nonatomic) IBOutlet UIWebView *webiView;
@property (strong, nonatomic) NSString *cmsToken;
@property (strong, nonatomic) Session *currentSession;



-(void) reloadOpenDocView;
-(void)loadOpenDocumentWithUrl: (NSURL *) url;
-(void)getOpenDocumentUrl;
-(void)createCmsTokenForSession: (Session *) session;

@end
