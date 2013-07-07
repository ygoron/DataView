//
//  BILogoff.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-02-21.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Session.h"

@class BILogoff;

@protocol BILogoffDelegate <NSObject>
- (void)biLogoff: (BILogoff *) biLogoff didLogoff:(BOOL) isSuccess;
@end

@interface BILogoff : NSObject <NSURLConnectionDelegate>

{
    NSMutableData *responseData;
}

@property (strong, nonatomic)   NSError *connectorError;
@property (strong, nonatomic)   NSString *boxiError;
@property (strong, nonatomic)   Session *biSession;
@property (nonatomic, weak) id <BILogoffDelegate> delegate;

-(void) logoffSession: (Session *) session withToken:(NSString *) token;
-(void)logoffSessionSync: (Session*) session withToken:(NSString *) token;


@end
