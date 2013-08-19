//
//  SessionDetailViewController.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-02-17.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import "SessionDetailViewController.h"
#import "BIConnector.h"
#import "BI4RestConstants.h"
#import "CoreDataHelper.h"
#import "BILogoff.h"
#import "TitleLabel.h"
#import "AdvancedSessionSettingsViewController.h"
#import "WebiAppDelegate.h"
#import "SharedUtils.h"

@interface SessionDetailViewController ()

@end

@implementation SessionDetailViewController
{
    NSManagedObjectContext *context;
    UIGestureRecognizer *tapper;
    UIActivityIndicatorView *spinner;
    WebiAppDelegate *appDelegate;
    BIConnector *connector;
    
}

@synthesize editedSession;
@synthesize editedIndexPath;
@synthesize allSessions;
@synthesize isNewSessionTestedOK;
@synthesize newSession;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) viewWillAppear:(BOOL)animated{
    [SharedUtils adjustLabelLeftMarginForIpadForBoldFontInTableView:self.tableView];
    [SharedUtils adjustRighMarginsForIpad:self.tableView.constraints];
    [super viewWillAppear:animated];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *backgroundImage = [UIImage imageNamed:@"leather-background.png"];
    UIColor *backgroundPattern= [UIColor colorWithPatternImage:backgroundImage];
    [self.tableView setBackgroundColor:backgroundPattern];
    
    
    UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    background.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"leather-background.png"]];
    self.tableView.backgroundView = background;
    
    
    appDelegate = (id)[[UIApplication sharedApplication] delegate];
    context = [appDelegate managedObjectContext];
    tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:tapper];
    tapper.cancelsTouchesInView = FALSE;
    spinner = [[UIActivityIndicatorView alloc]  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    spinner.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin);
    spinner.center = CGPointMake(self.tableView.bounds.size.width / 2.0f, self.tableView.bounds.size.height / 2.0f);
    
    
    //    [[self labelTestConnection]setTextColor:[UIColor colorWithRed:163.0/255 green:117.0/255 blue:89.0/255 alpha:1.0]];
    //RCSwitchOnOff* onSwitch = [[RCSwitchOnOff alloc] initWithFrame:CGRectMake(70, switchY, 70, switchHeight)];
    
    
    
    
    TitleLabel *titelLabel=[[TitleLabel alloc] initWithFrame:CGRectZero];
    self.navigationItem.titleView = titelLabel;
    titelLabel.text=self.title;
    [titelLabel sizeToFit];
    
    [self cutsomizeTextField:self.sessionNameTextField];
    [self cutsomizeTextField:self.sessionPortControl];
    [self cutsomizeTextField:self.sessionUserNameTextField];
    [self cutsomizeTextField:self.sessionUserPasswordTextField];
    [self cutsomizeTextField:self.sessionWCATextField];
    
    [self.view addSubview:spinner];
    
    if (editedSession==nil){
        NSLog(@"Creating a new Session");
        self.newSession = [NSEntityDescription
                           insertNewObjectForEntityForName:@"Session"
                           inManagedObjectContext:context];
        self.newSession.cypressSDKBase=cypressSDKPoint_Default;
        self.newSession.webiRestSDKBase=webiRestSDKPoint_Default;
        
        
    }
    
    
    //    [self.buttonTestSession setBackgroundColor:[UIColor colorWithRed:163.0/255 green:117.0/255 blue:89.0/255 alpha:1.0]];
    //    [self.buttonTestSession setTitleColor:[UIColor colorWithRed:163.0/255 green:117.0/255 blue:89.0/255 alpha:1.0] forState:UIControlStateNormal];
    
    
    
    NSLog(@"Edited Session:%@",editedSession);
    if (editedSession!=nil){
        [[self navigationItem] setTitle:@"Edit Session"];
        self.sessionNameTextField.text=editedSession.name;
        self.sessionWCATextField.text=editedSession.cmsName;
        self.sessionUserNameTextField.text=editedSession.userName;
        self.sessionUserPasswordTextField.text=editedSession.password;
        [self.sessionSegmentedControl setSelectedSegmentIndex: [self getAuthTypeInt:editedSession.authType] ];
        [self.sessionHttpsSwitchControl setOn:[editedSession.isHttps integerValue] ];
        [self.sessionIsEnbaledSwitchControl setOn:[editedSession.isEnabled integerValue] ];
        self.sessionPortControl.text =[editedSession.port stringValue];
        editedSession.isTestedOK=[NSNumber numberWithBool:NO];
    }else{
        if (allSessions.count==0) [self.sessionIsEnbaledSwitchControl setOn:1 ];
    }
    
    NSLog(@"Loaded");
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)cutsomizeTextField:(UITextField *)textField
{
    float redC=63.0/255;
    float greenC=114.0/255;
    float blueC=173.0/255;
    
    //    [textField setTextColor:[UIColor colorWithRed:163.0/255 green:117.0/255 blue:89.0/255 alpha:1.0]];
    [textField setTextColor:[UIColor colorWithRed:redC green:greenC blue:blueC alpha:1.0]];
    [textField setBackgroundColor:[UIColor clearColor]];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    NSLog(@"Memory Warning");
    // Dispose of any resources that can be recreated.
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@",indexPath);
    if (indexPath.section==5){
        NSLog(@"Check Connection");
        [self testConnection];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES ];
    }
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}
-(void) cancel:(id)sender{
    NSLog(@"Cancel Adding Sessions");
    if (self.newSession!=nil){
        NSPredicate *predicate =[NSPredicate predicateWithFormat:@"name == %@", self.newSession.name ];
        [CoreDataHelper deleteAllObjectsForEntity:@"Session" withPredicate:predicate andContext:context];
        
    }
    [self.delegate sessionDetailViewControllerDidCancel:self];
}
-(void)done:(id)sender{
    
    [self.view endEditing:YES];
    if(self.sessionNameTextField.text.length>0) [self saveSession];
    else{
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failed to Save Connection",nil) message:NSLocalizedString(@"Please provide session name",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil, nil];
        [alert show];
    }
    
    
}
-(void) saveSession
{
    
    if (self.editedSession==nil){
        NSLog(@"Adding Session: %@",self.sessionNameTextField.text);
        if ([self isNameAlreadyExistWithName:_sessionNameTextField.text WithSessions:allSessions]==YES){
            UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failed to Save Connection",nil) message:[NSString stringWithFormat:NSLocalizedString(@" Name %@ Already Exists. Please choose a different connection name",nil),_sessionNameTextField.text]  delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil, nil];
            [alert show];
            
        }else{
            
            [self setSession:self.newSession];
            if (isNewSessionTestedOK==YES) self.newSession.isTestedOK=[NSNumber numberWithBool:YES];
            else
                self.newSession.isTestedOK=[NSNumber numberWithBool:NO];
            [self disableOtherSession:self.newSession WithAllSessions:self.allSessions];
            [self.delegate sessionDetailsViewController:self didAddSession:self.newSession];
        }
        
        
    }else{
        NSLog(@"Editing Session: %@",self.sessionNameTextField.text);
        [self setSession:editedSession];
        [self disableOtherSession:editedSession WithAllSessions:self.allSessions];
        BILogoff *biLogoff=[[BILogoff alloc] init];
        [biLogoff logoffSession:appDelegate.activeSession withToken:appDelegate.activeSession.cmsToken];
        [self checkEnabledSessionInSessions:self.allSessions];
        [self.delegate sessionDetailsViewController:self didUpdateSession:editedSession atIndex:editedIndexPath];

        
    }
    
    
    
    
}

