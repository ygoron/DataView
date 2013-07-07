//
//  ScheduleDetailViewController.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-03-04.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import "ScheduleDetailViewController.h"
#import "BIGetScheduleDetail.h"
#import "ScheduleDetailCell.h"
#import "DocumentDetailsViewController.h"
#import "BI4RestConstants.h"
#import "DeleteStatus.h"
#import "TitleLabel.h"


@interface ScheduleDetailViewController ()

@end

@implementation ScheduleDetailViewController
{
    UIActivityIndicatorView *spinner;
    Document *currentDocument;
    
}
@synthesize document;
@synthesize scheduleDetailsArray;

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
    
    
    id appDelegate = (id)[[UIApplication sharedApplication] delegate];
    context = [appDelegate managedObjectContext];
    
    scheduleDetailsArray=[[NSMutableArray alloc] initWithCapacity:50];
    spinner = [[UIActivityIndicatorView alloc]  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin);
    spinner.center = CGPointMake(self.tableView.bounds.size.width / 2.0f, self.tableView.bounds.size.height / 2.0f);
    [self.view addSubview:spinner];
    
    TitleLabel *titelLabel=[[TitleLabel alloc] initWithFrame:CGRectZero];
    self.navigationItem.titleView = titelLabel;
    titelLabel.text=self.document.name;
    [titelLabel sizeToFit];
    
    //    self.title=self.document.name;
    
    if ([UIRefreshControl class]){
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.attributedTitle=[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Pull To Refresh",nil)];
        self.refreshControl = refreshControl;
        [refreshControl addTarget:self action:@selector(loadScheduleDetails) forControlEvents:UIControlEventValueChanged];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadScheduleDetails)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    self.navigationItem.rightBarButtonItem=[self editButtonItem];
    
    [self loadScheduleDetails];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}



#pragma mark Load Schedule Details
-(void) loadScheduleDetails{
    
    if (self.document!=nil){
        [spinner startAnimating];
        [self.scheduleDetailsArray removeAllObjects];
        BIGetScheduleDetail *biGetScheduleDetails=[[BIGetScheduleDetail alloc] init];
        
        biGetScheduleDetails.delegate=self;
        [biGetScheduleDetails geScheduleDetailForDocument:self.document];
        
    }
    
    
}

