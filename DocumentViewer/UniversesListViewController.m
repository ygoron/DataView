//
//  UniversesListViewController.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-03-30.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import "UniversesListViewController.h"
#import "UniverseDetailsViewControllerSolo.h"
//TODO REMOVE
//#import "SelectWebiFieldsViewController.h"
#import "TitleLabel.h"
#import "WebiAppDelegate.h"



@interface UniversesListViewController ()


@end



@implementation UniversesListViewController
{
    WebiAppDelegate *appDelegate;
    BOOL wasRefreshedAtLeastOnce;
    NSIndexPath *selectedIndex;
    
}
@synthesize sessions;
@synthesize universes;

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
    
    wasRefreshedAtLeastOnce=NO;
    NSLog(@"Universes View Controller");
    universes=[[NSMutableArray alloc] initWithCapacity:50];
    appDelegate = (id)[[UIApplication sharedApplication] delegate];
    context = [appDelegate managedObjectContext];
    
    offset=0;
    isDataLoded=NO;
    
    spinner = [[UIActivityIndicatorView alloc]  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin);
    spinner.center = CGPointMake(self.tableView.bounds.size.width / 2.0f, self.tableView.bounds.size.height / 2.0f);
    [self.view addSubview:spinner];
    if ([UIRefreshControl class]){
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.attributedTitle=[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Pull To Refresh Universes",nil)];
        self.refreshControl = refreshControl;
        [refreshControl addTarget:self action:@selector(reloadUniverses) forControlEvents:UIControlEventValueChanged];
    }
    
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(reloadUniverses)
    //                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    
    
    
    TitleLabel *titelLabel=[[TitleLabel alloc] initWithFrame:CGRectZero];
    self.navigationItem.titleView = titelLabel;
    titelLabel.text=NSLocalizedString(@"Universes",nil);
    [titelLabel sizeToFit];
    
    [self loadUniverses];
    
    
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

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (_isWebiCreation==YES){
        if (selectedIndex)
        {
            Universe *universe=[self.universes objectAtIndex:selectedIndex.row];
            if (universe){
                NSLog(@"Selected Universe Id:%d",universe.universeId);
                [self.delegate UniversesListViewController:self didSelectUniverse:universe];
            }else{
                NSLog(@"Universe Not Found");
            }
        }
    }
    
}

#pragma mark Reload Universes
-(void) reloadUniverses{
    
    UITabBarController *tabBarController =(UITabBarController *)  appDelegate.window.rootViewController;
    NSLog(@"Selected index:%d",    tabBarController.selectedIndex);
    //Refresh only if current view
    if (tabBarController.selectedIndex==2){
        
        offset=0;
        universes=[[NSMutableArray alloc] initWithCapacity:50];
        [self loadUniverses];
    }
}

#pragma mark Load Universes

-(void) loadUniverses {
    self.sessions=[CoreDataHelper getObjectsForEntity:@"Session" withSortKey:nil andSortAscending:YES andContext:context];
    NSLog(@"Sessions:%d",[sessions count]);
    
    if (sessions.count==0){
        if ([UIRefreshControl class]){
            [self.refreshControl endRefreshing];
        }
        [spinner stopAnimating];
        [self.tableView reloadData];
    }
    for (Session *session in self.sessions) {
        if ([session.isEnabled intValue ] ==1){
            isDataLoded=NO;
            NSLog(@"Updating universes");
            [spinner startAnimating];
            BIGetUniverses *getUniversesAdapter=[[BIGetUniverses alloc]init];
            getUniversesAdapter.context=context;
            getUniversesAdapter.delegate=self;
            getUniversesAdapter.biSession=session;
            NSLog(@"Get Universes for offset%d",offset);
            [getUniversesAdapter getUniversesForSession:session withLimit:appDelegate.globalSettings.fetchDocumentLimit.intValue withOffset:offset];
            break;
        }
        
        
    }
}

#pragma mark Universes Receieved