-(void) checkEnabledSessionInSessions: (NSMutableArray *)existingSessions
{
    BOOL isAtLeastOneSessionEnabled=NO;
    for (Session *session in existingSessions) {
        if ([session.isEnabled boolValue]==YES){
            isAtLeastOneSessionEnabled=YES;
            break;
        }
    }
    
    if (isAtLeastOneSessionEnabled==NO){
        NSLog(@"No Enabled Session. Enable the first one");
        if (existingSessions.count>0){
            [[existingSessions objectAtIndex:0] setIsEnabled:[NSNumber numberWithBool:YES]];
              appDelegate.activeSession=[existingSessions objectAtIndex:0];
              appDelegate.activeSession.cmsToken=nil;
            [appDelegate.activeSession setIsTestedOK:[NSNumber numberWithBool:YES]];
              NSLog(@"First Session Enabled. Name:%@",appDelegate.activeSession.name);

              
        }
    }
    
}
-(BOOL) isNameAlreadyExistWithName:(NSString *)name WithSessions:(NSMutableArray *)existingSessions
{
    for (Session *session in existingSessions) {
        if ([name isEqual:session.name]) return YES;
    }
    return NO;
}
-(void) disableOtherSession:(Session *)defaultSession WithAllSessions:(NSMutableArray *)allAvailableSessions
{
    if ([defaultSession.isEnabled boolValue]==YES){
        NSLog(@"Session is Default. Disable other sessions");
        for (Session *session in allAvailableSessions) {
            if(session!=defaultSession){
                if ([session.isEnabled intValue]==1){
                    session.isEnabled=  0;
                    NSLog(@"Disabling Session:%@",[session name]);
                    if (session.cmsToken!=nil)
                    {
                        NSLog(@"Logoff The disabled Session");
                        BILogoff *biLogof=[[BILogoff alloc] init];
                        [biLogof logoffSession:session withToken:session.cmsToken];
                        [TestFlight passCheckpoint:@"Switched Session. Logoff Old Session"];
                    }
                    
                }
            }
        }
    }
    
}
#pragma mark Test Connection

