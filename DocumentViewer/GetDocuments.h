//
//  GetDocuments.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-02-21.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Session.h"

@class GetDocuments;

@protocol GetDocumentsDelegate <NSObject>
- (void)getDocuments: (GetDocuments *) getDocuments didGetDocuments:(BOOL) isSuccess;
@end

@interface GetDocuments : NSObject <NSURLConnectionDelegate>

{
    NSMutableData *responseData;
}

@property (strong, nonatomic)   NSError *connectorError;
@property (strong, nonatomic)   NSString *boxiError;
@property (nonatomic, weak) id <GetDocumentsDelegate> delegate;

-(void) getDocumentsFromSession: (Session *) session ;

@end
