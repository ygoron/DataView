//
//  EditPromptViewController.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-11-02.
//  Copyright (c) 2013 APOS Systems. All rights reserved.
//

#import "EditPromptViewController.h"
#import "SharedUtils.h"

@interface EditPromptViewController ()
{
    UITextField *__textField;
    UIDatePicker *__datePicker;
}
@end

@implementation EditPromptViewController

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

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([_webiprompt.answer.type isEqualToString:@"DateTime"]||[_webiprompt.answer.type isEqualToString:@"Date"] ){
        return 220;
    }else
    return 44;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    
    if ([_webiprompt.answer.type isEqualToString:@"DateTime"]||[_webiprompt.answer.type isEqualToString:@"Date"] ){
        if (__datePicker==nil) {
            __datePicker=[[UIDatePicker alloc]initWithFrame: CGRectMake(15, 0, cell.bounds.size.width, cell.bounds.size.height)];
//                        __datePicker=[[UIDatePicker alloc]initWithFrame: CGRectMake(15, 0, cell.bounds.size.width, 220)];
            
            UIView *backView = [[UIView alloc] initWithFrame:CGRectZero];
            backView.backgroundColor = [UIColor clearColor];
            cell.backgroundView = backView;

            [cell.contentView addSubview:__datePicker];
            
//            tableView.backgroundColor=[UIColor clearColor];
//            cell.textLabel.backgroundColor=[UIColor clearColor];
            
        }
        __datePicker.tag=indexPath.row;
//        __datePicker.datePickerMode=UIDatePickerModeDateAndTime;
        __datePicker.datePickerMode=UIDatePickerModeDate;
        __datePicker.hidden = NO;
        __datePicker.timeZone=[NSTimeZone timeZoneWithName:@"UTC"];
        if (_webiprompt.answer.values.count >0){
            NSLog(@"Value From Json:%@",[_webiprompt.answer.values objectAtIndex:0]);
            __datePicker.date=[SharedUtils getDateFromRaylightJSONString:[_webiprompt.answer.values objectAtIndex:0]];
            NSLog(@"Date Value:%@",__datePicker.date);
        }
        else {
            __datePicker.date = [NSDate date];
        }
        
    }else
    {
        if (__textField==nil){
            __textField=[[UITextField alloc] initWithFrame: CGRectMake(15, 0, cell.bounds.size.width, cell.bounds.size.height)];
            [cell.contentView addSubview:__textField];
            
        }
        //        [textField setTranslatesAutoresizingMaskIntoConstraints:NO];
        __textField.tag = indexPath.row;
        __textField.enablesReturnKeyAutomatically = YES;
        __textField.autocorrectionType = UITextAutocorrectionTypeNo;
        __textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        __textField.placeholder=NSLocalizedString(@"Enter Prompt Value", nil);
        //        [textField setClearButtonMode:UITextFieldViewModeAlways];
        __textField.returnKeyType=UIReturnKeyDone;
        __textField.delegate=self;
        
        if ([_webiprompt.answer.type isEqualToString:@"Numeric"])
        __textField.keyboardType=UIKeyboardTypeNumberPad;
        else
        __textField.keyboardType=UIKeyboardTypeDefault;
        
        __textField.text=nil;
        [__textField becomeFirstResponder];
        
    }
    
    
    // Configure the cell...
    
    return cell;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    NSLog(@"End Eiditing");
    [self.navigationController popViewControllerAnimated:YES];
    return YES;
    
}
-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [ _webiprompt.name lowercaseString];
}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if([view isKindOfClass:[UITableViewHeaderFooterView class]]){
        UITableViewHeaderFooterView *tableViewHeaderFooterView = (UITableViewHeaderFooterView *) view;
        tableViewHeaderFooterView.textLabel.text = [tableViewHeaderFooterView.textLabel.text capitalizedString];
    }
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (__textField!=nil) [self.delegate promptChanged:self isSuccess:YES withValue:__textField.text];
    else
    if (__datePicker!=nil){
        
        [self.delegate promptChanged:self isSuccess:YES withValue:[SharedUtils getStringFromRaylightDate:__datePicker.date]];
    }
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

/*
 #pragma mark - Table view delegate
 
 // In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Navigation logic may go here, for example:
 // Create the next view controller.
 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
 
 // Pass the selected object to the new view controller.
 
 // Push the view controller.
 [self.navigationController pushViewController:detailViewController animated:YES];
 }
 
 */

@end
