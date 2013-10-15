//
//  BIRefreshDocument.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-10-12.
//  Copyright (c) 2013 APOS Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BIConnector.h"

@class BIRefreshDocument;
@protocol BIRefreshDocumentDelegate <NSObject>

-(void) biRefreshDocument: (BIRefreshDocument *) biRefreshDocument isSuccess:(BOOL) isSuccess withMessage:(NSString *) message;

@end
@interface BIRefreshDocument : NSObject <NSURLConnectionDataDelegate, BIConnectorDelegate>

@property (strong, nonatomic)   NSError *connectorError;
@property (strong, nonatomic)   NSString *boxiError;
@property (strong, nonatomic) NSString *currentToken;
@property (nonatomic, weak) id <BIRefreshDocumentDelegate> delegate;

-(void) refreshDocument: (Document *) document withPrompts:(NSArray *) webiPromts;

@end
