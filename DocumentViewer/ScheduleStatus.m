//
//  ScheduleStatus.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-03-18.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import "ScheduleStatus.h"

@implementation ScheduleStatus
@synthesize message,code,newInstanceId;

-(id) init{
    self = [super init];
    if (self) {
        code=-1;
    }
    return self;
}
@end
