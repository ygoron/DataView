//
//  Report.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-02-28.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Document;

@interface Report : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * reference;
@property (nonatomic, retain) Document *document;

@end
