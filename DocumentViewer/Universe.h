//
//  Universe.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-03-30.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Session;

@interface Universe : NSObject


@property (nonatomic,assign) int universeId;
@property (nonatomic, strong) NSString *cuid;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, assign) int folderId;
@property (nonatomic,strong) Session *session;
@end
