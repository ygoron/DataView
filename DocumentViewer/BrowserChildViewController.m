//
//  BrowserChildViewController.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-05-09.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import "BrowserChildViewController.h"
#import "WebiAppDelegate.h"
#import "BrowserCell.h"
#import "InfoObject.h"
#import "CypressResponseHeader.h"
#import "BrowserObjectActionsViewController.h"
#import "DocumentDetailsViewController.h"

@interface BrowserChildViewController ()

@end

@implementation BrowserChildViewController

{
    
    UIActivityIndicatorView *spinner;
    BOOL isDataLoded;
    BOOL isNoMoreDocumentsLeft;
    int totalInfoObjectsReceived;
    WebiAppDelegate *appDelegate;
    NSURL *urlStart;
    
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void) viewDidAppear:(BOOL)animated{
    NSLog(@"Active Session:%@",appDelegate.activeSession.name);
    _currentSession=appDelegate.activeSession;
    [super viewDidAppear:animated];
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
    
    
    UINib *nib=[UINib nibWithNibName:@"BrowserCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"Browser_Cell"];
    
    nib=[UINib nibWithNibName:@"MoreCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"More_Cell"];
    
    
    spinner = [[UIActivityIndicatorView alloc]  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin);
    spinner.center = CGPointMake(self.tableView.bounds.size.width / 2.0f, self.tableView.bounds.size.height / 2.0f);
    [self.view addSubview:spinner];
    
    if ([UIRefreshControl class]){
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.attributedTitle=[[NSAttributedString alloc] initWithString:@"Pull To Refresh Objects List"];
        self.refreshControl = refreshControl;
        [refreshControl addTarget:self action:@selector(reLoadObjects) forControlEvents:UIControlEventValueChanged];
    }
    
    appDelegate= (id)[[UIApplication sharedApplication] delegate];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    
    
    //    _textViewInfo.text=@"Name: Root Folder\nDescription:This a top level folder\nCUID:jkdjkdjkdkjdkd\nid:dkldkldkl";
    
    TitleLabel *titelLabel=[[TitleLabel alloc] initWithFrame:CGRectZero];
    titelLabel.text=self.title;
    self.navigationItem.titleView = titelLabel;
    [titelLabel sizeToFit];
    
    UIBarButtonItem *refreshButton         = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                              target:self
                                              action:@selector(reLoadObjects)];
    self.navigationItem.rightBarButtonItems =
    [NSArray arrayWithObjects:refreshButton, nil];
    urlStart=_urlForChildren;
    [self reLoadObjects];
    //    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)displayHeaderInfoWithInfoObject:(InfoObject *)infoObject
{
    //    NSString *text=[NSString stringWithFormat:@"%@%@%@%@%@%d%@%@%@%@",infoObject.name,@"\n",infoObject.type,@"\n",@"id:",infoObject.objectId,@"\n",@"cuid:",infoObject.cuid,@"\n"];
    
    
}
-(void) reLoadObjects
{
    _infoObjects=[[NSMutableArray alloc] initWithCapacity:50];
    _urlForChildren=urlStart;
    [self loadObjects];
}
-(void) loadObjects
{
    NSLog(@"Starting Load Objects");
    [spinner startAnimating];
    if (_urlForChildren){
        
        BISDKCall *biCallChildren=[[BISDKCall alloc]init];
        biCallChildren.delegate=self;
        biCallChildren.biSession=_currentSession;
        biCallChildren.isFilterByUserName=_isFilterByUserName;
        [biCallChildren getObjectsForSession:_currentSession withUrl:_urlForChildren];
    }
    
    
    //    if (_urlForSelectedObject){
    //        BISDKCall *biCallSelected=[[BISDKCall alloc]init];
    //        biCallSelected.delegate=self;
    //        biCallSelected.biSession=_currentSession;
    //        biCallSelected.isFilterByUserName=_isFilterByUserName;
    //        [biCallSelected getSelectedObjectForSession:_currentSession withUrl:_urlForSelectedObject];
    //    }
    
}

-(void) cypressCallSelectedObject:(BISDKCall *)biSDKCall withResponse:(CypressResponseHeader *)response isSuccess:(BOOL)isSuccess withObject:(InfoObject *)receivedObject
{
    
    if (isSuccess==YES){
        NSLog(@"Selected Object Received ID: %d",receivedObject.objectId);
        NSLog(@"Selected Object Received ID: %@",receivedObject.cuid);
        [TestFlight passCheckpoint:@"Selected Object Received"];
        _selectedObject=receivedObject;
        [self displayHeaderInfoWithInfoObject:receivedObject];
        
        //        if (_selectedObject.childrenUrl){
        //            _urlForChildren=_selectedObject.childrenUrl;
        //            BISDKCall *biCallChildren=[[BISDKCall alloc]init];
        //            biCallChildren.delegate=self;
        //            biCallChildren.biSession=_currentSession;
        //            biCallChildren.isFilterByUserName=_isFilterByUserName;
        //            [biCallChildren getObjectsForSession:_currentSession withUrl:_urlForChildren];
        //        }else{
        //
        //            if ([UIRefreshControl class]){
        //                [self.refreshControl endRefreshing];
        //            }
        //
        //            [spinner stopAnimating];
        //
        //        }
        
    }
    else {
        
        if (biSDKCall.connectorError!=nil){
            UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Load Selected Object Failed",@"Failed") message:[biSDKCall.connectorError localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
        }else if (biSDKCall.boxiError!=nil){
            UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Load Selected Object Failed in BI",nil) message:biSDKCall.boxiError delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
        } else{
            UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Load Selected Object Failed",nil) message:@"Server Error" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
        }
    }
    
}

-(void)cypressCallForChildren:(BISDKCall *)biSDKCall withResponse:(CypressResponseHeader *)response isSuccess:(BOOL)isSuccess withChildrenObjects:(NSArray *)receivedObjects
{
    if ([UIRefreshControl class]){
        [self.refreshControl endRefreshing];
    }
    
    [spinner stopAnimating];
    
    
    if (isSuccess==YES){
        NSLog(@"Children Objects Received");
        
        NSString *checkPointMesssage=[NSString stringWithFormat:@"%@%d",@"All Children Objects Received. Number Of Objects:",receivedObjects.count];
        [TestFlight passCheckpoint:checkPointMesssage];
        
        NSSortDescriptor *byType=[[NSSortDescriptor alloc]initWithKey:@"sortPriority" ascending:YES];
        NSArray *sortDescriptors = @[byType];
        //        NSArray *sortedArray=[receivedObjects sortedArrayUsingDescriptors:sortDescriptors];
        //        [_infoObjects addObjectsFromArray:sortedArray];
        
        [_infoObjects addObjectsFromArray:receivedObjects];
        //        NSArray *tempArray=[_infoObjects copy];
        _infoObjects=[NSMutableArray arrayWithArray:[_infoObjects sortedArrayUsingDescriptors:sortDescriptors]];
        
        isDataLoded=YES;
        NSLog(@"Last URL %@",[response.last absoluteString]);
        NSLog(@"Current URL %@",[response.metadata absoluteString]);
        if ([[response.last absoluteString] isEqualToString:[response.metadata absoluteString]] || response.last ==nil){
            isNoMoreDocumentsLeft=YES;
            NSLog(@"No More Objects Left");
        }
        else {
            
            isNoMoreDocumentsLeft=NO;
            _urlForChildren=response.next;
            NSLog(@"There will be more objects");
            [TestFlight passCheckpoint:@"There are more objects on BI than in view"];
        }
    }
    else if (biSDKCall.connectorError!=nil){
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Load Objects Failed",nil) message:[biSDKCall.connectorError localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        _infoObjects=nil;
        
    }else if (biSDKCall.boxiError!=nil){
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Load Objects Failed in BI",nil) message:biSDKCall.boxiError delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        _infoObjects=nil;
        
    } else{
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Load Objects Failed",nil) message:NSLocalizedString(@"Server Error",nil)delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        _infoObjects=nil;
        
    }
    
    NSLog(@"Sorting Array");
    
    [self.tableView reloadData];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (_isInstance==YES) return NSLocalizedString(@"Historical Instances",@"Title for the header");
    else return nil;
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    //    return [_infoObjects count];
    
    
    // Return the number of rows in the section.
    NSLog(@"Number of Rows in Table:%d",[_infoObjects count]);
    int rowsCount;
    if (isDataLoded && isNoMoreDocumentsLeft==NO ){
        rowsCount=[_infoObjects count]+1;
        NSLog(@"Added Row count:%d",rowsCount);
    }else{
        rowsCount=[_infoObjects count];
    }
    
    return rowsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row]<_infoObjects.count){
        static NSString *CellIdentifier = @"Browser_Cell";
        BrowserCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[BrowserCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        InfoObject *infoObject=[_infoObjects objectAtIndex:[indexPath row]];
        // Configure the cell...
        //        NSLog(@"Object id:%d",infoObject.objectId);
        cell.labelName.text=infoObject.name;
        if (_isInstance==NO){
            if (infoObject.description.length==0)
                cell.labelDescription.text=NSLocalizedString(@"No Description is Available",@"Object does not have a description");
            else cell.labelDescription.text=infoObject.description;
        }else{
            cell.labelDescription.text=@"";
        }
        
        cell.labelType.text=infoObject.type;
        [cell.labelType setHidden:YES];
        if (_isSupressShowChildrenOfChildren==YES) {
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        
        
        if ([infoObject.type isEqualToString:@"Folder"])
            [cell.imageViewIcon setImage:[UIImage imageNamed:@"Folder_48.png"]];
        else if ([infoObject.type isEqualToString:@"CrystalReport"])
            [cell.imageViewIcon setImage:[UIImage imageNamed:@"CrystalDoc_48.png"]];
        else if ([infoObject.type isEqualToString:@"Webi"])
            [cell.imageViewIcon setImage:[UIImage imageNamed:@"WebiDoc_48.png"]];
        
        else if ([infoObject.type isEqualToString:@"Pdf"])
            [cell.imageViewIcon setImage:[UIImage imageNamed:@"Pdf.png"]];
        
        else if ([infoObject.type isEqualToString:@"Word"]|| [infoObject.type isEqualToString:@"Rtf"])
            [cell.imageViewIcon setImage:[UIImage imageNamed:@"Word.png"]];
        
        else if ([infoObject.type isEqualToString:@"Excel"])
            [cell.imageViewIcon setImage:[UIImage imageNamed:@"Excel.png"]];
        
        else if ([infoObject.type isEqualToString:@"FavoritesFolder"])
            [cell.imageViewIcon setImage:[UIImage imageNamed:@"FolderPersonal_48.png"]];
        
        else if ([infoObject.type isEqualToString:@"Inbox"])
            [cell.imageViewIcon setImage:[UIImage imageNamed:@"Inbox_48.png"]];
        
        else if ([infoObject.type isEqualToString:@"PersonalCategory"])
            [cell.imageViewIcon setImage:[UIImage imageNamed:@"CategoriesPersonal_48.png"]];
        
        else if ([infoObject.type isEqualToString:@"Category"])
            [cell.imageViewIcon setImage:[UIImage imageNamed:@"Categories_48.png"]];
        
        else if ([infoObject.type isEqualToString:@"XL.XcelsiusEnterprise"])
            [cell.imageViewIcon setImage:[UIImage imageNamed:@"DashboardDoc_48.png"]];
        else
        {
            [cell.imageViewIcon setImage:[UIImage imageNamed:@"BlankDoc_48.png"]];
            [cell.labelType setHidden:NO];
        }
        return cell;
    }else{
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"More_Cell"];
        return cell;
    }
    
    //    if ([infoObject.type isEqualToString:@"Folder"]){
    //        [cell.imageView setImage:[UIImage imageNamed:@"Folder-1.png"]];
    ////                [cell.imageView setImage:nil];
    //    }
    //
    //    else if ([infoObject.type isEqualToString:@"Webi"]){
    //        [cell.imageView setImage:[UIImage imageNamed:@"WebiDoc_48.png"]];
    //
    //    }
    //    else{
    //        [cell.imageView setImage:nil];
    //    }
    
    //    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

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
    if ([indexPath row]>=_infoObjects.count) {
        [TestFlight passCheckpoint:@"More Clicked"];
        [self loadObjects];
    }else{
        InfoObject *objectAtRow=[_infoObjects objectAtIndex:[indexPath row]];
        
        
        [TestFlight passCheckpoint:[NSString stringWithFormat:@"%@%@",@"Object Type Selected:",objectAtRow.type]];
        
        if (_isSupressShowChildrenOfChildren==YES) return;
        
        if ([objectAtRow.type isEqualToString:@"Webi"]){
            NSLog (@"Proceed with existing Webi REST API support");
            UIStoryboard *storyboard = _myStoryBoard;
            NSManagedObjectContext      *context = [appDelegate managedObjectContext];
            DocumentDetailsViewController *svc = [storyboard instantiateViewControllerWithIdentifier:@"DocumentDetail_Ident"];
            Document *document = [NSEntityDescription
                                  insertNewObjectForEntityForName:@"Document"
                                  inManagedObjectContext:context];
            document.session=_currentSession;
            document.id=[NSNumber numberWithInt:objectAtRow.objectId];
            document.name=objectAtRow.name;
            document.cuid=objectAtRow.cuid;
            svc.document=document;
            [self.navigationController pushViewController:svc animated:YES];
            
            
        }
        
            else if ([objectAtRow.type isEqualToString:@"CrystalReport"] || [objectAtRow.type isEqualToString:@"Pdf"]|| [objectAtRow.type isEqualToString:@"Word"]|| [objectAtRow.type isEqualToString:@"Excel"]|| [objectAtRow.type isEqualToString:@"Txt"] || [objectAtRow.type isEqualToString:@"Rtf"] || [objectAtRow.type isEqualToString:@"Agnostic"] || [objectAtRow.type isEqualToString:@"XL.XcelsiusEnterprise"]){
            BrowserObjectActionsViewController *bavc=[[BrowserObjectActionsViewController alloc]initWithNibName:@"BrowserObjectActionsViewController" bundle:nil];
            NSURL *urlForSelectedObject=[NSURL URLWithString:[NSString stringWithFormat:@"%@",[objectAtRow.metaDataUrl absoluteString] ]];
            bavc.currentSession=_currentSession;
            bavc.objectUrl=urlForSelectedObject;
            bavc.isInstance=_isInstance;
            bavc.path=[NSString stringWithFormat:@"%@%@%@",_displayPath,@"/",objectAtRow.name];
            [self.navigationController pushViewController:bavc animated:YES];
            //            UINavigationController *navigationController = [[UINavigationController alloc]
            //                                                            initWithRootViewController:bavc];
            //            [self presentModalViewController:navigationController animated:YES];
            
        }else{
            BrowserChildViewController *vc=[[BrowserChildViewController alloc] initWithNibName:@"BrowserChildViewController" bundle:nil];
            NSURL *urlForSelectedObject=[NSURL URLWithString:[NSString stringWithFormat:@"%@",[objectAtRow.metaDataUrl absoluteString] ]];
            NSURL *urlForChildren=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%d",[objectAtRow.metaDataUrl absoluteString],@"/children",@"?pageSize=",[appDelegate.globalSettings.fetchDocumentLimit intValue] ]];
            //    NSLog("Children url: %@",_selectedObject.childrenUrl);
            //    NSURL *urlForChildren=_selectedObject.childrenUrl;
            vc.urlForChildren=urlForChildren;
            vc.urlForSelectedObject=urlForSelectedObject;
            vc.currentSession=appDelegate.activeSession;
            vc.title=objectAtRow.name;
            vc.myStoryBoard=self.myStoryBoard;
            vc.displayPath=[NSString stringWithFormat:@"%@%@%@",_displayPath,@"/",objectAtRow.name];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
