//
//  SessionsViewController.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-02-16.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import "SessionsViewController.h"
#import "SessionDetailViewController.h"
#import "SessionCell.h"
#import "CoreDataHelper.h"
#import "TitleLabel.h"
#import "DocumentsViewController.h"
#import "GlobalPreferencesConstants.h"
#import "BILogoff.h"
#import "WebiAppDelegate.h"
#import "BrowserMainViewController.h"
@interface SessionsViewController ()

@end

@implementation SessionsViewController

{
    NSManagedObjectContext *context;
    WebiAppDelegate *appDelegate;
    
}

@synthesize sessions;
@synthesize buttonAddSession;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"Session View Controller");
    appDelegate = (id)[[UIApplication sharedApplication] delegate];
    context = [appDelegate managedObjectContext];
    self.sessions=[appDelegate sessions];
    
    UIImage *backgroundImage = [UIImage imageNamed:@"leather-background.png"];
    UIColor *backgroundPattern= [UIColor colorWithPatternImage:backgroundImage];
    [self.tableView setBackgroundColor:backgroundPattern];
    
    
    UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    background.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"leather-background.png"]];
    self.tableView.backgroundView = background;
    
    TitleLabel *titelLabel=[[TitleLabel alloc] initWithFrame:CGRectZero];
    self.navigationItem.titleView = titelLabel;
    titelLabel.text=@"Sessions";
    [titelLabel sizeToFit];
    
    [TestFlight passCheckpoint:[NSString stringWithFormat:@"%@%d",@"Sessions List. Session Count: ",self.sessions.count]];
    
    
    //    if ([UIViewController instancesRespondToSelector:@selector(shouldPerformSegueWithIdentifier:sender:)]==YES){
    //        NSLog(@"Responds To Selector!");
    //    }else{
    //        NSLog(@"Does not to respond to Selector");
    //    }
    if ([UIViewController instancesRespondToSelector:@selector(shouldPerformSegueWithIdentifier:sender:)]==NO){
#ifdef Lite
        [TestFlight passCheckpoint:@"iOS 5 - View Sessions"];
        [self.buttonAddSession setEnabled:NO];
#endif
        
    }
    
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [sessions count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SessionCell *cell=[tableView dequeueReusableCellWithIdentifier:@"SessionCell"];
    Session *session=[self.sessions objectAtIndex:indexPath.row];
    
    // Configure the cell...
    NSLog(@"WCS:%@",session.cmsName);
    cell.sessionNameLabel.text=session.name;
    cell.sessionWCALabel.text=[NSString stringWithFormat:@"%@%@%@",session.cmsName,@"\\",session.userName];
    //    cell.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"list-item.png"]];
    if ([session.name isEqualToString:DEFAULT_APOS_DEMO_CONNECTION_NAME]){
        cell.userInteractionEnabled=NO;
        //        cell.sessionWCALabel.hidden=YES;
        cell.sessionWCALabel.text=@"Demo CMS connection.";
    }
    if ([session.isEnabled integerValue]==1) {
        [cell.sessionActive setHidden:NO];
    }
    else {
        [cell.sessionActive setHidden:YES];
    }
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    Session *session=[self.sessions objectAtIndex:[indexPath row]];
    if ([session.name isEqualToString:DEFAULT_APOS_DEMO_CONNECTION_NAME])
        return NO;
    else return YES;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        Session *session=[self.sessions objectAtIndex:[indexPath row]];
        
        NSPredicate *predicate =[NSPredicate predicateWithFormat:@"name == %@", session.name ];
        [CoreDataHelper deleteAllObjectsForEntity:@"Session" withPredicate:predicate andContext:context];
        [self.sessions removeObjectAtIndex:[indexPath row]];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        if ([session.isEnabled integerValue]==1 && session.cmsToken!=nil){
            NSLog(@"Logoff Deleted Session %@",session.name);
            BILogoff *biLogOff =[[BILogoff alloc]init];
            //            biLogOff.delegate=self;
            [biLogOff logoffSession:session withToken:session.cmsToken];
        }
        
        
        //        // Check to see if only APOS Demo Left - then make it default
        //        if (self.sessions.count==1){
        //            if ([[[self.sessions objectAtIndex:0] name] isEqualToString:DEFAULT_APOS_DEMO_CONNECTION_NAME]) {
        //                Session *session=[self.sessions objectAtIndex:0];
        //                session.isEnabled=[NSNumber numberWithBool:YES];
        //                [self.tableView reloadData];
        //            }
        //        }
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    

    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog (@"Seque: %@",segue.identifier);
    [TestFlight passCheckpoint:[NSString stringWithFormat:@"%@%@",@"Session management",segue.identifier]];
    UINavigationController *navigationController =segue.destinationViewController;
    SessionDetailViewController        *sessionDetailViewController =[[navigationController viewControllers]objectAtIndex:0];
    sessionDetailViewController.delegate = self;
    sessionDetailViewController.allSessions=sessions;
    
	if ([segue.identifier isEqualToString:@"AddSession"])
	{
        sessionDetailViewController.editedSession=nil;
        sessionDetailViewController.title=@"BI Connection";
	}else if ([segue.identifier isEqualToString:@"EditSession"]){
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        sessionDetailViewController.editedSession=[sessions objectAtIndex:[indexPath row]];
        sessionDetailViewController.title=sessionDetailViewController.editedSession.name;
        sessionDetailViewController.editedIndexPath=indexPath;
        
    }
}


