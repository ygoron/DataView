//
//  WebiPromptInfo.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-09-29.
//  Copyright (c) 2013 APOS Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WebiPromptLov.h"

@interface WebiPromptInfo : NSObject
@property (strong, nonatomic) NSString *cardinality;
@property (strong, nonatomic) WebiPromptLov *lov;
@property (strong, nonatomic) NSArray *previous;
@property (strong, nonatomic) NSArray *values;
@end
