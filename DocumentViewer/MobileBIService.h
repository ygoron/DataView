//
//  MobileBIService.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-09-01.
//  Copyright (c) 2013 APOS Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MobileSession;
@class MobileBIService;
@class Session;

//#define MOBILE_SERVICE @"/MobileBIService/MessageHandlerServlet"
#define MOBILE_FUNCTION_LOGON 0
#define MOBILE_FUNCTION_LOGOFF 1
#define MOBILE_FUNCTION_GET_DASHBOARD 2
#define MOBILE_JS_STRING_TO_RERPLACE40 @"this._ceSerializedSession=this._connectionAPI.getInitParameter(l.PARAM_CE_SERIALIZED_SESSION);"
#define MOBILE_JS_STRING_TO_RERPLACE41 @"this._loginSerializedSession=c.loginSerializedSession;"




@protocol MobileBiServiceDelegate <NSObject, NSURLConnectionDelegate>

-(void) sessionReceived: (MobileBIService *) mobileService isSuccess:(BOOL) isSuccess WithMobileSession:(MobileSession *) mobileSession WithErrorText:(NSString *) textString;

-(void) logoffCompleted: (MobileBIService *) mobileService isSuccess:(BOOL) isSuccess;

-(void) DashboardReceived: (MobileBIService *) mobileService isSuccess:(BOOL) isSuccess WithFileLocation:(NSString *) filePath WithError:(NSString *) error WithZipFile: (NSString *) zipFile WithFolder:(NSString *) folderName;

@end

@interface MobileBIService : NSObject <NSXMLParserDelegate>

@property (strong, nonatomic)   NSError *connectorError;
@property (nonatomic, assign) int statusCode;
@property (nonatomic, weak) id <MobileBiServiceDelegate> delegate;

-(void) initMobileWithSession:(Session *) session;
-(void) mobileLogoff;
-(void) getDashboardWithCUID:(NSString *) cuid WithMobileSession:(MobileSession *) mobileSession;

@end
