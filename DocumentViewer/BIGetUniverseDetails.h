//
//  BIGetUniverseDetails.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-03-30.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BIConnector.h"
#import "Universe.h"
#import "BI4RestConstants.h"

@class BIGetUniverseDetails;
@class UniverseDetail;

@protocol BIGetUniverseDetailsDelegate <NSObject>

-(void) getUniverseDetails: (BIGetUniverseDetails *) biGetUniverseDetails isSuccess:(BOOL) isSuccess WithUniverseDetails:(NSMutableArray *) universeDetails;

@end

@interface BIGetUniverseDetails : NSObject <NSURLConnectionDelegate,BIConnectorDelegate>
{
    NSMutableData *responseData;
    Universe *_universe;
}

@property (strong, nonatomic)   NSError *connectorError;
@property (strong, nonatomic)   NSString *boxiError;
@property (strong, nonatomic)   Session *biSession;
@property (strong, nonatomic) NSManagedObjectContext *context;

@property (strong, nonatomic) NSString *currentToken;


@property (nonatomic, weak) id <BIGetUniverseDetailsDelegate> delegate;

-(void) getUniverseDetails: (Universe *) universe;
-(void) logoOffIfNeeded;


@end

