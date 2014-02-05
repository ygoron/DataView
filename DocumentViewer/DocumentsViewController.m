//
//  DocumentsViewController.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-02-21.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import "DocumentsViewController.h"
#import "CoreDataHelper.h"
#import "Session.h"
#import "Document.h"
#import "DocumentCell.h"
#import "DocumentDetailsViewController.h"
#import "BI4RestConstants.h"
#import "BIDeleteDocument.h"
#import "DeleteStatus.h"
#import "TitleLabel.h"
#import "WebiAppDelegate.h"
#import "Utils.h"

@interface DocumentsViewController ()


@end


@implementation DocumentsViewController


{
    
    NSManagedObjectContext *context;
    UIActivityIndicatorView *spinner;
    int offset;
    BOOL isDataLoded;
    BOOL isNoMoreDocumentsLeft;
    int totalDocumentsReceived;
    WebiAppDelegate *appDelegate;
    
}

@synthesize sessions;
@synthesize currentSession;
//@synthesize documents;
@synthesize grouppedDocuments;
@synthesize titleLabel;

    
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
    
    
//        UIImage *backgroundImage = [UIImage imageNamed:@"leather-background.png"];
//        UIColor *backgroundPattern= [UIColor colorWithPatternImage:backgroundImage];
//        [self.view setBackgroundColor:backgroundPattern];
    
    NSLog(@"Documents View Controller");
    
    //    UIImage* toolbarBgBottom = [UIImage imageNamed:@"ipad-tabbar-right.png"];
    //    [self.navigationController.toolbar setBackgroundImage:toolbarBgBottom forToolbarPosition:UIToolbarPositionBottom barMetrics:UIBarMetricsDefault];
    
    //    UIImage *navBarImage = [UIImage imageNamed:@"ipad-menubar-right.png"];
    //
    //    [self.navigationController.navigationBar setBackgroundImage:navBarImage
    //                                                  forBarMetrics:UIBarMetricsDefault];
    
    
    grouppedDocuments=[[NSMutableArray alloc] initWithCapacity:50];
    //    id appDelegate = (id)[[UIApplication sharedApplication] delegate];
    
    appDelegate= (id)[[UIApplication sharedApplication] delegate]; 
    context = [appDelegate managedObjectContext];
    offset=0;
    isDataLoded=NO;
    self.navigationItem.leftBarButtonItem=[self editButtonItem];
    
    
    
    
    spinner = [[UIActivityIndicatorView alloc]  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin);
    spinner.center = CGPointMake(self.tableView.bounds.size.width / 2.0f, self.tableView.bounds.size.height / 2.0f);
    [self.view addSubview:spinner];
    
    if ([UIRefreshControl class]){
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.attributedTitle=[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Pull To Refresh Webi Documents List",nil)];
        self.refreshControl = refreshControl;
        [refreshControl addTarget:self action:@selector(reloadDocuments) forControlEvents:UIControlEventValueChanged];
    }
    
    
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(reloadDocuments)
//                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    
    self.titleLabel=[[TitleLabel alloc] initWithFrame:CGRectZero];
    self.navigationItem.titleView = titleLabel;
    //    titelLabel.text=@"Webi Documents";
    
    [self reloadDocuments];
    
    
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


#pragma mark ReloadDocuments
-(void) reloadDocuments{
#ifdef Trace
    UITabBarController *tabBarController =(UITabBarController *)  appDelegate.window.rootViewController;
    NSLog(@"Selected index:%d",     tabBarController.selectedIndex);
#endif
    //Refresh only if current view
//    if (self.isViewLoaded && self.view.window) {
        //    if (tabBarController.selectedIndex==0){
        offset=0;
        totalDocumentsReceived=0;
        grouppedDocuments=[[NSMutableArray alloc] initWithCapacity:50];
        [self loadDocuments];
//    }
}

#pragma mark Load Documents

-(void) loadDocuments {
    if (context==nil)     {
        NSLog(@"Context is Null!!");
        appDelegate= (id)[[UIApplication sharedApplication] delegate];
        context = [appDelegate managedObjectContext];
    }
    self.sessions=[CoreDataHelper getObjectsForEntity:@"Session" withSortKey:nil andSortAscending:YES andContext:context];
    NSLog(@"Sessions:%d",[sessions count]);
    
    if (sessions.count==0){
        if ([UIRefreshControl class]){
            [self.refreshControl endRefreshing];
        }
        [spinner stopAnimating];
        [self.tableView reloadData];
    }
    BOOL isAtLeastOneSessionEnabled=NO;
    for (Session *session in self.sessions) {
        if ([session.isEnabled intValue ] ==1){
            isAtLeastOneSessionEnabled=YES;
            isDataLoded=NO;
            NSLog(@"Processing Session %@ Documents Count:%d",session.name,session.documents.count);
            NSLog(@"Updating documents");
            [spinner startAnimating];
            BIGetDocuments *getDocuments=[[BIGetDocuments alloc]init];
            getDocuments.context=context;
            getDocuments.delegate=self;
            getDocuments.biSession=session;
            self.currentSession=session;
            self.titleLabel.text=self.currentSession.name;
            [self.titleLabel sizeToFit];
            [getDocuments getDocumentsForSession:session withLimit:[appDelegate.globalSettings.fetchDocumentLimit intValue] withOffset:offset];
            
            break;
        }
        
        
    }
    if (isAtLeastOneSessionEnabled==NO)  {
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Active Sessions Found",nil) message:NSLocalizedString(@"Please Create/Enable at least one CMS Session" ,nil)delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void) restoreDocuments{
    NSLog(@"Controller Becomes Active");
}

#pragma mark documents receieved

-(void)biGetDocuments:(BIGetDocuments *)biGetDocuments isSuccess:(BOOL)isSuccess documents:(NSMutableArray *)receivedDocuments{
    if ([UIRefreshControl class]){
        [self.refreshControl endRefreshing];
    }
    [spinner stopAnimating];
    if (isSuccess==YES){
        NSLog(@"Documents Received");
        [TestFlight passCheckpoint:[NSString stringWithFormat:@"%@%d",@"Webi Documents Received. Count:",receivedDocuments.count]];
        isDataLoded=YES;
        if ([receivedDocuments count]==0 || receivedDocuments.count< [appDelegate.globalSettings.fetchDocumentLimit intValue]) isNoMoreDocumentsLeft=YES;
        else isNoMoreDocumentsLeft=NO;
        [self populateFirstLetters:receivedDocuments];
    }
    else if (biGetDocuments.connectorError!=nil){
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Load Documents Failed",nil) message:[biGetDocuments.connectorError localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil, nil];
        [alert show];
        self.grouppedDocuments=nil;
        
    }else if (biGetDocuments.boxiError!=nil){
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Load Documents Failed in BI",nil) message:biGetDocuments.boxiError delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil, nil];
        [alert show];
        self.grouppedDocuments=nil;
        
    } else{
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Load Documents Failed",nil) message:NSLocalizedString(@"Server Error",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil, nil];
        [alert show];
        self.grouppedDocuments=nil;
        
    }
    
    
    
    [self.tableView reloadData];
    
    
}


#pragma mark Create/Update of Array of Grouped Documents

-(void) populateFirstLetters:(NSMutableArray *)newDocuments{
    NSMutableArray *tempDocs=[[NSMutableArray alloc] init];
    NSString *firstChar;
    NSString *oldFirstChar;
    NSMutableDictionary *groupRow;
    for (Document *document in newDocuments) {
        //        NSLog(@"Processing Document:%@",document.name);
        firstChar=[document.name substringToIndex:1];
        //        NSLog(@"Creating character %@",firstChar);
        if (![firstChar isEqualToString:oldFirstChar]){
            if (tempDocs.count>0){
                int indexOfTheGroup=[[self.grouppedDocuments  valueForKey:@"index"] indexOfObject:oldFirstChar];
                
                if (indexOfTheGroup==NSNotFound){
                    //                    NSLog(@"Creating New Group");
                    groupRow= [self createNewDocumentGroupWithIndex:oldFirstChar withArray:tempDocs];
                    [self.grouppedDocuments addObject:groupRow];
                    
                }
                else{
                    groupRow=[self.grouppedDocuments objectAtIndex:indexOfTheGroup];
                    [groupRow setObject:oldFirstChar forKey:@"index"];
                    [groupRow setObject:tempDocs forKey:@"values"];
                }
                //                NSLog(@"Added Rows:%d",tempDocs.count);
                tempDocs=[[NSMutableArray alloc] init];
            }
        }
        [tempDocs addObject:document];
        
        
        oldFirstChar=firstChar;
    }
    if(tempDocs.count>0)   {
        int indexOfTheGroup=[[self.grouppedDocuments  valueForKey:@"index"] indexOfObject:oldFirstChar];
        if (indexOfTheGroup==NSNotFound){
            //            NSLog(@"Creating New Group");
            NSDictionary *group= [self createNewDocumentGroupWithIndex:oldFirstChar withArray:tempDocs];
            [self.grouppedDocuments addObject:group];
        }
        else{
            //            NSLog(@"Groupped Documents:%@",self.grouppedDocuments);
            NSMutableArray *docsInGroup=[[self.grouppedDocuments objectAtIndex:indexOfTheGroup] objectForKey:@"values"];
            [docsInGroup addObjectsFromArray:tempDocs];
            //            NSLog(@"Array!");
        }
        
    }
    
    
    totalDocumentsReceived+=[newDocuments count];
}

-(NSMutableDictionary *)createNewDocumentGroupWithIndex:(NSString *)indexString withArray:(NSArray *)documents{
    
    NSMutableDictionary *group= [[NSMutableDictionary alloc]init];
    [group setObject:indexString forKey:@"index"];
    [group setObject:documents forKey:@"values"];
    return group;
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    
    int numberOfSections=[self.grouppedDocuments count];
    if (self.grouppedDocuments.count>0){
        if (isDataLoded==YES && isNoMoreDocumentsLeft==NO){
            NSLog(@"Number of sections:%d",numberOfSections);
            return numberOfSections+1;
        }else{
            
            return numberOfSections;
        }
    }
    
    
    return 0;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    
    if (section < self.grouppedDocuments.count){
        int rowsCount=0;
        //        NSLog(@"Section Count:%d",[[[self.grouppedDocuments objectAtIndex:section] objectForKey:@"values"]count]);
        rowsCount=[[[self.grouppedDocuments objectAtIndex:section] objectForKey:@"values"]count];
        //        NSLog(@"Rows count %d for section %d",rowsCount, section);
        return rowsCount;
    }else return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
        appDelegate= (id)[[UIApplication sharedApplication] delegate];
      
    if ([indexPath section]<self.grouppedDocuments.count){
        DocumentCell *cell=[tableView dequeueReusableCellWithIdentifier:@"DocumentCell_Ident"];
        Document *document=[[[self.grouppedDocuments objectAtIndex:indexPath.section] objectForKey:@"values"] objectAtIndex:indexPath.row];
        cell.documentNameLabel.text=document.name;
        //        cell.labelSession.text=document.session.name;
        if (document.descriptiontext!=nil)
            cell.documentDescriptionLabel.text=document.descriptiontext;
        else cell.documentDescriptionLabel.text=[NSString stringWithFormat:@"%@",NSLocalizedString(@"No Description Available",nil)];
        cell.documentIDLabel.text=[document.id stringValue];
        
        return cell;
    }
    else{
        [TestFlight passCheckpoint:@"There are more Webi Document objects on BI than in view"];
        DocumentCell *cell=[tableView dequeueReusableCellWithIdentifier:@"MoreCell_Ident"];
        return cell;
    }
    
    
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
#ifdef Lite
    //    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Lite Version" message:@"Deleting objects is not supported in the Lite version. Please purchase a full version on the app store" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    //    [alertView show];
    
    return NO;
#endif
    if (indexPath.section==[self.grouppedDocuments count]) return NO;
    return YES;
}

-(void) setEditing:(BOOL)editing animated:(BOOL)animated{
    NSLog(@"Edit/Cancel Clicked");

#ifdef Lite
    [super setEditing:NO animated:animated];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Lite Version",nil) message:NSLocalizedString(@"Deleting objects is not supported in the Lite version. Please purchase a full version on the app store",nil) delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];

#endif
#ifndef Lite
    [super setEditing:editing animated:animated];
#endif

    
}

//-(void) setEditing:(BOOL)editing animated:(BOOL)animated{
//    [super setEditing:editing animated:animated];
//    NSLog(@"Edit/Cancel Clicked");
//    if (editing==YES){
//        [self.tableView endEditing:YES];
//    }
//}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        Document *doc=[[[self.grouppedDocuments objectAtIndex:indexPath.section] objectForKey:@"values"] objectAtIndex:indexPath.row];
        NSLog(@"Deleting document name %@",doc.name);
        [[[self.grouppedDocuments objectAtIndex:indexPath.section] objectForKey:@"values"] removeObject:doc];

        if (doc.session==nil) doc.session=appDelegate.activeSession;
        BIDeleteDocument *biDeletDocument=[[BIDeleteDocument alloc]init];
        biDeletDocument.delegate=self;
        [biDeletDocument deleteDocument:[doc.id  integerValue] withSession:doc.session ];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

-(void) biDeleteDocument:(BIDeleteDocument *)biDeleteDocument isSuccess:(BOOL)isSuccess withDeleteStatus:(DeleteStatus *)deleteStatus{
    if (isSuccess==NO){
        [TestFlight passCheckpoint:@"Webi Document Fialed to Delete"];
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Delete Document Failed",nil) message:[deleteStatus message ] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil, nil];
        [alert show];
        
    }else{
        [TestFlight passCheckpoint:@"Webi Document Deleted"];
        NSLog(@"Document deleted");
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


- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIImage *backgroundImage = [UIImage imageNamed:@"leather-background.png"];
    //    UIImage *backgroundImage = [UIImage imageNamed:@"list-item.png"];
    UIColor *backgroundPattern= [UIColor colorWithPatternImage:backgroundImage];
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 3, tableView.bounds.size.width - 10, 18)];
    if(section< self.grouppedDocuments.count)
        label.text = [[self.grouppedDocuments objectAtIndex:section] valueForKey:@"index"];
    //    label.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.75];
    
    label.font = [UIFont  boldSystemFontOfSize:12.0];
    //    label.shadowColor = [UIColor blackColor];
    label.textAlignment=NSTextAlignmentLeft;
    //        label.textColor = [UIColor blueColor];
    
    label.backgroundColor = [UIColor clearColor];
    [headerView addSubview:label];
    [headerView setBackgroundColor:backgroundPattern];
    return headerView;
}


-(NSArray *) sectionIndexTitlesForTableView:(UITableView *)tableView{
    return [self.grouppedDocuments valueForKey:@"index"];
}

-(NSInteger) tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    int indexOftheTitle =[[self.grouppedDocuments valueForKey:@"index"] indexOfObject:title];
    NSLog(@"Indexes:%@, Title %@,retuned index:%d",[self.grouppedDocuments valueForKey:@"index"],title,indexOftheTitle );
    return indexOftheTitle;
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
    if (section <self.grouppedDocuments.count)
        return [[self.grouppedDocuments objectAtIndex:section] objectForKey:@"index"];
    else return nil;
    
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if ([indexPath row]>=self.documents.count) {
    if ([indexPath section]>=self.grouppedDocuments.count) {
        
        NSLog(@"Clicked More!");
        [TestFlight passCheckpoint:@"More Webi Document Clicked"];
        //        offset=self.documents.count;
        offset=totalDocumentsReceived;
        [self loadDocuments];
    }
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
    
    if ([segue.identifier isEqualToString:@"DocumentDetailsIdent"])
    {
        [TestFlight passCheckpoint:@"Webi Document Details Requested"];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        //        if ([indexPath row]<self.documents.count)
        NSLog(@"Selected row:%d",[indexPath row]);
        Document *doc=[[[self.grouppedDocuments objectAtIndex:indexPath.section] objectForKey:@"values"] objectAtIndex:indexPath.row];
        documentDetailsViewController.document=doc;
        documentDetailsViewController.document.session=currentSession;
        
    }
}


-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)edit:(id)sender {
    [self.tableView setEditing:YES animated:YES];
}
- (IBAction)buttonRefresh:(id)sender {
    [self reloadDocuments];
}
@end
