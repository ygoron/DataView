//
//  BICypressSchedule.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-05-20.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BIConnector.h"
#import "Session.h"

@class BICypressSchedule;

@protocol CypressSDKScheduleDelegate <NSObject>
-(void)availableSchedules: (BICypressSchedule *) biCypressSchedule withUrls:(NSArray *) urls isSuccess:(BOOL) isSucess;
-(void)scheduleResult: (BICypressSchedule *) biCypressSchedule withData:(NSDictionary *) data withUrl:(NSURL *) scheduleUrl isSuccess:(BOOL) isSucess;
@end

@interface BICypressSchedule : NSObject <NSURLConnectionDelegate, BIConnectorDelegate>

{
    NSMutableData *responseData;
    NSData *jsonData;
    NSString *jsonString;
}


@property (strong, nonatomic)   NSError *connectorError;
@property (strong, nonatomic)   NSString *boxiError;
@property (strong, nonatomic)   Session *biSession;
@property (strong, nonatomic) NSString *currentToken;

@property (nonatomic, weak) id <CypressSDKScheduleDelegate> delegate;

-(void) getScheduleFormsWithUrl: (NSURL *) scheduleFormUrl forSession: (Session *) session;
-(void) scheduleWithUrl: (NSURL *) scheduleUrl withData:(NSDictionary *) scheduleDataForm forSession:(Session *) session;

-(void) processHttpRequestForScheduleForms;
-(void) processHttpRequestForScheduleObjectWithData: (NSDictionary *) dataDic;

-(NSString *) parseLevelName: (NSString *) name subLevel:(NSString *) subLevel withDictionary: (NSDictionary *) dictionary;

-(void) logoOffIfNeeded;

@end
