//
//  BIGetDocumentDetails.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-02-26.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Document.h"
#import "BIConnector.h"

@class BIGetDocumentDetails;

@protocol BIGetDocumentDetailsDelegate <NSObject>

- (void) biGetDocumentDetails: (BIGetDocumentDetails *) biGetDocumentDetails isSuccess:(BOOL) isSuccess document:(Document *) receivedDocument;

@end

@interface BIGetDocumentDetails : NSObject <NSURLConnectionDelegate, BIConnectorDelegate>

{
    NSMutableData *responseData;
}

@property (strong, nonatomic)   NSError *connectorError;
@property (strong, nonatomic)   NSString *boxiError;
@property (strong, nonatomic)   Session *biSession;
@property (strong, nonatomic)   Document *document;
@property (nonatomic, assign)   BOOL isInstance;
@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) NSString *currentToken;


@property (nonatomic, weak) id <BIGetDocumentDetailsDelegate> delegate;

-(void) getDocumentDetailForDocument: (Document *) document;
-(void) getDocumentDetailForDocument: (Document *) document withToken:(NSString *) token;
-(void) logoOffIfNeeded;

@end

