//
//  BISaveDocument.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-10-28.
//  Copyright (c) 2013 APOS Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BIConnector.h"

@class BISaveDocument;
@protocol BISaveDocumentDelegate <NSObject>

-(void) biSaveDocument:(BISaveDocument *) biSaveDocument isSuccess: (BOOL) isSuccess withMessage: (NSString *) message;

@end
@interface BISaveDocument : NSObject <NSURLConnectionDataDelegate, BIConnectorDelegate>

@property (strong, nonatomic)   NSError *connectorError;
@property (strong, nonatomic)   NSString *boxiError;
@property (strong, nonatomic) NSString *currentToken;
@property (nonatomic, weak) id <BISaveDocumentDelegate> delegate;

-(void) saveDocument: (Document *) document;

@end
