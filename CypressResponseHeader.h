//
//  CypressResponseHeader.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-05-03.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CypressResponseHeader : NSObject

@property (strong, nonatomic) NSURL *metadata;
@property (strong, nonatomic) NSURL *first;
@property (strong, nonatomic) NSURL *next;
@property (strong, nonatomic) NSURL *last;
@property (strong, nonatomic) NSURL *children;
@property (strong, nonatomic) NSURL *up;

@end
