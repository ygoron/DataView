//
//  UniverseDetail.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-03-30.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Universe;

@interface UniverseDetail : NSObject

@property (nonatomic, strong) Universe  *universe;
@property (nonatomic, assign) BOOL isConnected;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableArray *folders;
@end
