//
//  ExtensionPack.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-09-17.
//  Copyright (c) 2013 APOS Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ExtensionPack;

@class SessionInfo;
@protocol ExtensionPackDelegate <NSObject>
- (void)ExtensionPack:(ExtensionPack *)extensionPack didGetSessionInfo:(SessionInfo *) extensionPackSessionInfo forToken:(NSString *) cmsToken withError: (NSString *) error withSuccess:(BOOL) isSuccess;
@end

#define FUNCTION_GET_SESSION 0

@interface ExtensionPack : NSObject <NSURLConnectionDelegate>

{
    NSData *jsonData;
    NSString *jsonString;
    NSMutableData *responseData;
}


@property (nonatomic, weak) id <ExtensionPackDelegate> delegate;
@property (nonatomic, assign) NSTimeInterval timeOut;
@property (nonatomic, assign) int statusCode;

-(void) getExtensionPackInfoWithToken: (NSString *) cmsToken forExtensionPackUrl:(NSString *) url;

@end
