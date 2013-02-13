//
//  WebiAppDelegate.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-02-12.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebiAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
