//
//  DataProviderSelectorViewController.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-12-12.
//  Copyright (c) 2013 APOS Systems. All rights reserved.
//

#import "DataProviderSelectorViewController.h"
#import "TextEditCell.h"
#import "DocTitleCell.h"
#import "UniversesListViewController.h"

@interface DataProviderSelectorViewController ()

@end

@implementation DataProviderSelectorViewController
{
    UITextField *textField;
    UILabel *labelField;
    Universe *selectedUniverse;
    
    
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
    
    UINib *nib2=[UINib nibWithNibName:@"DocTitleCell" bundle:nil];
    [[self tableView] registerNib:nib2 forCellReuseIdentifier:@"DocTitle_ID"];
    
    
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
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellText = @"TextEdit_ID";
    static NSString *CellUniverseId = @"DocTitle_ID";
    
    if (indexPath.row==0){
        
        DocTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:CellUniverseId];
        if (cell == nil) {
            cell = [[DocTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellUniverseId];
        }
        
        if (labelField==nil) labelField=cell.DocNameActualLabel;
        
        if (_dataprovidersXml==nil) {
            cell.DocNameLabel.text=NSLocalizedString(@"Universe", nil);
            cell.DocNameActualLabel.text=nil;
        }
        return cell;

        
    }else{
        

        TextEditCell *cell = [tableView dequeueReusableCellWithIdentifier:CellText];
        if (cell == nil) {
            cell = [[TextEditCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellText];
        }
        
        if (textField==nil) textField=cell.TextEditField;
        // Configure the cell...
        textField.placeholder=_placeHolderText;
        textField.text=_defaultValue;
        
        textField.enablesReturnKeyAutomatically = YES;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        [    textField setClearButtonMode:UITextFieldViewModeAlways];
        textField.returnKeyType=UIReturnKeyDone;
        textField.keyboardType=UIKeyboardTypeDefault;
        
//        [textField becomeFirstResponder];
        
        
        return cell;

    }
    
    // Configure the cell...
    
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
    // Navigation logic may go here, for example:
    // Create the next view controller.
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
    UniversesListViewController *unvVC = (UniversesListViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"UniverseList"];
    unvVC.delegate=self;
    
    [unvVC setIsWebiCreation:YES];
    // Configure the new view controller here.
    [self.navigationController pushViewController:unvVC animated:YES];
}

-(void) UniversesListViewController:(UniversesListViewController *)controller didSelectUniverse:(Universe *)universe
{
    NSLog(@"Universe Selected: %@",universe.name);
    if (labelField!=nil) labelField.text=universe.name;
//    if (textField.text!=nil) textField.text=_defaultValue;
    if (textField.text) textField.text=[NSString stringWithFormat:@"%@%@%@%@",textField.text,@" (",universe.name,@")"];
    selectedUniverse=universe;
}
-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (textField!=nil && selectedUniverse!=nil)
        [self.delegate DataProviderSelectorViewController:self didFinishEditingWithQueryName:textField.text UniverseId:selectedUniverse.universeId];
}



@end
