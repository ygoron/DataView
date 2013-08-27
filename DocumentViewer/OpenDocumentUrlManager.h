//
//  OpenDocumentUrlManager.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-08-23.
//  Copyright (c) 2013 APOS Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BISDKCall.h"
#import "WebiAppDelegate.h"

@class OpenDocumentUrlManager;


@protocol OpenDocDelegate <NSObject>

-(void) openDocHackView:  (OpenDocumentUrlManager *) openDocManager  IsSuccess:(BOOL) isSuccess WithUrl: (NSURL *) url LogOffUrl: (NSURL *) logoffUrl withBTToken:(NSString *) bttoken;
-(void) getBTToken: (OpenDocumentUrlManager *) openDocManeger IsSuccess:(BOOL) isSuccess LogOffUrl: (NSURL *) logoffUrl withBTToken:(NSString *) bttoken WithOpenDocURL: (NSURL *) openDocUrl;

@end
@interface OpenDocumentUrlManager : NSObject <UIWebViewDelegate,CypressSDKDelegate>

@property (nonatomic,strong) Session *currentSession;
@property (nonatomic,strong) WebiAppDelegate *webiAppDelegate;
@property (nonatomic,strong) NSNumber *objectId;
@property (nonatomic, weak) id <OpenDocDelegate> delegate;
@property (nonatomic, assign) int statusCode;
@property (strong, nonatomic)   NSError *connectorError;


-(void) getWebiViewUrl;
-(void) getBTToken;

@end
