//
//  WebiAppDelegate.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-02-12.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import "WebiAppDelegate.h"
#import "Session.h"
#import "LogonViewController.h"
#import "CoreDataHelper.h"
#import "SessionsViewController.h"
#import "Settings.h"
#import "DocumentsViewController.h"
//#import "TestFlight.h"
#import "GlobalPreferencesConstants.h"
#import "BI4RestConstants.h"
#import "InAppPurchase.h"
#import "BIMobileIAPHelper.h"
#import "PreferencesViewController.h"
#import "Products.h"


@implementation WebiAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize sessions;
@synthesize isUIRefreshRequred;
@synthesize isOpenDocumentUrl;
@synthesize globalSettings;
@synthesize universeViewController;
@synthesize activeSession;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [BIMobileIAPHelper sharedInstance];
    
#ifndef Prod
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
    [TestFlight passCheckpoint:@"Device ID Registered"];
#endif
    
    //    [TestFlight takeOff:@"a021f062-d6ec-4c4a-9234-22901b218bfb"];
    
    
    
#ifdef AllFeaturesPurchased
    [TestFlight takeOff:@"c055a92a-0135-4717-9236-9afc2800d512"];
    NSLog (@"Internal Version with All Features Purchased");
#else
    [TestFlight takeOff:@"90a4b6e7-e01a-4b4d-bbee-00c59a25aab8"];
    NSLog (@"App Store Version");
#endif
    
    
    
    
    // The rest of your application:didFinishLaunchingWithOptions method// ...
    
#ifdef Lite
    NSLog(@"Started. Lite Version: %@ Build:%@ " ,    [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] );
#else
    NSLog(@"Started. Full Version: %@ Build:%@ " ,    [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] );
#endif
    
#ifdef Trace
    NSLog(@"Trace is Defined");
