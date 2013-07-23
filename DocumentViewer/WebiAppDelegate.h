//
//  WebiAppDelegate.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-02-12.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import  "Settings.h"
#import "Session.h"

@interface WebiAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong) NSMutableArray *sessions;
@property (nonatomic,assign) BOOL isUIRefreshRequred;
@property (nonatomic, assign) BOOL isOpenDocumentUrl;
@property (nonatomic, assign) BOOL isCreateSessionAllowed;
@property (nonatomic, strong) Settings *globalSettings;

@property (nonatomic,strong) UIViewController *universeViewController;
@property (nonatomic,strong) Session *activeSession;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)customizeGlobalTheme;
- (void)customizeiPadTheme;
- (void)iPadInit;
- (void)iPhoneInit;
- (Settings *) getGlobalSettingsWithContext: (NSManagedObjectContext *) context;
-(void) showHideUniverseController;
-(void) createAposDemoConnectionAsDefault:(BOOL) isDefault;
-(Session *) isNameAlreadyExistWithName:(NSString *)name WithSessions:(NSMutableArray *)existingSessions;
-(void) cleanUpSessions;
-(void) refreshSessions;
@end
