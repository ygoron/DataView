//
//  WebiPromptLov.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-09-29.
//  Copyright (c) 2013 APOS Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebiPromptLov : NSObject

@property (nonatomic,assign) BOOL isHieararchical;
@property (nonatomic,assign) BOOL isPartial;
@property (nonatomic,assign) BOOL isRefreshable;
@property (nonatomic,strong) NSString *dpId;
@property (nonatomic, strong) NSArray *values;
@property (nonatomic, strong) NSArray *intervals;
@property (nonatomic, strong) NSDate *updated;

@end