-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    NSLog(@"Selectior:%@",NSStringFromSelector(_cmd));
	if ([identifier isEqualToString:@"AddSession"]||[identifier isEqualToString:@"EditSession"]){
#ifdef Lite
        [TestFlight passCheckpoint:@"Tried to create new Session in Lite Version"];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Lite Version" message:@"Creating a new CMS connection is not supported in the Lite version. Please purchase a full version on the app store" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alertView show];
        return NO;
# else
        return YES;
#endif
    }
    
    return YES;
}

-(void) sessionDetailViewControllerDidCancel:(SessionDetailViewController *)controller{
    NSLog(@"Dismissed!");
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void) sessionDetailsViewController:(SessionDetailViewController *)controller didAddSession:(Session *)session{
    NSLog(@"Session--> Add");
    
    [self.sessions addObject:session];
    //    NSIndexPath *indexPath =[NSIndexPath indexPathForRow:[self.sessions count] - 1 inSection:0];
    //	[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView reloadData];
	[self dismissViewControllerAnimated:YES completion:nil];
    [self saveContext];
    [appDelegate refreshSessions];
    [self switchToDocumentListWithRefresh];
    [TestFlight passCheckpoint:@"Session Added"];
    
}

-(void) sessionDetailsViewController:(SessionDetailViewController *)controller didUpdateSession:(Session *)session atIndex:(NSIndexPath *)indexPath
{
    NSLog(@"Session Update");
    //    [self.sessions replaceObjectAtIndex:[indexPath row] withObject:session];
    //    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    

    Session *oldSession=appDelegate.activeSession;
    NSLog(@"Old Session Name %@,New Session Name %@",oldSession.name,session.name);

    [self.tableView reloadData];
    [self saveContext];
    [appDelegate refreshSessions];
    
    NSLog(@"Sessions count,%d",[sessions count]);
	[self dismissViewControllerAnimated:YES completion:nil];
    
    [self switchToDocumentListWithRefresh];
    
    if ([oldSession.name caseInsensitiveCompare:session.name]!=NSOrderedSame){
        NSLog(@"Session switched from %@ to %@",oldSession.name,session.name);
        [TestFlight passCheckpoint:@"Default Session Switched"];
                self.tabBarController.selectedIndex=0;
                
        self.tabBarController.selectedIndex=0;
            UINavigationController *navigationController=[[self.tabBarController viewControllers] objectAtIndex:0];
        [navigationController popToRootViewControllerAnimated:YES];
//            BrowserMainViewController *vc=[[navigationController viewControllers] objectAtIndex:0];

       
    }

    [TestFlight passCheckpoint:@"Session Updated"];
}


-(void) saveContext{
    
    NSError *error = nil;
    if (context != nil) {
        if ([context hasChanges] && ![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }
    }
    
}

-(void) switchToDocumentListWithRefresh
{
    if (self.isSwitchToDocumentsViewAllowed){
        self.tabBarController.selectedIndex=0;
        //        UINavigationController *navigationController=[[self.tabBarController viewControllers] objectAtIndex:0];
        //        BrowserMainViewController *vc=[[navigationController viewControllers] objectAtIndex:0];
        //
        //        if (vc){
        //            //            Session *currentSession=[self.sessions objectAtIndex:[[self.tableView indexPathForSelectedRow] row]];
        //            //            if ([vc.currentSession.name isEqualToString:currentSession.name])
        //        }else{
        //            NSLog(@"Documents View Controller is nil");
        //        }
    }
    
}


- (IBAction)buttonAddNewSession:(id)sender {
    NSLog(@"New Session Clicked!");
}

-(BOOL) isSwitchToDocumentsViewAllowed{
    for (Session *session in sessions) {
        NSLog(@"IsSession Tested %@, isEnabled: %@",session.isTestedOK,session.isEnabled);
        if ([session.isTestedOK intValue]==1 && [session.isEnabled intValue]==1) {
            session.isTestedOK=[NSNumber numberWithBool:NO];
            return YES;
        }
    }
    return NO;
}

-(void)biLogoff:(BILogoff *)biLogoff didLogoff:(BOOL)isSuccess
{
    NSLog(@"Logoff Session ? %d",isSuccess);
}


- (void)viewDidUnload {
    [self setButtonAddSession:nil];
    [self setButtonAddSession:nil];
    [super viewDidUnload];
}
@end
