//
//  UniverseDetailsViewControllerSolo.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-03-31.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import "UniverseDetailsViewControllerSolo.h"
#import "TitleLabel.h"
#import "Utils.h"

@interface UniverseDetailsViewControllerSolo ()

@end

@implementation UniverseDetailsViewControllerSolo


@synthesize universe;
@synthesize unvDetails;

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
    
    if([Utils isVersion6AndBelow]){
        
        UIImage *backgroundImage = [UIImage imageNamed:@"leather-background.png"];
        UIColor *backgroundPattern= [UIColor colorWithPatternImage:backgroundImage];
        [self.tableView setBackgroundColor:backgroundPattern];
        
        
        UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
        background.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"leather-background.png"]];
        self.tableView.backgroundView = background;
    }
    
    
    spinner = [[UIActivityIndicatorView alloc]  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin);
    spinner.center = CGPointMake(self.tableView.bounds.size.width / 2.0f, self.tableView.bounds.size.height / 2.0f);
    [self.view addSubview:spinner];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadUniverseDetails)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    
    
    UINib *nib=[UINib nibWithNibName:@"UniverseDetailsCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"UniverseDetails_Cell"];
    
    TitleLabel *titelLabel=[[TitleLabel alloc] initWithFrame:CGRectZero];
    self.navigationItem.titleView = titelLabel;
    titelLabel.text=self.title;
    [titelLabel sizeToFit];
    
    
    
    NSLog(@"Loading Universe Details");
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
    else{
        NSLog(@"Loading recursive");
    }
    
}


-(void) getUniverseDetails:(BIGetUniverseDetails *)biGetUniverseDetails isSuccess:(BOOL)isSuccess WithUniverseDetails:(NSMutableArray *)universeDetails{
    
    unvDetails=[[NSMutableArray alloc] init];
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
    NSDictionary *dictionary=[self.unvDetails objectAtIndex:[indexPath row]];
    //    NSLog(@"Dictionary:%@",dictionary);
    
    static NSString *CellIdentifier = @"UniverseDetails_Cell";
    UniverseDetailsCellSolo *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UniverseDetailsCellSolo alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
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
    UniverseDetailsViewControllerSolo *vc=[[UniverseDetailsViewControllerSolo alloc] init];

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
            //            [vc.tableView registerClass:[UniverseDetailsCellSolo class] forCellReuseIdentifier:@"UniverseDetails_Cell"];
            vc.title=[selectedItem objectForKey:@"name"];
            [self.navigationController pushViewController:vc animated:YES];
        }
        
    }
}

-(UniverseDetailsCellSolo* ) setUniverseCell:(UniverseDetailsCellSolo *)sourceCell withDictionary:(NSDictionary *)dictionary{
    
    if ([dictionary objectForKey:@"name"]!=nil)
        sourceCell.lableName.text=[dictionary objectForKey:@"name"];
    else
        sourceCell.lableName.text=NSLocalizedString(@"Description not available",nil);
    
    if ([dictionary objectForKey:@"description"]!=nil)
        sourceCell.labelDescription.text=[dictionary objectForKey:@"description"];
    else
        sourceCell.labelDescription.text=NSLocalizedString(@"Description not available",nil);
    
    
    if ([dictionary objectForKey:@"@type"]==nil) {
        sourceCell.labelType.text=NSLocalizedString(@"Folder",nil);
        
        [sourceCell.myImageView setImage:[UIImage imageNamed:@"Folder_48.png"]];
        
    }
    else {
        NSLog(@"Type Of Object %@",[dictionary objectForKey:@"@type"]);
        sourceCell.labelType.text=[dictionary objectForKey:@"@type"];
        
        if ([[dictionary objectForKey:@"@type"] isEqual:@"Dimension"]){
            [sourceCell.myImageView setImage:[UIImage imageNamed:@"dimension.png"]];
        }else if([[dictionary objectForKey:@"@type"] isEqual:@"Filter"])
        {
            [sourceCell.myImageView setImage:[UIImage imageNamed:@"filter.png"]];
        }
        else if([[dictionary objectForKey:@"@type"] isEqual:@"Attribute"])
        {
            [sourceCell.myImageView setImage:[UIImage imageNamed:@"attribute.png"]];
        }
        else if([[dictionary objectForKey:@"@type"] isEqual:@"Measure"])
        {
            [sourceCell.myImageView setImage:[UIImage imageNamed:@"measure.jpg"]];
        }
        
        
    }
    
    
    if ([dictionary objectForKey:@"item"]!=nil) {
        if ([[dictionary objectForKey:@"item"] isKindOfClass:[NSArray class]]){
            [sourceCell.labelArraySize setHidden:NO];
            NSArray *array=[dictionary objectForKey:@"item"] ;
            sourceCell.labelArraySize.text=[NSString stringWithFormat:@"%d",array.count];
            
        }else{
            sourceCell.labelArraySize.text=@"1";
        }
        sourceCell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
        sourceCell.selectionStyle=UITableViewCellSelectionStyleBlue;
        
    }
    else {
        sourceCell.accessoryType=UITableViewCellAccessoryNone;
        sourceCell.selectionStyle=UITableViewCellSelectionStyleNone;
        
        [sourceCell.labelArraySize setHidden:YES];
    }
    
    
    return sourceCell;
    
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
