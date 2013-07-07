//
//  BIGetScheduleDetail.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-03-04.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ScheduleDetails.h"
#import "BIConnector.h"
#import "Document.h"

@class BIGetScheduleDetail;

@protocol BIGetScheduleDetailDelegate <NSObject>

- (void) biGetScheduleDetails: (BIGetScheduleDetail *) biGetScheduleDetail isSuccess:(BOOL) isSuccess scheduleDetails:(NSMutableArray *) scheduleDetails;

@end

@interface BIGetScheduleDetail : NSObject <NSURLConnectionDelegate, BIConnectorDelegate>

{
    NSMutableData *responseData;
}

@property (strong, nonatomic)   NSError *connectorError;
@property (strong, nonatomic)   NSString *boxiError;
@property (strong, nonatomic)   Session *biSession;
@property (strong, nonatomic)   Document *document;
@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) NSString *currentToken;



@property (nonatomic, weak) id <BIGetScheduleDetailDelegate> delegate;

-(void) geScheduleDetailForDocument: (Document *) document ;
-(void) logoOffIfNeeded;


@end
