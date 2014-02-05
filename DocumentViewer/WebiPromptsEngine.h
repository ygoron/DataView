//
//  WebiPrompts.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-09-29.
//  Copyright (c) 2013 APOS Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BIConnector.h"
#import "WebiPrompt.h"
#import "Session.h"

@class WebiPromptsEngine;


@protocol WebiPromptsEngineDelegate <NSObject>

-(void) didGetPrompts:(WebiPromptsEngine *) webiPromptsEngine isSuccess:(BOOL)  isSuccess withPrompts: (NSArray *) webiPrompts withErrorText:(NSString *) errorText;

@optional
-(void)  didRefreshPrompt:(WebiPromptsEngine *) webiPromptsEngine isSuccess:(BOOL)  isSuccess refreshedPrompts: (NSArray *) webiPrompts  withErrorText:(NSString *) errorText;

@end
@interface WebiPromptsEngine : NSObject <NSURLConnectionDataDelegate,BIConnectorDelegate>

@property (nonatomic, weak) id <WebiPromptsEngineDelegate> delegate;

-(void) getPrompts: (Document *) document;
-(void) refreshPromptForPrompt: (WebiPrompt *) webiPrompt forDocument: (Document *) document;

-(void) getPrompts: (Document *) document withToken: (NSString *) cmsToken;
-(void) getPromptsForDocId: (int) docId withSession: (Session *) session;

@end
