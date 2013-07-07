//
//  BIGetUniverses.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-03-30.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BIConnector.h"
#import "Universe.h"

@class BIGetUniverses;

@protocol BIGetUniversesDelegate <NSObject>
-(void) getUniverses: (BIGetUniverses *) biGetUniverses isSuccess:(BOOL) isSuccess universes:(NSMutableArray*) receivedUniverses;

@end

@interface BIGetUniverses : NSObject <NSURLConnectionDataDelegate, BIConnectorDelegate>

{
    NSMutableData *responseData;
}

@property (strong, nonatomic)   NSError *connectorError;
@property (strong, nonatomic)   NSString *boxiError;
@property (strong, nonatomic)   Session *biSession;
@property (strong, nonatomic) NSManagedObjectContext *context;
@property (nonatomic)   int limit;
@property (nonatomic)   int offset;
@property (strong, nonatomic) NSString *currentToken;


@property (nonatomic, weak) id <BIGetUniversesDelegate> delegate;

-(void) getUniversesForSession: (Session *) session withLimit: (int) limit withOffset:(int) offset;

-(void) logoOffIfNeeded;

@end
