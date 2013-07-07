//
//  BIScheduleDocument.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-03-18.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BIConnector.h"

@class BIScheduleDocument;
@class ScheduleStatus;
@class Destination;
@class Format;


@protocol BIScheduleDocumentDelegate <NSObject>

-(void) biScheduleDocument: (BIScheduleDocument *) biScheduleDocument isSuccess:(BOOL) isSuccess withScheduleStatus:(ScheduleStatus *) scheduleStatus;

@end

@interface BIScheduleDocument : NSObject <NSURLConnectionDelegate, BIConnectorDelegate>

{
    NSMutableData *responseData;
}

@property (strong, nonatomic)   NSError *connectorError;
@property (strong, nonatomic)   NSString *boxiError;
@property (strong, nonatomic)   Session *biSession;
@property (strong, nonatomic)   Document *document;
@property (strong, nonatomic)   Destination *destination;
@property (strong, nonatomic)   Format *format;
@property (strong, nonatomic) NSString *currentToken;


@property (nonatomic, weak) id <BIScheduleDocumentDelegate> delegate;

-(void) scheduleDocument: (Document *) document withDestination:(Destination *)  destination withFormat:(Format *) format;
-(void) logoOffIfNeeded;

@end