-(void) getUniverses:(BIGetUniverses *)biGetUniverses isSuccess:(BOOL)isSuccess universes:(NSMutableArray *)receivedUniverses{
    
    if ([UIRefreshControl class]){
        [self.refreshControl endRefreshing];
    }
    [spinner stopAnimating];
    if (isSuccess==YES){
        NSLog(@"Universes Received");
        [TestFlight passCheckpoint:[NSString stringWithFormat:@"%@%d",@"Universe List Received Count:",receivedUniverses.count]];
        wasRefreshedAtLeastOnce=YES;
        [self.universes addObjectsFromArray:receivedUniverses];
        isDataLoded=YES;
        if ([receivedUniverses count]==0 || receivedUniverses.count< appDelegate.globalSettings.fetchDocumentLimit.intValue) isNoMoreDocumentsLeft=YES;
        else isNoMoreDocumentsLeft=NO;
    }
    else if (biGetUniverses.connectorError!=nil){
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Load Universe Failed",nil) message:[biGetUniverses.connectorError localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil, nil];
        [alert show];
        self.universes=nil;
        
    }else if (biGetUniverses.boxiError!=nil){
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Load Universe Failed in BI",nil) message:biGetUniverses.boxiError delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil, nil];
        [alert show];
        self.universes=nil;
        
    } else{
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Load Universe Failed",nil) message:NSLocalizedString(@"Server Error",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil, nil];
        [alert show];
        self.universes=nil;
        
    }
    
    [self.tableView reloadData];
    
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSLog(@"Number of Rows in Table:%d",[self.universes count]);
    int rowsCount;
    if (isDataLoded && isNoMoreDocumentsLeft==NO ){
        rowsCount=self.universes.count+1;
        NSLog(@"Added Row count:%d",rowsCount);
        [TestFlight passCheckpoint:@"There are more Universes in BI than in the view"];
    }else{
        rowsCount=self.universes.count;
    }
    
    return rowsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row]<self.universes.count){
        UniverseCell *cell=[tableView dequeueReusableCellWithIdentifier:@"UniverseCell_Ident"];
        Universe *universe=[self.universes objectAtIndex:indexPath.row];
        
        cell.univernameLabel.text=universe.name;
        cell.universeIdLabel.text=[NSString stringWithFormat:@"%d",universe.universeId];
        cell.lableFolderId.text=[NSString stringWithFormat:@"Folder Id:%d",universe.folderId];
        cell.lableType.text=universe.type;
        if ([universe.type isEqualToString:@"unv"])
            [cell.imageOfUnv setImage:[UIImage imageNamed:@"unv_16-256.png"]];
        else         if ([universe.type isEqualToString:@"unx"])
            [cell.imageOfUnv setImage:[UIImage imageNamed:@"unx_16-256.png"]];
        
        if (_isWebiCreation == YES) [cell setAccessoryType:UITableViewCellAccessoryNone];
        return cell;
    }else{
        UniverseCell *cell=[tableView dequeueReusableCellWithIdentifier:@"MoreCell_Ident"];
        return cell;
    }
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
#ifdef Lite
    return NO;
#endif
    if ([indexPath row]>=self.universes.count) return NO;
    return YES;
}

-(void) setEditing:(BOOL)editing animated:(BOOL)animated{
    NSLog(@"Edit/Cancel Clicked");
    
#ifdef Lite
    [super setEditing:NO animated:animated];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Demo Version",nil) message:NSLocalizedString(@"Deleting objects is not supported in the Lite version. Please purchase a full version on the app store",nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK",nil), nil];
    [alertView show];
    
#endif
#ifndef Lite
    [super setEditing:editing animated:animated];
#endif
    
}

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

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
    
    if ([indexPath row]>=self.universes.count) {
        
        NSLog(@"Clicked More!");
        offset=self.universes.count;
        [self loadUniverses];
    }else{
        if (_isWebiCreation==NO){
            UniverseDetailsViewControllerSolo *vc=[[UniverseDetailsViewControllerSolo alloc]initWithNibName:@"UniverseDetailsViewControllerSolo" bundle:nil];
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            NSLog(@"Selected row:%d",[indexPath row]);
            [TestFlight passCheckpoint:@"Universe Detail Requested"];
            vc.universe=[self.universes objectAtIndex:[indexPath row]];
            vc.unvDetails=nil;
            vc.title=vc.universe.name;
            [self.navigationController pushViewController:vc animated:YES];
            
            
            //TODO REMOVE
            //            SelectWebiFieldsViewController *swf=[[SelectWebiFieldsViewController alloc] initWithNibName:@"SelectWebiFieldsViewController" bundle:nil];
            //            swf.universe=[self.universes objectAtIndex:[indexPath row]];
            //            [self.navigationController pushViewController:swf animated:YES];
            
            // END REMOVE
            
            
        }else{
            UniverseCell *cell=(UniverseCell *)[tableView cellForRowAtIndexPath:indexPath];
            
            
            if (cell.accessoryType==UITableViewCellAccessoryNone){
                cell.accessoryType=UITableViewCellAccessoryCheckmark;
            }
            else{
                cell.accessoryType=UITableViewCellAccessoryNone;
            }
            
            
            if (selectedIndex){
                if (selectedIndex.row!=indexPath.row){
                    UniverseCell *prevSelectedCell=(UniverseCell *)[tableView cellForRowAtIndexPath:selectedIndex];
                    [prevSelectedCell setAccessoryType:UITableViewCellAccessoryNone];
                    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:selectedIndex] withRowAnimation:UITableViewRowAnimationFade];
                }else{
                    
                }
            }
            
            if (cell.accessoryType==UITableViewCellAccessoryCheckmark){
                selectedIndex=indexPath;
//                [self.navigationController popToRootViewControllerAnimated:YES];
            }else{
                selectedIndex=nil;
            }
            
            
            
        }
        
    }
    
}


//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    NSLog (@"Seque: %@",segue.identifier);
//    UniverseDetailsViewController *universeDetailsViewController =segue.destinationViewController;
//
//	if ([segue.identifier isEqualToString:@"UniverseDetails_Ident"])
//	{
//        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//        //        if ([indexPath row]<self.documents.count)
//        NSLog(@"Selected row:%d",[indexPath row]);
//        universeDetailsViewController.universe=[self.universes objectAtIndex:[indexPath row]];
//        universeDetailsViewController.unvDetails=nil;
//
//	}
//}


//-(void) viewDidAppear:(BOOL)animated{
//    [super viewDidAppear:animated];
//    if (!wasRefreshedAtLeastOnce) [self reloadUniverses];
//}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (IBAction)refreshUniverseList:(id)sender {
    [self reloadUniverses];
}
- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
