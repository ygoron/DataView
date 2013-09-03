//
//  MobileSession.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-09-01.
//  Copyright (c) 2013 APOS Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MobileSession : NSObject
@property (nonatomic, strong) NSString *logonToken;
@property (nonatomic , strong) NSString *wcaToken;
@property (nonatomic, strong) NSString *bSerializedSession;
@property (nonatomic, strong) NSString *serializedSession;
@property (nonatomic, strong) NSString *productVersion;
@property (nonatomic, strong) NSString *internalVersion;
@end
