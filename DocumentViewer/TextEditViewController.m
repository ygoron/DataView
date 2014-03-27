//
//  TextEditViewController.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-12-01.
//  Copyright (c) 2013 APOS Systems. All rights reserved.
//

#import "TextEditViewController.h"
#import "TextEditCell.h"

@interface TextEditViewController ()

@end

@implementation TextEditViewController
{
    UITextField *__textField;
    
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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    UINib *nib=[UINib nibWithNibName:@"TextEditCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"TextEdit_ID"];
    
}


-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    NSLog(@"Passing Value:%@",__textField.text);
    [self.delegate TextTextEditViewController:self didFinishEditingValue:__textField.text];
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
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TextEdit_ID";
    TextEditCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[TextEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    if (__textField==nil) __textField=cell.TextEditField;
    // Configure the cell...
    __textField.placeholder=_placeHolderText;
    __textField.text=_defaultValue;
    
    __textField.enablesReturnKeyAutomatically = YES;
    __textField.autocorrectionType = UITextAutocorrectionTypeDefault;
    [__textField setClearButtonMode:UITextFieldViewModeAlways];
    __textField.returnKeyType=UIReturnKeyDone;
    __textField.keyboardType=UIKeyboardTypeDefault;
    [__textField becomeFirstResponder];
    [__textField setDelegate:(id)self];
    
    
    
    return cell;
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    [[self navigationController] popViewControllerAnimated:YES];
    return YES;
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
