//
//  PreferencesViewController.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-04-21.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import "PreferencesViewController.h"
#import "TitleLabel.h"
#import "WebiAppDelegate.h"

@interface PreferencesViewController ()

@end

@implementation PreferencesViewController
{
    NSManagedObjectContext *context;
    UIGestureRecognizer *tapper;
    WebiAppDelegate *_appDelegate;
    
}

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
    
    
    UIImage *backgroundImage = [UIImage imageNamed:@"leather-background.png"];
    UIColor *backgroundPattern= [UIColor colorWithPatternImage:backgroundImage];
    [self.tableView setBackgroundColor:backgroundPattern];
    
    
    UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    background.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"leather-background.png"]];
    self.tableView.backgroundView = background;

    _appDelegate = (id)[[UIApplication sharedApplication] delegate];
    
    context = [_appDelegate managedObjectContext];
    tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:tapper];
    tapper.cancelsTouchesInView = FALSE;
    [TestFlight passCheckpoint:@"Preferences View"];
    if (_appDelegate.globalSettings!=nil){
        self.textFetchSize.text=[_appDelegate.globalSettings.fetchDocumentLimit stringValue];
        self.sliderFetch.value=[_appDelegate.globalSettings.fetchDocumentLimit floatValue];
        self.textTimeout.text=[_appDelegate.globalSettings.networkTimeout stringValue];
        [self.logoffInBackgrndSwitch setOn:[_appDelegate.globalSettings.isLogoffInBackground integerValue]];
        [self.savePasswordSwitch setOn:[_appDelegate.globalSettings.isSavePassword integerValue]];
        [self.showUniversesSwitch setOn:[_appDelegate.globalSettings.isShowUniverses integerValue]];
        [self.autoLogoffSwitch setOn:[_appDelegate.globalSettings.autoLogoff integerValue]];
#ifdef Lite
        [self.autoLogoffSwitch setEnabled:NO];
        [self.savePasswordSwitch setEnabled:NO];
        [self.textFetchSize setEnabled:NO];
        [self.sliderFetch setEnabled:NO];
#endif
        
    }else{
        NSLog(@"Global Settings is Nil!");
    }
    
    [self cutsomizeTextField:self.textFetchSize];
    [self cutsomizeTextField:self.textTimeout];
    
    TitleLabel *titelLabel=[[TitleLabel alloc] initWithFrame:CGRectZero];
    self.navigationItem.titleView = titelLabel;
    titelLabel.text=NSLocalizedString(@"Global Preferences",nil);
    [titelLabel sizeToFit];
    [TestFlight passCheckpoint:@"Global Preferences"];
    
    
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


- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    NSLog(@"Hanlde Single Tap");
    [self.view endEditing:YES];
}


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

- (void)viewDidUnload {
    [self setTextFetchSize:nil];
    [self setSliderFetch:nil];
    [self setTextTimeout:nil];
    [self setSavePasswordSwitch:nil];
    [self setLogoffInBackgrndSwitch:nil];
    [self setShowUniversesSwitch:nil];
    [self setAutoLogoffSwitch:nil];
    [super viewDidUnload];
}
- (IBAction)sliderValueChanged:(id)sender {
    self.textFetchSize.text= [NSString stringWithFormat:@"%d",[[NSNumber numberWithFloat:self.sliderFetch.value] integerValue]];
}

-(void)viewWillDisappear:(BOOL)animated{
    NSLog(@"View will disappear");
    [super viewWillDisappear:animated];
    _appDelegate.globalSettings.fetchDocumentLimit=[NSNumber numberWithInteger:[self.textFetchSize.text integerValue]];
    _appDelegate.globalSettings.isLogoffInBackground=[NSNumber numberWithBool:self.logoffInBackgrndSwitch.isOn];
    _appDelegate.globalSettings.isSavePassword=[NSNumber numberWithBool:self.savePasswordSwitch.isOn];
    _appDelegate.globalSettings.isShowUniverses=[NSNumber numberWithBool:self.showUniversesSwitch.isOn];
    _appDelegate.globalSettings.networkTimeout=[NSNumber numberWithInteger:[self.textTimeout.text integerValue]];
    _appDelegate.globalSettings.autoLogoff=[NSNumber numberWithBool:self.autoLogoffSwitch.isOn];
    NSLog(@"Fetch Document Limit:%@",    _appDelegate.globalSettings.fetchDocumentLimit);

}
- (IBAction)fetchSizeEditEnded:(id)sender {
    int value=[self.textFetchSize.text integerValue];
    
    if (value>50) value=50;
    else if (value<5) value=5;
    self.sliderFetch.value=value;
    
    
    
    
}

- (IBAction)refreshUniverseTab:(id)sender {
    
    _appDelegate.globalSettings.isShowUniverses=[NSNumber numberWithBool:self.showUniversesSwitch.isOn];
    [_appDelegate showHideUniverseController];

}
@end
