//
//  Response.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-09-17.
//  Copyright (c) 2013 APOS Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Response : NSObject

@property (strong,nonatomic) NSString *message;
@property (assign, nonatomic) NSInteger httpCode;

@end
