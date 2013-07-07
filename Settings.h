//
//  Settings.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-06-04.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Settings : NSManagedObject

@property (nonatomic, retain) NSNumber * autoLogoff;
@property (nonatomic, retain) NSNumber * fetchDocumentLimit;
@property (nonatomic, retain) NSNumber * isLogoffInBackground;
@property (nonatomic, retain) NSNumber * isOfflineMode;
@property (nonatomic, retain) NSNumber * isSavePassword;
@property (nonatomic, retain) NSNumber * isShowUniverses;
@property (nonatomic, retain) NSNumber * isUseHttpCache;
@property (nonatomic, retain) NSNumber * networkTimeout;

@end
