//
//  Session.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-06-04.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Document;

@interface Session : NSManagedObject

@property (nonatomic, retain) NSString * authType;
@property (nonatomic, retain) NSString * cmsName;
@property (nonatomic, retain) NSString * cmsToken;
@property (nonatomic, retain) NSNumber * isEnabled;
@property (nonatomic, retain) NSNumber * isHttps;
@property (nonatomic, retain) NSNumber * isTestedOK;
@property (nonatomic, retain) NSDate * lastTested;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * opendocPort;
@property (nonatomic, retain) NSString * opendocServer;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSNumber * port;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSString * cypressSDKBase;
@property (nonatomic, retain) NSString * webiRestSDKBase;
@property (nonatomic, retain) NSSet *documents;
@end

@interface Session (CoreDataGeneratedAccessors)

- (void)addDocumentsObject:(Document *)value;
- (void)removeDocumentsObject:(Document *)value;
- (void)addDocuments:(NSSet *)values;
- (void)removeDocuments:(NSSet *)values;

@end
