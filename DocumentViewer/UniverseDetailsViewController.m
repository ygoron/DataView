//
//  UniverseDetailsViewController.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-03-31.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import "UniverseDetailsViewController.h"


@interface UniverseDetailsViewController ()


@end

@implementation UniverseDetailsViewController

@synthesize universe;
@synthesize unvDetails;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    spinner = [[UIActivityIndicatorView alloc]  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin);
    spinner.center = CGPointMake(self.tableView.bounds.size.width / 2.0f, self.tableView.bounds.size.height / 2.0f);
    [self.view addSubview:spinner];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle=[[NSAttributedString alloc] initWithString:@"Pull To Refresh"];
    self.refreshControl = refreshControl;
    [refreshControl addTarget:self action:@selector(loadUniverseDetails) forControlEvents:UIControlEventValueChanged];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadUniverseDetails)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    
    
    [self loadUniverseDetails];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}


-(void)loadUniverseDetails{
    if (self.unvDetails==nil){
        [spinner startAnimating];
        NSLog(@"First Time Opening - Load data from BI");
        BIGetUniverseDetails *getUniverseDetails=[[BIGetUniverseDetails alloc] init];
        getUniverseDetails.delegate=self;
        [getUniverseDetails getUniverseDetails:self.universe];
    }
    
}



-(void) getUniverseDetails:(BIGetUniverseDetails *)biGetUniverseDetails isSuccess:(BOOL)isSuccess WithUniverseDetails:(NSMutableArray *)universeDetails{
    
    unvDetails=[[NSMutableArray alloc] init];
    [self.refreshControl endRefreshing];
    [spinner stopAnimating];
    if (isSuccess==YES){
        NSLog(@"Universe Details Received. Cound=%d",universeDetails.count);
        [unvDetails addObjectsFromArray:universeDetails];
    }
    else if (biGetUniverseDetails.connectorError!=nil){
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"Load Universe Failed" message:[biGetUniverseDetails.connectorError localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        self.unvDetails=nil;
        
    }else if (biGetUniverseDetails.boxiError!=nil){
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"Load Universe Failed in BI" message:biGetUniverseDetails.boxiError delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        self.unvDetails=nil;
        
    } else{
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"Load Universe Failed" message:@"Server Error" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        self.unvDetails=nil;
        
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
    NSLog(@"Number of Rows:%d",self.unvDetails.count);
    return self.unvDetails.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UniverseDetails_Cell";
    UniverseDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    NSDictionary *dictionary=[self.unvDetails objectAtIndex:[indexPath row]];
    
    NSLog(@"Dictionary:%@",dictionary);
    
    cell=[self setUniverseCell:cell withDictionary:dictionary];
    
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
    UniverseDetailsViewController *vc=[[UniverseDetailsViewController alloc] init];
    
    if([[unvDetails objectAtIndex:[indexPath row]]isKindOfClass:[NSDictionary class]]){
        NSDictionary *selectedItem=[unvDetails objectAtIndex:[indexPath row]];
        NSLog (@"Selected Item:%@",[selectedItem objectForKey:@"name"]);
        
        if ([selectedItem objectForKey:@"item"]!=nil){
            NSLog(@"Item Found");
            NSMutableArray *unvItems=[[NSMutableArray alloc] init];
            if ([[selectedItem objectForKey:@"item"] isKindOfClass:[NSArray class]]){
                NSLog(@"Type Array");
                [unvItems addObjectsFromArray:[selectedItem objectForKey:@"item"]];
            }else{
                NSLog(@"Single Item");
                [unvItems addObject:[selectedItem objectForKey:@"item"]];
            }
            NSLog(@"Total Items to Pass:%d",[unvItems count]);
            vc.unvDetails=unvItems;
            [vc.tableView registerClass:[UniverseDetailsCell class] forCellReuseIdentifier:@"UniverseDetails_Cell"];
            [self.navigationController pushViewController:vc animated:YES];
        }
        
    }
    
    
    
    // Navigation logic may go here. Create and push another view controller.
    /*
     DetailViewController *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

-(UniverseDetailsCell* ) setUniverseCell:(UniverseDetailsCell *)sourceCell withDictionary:(NSDictionary *)dictionary{

    if ([dictionary objectForKey:@"name"]!=nil){
        NSLog(@"Name:%@",[dictionary objectForKey:@"name"]);
        sourceCell.labelName.text=[dictionary objectForKey:@"name"];
    }else{
        sourceCell.labelName.text=@"Description not available";
    }
    if ([dictionary objectForKey:@"description"]!=nil){
        sourceCell.labelDescription.text=[dictionary objectForKey:@"description"];
    }else{
        sourceCell.labelDescription.text=@"Description not available";
    }
    
    if ([dictionary objectForKey:@"@type"]==nil) sourceCell.labelType.text=@"Folder";
    
    
    return sourceCell;
    
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