-(void) biGetScheduleDetails:(BIGetScheduleDetail *)biGetScheduleDetail isSuccess:(BOOL)isSuccess scheduleDetails:(NSMutableArray *)receviedDocuments{
    NSLog(@"Process displaying Schedule Details");
    if ([UIRefreshControl class])
        [self.refreshControl endRefreshing];
    [spinner stopAnimating];
    if (isSuccess==YES){
        NSLog(@"Received Documents count:%d",[receviedDocuments count]);
        
        //[self.scheduleDetailsArray addObjectsFromArray:receviedDocuments];
        self.scheduleDetailsArray=receviedDocuments;
        NSLog(@"Number of Rows:%d",self.scheduleDetailsArray.count);
    }
    
    [self.tableView reloadData];
    
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    //    int rowsCount;
    //    if (isDataLoded && isNoMoreDocumentsLeft==NO ){
    //        rowsCount=self.scheduleDetailsArray.count+1;
    //        NSLog(@"Added Row count:%d",rowsCount);
    //    }else{
    //        rowsCount=self.scheduleDetailsArray.count;
    //    }
    
    return self.scheduleDetailsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ScheduleDetail_Ident";
    ScheduleDetailCell *cell;
    if ([self.tableView respondsToSelector:@selector(dequeueReusableCellWithIdentifier:forIndexPath:)])
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    else
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // Configure the cell...
    if ([indexPath row]<=[scheduleDetailsArray count]){
        ScheduleDetails * scheduleDetails=[self.scheduleDetailsArray objectAtIndex:[indexPath row]];
        cell.scheduleLabelId.text=[NSString stringWithFormat:@"%d",[scheduleDetails scheduleId]];
        cell.scheduleLabelName.text=[scheduleDetails scheduleName] ;
        cell.scheduleLabelStatus.text=[scheduleDetails scheduleStatus] ;
        if ([[scheduleDetails scheduleStatus] isEqualToString:@"Completed"]){
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        }else if ([[scheduleDetails scheduleStatus] isEqualToString:@"Failed"]){
            cell.scheduleLabelStatus.textColor =[UIColor redColor];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            
        }
        if ([scheduleDetails.scheduleFormat isEqualToString:@"webi"]){
            [cell.scheduleLabelFormat setImage:[UIImage imageNamed:@"WebiDoc_48.png"]];
        }else if ([scheduleDetails.scheduleFormat isEqualToString:@"pdf"]){
            [cell.scheduleLabelFormat setImage:[UIImage imageNamed:@"Pdf.png"]];
        }else if ([scheduleDetails.scheduleFormat isEqualToString:@"xls"]){
            [cell.scheduleLabelFormat setImage:[UIImage imageNamed:@"Excel.png"]];
        }else{
            [cell.scheduleLabelFormat setImage:[UIImage imageNamed:@"BlankDoc_48.png"]];
        }
    }
    
    return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        ScheduleDetails * scheduleDetails=[self.scheduleDetailsArray objectAtIndex:[indexPath row]];
        [self.scheduleDetailsArray removeObject:scheduleDetails];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        BIDeleteDocument *biDeleteDocument=[[BIDeleteDocument alloc]init];
        biDeleteDocument.delegate=self;
        [biDeleteDocument deleteScheduledInstance:scheduleDetails forDocumentId:[scheduleDetails.document.id intValue] withSession:scheduleDetails.document.session];
        
        
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

-(void) biDeleteDocument:(BIDeleteDocument *)biDeleteDocument isSuccess:(BOOL)isSuccess withDeleteStatus:(DeleteStatus *)deleteStatus{
    if (isSuccess==NO){
        [TestFlight passCheckpoint:@"Webi Document Instance Failed to delete"];
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Delete Document Failed",nil) message:[deleteStatus message ] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil, nil];
        [alert show];
        
    }else{
        NSLog(@"Instance deleted");
        [TestFlight passCheckpoint:@"Webi Document Instance Deleted"];
    }
}

-(void) setEditing:(BOOL)editing animated:(BOOL)animated{
    NSLog(@"Edit/Cancel Clicked");
    
#ifdef Lite
    [super setEditing:NO animated:animated];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Lite Version",@"Demo Version - some functions not allowed") message:NSLocalizedString(@"Deleting objects is not supported in the Lite version. Please purchase a full version on the app store",nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"OK",nil), nil];
    [alertView show];
    
#endif
#ifndef Lite
    [super setEditing:editing animated:animated];
#endif
    
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    
#ifdef Lite
    return NO;
#endif
    return YES;
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
    DocumentDetailsViewController        *documentDetailsViewController =segue.destinationViewController;
    
	if ([segue.identifier isEqualToString:@"ShowSchduledInstance_Ident"])
	{
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        ScheduleDetails * scheduleDetails=[self.scheduleDetailsArray objectAtIndex:[indexPath row]];
        
        Document *instance = [NSEntityDescription
                              insertNewObjectForEntityForName:@"Document"
                              inManagedObjectContext:context];
        instance.id=[NSNumber numberWithInt:scheduleDetails.scheduleId];
        instance.name=scheduleDetails.scheduleName;
        instance.path=document.path;
        instance.session=scheduleDetails.document.session;
        documentDetailsViewController.isInstance=YES;
        documentDetailsViewController.document=instance;
        if ([scheduleDetails.scheduleFormat isEqualToString:@"webi"])
            [documentDetailsViewController setIsExternalFormat:NO];
        else [documentDetailsViewController setIsExternalFormat:YES];
        
        NSLog(@"Selected Instance ID:%@",instance.id);
        
	}
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



@end
