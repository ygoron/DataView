//
//  BIConnector.h
//  WebiViewer
//
//  Created by Yuri Goron on 2013-02-12.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Session.h"

@class BIConnector;

@protocol BIConnectorDelegate <NSObject,UIAlertViewDelegate>
- (void)biConnector:(BIConnector *)biConnector didCreateCmsToken:(NSString *) cmsToken forSession:(Session *) session ;
@end

@interface BIConnector : NSObject
{
    NSData *jsonData;
    NSString *jsonString;
    NSMutableData *responseData;
}

@property (weak, nonatomic)   NSString *url;
@property (weak, nonatomic)   NSString *user;
@property (weak, nonatomic)   NSString *password;
@property (weak, nonatomic)   NSString *authType;
@property (strong, nonatomic)   NSError *connectorError;
@property (strong, nonatomic)   NSString *boxiError;
@property (strong, nonatomic)   NSString *cmsToken;
@property (strong, nonatomic)   Session *biSession;
@property (nonatomic, strong) id <BIConnectorDelegate> delegate;
@property (nonatomic, assign) NSTimeInterval timeOut;
@property (nonatomic, assign) NSInteger option;




-(void) getCmsTokenWithSession: (Session *) session;

@end
