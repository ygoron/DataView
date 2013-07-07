//
//  ScheduleWebiViewController.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-03-10.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import "ScheduleWebiViewController.h"
#import "DestinationViewController.h"
#import "Document.h"
#import "BIScheduleDocument.h"
#import "ScheduleStatus.h"
#import "Format.h"
#import "FormatPDF.h"
#import "FormatExcel.h"
#import "FormatWebi.h"
#import "TitleLabel.h"
#import "WebiAppDelegate.h"
@interface ScheduleWebiViewController ()

@end

@implementation ScheduleWebiViewController
{
    UIActivityIndicatorView *spinner;
    SystemSoundID soundID;
    Session *currentSession;
}
@synthesize document;

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
    
    //    self.title=[NSString stringWithFormat:@"%@%@",@"Schedule ",document.name];
    
    UIImage *backgroundImage = [UIImage imageNamed:@"leather-background.png"];
    UIColor *backgroundPattern= [UIColor colorWithPatternImage:backgroundImage];
    [self.tableView setBackgroundColor:backgroundPattern];
    
    
    UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    background.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"leather-background.png"]];
    self.tableView.backgroundView = background;
    
    TitleLabel *titelLabel=[[TitleLabel alloc] initWithFrame:CGRectZero];
    self.navigationItem.titleView = titelLabel;
    titelLabel.text=[NSString stringWithFormat:@"%@%@",@"Schedule ",document.name];
    [titelLabel sizeToFit];
    
    
    spinner = [[UIActivityIndicatorView alloc]  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin);
    spinner.center = CGPointMake(self.tableView.bounds.size.width / 2.0f, self.tableView.bounds.size.height / 2.0f);
    [self.view addSubview:spinner];
    
//    currentSession=document.session;
    WebiAppDelegate *appDelegate = (id)[[UIApplication sharedApplication] delegate];
    currentSession=appDelegate.activeSession;
    
    
    
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

#pragma mark - Table view data source

//-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//   NSLog(@"%f",((UITableViewCell*)[self.tableView.visibleCells objectAtIndex:0]).bounds.origin.x);
//
//    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 50)];
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(tableView.bounds.origin.x+15, 0, self.tableView.bounds.size.width - 10, 18)];
//    label.backgroundColor=[UIColor clearColor];
//    label.shadowColor=[UIColor clearColor];
//    label.textAlignment=NSTextAlignmentLeft;
//    label.highlightedTextColor = [UIColor whiteColor];
//    label.font=[UIFont boldSystemFontOfSize:16];
//    label.textColor= [UIColor colorWithRed:163.0/255 green:117.0/255 blue:89.0/255 alpha:1.0];
//    label.numberOfLines=0;
//    
//    switch (section) {
//        case 0:
//            label.text=@"Destination";
//            break;
//        case 1:
//            label.text=@"Format";
//            break;
//        case 2:
//            label.text=@"Recurrence";
//            break;
//            
//        default:
//            break;
//    }
//    label.backgroundColor = [UIColor clearColor];
//    [headerView addSubview:label];
//
//    return headerView;
//}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//
//    // Configure the cell...
//
//    return cell;
//}

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

#pragma mark proceed with schedule options
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog (@"Seque: %@",segue.identifier);
    //    DestinationViewController        *destinationViewController =segue.destinationViewController;
    
	if ([segue.identifier isEqualToString:@"Destination_Ident"])
	{
        //      NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
	}
}

#pragma mark schedule button touched
-(void) scheduleDocumentTouch:(id)sender{
    [spinner startAnimating];
    NSLog(@"Proceed with Scheduling document %@",document.id);
    BIScheduleDocument *biScheduleDocument=[[BIScheduleDocument alloc]init];
    biScheduleDocument.delegate=self;
    biScheduleDocument.document=document;
    
    Format *format=[[Format alloc] init];
    if (self.segmentedControlFormat.selectedSegmentIndex==0){
        NSLog(@"Schedule to Webi");
        FormatWebi *webi=[[FormatWebi alloc]init];
        format.formatWebi=webi;
    }else if (self.segmentedControlFormat.selectedSegmentIndex==1){
        NSLog(@"Schedule to PDF");
        FormatPDF *pdf=[[FormatPDF alloc]init];
        format.formatPdf=pdf;
        
    }else if (self.segmentedControlFormat.selectedSegmentIndex==2){
        NSLog(@"Schedule to Excel");
        FormatExcel *excel=[[FormatExcel alloc]init];
        format.formatExcel=excel;
        
    }
    if(document.session==nil) document.session=currentSession;
    NSLog(@"Schedule document %d with sesison %@ with token %@",document.id.intValue, document.session.name,document.session.cmsToken);
    [biScheduleDocument scheduleDocument:document withDestination:nil withFormat:format];
    
}

#pragma returned from Schedule Document
-(void)biScheduleDocument:(BIScheduleDocument *)biScheduleDocument isSuccess:(BOOL)isSuccess withScheduleStatus:(ScheduleStatus *)scheduleStatus{
    [spinner stopAnimating];
    NSLog(@"Schedule Status Code:%d",scheduleStatus.code);
    NSLog(@"Schedule Status Message:%@",scheduleStatus.message);
    NSLog(@"Schedule Status New Instance Id:%d",scheduleStatus.newInstanceId);
    
    if (isSuccess){
        
        //              NSString *path = [[NSBundle bundleWithIdentifier:@"com.apple.UIKit"] pathForResource:@"Tock" ofType:@"aiff"];
        
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle]
                                                                                    pathForResource: @"ScheduleSound" ofType:@"wav"]], &soundID);
        AudioServicesPlaySystemSound(soundID);
        AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
        [[self navigationController] popViewControllerAnimated:YES];
        
    }
    else{
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Schedule",nil) message:scheduleStatus.message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil, nil];
        [alert show];
    }
    
}
@end
