//
//  WebiPrompts.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-09-29.
//  Copyright (c) 2013 APOS Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WebiPromptsEngine;

@protocol WebiPromptsEngineDelegate <NSObject>

-(void) getPrompts:(WebiPromptsEngine *) webiPrompts isSuccess:(BOOL)  isSuccess;

@end
@interface WebiPrompts : NSObject

@end