#endif
    
    [self customizeGlobalTheme];
    
    UIUserInterfaceIdiom idiom = [[UIDevice currentDevice] userInterfaceIdiom];
    
    if (idiom == UIUserInterfaceIdiomPad) {
        [self customizeiPadTheme];
        [self iPadInit];
    } else if(idiom == UIUserInterfaceIdiomPhone) {
        [self iPhoneInit];
    }
    self.isOpenDocumentUrl=NO;
    
	
    self.globalSettings=[self getGlobalSettingsWithContext:self.managedObjectContext];
    
    sessions=[CoreDataHelper getObjectsForEntity:@"Session" withSortKey:nil andSortAscending:YES andContext:self.managedObjectContext];
    NSLog(@"Sessions Count:%d",[sessions count]);
    
    
    
    //    NSLog(@"Language:%@",[[NSLocale preferredLanguages] objectAtIndex:0]);
    [TestFlight passCheckpoint:[NSString stringWithFormat:@"%@%@",@"Locale:",[[NSLocale preferredLanguages] objectAtIndex:0]]];
    
    
    //    if ([[BIMobileIAPHelper sharedInstance] productPurchased:MANAGE_CONNECTIONS]==NO){
    //#ifndef AllFeaturesPurchased
    [self createAposDemoConnectionAsDefault:YES];
    //#endif
    //    }
    
    
    
    
    
    
    //    UITabBarController *tabBarController =(UITabBarController *)self.window.rootViewController;
    //    UINavigationController *navigationController =[[tabBarController viewControllers] objectAtIndex:0];
    //
    //    SessionsViewController *sessionViewController =[[navigationController viewControllers] objectAtIndex:0];
    //    sessionViewController.sessions=sessions;
    
    return YES;
}
- (void)customizeGlobalTheme {
    [[UIApplication sharedApplication]
     setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
    
    UIImage *barButton = [[UIImage imageNamed:@"navbar-icon.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)];
    UIImage *barButtonLandscape = [[UIImage imageNamed:@"navbar-icon_landscape.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)];
    
    [[UIBarButtonItem appearance] setBackgroundImage:barButton forState:UIControlStateNormal
                                          barMetrics:UIBarMetricsDefault];
    
    [[UIBarButtonItem appearance] setBackgroundImage:barButtonLandscape forState:UIControlStateNormal
                                          barMetrics:UIBarMetricsLandscapePhone];
    
    
    
    
    UIImage *backButton = [[UIImage imageNamed:@"back-button.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 4)];
    UIImage *backButtonLandscape = [[UIImage imageNamed:@"back-button_landscape.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 4)];
    
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButton forState:UIControlStateNormal
                                                    barMetrics:UIBarMetricsDefault];
    
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButtonLandscape forState:UIControlStateNormal
                                                    barMetrics:UIBarMetricsLandscapePhone];
    
    
    
    UIImage *minImage = [[UIImage imageNamed:@"slider-track-fill.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 4, 0, 4)];
    UIImage *maxImage = [UIImage imageNamed:@"slider-track.png"];
    UIImage *thumbImage = [UIImage imageNamed:@"slider-cap.png"];
    
    
    [[UISlider appearance] setMaximumTrackImage:maxImage
                                       forState:UIControlStateNormal];
    [[UISlider appearance] setMinimumTrackImage:minImage
                                       forState:UIControlStateNormal];
    [[UISlider appearance] setThumbImage:thumbImage
                                forState:UIControlStateNormal];
    [[UISlider appearance] setThumbImage:thumbImage
                                forState:UIControlStateHighlighted];
    
    
    
#pragma mark Bug in OS6 - Test in iOS7 (crashes when opening in Mail)
    //    [[UIProgressView appearance] setProgressTintColor:[UIColor colorWithPatternImage:minImage]];
    //    [[UIProgressView appearance] setTrackTintColor:[UIColor colorWithPatternImage:maxImage]];
    
    
    [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"tabbar-item.png"]];
    
    //    [[UISegmentedControl appearance] setTintColor:[UIColor colorWithRed:163.0/255 green:117.0/255 blue:89.0/255 alpha:1.0]];
    //    [[UISwitch appearance] setOnTintColor:[UIColor colorWithRed:163.0/255 green:117.0/255 blue:89.0/255 alpha:1.0]];
    
    
    [[UISegmentedControl appearance] setTintColor:[UIColor colorWithRed:48.0/255 green:96.0/255 blue:144./255 alpha:1.0]];
    [[UISwitch appearance] setOnTintColor:[UIColor colorWithRed:63.0/255 green:114.0/255 blue:173.0/255 alpha:1.0]];
    
    
    
    
}

- (void)customizeiPadTheme {
    
    
    UIImage *navBarImage = [UIImage imageNamed:@"ipad-menubar-right__landscape.png"];
    [[UINavigationBar appearance] setBackgroundImage:navBarImage
                                       forBarMetrics:UIBarMetricsDefault];
    UIImage* toolBarBg = [UIImage imageNamed:@"ipad-menubar-right__landscape.png"];
    [[UIToolbar appearance] setBackgroundImage:toolBarBg forToolbarPosition:UIToolbarPositionTop barMetrics:UIBarMetricsDefault];
    
    UIImage* bottomToolBarBg = [UIImage imageNamed:@"tabbar__landscape.png"];
    [[UITabBar appearance] setBackgroundImage:bottomToolBarBg];
}

-(void)iPadInit {
    //    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
    //
    //    splitViewController.delegate = [splitViewController.viewControllers lastObject];
    //
    //
    //    id<MasterViewControllerDelegate> delegate = [splitViewController.viewControllers lastObject];
    //    UINavigationController* nav = (splitViewController.viewControllers)[0];
    //
    //    MasterViewController* master = (nav.viewControllers)[0];
    //
    //    master.delegate = delegate;
    
}

-(void)iPhoneInit {
    
    
    
    UIImage    *navBarImagePortrait = [UIImage imageNamed:@"navbar.png" ];
    UIImage    *tabBarBackgroundPortrait = [UIImage imageNamed:@"tabbar_landscape.png" ] ;
    UIImage    *navBarImageLandscape = [UIImage imageNamed:@"navbar_landscape.png"] ;
    [[UINavigationBar appearance] setBackgroundImage:navBarImagePortrait
                                       forBarMetrics:UIBarMetricsDefault];
    [[UITabBar appearance] setBackgroundImage:tabBarBackgroundPortrait ];
    [[UINavigationBar appearance] setBackgroundImage:navBarImageLandscape
                                       forBarMetrics:UIBarMetricsLandscapePhone];
    
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSLog(@"applicationWillResignActive");
    
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"Did Enter Background");
    if (!isOpenDocumentUrl) {
        // Logoff from BOXI
        if ([globalSettings.isLogoffInBackground isEqualToNumber:[NSNumber numberWithInteger:1]])
            [self biLoggoff];
    }else{
        NSLog(@"Skipping Logof - Open Document called");
        isOpenDocumentUrl=NO;
    }
    [self saveContext];
    
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"applicationDidBecomeActive");
    [self refreshSessions];
    [self showHideUniverseController];
    
    UITabBarController *tabBarController =(UITabBarController *)self.window.rootViewController;
    //    UITabBarItem *tabBarItemDocs = [tabBarController.tabBar.items objectAtIndex:0];
    //    [tabBarItemDocs setFinishedSelectedImage:[UIImage imageNamed:@"DocumentsAll_selected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"DocumentsAll_unselected.png"]];
    
    for (UITabBarItem *tabBarItem in tabBarController.tabBar.items) {
        if ([tabBarItem.title isEqualToString:NSLocalizedString(@"Browser",nil)]){
            NSLog(@"Checking %@",NSLocalizedString(@"Browser",nil));
            //        if ([tabBarItem.title isEqualToString:NSLocalizedString(@"qcJ-5z-gfl.title",nil)]){
            [tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"Browse_60.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"Browse_White_60.png"]];
        }else
            
            if ([tabBarItem.title isEqualToString:NSLocalizedString(@"Documents",nil)]){
                [tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"DocumentsAll_selected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"DocumentsAll_unselected.png"]];
            }
            else if ([tabBarItem.title isEqualToString:NSLocalizedString(@"Universes",nil)]){
                [tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"Universe_selected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"Universe_unselected.png"]];
            }else if ([tabBarItem.title isEqualToString:NSLocalizedString(@"Settings",nil)]){
                [tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"SettingGears_blue.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"SettingGears_white.png"]];
            }
        
    }
    
    
    if (sessions.count==0){
        //        tabBarController =(UITabBarController *)self.window.rootViewController;
        if (tabBarController.tabBar.items.count==4)
            tabBarController.selectedIndex=3;
        else if (tabBarController.tabBar.items.count==3)
            tabBarController.selectedIndex=2;
    }
    
    [self onlyOneSessionEnabled];
    
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    NSLog(@"Application will terminate");
    if ([globalSettings.isLogoffInBackground isEqualToNumber:[NSNumber numberWithInteger:1]])
        [self biLoggoff];
    [self saveContext];
    
}

-(void) biLoggoff{
    
    
    NSLog(@"Sessions count:%d",sessions.count);
    for (Session *session in sessions) {
        if ([session.isEnabled intValue]==1){
            NSLog(@"Session Token:%@",session.cmsToken);
            if (session.cmsToken!=nil){
                NSLog(@"Logoff Session %@",session.name);
                //                session.cmsToken=nil;
                //                NSLog(@"Set Token to Nil");
                
                BILogoff *logOff=[[BILogoff alloc]init];
                [logOff logoffSession:session withToken:session.cmsToken];
                //                [logOff logoffSessionSync:session withToken:session.cmsToken];
                session.cmsToken=nil;
                NSLog(@"Token was set to nil");
                
            }
        }
    }
    
    if (_mobileService!=nil) {
        [_mobileService mobileLogoff];
    }
    _mobileSession=nil;
    
    
}

- (void)saveContext
{
    
    //  Reset Password if neccessary
    
    NSLog(@"Save Password? %@",self.globalSettings.isSavePassword);
    if ([self.globalSettings.isSavePassword intValue]==0){
        NSLog(@"Password will not be saved");
        for (Session *session in sessions) {
            if (![session.name isEqualToString:DEFAULT_APOS_DEMO_CONNECTION_NAME])
                session.password=nil;
            //            session.cmsToken=nil;
        }
    }
    
    
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (self.activeSession)
        self.activeSession.documents=nil;
    NSLog(@"Will be saved %d documents",self.activeSession.documents.count);
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        NSLog(@"Context Saved");
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"DocumentViewer" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"DocumentViewer.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        error = nil;
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                                 [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
        
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                       configuration:nil URL:storeURL
                                                             options:options error:&error]){
            
            NSLog(@"Error during Migration:%@",[error userInfo]);
            [TestFlight passCheckpoint:@"Store Failed To Migrate"];
            abort();
            
        }
        else
            NSLog(@"Store Migrated!");
        [TestFlight passCheckpoint:@"Store Migrated"];
        
        //        abort();
    }
    
    return _persistentStoreCoordinator;
    
}

//-(BOOL) IsCreateSessionPurchased:(NSManagedObjectContext *)context{
//    //  Set up a predicate (or search criteria) for checking Create Session Purchase
//    NSLog(@"Searching for %@",MANAGE_CONNECTIONS);
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(productid == %@ )", MANAGE_CONNECTIONS];
//
//    //  Actually run the query in Core Data and return the count of purchases with these details
//    if ([CoreDataHelper countForEntity:@"InAppPurchase" withPredicate:predicate andContext:context] <= 0){
//        NSLog(@"No Purchases Yet");
//        _isCreateSessionAllowed=NO;
////        NSLog(@"Creating Purchase for Testing");
////        InAppPurchase *purchase = [NSEntityDescription
////                             insertNewObjectForEntityForName:@"InAppPurchase"
////                             inManagedObjectContext:context];
////        purchase.productid=MANAGE_CONNECTIONS;
//
//    }else{
//        NSLog(@"Already purchased!");
//                _isCreateSessionAllowed=YES;
//    }
//
//    return _isCreateSessionAllowed;
//}
-(Settings *) getGlobalSettingsWithContext:(NSManagedObjectContext *)context{
    NSMutableArray *settings=[CoreDataHelper getObjectsForEntity:@"Settings" withSortKey:nil andSortAscending:YES andContext:self.managedObjectContext];
    Settings *globalPreferences;
    if (settings.count<=0){
        NSLog(@"Global Settings Not Found. Initialize");
        globalPreferences = [NSEntityDescription
                             insertNewObjectForEntityForName:@"Settings"
                             inManagedObjectContext:context];
        
        globalPreferences.fetchDocumentLimit=[NSNumber numberWithInteger:[DEFAULT_FETCH_SIZE integerValue]];
        NSLog(@"Default Fetch Document Limit:%@",globalPreferences.fetchDocumentLimit);
        globalPreferences.isLogoffInBackground=[NSNumber numberWithInteger:[DEFAULT_LOGOFF_BACKGROUND integerValue]];
        NSLog(@"Default isLofoffInBackground:%@",globalPreferences.isLogoffInBackground);
        
        globalPreferences.isSavePassword=[NSNumber numberWithInteger:[DEFAULT_SAVE_PASSWORD integerValue]];
        
        globalPreferences.networkTimeout=[NSNumber numberWithInteger:[DEFAULT_NETWORK_TIMEOUT integerValue]];
#ifdef Lite
        //        globalPreferences.autoLogoff=[NSNumber numberWithInteger:1];
        globalPreferences.autoLogoff=[NSNumber numberWithInteger:[DEFAULT_AUTO_LOGOFF integerValue]];
#else
        globalPreferences.autoLogoff=[NSNumber numberWithInteger:[DEFAULT_AUTO_LOGOFF integerValue]];
#endif
        
        
        
#ifdef Lite
        globalPreferences.isShowUniverses=[NSNumber numberWithInteger:[DEFAULT_APOS_DEMO_SHOW_UNIVERSE integerValue]];
#else
        globalPreferences.isShowUniverses=[NSNumber numberWithInteger:[DEFAULT_SHOW_UNIVERSE integerValue]];
#endif
        
        
    }else{
        globalPreferences=[settings objectAtIndex:0];
    }
    
    
    return globalPreferences;
    
    
    
}
#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

-(void)createAposDemoConnectionAsDefault:(BOOL)isDefault
{
    NSLog (@"Create Apos Demo Session if it does not exist");
    Session *aposDemoSession=[self isNameAlreadyExistWithName:DEFAULT_APOS_DEMO_CONNECTION_NAME WithSessions:self.sessions];
    BOOL isNewDemoSession=NO;
    if(aposDemoSession==nil){
        NSLog(@"Session Does not Exist - Create One");
        aposDemoSession = [NSEntityDescription
                           insertNewObjectForEntityForName:@"Session"
                           inManagedObjectContext:self.managedObjectContext];
        isNewDemoSession=YES;
        
    }else{
        NSLog(@"Apos Demo Already Exist");
        
    }
    
    
    aposDemoSession.name=DEFAULT_APOS_DEMO_CONNECTION_NAME;
    aposDemoSession.cmsName=DEFAULT_APOS_DEMO_CONNECTION_SERVER;
    aposDemoSession.userName=DEFAULT_APOS_DEMO_CONNECTION_USER;
    aposDemoSession.password=DEFAULT_APOS_DEMO_CONNECTION_PASSWORD;
    aposDemoSession.authType=DEFAULT_APOS_DEMO_CONNECTION_AUTH;
    aposDemoSession.isHttps=[NSNumber numberWithInt:[DEFAULT_APOS_DEMO_CONNECTION_HTTPS intValue]];
    if (isNewDemoSession==YES)
        aposDemoSession.isEnabled=[NSNumber numberWithInt:[DEFAULT_APOS_DEMO_CONNECTION_ENABLED intValue]];
    aposDemoSession.port=[NSNumber numberWithInt:[DEFAULT_APOS_DEMO_CONNECTION_PORT intValue]];
    aposDemoSession.opendocPort=[NSNumber numberWithInt:[DEFAULT_APOS_DEMO_CONNECTION_OPENDOC_PORT intValue]];
    aposDemoSession.cmsNameEx=DEFAULT_APOS_DEMO_CMS_NAME;
    aposDemoSession.opendocServer=DEFAULT_APOS_DEMO_CONNECTION_OPENDOC_SERVER;
    aposDemoSession.cypressSDKBase=cypressSDKPoint_Default;
    aposDemoSession.webiRestSDKBase=webiRestSDKPoint_Default;
    
    
    
    if (isNewDemoSession){
        [self.sessions insertObject:aposDemoSession atIndex:0];
        //        [TestFlight passCheckpoint:@"New Apos Demo Session Created"];
    }else{
        //        [TestFlight passCheckpoint:@"Apos Demo Session Updated"];
    }
    
}
-(void) onlyOneSessionEnabled{
    BOOL isAtLeastOneSessionEnabled=NO;
    
    for (Session *session in self.sessions) {
        if (isAtLeastOneSessionEnabled==YES) {
            session.isEnabled=[NSNumber numberWithBool:NO];
            continue;
        }
        if ([session.isEnabled isEqualToNumber:[NSNumber numberWithBool:YES]]){
            isAtLeastOneSessionEnabled=YES;
            NSLog(@"Session %@ is enabled. Make sure the rest session are not",session.name);
            
        }
    }
}
-(Session *) isNameAlreadyExistWithName:(NSString *)name WithSessions:(NSMutableArray *)existingSessions
{
    for (Session *session in existingSessions) {
        if ([name isEqual:session.name]) return session;
    }
    return nil;
    
    
}

-(void) showHideUniverseController{
    NSLog(@"Is show Univreses?%@", globalSettings.isShowUniverses);
    UITabBarController *tabBarController =(UITabBarController *)self.window.rootViewController;
    if ([globalSettings.isShowUniverses isEqualToNumber:[NSNumber numberWithBool:NO]] && tabBarController.viewControllers.count==4){
        NSLog(@"Hide Universes Tab");
        NSMutableArray *tabbarViewControllers = [NSMutableArray arrayWithArray: [tabBarController viewControllers]];
        self.universeViewController=[tabbarViewControllers objectAtIndex: 2];
        [tabbarViewControllers removeObjectAtIndex: 2];
        [tabBarController setViewControllers: tabbarViewControllers ];
        //        [TestFlight passCheckpoint:@"Remove Universe Tab"];
    }else if ([globalSettings.isShowUniverses isEqualToNumber:[NSNumber numberWithBool:YES]] && tabBarController.viewControllers.count==3 && self.universeViewController!=nil){
        NSLog(@"Show Universe");
        [[universeViewController tabBarItem]setFinishedSelectedImage:[UIImage imageNamed:@"Universe_selected.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"Universe_unselected.png"]];
        NSMutableArray *tabbarViewControllers = [NSMutableArray arrayWithArray: [tabBarController viewControllers]];
        [tabbarViewControllers insertObject:universeViewController atIndex:2];
        [tabBarController setViewControllers: tabbarViewControllers ];
        //        [TestFlight passCheckpoint:@"Restore Universe Tab"];
    }
    
    
}

-(void) cleanUpSessions{
    NSLog(@"Clean Up Sessions");
    NSMutableArray *sessionsToDelete=[[NSMutableArray alloc] init];
    for (Session *session in self.sessions) {
        NSLog(@"Processing Session with Name:%@",session.name);
        if (session.name.length==0){
            NSLog(@"Cleanup Deleting Session");
            [sessionsToDelete addObject:session];
        }else{
            if ([session.isEnabled intValue]==1){
                
                if (session.cmsNameEx.length <=0){
                    NSLog(@"CMS Name is not set");
                    session.cmsNameEx=DEFAULT_CMS_NAME;
                }

                if (session.cypressSDKBase.length <=0){
                    NSLog(@"Cypress SDK Base is not set");
                    session.cypressSDKBase=cypressSDKPoint_Default;
                }
                if (session.webiRestSDKBase.length<=0){
                    NSLog(@"Webi SDK  Base is not set");
                    session.webiRestSDKBase=webiRestSDKPoint_Default;
                }
                if (session.mobileBIServiceBase<=0){
                    session.mobileBIServiceBase=mobileServiceBase;
                }
                if (session.mobileBIServicePort <=0){
                    [session setMobileBIServicePort:[NSNumber  numberWithInt:mobileServicePort]];
                }
                
                self.activeSession=session;
                
                NSLog(@"Active Session:%@",self.activeSession.name);
                
            }
        }
    }
    
    for (Session *sessionToDelete in sessionsToDelete) {
        NSLog(@"Deleting Sesion:%@",sessionToDelete.name);
        NSPredicate *predicate =[NSPredicate predicateWithFormat:@"name == %@", sessionToDelete.name ];
        [CoreDataHelper deleteAllObjectsForEntity:@"Session" withPredicate:predicate andContext:self.managedObjectContext];
        [self.sessions removeObject:sessionToDelete];
        
    }
}

-(void) refreshSessions{
    sessions=[CoreDataHelper getObjectsForEntity:@"Session" withSortKey:nil andSortAscending:YES andContext:self.managedObjectContext];
    NSLog(@"Sessions Count:%d",[sessions count]);
    [self cleanUpSessions];
    isUIRefreshRequred=YES;
    
}

@end
