//
//  WebiPromptViewController.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-10-14.
//  Copyright (c) 2013 APOS Systems. All rights reserved.
//

#import "WebiPromptViewController.h"
#import "PromptCell.h"
#import "WebiPrompt.h"
#import "ActionCell.h"
#import "PromptLovViewController.h"
#import "WebiPrompt.h"

@interface WebiPromptViewController ()

@end

@implementation WebiPromptViewController

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
    
    UINib *nib=[UINib nibWithNibName:@"PromptCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"Prompt_Cell"];
    
    nib=[UINib nibWithNibName:@"ActionCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"ActionCell"];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section==0)
        return _webiPrompts.count;
    else if (section ==1)
        return 1;
    else return 0;
    
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section==0) return NSLocalizedString(@"Prompts", nil);
    else return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Prompt_Cell";
    static NSString *ActionCellIdentifier = @"ActionCell";
    
    
    if (indexPath.section==0){
        PromptCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[PromptCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        WebiPrompt *webiPrompt=[_webiPrompts objectAtIndex:indexPath.row];
        cell.promptNameLabel.text=webiPrompt.name;
        cell.promptValuesLabel.text=[self getDefaultPromptValuesString:webiPrompt.answer.values];
        
        // Configure the cell...
        
        return cell;
    }else if (indexPath.section==1){
        ActionCell *cell=[tableView dequeueReusableCellWithIdentifier:ActionCellIdentifier];
        
        if (indexPath.row==1){
            
            if (cell == nil) {
                cell = [[ActionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            cell.labelActionName.text=NSLocalizedString(@"Refresh",nil);
        }
        return cell;
    }
    
    return nil;
}


-(NSString *) getDefaultPromptValuesString:(NSArray *) values
{
    NSMutableString *resutlString=[[NSMutableString alloc] init];
    
    for (NSString *value in values){
        NSLog(@"Value:%@:",value);
        [resutlString appendFormat:@"%@%@",value,@";"];
    }
    if  ([resutlString hasSuffix:@";"] ) {
        [resutlString deleteCharactersInRange:NSMakeRange([resutlString length]-1, 1)];
    }
    return resutlString;
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
    if (indexPath.section==0) {
        
        WebiPrompt *webiPrompt=[_webiPrompts objectAtIndex:indexPath.row];
        // Navigation logic may go here, for example:
        // Create the next view controller.
        PromptLovViewController *promptLovController = [[PromptLovViewController alloc] initWithNibName:@"PromptLovViewController" bundle:nil];
        promptLovController.webiprompt=webiPrompt;
        // Pass the selected object to the new view controller.
        
        // Push the view controller.
        [self.navigationController pushViewController:promptLovController animated:YES];
        
    }
}


@end
