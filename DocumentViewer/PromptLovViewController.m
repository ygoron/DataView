//
//  PromptLovViewController.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-10-14.
//  Copyright (c) 2013 APOS Systems. All rights reserved.
//

#import "PromptLovViewController.h"
#import "LovValueCell.h"

@interface PromptLovViewController ()

@end

@implementation PromptLovViewController
{
    NSMutableArray *__selectedValues;
    NSMutableArray *__availableValues;
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
    
    UINib *nib=[UINib nibWithNibName:@"LovValueCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"LOV_CELL"];
    
    __selectedValues=[_webiprompt.answer.values mutableCopy];
    __availableValues=[_webiprompt.answer.info.lov.values mutableCopy];
    
    [self updateValueArrays];
    
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section==0)
        return __selectedValues.count;
    else return __availableValues.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LOV_CELL";
    NSString *value=[[NSString alloc] init];
    
    if (indexPath.section==0) value=[__selectedValues objectAtIndex:indexPath.row];
    else value=[__availableValues objectAtIndex:indexPath.row];
    
    
    LovValueCell  *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[LovValueCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSLog(@"Value:%@",value);
    [cell.lableLovName setText:[NSString stringWithFormat:@"%@",value]];
    if (indexPath.section==0) [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    else [cell setAccessoryType:UITableViewCellAccessoryNone];
    
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

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath

{
    if (indexPath.section==0){
        NSString *value=[__selectedValues objectAtIndex:indexPath.row];
            [__selectedValues removeObject:value];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
//            [__availableValues addObject:[NSString stringWithFormat:@"%@", value]];
            [__availableValues addObject:value];
            [__availableValues sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    }else if (indexPath.section==1){

        NSString *value=[__availableValues objectAtIndex:indexPath.row];
        
//        [__selectedValues addObject:[NSString stringWithFormat:@"%@", value]];
                [__selectedValues addObject:value];
        [__selectedValues sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        [__availableValues removeObject:value];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        
    }
    // // Navigation logic may go here, for example:
    // // Create the next view controller.
    // <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
    //
    // // Pass the selected object to the new view controller.
    //
    // // Push the view controller.
    // [self.navigationController pushViewController:detailViewController animated:YES];
}


-(void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    _webiprompt.answer.values=__selectedValues;
    _webiprompt.answer.info.lov.values=__availableValues;

}
-(void) updateValueArrays
{
    for (NSString *value  in __selectedValues) {
        NSLog(@"Index of %@ Eq:%d",value,[__availableValues indexOfObject:value]);
        if ([__availableValues indexOfObject:value]!=NSNotFound){
            [__availableValues removeObject:value];
        }
    }
}

@end
