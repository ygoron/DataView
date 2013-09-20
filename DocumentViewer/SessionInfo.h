//
//  SessionInfo.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-09-17.
//  Copyright (c) 2013 APOS Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Response.h"

@interface SessionInfo : Response
@property (strong,nonatomic) NSString *mobileServiceVersion;
@property (assign,nonatomic) NSInteger biPlatformVersion;

@end
