//
//  ScheduleDetails.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-03-04.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Document;

@interface ScheduleDetails : NSObject

@property  (nonatomic) int  scheduleId;
@property (nonatomic,strong) NSString *scheduleName;
@property (nonatomic,strong) NSString *scheduleFormat;
@property (nonatomic,strong) NSString *scheduleStatus;
@property (nonatomic,strong) Document *document;


@end
