//
//  InAppPurchase.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-07-19.
//  Copyright (c) 2013 APOS Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface InAppPurchase : NSManagedObject

@property (nonatomic, retain) NSString * productid;
@property (nonatomic, retain) NSDate * dateofpucrhase;

@end
