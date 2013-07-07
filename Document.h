//
//  Document.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-06-04.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Report, Session;

@interface Document : NSManagedObject

@property (nonatomic, retain) NSString * createdby;
@property (nonatomic, retain) NSString * cuid;
@property (nonatomic, retain) NSString * descriptiontext;
@property (nonatomic, retain) NSNumber * folderid;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * lastauthor;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSNumber * refreshonopen;
@property (nonatomic, retain) NSNumber * scheduled;
@property (nonatomic, retain) NSNumber * size;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSDate * updated;
@property (nonatomic, retain) NSSet *reports;
@property (nonatomic, retain) Session *session;
@end

@interface Document (CoreDataGeneratedAccessors)

- (void)addReportsObject:(Report *)value;
- (void)removeReportsObject:(Report *)value;
- (void)addReports:(NSSet *)values;
- (void)removeReports:(NSSet *)values;

@end
