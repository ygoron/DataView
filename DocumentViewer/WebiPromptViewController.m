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
#import "Utils.h"
#import "TitleLabel.h"
#import "ReportViewController.h"
#import "SharedUtils.h"

@interface WebiPromptViewController ()

@end

@implementation WebiPromptViewController
{
    EditPromptViewController *__editPromptViewController;
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
    
    if([Utils isVersion6AndBelow]){
        UIImage *backgroundImage = [UIImage imageNamed:@"leather-background.png"];
        UIColor *backgroundPattern= [UIColor colorWithPatternImage:backgroundImage];
        [self.tableView setBackgroundColor:backgroundPattern];
        
        
        UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
        background.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"leather-background.png"]];
        self.tableView.backgroundView = background;
    }
    
    TitleLabel *titelLabel=[[TitleLabel alloc] initWithFrame:CGRectZero];
    self.navigationItem.titleView = titelLabel;
    titelLabel.text=_document.name;
    [titelLabel sizeToFit];
    
    
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
    NSLog(@"Check if values provided for all parameters - if not - do not show Refresh Section");
    
    
    if ([self isAllPromptsHaveSelectedValues])
        return 2;
    else return 1;
}

-(BOOL) isAllPromptsHaveSelectedValues{
    for (WebiPrompt *prompt in _webiPrompts) {
        if (prompt.answer.values.count==0) return NO;
    }
    return YES;
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

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if([view isKindOfClass:[UITableViewHeaderFooterView class]]){
        UITableViewHeaderFooterView *tableViewHeaderFooterView = (UITableViewHeaderFooterView *) view;
        tableViewHeaderFooterView.textLabel.text = [tableViewHeaderFooterView.textLabel.text capitalizedString];
    }
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
        cell.promptValuesLabel.text=[self getDefaultPromptValuesString:webiPrompt];
        
        // Configure the cell...
        
        return cell;
    }else if (indexPath.section==1){
        ActionCell *cell=[tableView dequeueReusableCellWithIdentifier:ActionCellIdentifier];
        
        if (indexPath.row==0){
            
            if (cell == nil) {
                cell = [[ActionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            cell.labelActionName.text=NSLocalizedString(@"Refresh Document",nil);
        }
        return cell;
    }
    
    return nil;
}


-(NSString *) getDefaultPromptValuesString:(WebiPrompt *) webiPrompt
{
    NSMutableString *resutlString=[[NSMutableString alloc] init];
    
    //    for (NSString *value in webiPrompt.answer.values){
    NSString *value;
    for (NSObject *valueObject in webiPrompt.answer.values){
        if ([valueObject isKindOfClass:[NSString class ]]){
            NSLog("Type String");
            value=(NSString *) valueObject;
            
        }else
            if ([valueObject isKindOfClass:[NSDictionary class ]]){
                NSDictionary *valueDict= (NSDictionary *) valueObject;
                value=[valueDict valueForKey:@"$"];
                NSLog("Type Dictionary");
            }
        
        NSLog(@"Value:%@",value);
        if ([webiPrompt.answer.type isEqualToString:@"DateTime"]||[webiPrompt.answer.type isEqualToString:@"Date"] )
        {
            NSDate *date=[SharedUtils getDateFromRaylightJSONString:value];
            NSLog(@"Converted To Date: %@",date);
            
            NSString  *dateString =[SharedUtils getDisplayStringFromDate:date];
            NSLog(@"Converted Date String:%@",dateString);
            [resutlString appendFormat:@"%@%@",dateString,@";"];
        }
        else{
            [resutlString appendFormat:@"%@%@",value,@";"];
        }
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
        
        NSLog(@"Select Prompt");
        
        WebiPrompt *webiPrompt=[_webiPrompts objectAtIndex:indexPath.row];
        // Navigation logic may go here, for example:
        // Create the next view controller.
        if (webiPrompt.answer.info.lov!=nil){
            //                    if ([webiPrompt.answer.info.cardinality isEqualToString:@"Multiple"]){
            NSLog(@"Prompt with LOV");
            PromptLovViewController *promptLovController = [[PromptLovViewController alloc] initWithNibName:@"PromptLovViewController" bundle:nil];
            promptLovController.webiprompt=webiPrompt;
            promptLovController.document=_document;
            // Push the view controller.
            [self.navigationController pushViewController:promptLovController animated:YES];
            
        }else{
            
            NSLog(@"Prompt For the Value");
            
            if (__editPromptViewController == nil) {
                __editPromptViewController = [[EditPromptViewController alloc] init];
            }
            __editPromptViewController.webiprompt=webiPrompt;
            __editPromptViewController.delegate=self;
            [__editPromptViewController setTitle:NSLocalizedString(@"Add Prompt Value", nil)];
            
            [[self navigationController] pushViewController:__editPromptViewController animated:YES];
            
        }
        
        
    }else if(indexPath.section==1){
        NSLog(@"Select Refresh Report");
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
        
        ReportViewController *rvc = (ReportViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"ReportView"];
        UINavigationController *cntrol = [[UINavigationController alloc] initWithRootViewController:rvc];
        
        
        rvc.hidesBottomBarWhenPushed=YES;
        rvc.document=_document;
        rvc.isRefreshDocument=YES;
        rvc.webiPrompts=_webiPrompts;
        rvc.titleText=_document.name;
        [self presentViewController:cntrol animated:YES completion:nil];
        
        
    }
}

-(void) promptChanged:(EditPromptViewController *)editPromptController isSuccess:(BOOL)isSuccess withValue:(NSString *)value
{
    NSLog(@"Updated Value: %@",value);
    NSMutableArray *values=[[NSMutableArray alloc] init];
    [values addObject:value];
    editPromptController.webiprompt.answer.values=values;
    
    //    [self.tableView reloadData];
}




@end
