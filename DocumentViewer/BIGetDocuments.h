//
//  BIGetDocuments.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-02-22.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Session.h"
#import "BIConnector.h"

@class BIGetDocuments;

@protocol BIGetDocumentsDelegate <NSObject>

- (void) biGetDocuments: (BIGetDocuments *) biGetDocuments isSuccess:(BOOL) isSuccess documents:(NSMutableArray *) receivedDocuments;

@end

@interface BIGetDocuments : NSObject <NSURLConnectionDelegate, BIConnectorDelegate>

{
    NSMutableData *responseData;
}

@property (strong, nonatomic)   NSError *connectorError;
@property (strong, nonatomic)   NSString *boxiError;
@property (strong, nonatomic)   Session *biSession;
@property (strong, nonatomic) NSManagedObjectContext *context;
//@property (strong, nonatomic) BIConnector *biConnector;
@property (nonatomic)   int limit;
@property (nonatomic)   int offset;

@property (strong, nonatomic) NSString *currentToken;

@property (nonatomic, weak) id <BIGetDocumentsDelegate> delegate;

-(void) getDocumentsForSession: (Session *) session withLimit: (int) limit withOffset:(int) offset;

-(void) logoOffIfNeeded;

@end
