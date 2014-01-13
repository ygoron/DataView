//
//  QueryField.h
//  DocumentViewer
//
//  Created by Yuri Goron on 1/12/2014.
//  Copyright (c) 2014 APOS Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QueryField : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *datatype;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *expression;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSString *fieldId;

@end
