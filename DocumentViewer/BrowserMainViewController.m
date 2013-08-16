//
//  BrowserMainViewController.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-05-01.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import "BrowserMainViewController.h"
#import "BrowserChildViewController.h"
#import "WebiAppDelegate.h"
#import "BI4RestConstants.h"

@interface BrowserMainViewController ()

@end

@implementation BrowserMainViewController
{
    WebiAppDelegate *appDelegate;
    TitleLabel *titelLabel;
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
    
    if (appDelegate.activeSession!=nil){
        NSLog(@"Active Session:%@",appDelegate.activeSession.name);
        titelLabel.text=appDelegate.activeSession.name;
        self.navigationItem.titleView = titelLabel;
        [titelLabel sizeToFit];
        [super viewDidAppear:animated];
    }else{
        NSLog(@"No Active Session");
    }
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate= (id)[[UIApplication sharedApplication] delegate];
    
    titelLabel=[[TitleLabel alloc] initWithFrame:CGRectZero];
    
    UIUserInterfaceIdiom idiom = [[UIDevice currentDevice] userInterfaceIdiom];
    
    if (idiom == UIUserInterfaceIdiomPad) {
        [_inboxH setConstant:50];
    }
    //    UIView *myImage=_imageView;
    //    UIView *myInboxLabel=_inboxLabel;
    //    UIView *myTable=self.tableView;
    //    NSDictionary *viewsDictionary =    NSDictionaryOfVariableBindings(myImage,myInboxLabel,myTable);
    //    [self.view addConstraints:[NSLayoutConstraint
    //                               constraintsWithVisualFormat:@"|-(100@1000)-[myImage]-50-[myInboxLabel]"
    //                               options:0
    //                               metrics:nil
    //                               views:viewsDictionary]];
    
    
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
    
    
    
    if (appDelegate.activeSession!=nil){
        NSLog(@"Selected Row:%d",[indexPath row]);
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([cell.reuseIdentifier isEqualToString:@"Cell_Folders"]){
            
            [TestFlight passCheckpoint:@"Folders View Selected"];
            
            BrowserChildViewController *vc=[[BrowserChildViewController alloc] initWithNibName:@"BrowserChildViewController" bundle:nil];
            NSURL *urlChildren=[BrowserMainViewController buildUrlFromSession:appDelegate.activeSession forEntity:rootFolderChildrenPoint withPageSize:[appDelegate.globalSettings.fetchDocumentLimit intValue]];
            NSURL *urlSelected=[BrowserMainViewController buildUrlFromSession:appDelegate.activeSession forEntity:rootFolderPoint withPageSize:[appDelegate.globalSettings.fetchDocumentLimit intValue]];
            
            vc.urlForSelectedObject=urlSelected;
            vc.urlForChildren=urlChildren;
            vc.displayPath=@"Path:/Root";
            vc.currentSession=appDelegate.activeSession;
            vc.myStoryBoard=self.storyboard;
            vc.title=NSLocalizedString(@"Folders",@"Name- Folders");
            [self.navigationController pushViewController:vc animated:YES];
        } else if ([cell.reuseIdentifier isEqualToString:@"Cell_Inbox"]){
            
            [TestFlight passCheckpoint:@"Inbox View Selected"];
            
            BrowserChildViewController *vc=[[BrowserChildViewController alloc] initWithNibName:@"BrowserChildViewController" bundle:nil];
            NSURL *urlChildren=[BrowserMainViewController buildUrlFromSession:appDelegate.activeSession forEntity:inboxesChildrenPoint withPageSize:[appDelegate.globalSettings.fetchDocumentLimit intValue]];
            NSURL *urlSelected=[BrowserMainViewController buildUrlFromSession:appDelegate.activeSession forEntity:inboxesPoint withPageSize:[appDelegate.globalSettings.fetchDocumentLimit intValue]];
            
            vc.urlForSelectedObject=urlSelected;
            vc.urlForChildren=urlChildren;
            
            vc.currentSession=appDelegate.activeSession;
            vc.myStoryBoard=self.storyboard;
            vc.isFilterByUserName=YES;
            vc.currentSession=appDelegate.activeSession;
            vc.title=NSLocalizedString(@"Inbox",@"Name - Inbox");
            vc.displayPath=NSLocalizedString(@"/Inbox","Path");
            [self.navigationController pushViewController:vc animated:YES];
            
        }else if ([cell.reuseIdentifier isEqualToString:@"Cell_Personal"]){
            [TestFlight passCheckpoint:@"Personal Folder View Selected"];
            
            BrowserChildViewController *vc=[[BrowserChildViewController alloc] initWithNibName:@"BrowserChildViewController" bundle:nil];
            NSURL *urlChildren=[BrowserMainViewController buildUrlFromSession:appDelegate.activeSession forEntity:userFoldersChildrenPoint withPageSize:[appDelegate.globalSettings.fetchDocumentLimit intValue]];
            
            NSURL *urlSelected=[BrowserMainViewController buildUrlFromSession:appDelegate.activeSession forEntity:userFoldersPoint withPageSize:[appDelegate.globalSettings.fetchDocumentLimit intValue]];
            
            vc.urlForSelectedObject=urlSelected;
            vc.urlForChildren=urlChildren;
            
            vc.isFilterByUserName=YES;
            vc.currentSession=appDelegate.activeSession;
            vc.myStoryBoard=self.storyboard;
            vc.title=NSLocalizedString(@"Personal Folder",@"Label");
            vc.displayPath=NSLocalizedString(@"/Personal Folder",@"Label- Path");
            [self.navigationController pushViewController:vc animated:YES];
            
        }else if ([cell.reuseIdentifier isEqualToString:@"Cell_PersonalCategories"]){
            [TestFlight passCheckpoint:@"Personal Categories View Selected"];
            
            BrowserChildViewController *vc=[[BrowserChildViewController alloc] initWithNibName:@"BrowserChildViewController" bundle:nil];
            NSURL *urlChildren=[BrowserMainViewController buildUrlFromSession:appDelegate.activeSession forEntity:personalCategoriesChildrenPoint withPageSize:[appDelegate.globalSettings.fetchDocumentLimit intValue]];
            
            NSURL *urlSelected=[BrowserMainViewController buildUrlFromSession:appDelegate.activeSession forEntity:personalCategoriesPoint withPageSize:[appDelegate.globalSettings.fetchDocumentLimit intValue]];
            
            vc.urlForSelectedObject=urlSelected;
            vc.urlForChildren=urlChildren;
            
            vc.isFilterByUserName=YES;
            vc.currentSession=appDelegate.activeSession;
            vc.myStoryBoard=self.storyboard;
            vc.title=NSLocalizedString(@"Personal Categories",@"Label");
            vc.displayPath=NSLocalizedString(@"/Personal Categories",@"Label - Path");
            vc.isSupressShowChildrenOfChildren=YES;
            [self.navigationController pushViewController:vc animated:YES];
            
        }else if ([cell.reuseIdentifier isEqualToString:@"Cell_Categories"]){
            [TestFlight passCheckpoint:@"Enterprise Categories View Selected"];
            
            BrowserChildViewController *vc=[[BrowserChildViewController alloc] initWithNibName:@"BrowserChildViewController" bundle:nil];
            NSURL *urlChildren=[BrowserMainViewController buildUrlFromSession:appDelegate.activeSession forEntity:categoriesChildrenPoint withPageSize:[appDelegate.globalSettings.fetchDocumentLimit intValue]];
            
            NSURL *urlSelected=[BrowserMainViewController buildUrlFromSession:appDelegate.activeSession forEntity:categoriesPoint withPageSize:[appDelegate.globalSettings.fetchDocumentLimit intValue]];
            
            vc.urlForSelectedObject=urlSelected;
            vc.urlForChildren=urlChildren;
            vc.currentSession=appDelegate.activeSession;
            vc.myStoryBoard=self.storyboard;
            vc.isSupressShowChildrenOfChildren=YES;
            vc.title=NSLocalizedString(@"Categories",@"Label");
            vc.displayPath=NSLocalizedString(@"/Categories",@"Label-Path");
            [self.navigationController pushViewController:vc animated:YES];
            
        }
        
        
        
        
    }else{
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Active Sessions",@"Missing Session Info") message:NSLocalizedString(@"Please Create/Enable at least one SAP BI Session",@"Missing Session Info") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
    }
    
}

+(NSURL *) buildUrlFromSession:(Session *)session forEntity:(NSString *)entity withPageSize:(int)pageSize
{
    NSLog (@"Build  URL for Session Name:%@, Entity:%@",session,entity);
    NSURL *url;
    NSString *host=[NSString stringWithFormat: @"%@:%@",session.cmsName,session.port] ;
    if ([session.isHttps integerValue]==1){
        url=[[NSURL alloc]initWithScheme:@"https" host:host path:[NSString stringWithFormat:@"%@%@",session.cypressSDKBase,entity]];
    }
    else{
        url=[[NSURL alloc]initWithScheme:@"http" host:host path:[NSString stringWithFormat:@"%@%@",session.cypressSDKBase,entity]];
    }
    NSLog(@"URL:%@",url);
    NSString *urlString=  [[NSString alloc] initWithFormat:@"%@%@%d", [url absoluteString],@"?pageSize=",pageSize];
    
    return [[NSURL alloc] initWithString:urlString];
    
}


@end
