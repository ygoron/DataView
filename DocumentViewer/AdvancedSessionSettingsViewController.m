//
//  AdvancedSessionSettingsViewController.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-04-20.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import "AdvancedSessionSettingsViewController.h"
#import "TitleLabel.h"

@interface AdvancedSessionSettingsViewController ()

@end

@implementation AdvancedSessionSettingsViewController
{
    UIGestureRecognizer *tapper;

}

@synthesize session;
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

    

    [self cutsomizeTextField:self.textFieldOpenDocPort];
    [self cutsomizeTextField:self.textfieldOpenDocHost];

    
    tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:tapper];
    tapper.cancelsTouchesInView = FALSE;

    TitleLabel *titelLabel=[[TitleLabel alloc] initWithFrame:CGRectZero];
    self.navigationItem.titleView = titelLabel;
    titelLabel.text=@"Advanced Settings";
    [titelLabel sizeToFit];
    [TestFlight passCheckpoint:@"Advanced Sesttings"];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void) viewWillAppear:(BOOL)animated{
    NSLog(@"View Will Appear. Cypress SDK Base:%@",session.cypressSDKBase);
    self.textfieldOpenDocHost.text=session.opendocServer;
    self.textFieldOpenDocPort.text=[session.opendocPort stringValue];
    _textFieldRESTBase.text=session.cypressSDKBase;
    _textFieldRESTWebiBase.text=session.webiRestSDKBase;
    [super viewWillAppear:animated];


}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

-(void) viewWillDisappear:(BOOL)animated{
    session.opendocServer=self.textfieldOpenDocHost.text;
    session.opendocPort=[NSNumber numberWithInt:[self.textFieldOpenDocPort.text intValue] ];
    session.cypressSDKBase=_textFieldRESTBase.text;
    session.webiRestSDKBase=_textFieldRESTWebiBase.text;
    [super viewWillDisappear:animated];
    
}

- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    NSLog(@"Hanlde Single Tap");
    [self.view endEditing:YES];
}


- (void)viewDidUnload {
    [self setTextfieldOpenDocHost:nil];
    [self setTextFieldOpenDocPort:nil];
    [self setTextFieldRESTBase:nil];
    [self setTextFieldRESTWebiBase:nil];
    [super viewDidUnload];
}
@end
