//
//  BIDeleteDocument.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-03-23.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BIConnector.h"

@class ScheduleDetails;
@class BIDeleteDocument;
@class DeleteStatus;


@protocol BIDeleteDocumentDelegate <NSObject>

- (void) biDeleteDocument: (BIDeleteDocument *) biDeleteDocument isSuccess:(BOOL) isSuccess withDeleteStatus:(DeleteStatus *) deleteStatus;

@end

@interface BIDeleteDocument : NSObject <NSURLConnectionDelegate,BIConnectorDelegate>

{
    NSMutableData *responseData;
    int _docId;
    int _instanceId;
    BOOL _isInstance;
}

@property (strong, nonatomic)   NSError *connectorError;
@property (strong, nonatomic)   NSString *boxiError;
@property (strong, nonatomic)   Session *biSession;

@property (strong, nonatomic) NSManagedObjectContext *context;
@property (nonatomic, weak) id <BIDeleteDocumentDelegate> delegate;
@property (strong, nonatomic) NSString *currentToken;

-(void) deleteDocument: (int) docId withSession:(Session *) session;
-(void) deleteScheduledInstance: (ScheduleDetails *) instance forDocumentId:(int) docId withSession:(Session *) session;
-(void) logoOffIfNeeded;

@end

