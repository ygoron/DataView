//
//  BISDKCall.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-05-03.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BIConnector.h"
#import "InfoObject.h"

@class CypressResponseHeader;
@class BISDKCall;

@protocol CypressSDKDelegate <NSObject>

-(void) cypressCallForChildren:  (BISDKCall *) biSDKCall  withResponse:(CypressResponseHeader *) response isSuccess:(BOOL) isSuccess withChildrenObjects:(NSArray *) receivedObjects ;

-(void) cypressCallSelectedObject:  (BISDKCall *) biSDKCall  withResponse:(CypressResponseHeader *) response isSuccess:(BOOL) isSuccess withObject:(InfoObject *) receivedObject ;

@end
@interface BISDKCall : NSObject <NSURLConnectionDelegate, BIConnectorDelegate>

{
    NSMutableData *responseData;
}


@property (strong, nonatomic)   NSError *connectorError;
@property (strong, nonatomic)   NSString *boxiError;
@property (strong, nonatomic)   Session *biSession;
@property (strong, nonatomic) NSString *currentToken;
@property (nonatomic, assign) BOOL isFilterByUserName;
@property (nonatomic, assign) int statusCode;



@property (nonatomic, weak) id <CypressSDKDelegate> delegate;

-(void) getObjectsForSession: (Session *) session withUrl: (NSURL *) url;
-(void) getSelectedObjectForSession: (Session *) session withUrl: (NSURL *) url;

-(void) processHttpRequest;

-(NSString *) parseLevelName: (NSString *) name subLevel:(NSString *) subLevel withDictionary: (NSDictionary *) dictionary;

-(void) logoOffIfNeeded;

@end
