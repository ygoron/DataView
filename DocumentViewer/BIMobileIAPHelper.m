//
//  BIMobileIAPHelper.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-07-20.
//  Copyright (c) 2013 APOS Systems. All rights reserved.
//

#import "BIMobileIAPHelper.h"
#import "Products.h"

@implementation BIMobileIAPHelper

+ (BIMobileIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static BIMobileIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      MANAGE_CONNECTIONS,
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

@end
