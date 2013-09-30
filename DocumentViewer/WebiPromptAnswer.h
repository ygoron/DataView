//
//  WebiPromptAnswer.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-09-29.
//  Copyright (c) 2013 APOS Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebiPromptInfo.h"

@interface WebiPromptAnswer : NSObject

@property (nonatomic,assign) BOOL isConstrained;
@property (nonatomic,strong) NSString *type;
@property (nonatomic,strong) WebiPromptInfo *info;
@end