- (void)testConnection{
    NSLog(@"Test Connection");
    connector=[[BIConnector alloc]init];
    connector.timeOut=10;
    Session *session = [NSEntityDescription
                        insertNewObjectForEntityForName:@"Session"
                        inManagedObjectContext:context];
    
    if (self.editedSession!=nil){
        session.cypressSDKBase=editedSession.cypressSDKBase;
        session.webiRestSDKBase=editedSession.webiRestSDKBase;
    }else{
        session.cypressSDKBase=self.newSession.cypressSDKBase;
        session.webiRestSDKBase=self.newSession.webiRestSDKBase;
    }
    
    
    session.isTestedOK=[NSNumber numberWithBool:NO];
    self.isNewSessionTestedOK=NO;
    [self setSession:session];
    connector.delegate=self;
    [spinner startAnimating];
    [connector getCmsTokenWithSession:session];
    
}



#pragma mark Token Created

-(void) biConnector:(BIConnector *)biConnector didCreateCmsToken:(NSString *)cmsToken forSession:(Session *)session{
    NSLog (@"Got Token: %@",cmsToken);
    [spinner stopAnimating];
    session.lastTested=[NSDate date];
    if (cmsToken!=nil){
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connection Test",nil) message:NSLocalizedString(@"Success!",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil, nil];
        [alert show];
        session.cmsToken=cmsToken;
        
        if (self.editedSession!=nil) self.editedSession.isTestedOK=[NSNumber numberWithBool:YES];
        else self.isNewSessionTestedOK=YES;
        //        for (Session *workSession in allSessions) {
        //            if ([workSession.name isEqualToString:session.name])
        //                workSession.isTestedOK=[NSNumber numberWithBool:YES];
        //        }
        
        //        BILogoff *logOff=[[BILogoff alloc]init];
        //        logOff.delegate=self;
        //        [logOff logoffSession:session withToken:cmsToken];
        
    }else if (biConnector.connectorError!=nil){
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connection Test Failed",nil) message:[biConnector.connectorError localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil, nil];
        [alert show];
        
    }else if (biConnector.boxiError!=nil){
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connection Test Failed in BI",nil) message:biConnector.boxiError delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil, nil];
        [alert show];
        
    } else{
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connection Test Failed",nil) message:NSLocalizedString(@"Server Error",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil, nil];
        [alert show];
        
    }
    
    [context deleteObject:biConnector.biSession];
    //    NSPredicate *predicate =[NSPredicate predicateWithFormat:@"name == %@", biConnector.biSession.name ];
    //    [CoreDataHelper deleteAllObjectsForEntity:@"Session" withPredicate:predicate andContext:context];
    
}
#pragma mark Logoff Completed

