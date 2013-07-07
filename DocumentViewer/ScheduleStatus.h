//
//  ScheduleStatus.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-03-18.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScheduleStatus : NSObject

@property (nonatomic, strong) NSString *message;
@property (nonatomic) int code;
@property (nonatomic) int newInstanceId;

@end
