//
//  WebiPrompt.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-09-29.
//  Copyright (c) 2013 APOS Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebiPromptAnswer.h"

@interface WebiPrompt : NSObject

@property (nonatomic,assign) BOOL isOptional;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *dataproviderId;
@property (nonatomic, assign) int promptId;
@property (nonatomic, strong) NSString  *name;
@property (nonatomic, strong) NSString  *technicalName;
@property (nonatomic, strong) WebiPromptAnswer  *answer;

@end