-(void)biLogoff:(BILogoff *)biLogoff didLogoff:(BOOL)isSuccess{
    NSLog(@"Logoff Success? %d",isSuccess);
}
-(void) setSession:(Session *) session{
    
    NSLog(@"CMS Token Before: %@",session.cmsToken);
    if (![session.name isEqualToString:self.sessionNameTextField.text]) {
        session.cmsToken=nil;
        NSLog(@"Name Changed");
    }
    session.name=self.sessionNameTextField.text;
    
    if (![session.cmsName isEqualToString:self.sessionWCATextField.text]) {
        session.cmsToken=nil;
        NSLog(@"CMS Name Changed");
        
    }
    session.cmsName=self.sessionWCATextField.text;
    
    if (![session.userName isEqualToString:self.sessionUserNameTextField.text]) {
        NSLog(@"User Name Changed");
        NSLog(@"Old:%@ New %@",session.userName,self.sessionUserNameTextField.text);
        session.cmsToken=nil;
    }
    session.userName=self.sessionUserNameTextField.text;
    
    if (![session.password isEqualToString:self.sessionUserPasswordTextField.text]) {
        NSLog(@"Password Changed");
        session.cmsToken=nil;
    }
    if (appDelegate.globalSettings.isSavePassword==0)
        session.password=nil;
    else
        session.password=self.sessionUserPasswordTextField.text;
    
    if (session.authType!=[self getAuthTypeString:self.sessionSegmentedControl.selectedSegmentIndex]) {
        NSLog(@"AuthType Changed");
        session.cmsToken=nil;
    }
    session.authType=[self getAuthTypeString:self.sessionSegmentedControl.selectedSegmentIndex];
    
    if (![session.isHttps isEqualToNumber:[NSNumber numberWithBool:self.sessionHttpsSwitchControl.isOn]]) {
        NSLog(@"HTTPS Changed old %@ new %@",session.isHttps,[NSNumber numberWithBool:self.sessionHttpsSwitchControl.isOn] );
        session.cmsToken=nil;
    }
    session.isHttps=[NSNumber numberWithBool:self.sessionHttpsSwitchControl.isOn];
    
    if (![session.isEnabled isEqualToNumber:[NSNumber numberWithBool:self.sessionIsEnbaledSwitchControl.isOn]]) {
        NSLog(@"Enabled Changed");
        session.cmsToken=nil;
    }
    session.isEnabled=[NSNumber numberWithBool:self.sessionIsEnbaledSwitchControl.isOn];
    
    if (![session.port isEqualToNumber:[NSNumber numberWithInt:[self.sessionPortControl.text integerValue]]]) {
        NSLog(@"Port Changed");
        session.cmsToken=nil;
    }
    
    session.port=[NSNumber numberWithInt:[self.sessionPortControl.text integerValue]];
    
    if (session.opendocServer==nil) session.opendocServer=session.cmsName;
    if (session.opendocPort==[NSNumber numberWithInt:0]) session.opendocPort=session.port;
    if (session.cypressSDKBase==nil) session.cypressSDKBase=cypressSDKPoint_Default;
    if (session.webiRestSDKBase==nil) session.webiRestSDKBase=webiRestSDKPoint_Default;
    
    NSLog(@"CMS Token After: %@",session.cmsToken);
}

-(int) getAuthTypeInt: (NSString *) authType{
    if ([authType isEqualToString:AUTH_ENTERPRISE])return 0;
    else if ([authType isEqualToString:AUTH_WINAD]) return 1;
    else if ([authType isEqualToString:AUTH_LDAP]) return 2;
    return 0;
}
- (NSString *) getAuthTypeString: (int) index{
    NSString *authType=AUTH_ENTERPRISE;
    
    switch (self.sessionSegmentedControl.selectedSegmentIndex) {
        case 0:
            authType=AUTH_ENTERPRISE;
            break;
            
        case 1:
            authType=AUTH_WINAD;
            break;
        case 2:
            authType=AUTH_LDAP;
            break;
            
        default:
            authType=AUTH_ENTERPRISE;
            break;
    }
    
    return authType;
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog (@"Seque: %@",segue.identifier);
    AdvancedSessionSettingsViewController *advSetVC =segue.destinationViewController;
    
    NSLog(@"Edited Session Port %@, Name %@",editedSession.opendocPort,editedSession.name);
    
    if (editedSession!=nil){
        advSetVC.session=editedSession;
    }else if (newSession!=nil){
        advSetVC.session=newSession;
    }
    
    if (advSetVC.session.opendocPort==nil); advSetVC.session.opendocPort=[NSNumber numberWithInt:[self.sessionPortControl.text intValue]];
    if (advSetVC.session.opendocServer==nil) advSetVC.session.opendocServer=self.sessionWCATextField.text;
    
}



- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    NSLog(@"Hanlde Single Tap");
    [self.view endEditing:YES];
}

- (void)viewDidUnload {
    [self setLabelName:nil];
    [self setLabelServerName:nil];
    [self setLabelUserName:nil];
    [self setLabelPassword:nil];
    [self setLabelHTTPS:nil];
    [self setLabelPort:nil];
    [self setLabelDefault:nil];
    [self setLabelTestConnection:nil];
    [self setLabelTestConnection:nil];
    [super viewDidUnload];
}
@end
