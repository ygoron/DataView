//
//  BIGetReports.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-02-28.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BIConnector.h"


@class BIGetReports;

@protocol BIGetReportsDelegate <NSObject>

- (void) biGetReports: (BIGetReports *) biGetReports isSuccess:(BOOL) isSuccess reports:(NSMutableArray *) receivedReports;

@end

@interface BIGetReports : NSObject <NSURLConnectionDelegate, BIConnectorDelegate>

{
    NSMutableData *responseData;
}

@property (strong, nonatomic)   NSError *connectorError;
@property (strong, nonatomic)   NSString *boxiError;
@property (strong, nonatomic)   Session *biSession;
@property (strong, nonatomic)   Document *document;
@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) NSString *currentToken;

@property (nonatomic, weak) id <BIGetReportsDelegate> delegate;

-(void) getReportsForDocument: (Document *) document;
-(void) getReportsForDocument: (Document *) document withToken: (NSString *) cmsToken;
-(void) logoOffIfNeeded;

@end
