//
//  InfoObject.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-05-03.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InfoObject : NSObject
@property (nonatomic,strong) NSURL *metaDataUrl;
@property (nonatomic,strong) NSURL *childrenUrl;
@property (nonatomic,strong) NSURL *scheduleFormsUrl;
@property (nonatomic,strong) NSURL *latestInstanceUrl;
@property (nonatomic, strong) NSURL *openDoc;
@property (nonatomic, assign) int objectId;
@property (nonatomic, strong) NSString *cuid;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, assign) int sortPriority;
@property (nonatomic, assign) BOOL isInstance;

@end
