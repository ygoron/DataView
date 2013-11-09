//
//  PromptLovViewController.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-10-14.
//  Copyright (c) 2013 APOS Systems. All rights reserved.
//

#import "PromptLovViewController.h"
#import "LovValueCell.h"
#import "Utils.h"
#import "TitleLabel.h"
#import "EditPromptViewController.h"
#import "SharedUtils.h"

@interface PromptLovViewController ()

@end

@implementation PromptLovViewController
{
    NSMutableArray *__selectedValues;
    NSMutableArray *__availableValues;
    UIActivityIndicatorView *spinner;
    UIBarButtonItem *__addButton;
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
    
    
    
    UINib *nib=[UINib nibWithNibName:@"LovValueCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"LOV_CELL"];
    
    TitleLabel *titelLabel=[[TitleLabel alloc] initWithFrame:CGRectZero];
    self.navigationItem.titleView = titelLabel;
    titelLabel.text=_webiprompt.name;
    [titelLabel sizeToFit];
    
    
    spinner = [[UIActivityIndicatorView alloc]  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin);
    spinner.center = CGPointMake(self.tableView.bounds.size.width / 2.0f, self.tableView.bounds.size.height / 2.0f);
    
    [self.view addSubview:spinner];
    
    __selectedValues =[[NSMutableArray alloc]init];
    __availableValues =[[NSMutableArray alloc]init];
    if (_webiprompt.answer.values.count>0)
        __selectedValues=[_webiprompt.answer.values mutableCopy];
    if (_webiprompt.answer.info.lov.values.count>0)
        __availableValues=[_webiprompt.answer.info.lov.values mutableCopy];
    
    [self updateValueArrays];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //    self.navigationItem.rightBarButtonItem=self.editButtonItem;
    if (_webiprompt.answer.info.lov.isRefreshable){
        //        UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc]
        //                                          initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
        //                                          target:self
        //                                          action:@selector(refreshPrompt)];
        //        self.navigationItem.rightBarButtonItem = refreshButton;
        
        if ([UIRefreshControl class]){
            UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
            refreshControl.attributedTitle=[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Pull To Refresh Prompt",nil)];
            self.refreshControl = refreshControl;
            [refreshControl addTarget:self action:@selector(refreshPrompt) forControlEvents:UIControlEventValueChanged];
        }
        
    }
    if (!_webiprompt.answer.isConstrained){
        
        __addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItem:)];
        self.navigationItem.rightBarButtonItem = __addButton;
        
    }
}

-(void) refreshPrompt
{
    [spinner startAnimating];
    if ([UIRefreshControl class]){
        [self.refreshControl endRefreshing];
    }
    
    NSLog("Refresh Parameter %d",_webiprompt.promptId);
    WebiPromptsEngine *promptEngine=[[WebiPromptsEngine alloc] init];
    promptEngine.delegate=self;
    [promptEngine refreshPromptForPrompt:_webiprompt forDocument:_document];
}

-(void) didRefreshPrompt:(WebiPromptsEngine *)webiPromptsEngine isSuccess:(BOOL)isSuccess refreshedPrompts:(NSArray *)refreshedPrompts withErrorText:(NSString *)errorText
{
    [spinner stopAnimating];
    NSLog(@"PromptRefreshed: %@ with success %d",refreshedPrompts,isSuccess);
    if (isSuccess==NO){
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Prompt Refresh",nil) message:errorText delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    [TestFlight passCheckpoint:[NSString stringWithFormat:@"Parameter %@ Refreshd",_webiprompt.name]];
    WebiPrompt *refreshedPrompt=[refreshedPrompts objectAtIndex:_webiprompt.promptId];
    __availableValues=[refreshedPrompt.answer.info.lov.values mutableCopy];
    [self updateValueArrays];
    [self.tableView reloadData];
}
-(void)didGetPrompts:(WebiPromptsEngine *)webiPromptsEngine isSuccess:(BOOL)isSuccess withPrompts:(NSArray *)webiPrompts withErrorText:(NSString *)errorText
{
    NSLog(@"Will not be called - Ignore");
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)addItem:sender {
    if (__editPromptViewController == nil) {
        __editPromptViewController = [[EditPromptViewController alloc] init];
    }
    __editPromptViewController.webiprompt=_webiprompt;
    __editPromptViewController.delegate=self;
    [__editPromptViewController setTitle:NSLocalizedString(@"Add Prompt Value", nil)];
    
    [[self navigationController] pushViewController:__editPromptViewController animated:YES];
}
#pragma mark - Table view data source

-(void) promptChanged:(EditPromptViewController *)editPromptController isSuccess:(BOOL)isSuccess withValue:(NSString *)value
{
    NSLog(@"Updated Value: %@",value);
    if ([_webiprompt.answer.info.cardinality isEqualToString:@"Single"]) [__selectedValues removeAllObjects];
    if (![self isStringValueExistInArray:__selectedValues forValue:value])
        [__selectedValues addObject:value];
    [self.tableView reloadData];
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if(_webiprompt.answer.info.lov.values!=nil)
        return 2;
    else
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section==0)
        return __selectedValues.count;
    else return __availableValues.count;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if([view isKindOfClass:[UITableViewHeaderFooterView class]]){
        UITableViewHeaderFooterView *tableViewHeaderFooterView = (UITableViewHeaderFooterView *) view;
        tableViewHeaderFooterView.textLabel.text = [tableViewHeaderFooterView.textLabel.text capitalizedString];
    }
}


-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section==0) return NSLocalizedString(@"Selected", nil);
    else if (section==1) return NSLocalizedString(@"Available", nil);
    return  nil;
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
    if ([_webiprompt.answer.type isEqualToString:@"DateTime"]||[_webiprompt.answer.type isEqualToString:@"Date"] ){
        [cell.lableLovName setText:[NSString stringWithFormat:@"%@",[SharedUtils getDisplayStringFromDate:[SharedUtils getDateFromRaylightJSONString:value]]]];
        
    }else{
        [cell.lableLovName setText:[NSString stringWithFormat:@"%@",value]];
    }
    if (indexPath.section==0) [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    else [cell setAccessoryType:UITableViewCellAccessoryNone];
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}


- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0){
        return UITableViewCellEditingStyleInsert;
    }else return UITableViewCellEditingStyleNone;
}
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        // [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        NSLog(@"Insert Value");
        [__selectedValues addObject:@"New Value"];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}



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
        if (_webiprompt.answer.info.lov.values!=nil){
            [__availableValues addObject:value];
            [__availableValues sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
        }
    }else if (indexPath.section==1){
        
        NSString *value=[__availableValues objectAtIndex:indexPath.row];
        
        //        [__selectedValues addObject:[NSString stringWithFormat:@"%@", value]];
        if ([_webiprompt.answer.info.cardinality isEqualToString:@"Single"]) {
            if (__selectedValues.count>0){
                NSString *oldValue=[__selectedValues objectAtIndex:0];
                NSLog(@"Add Old Selected Value %@ to the list of available values",oldValue);
                [__availableValues addObject:oldValue];
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
            }
            [__selectedValues removeAllObjects];
        }
        [__selectedValues addObject:value];
        [__selectedValues sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        [__availableValues removeObject:value];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        
    }
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
-(BOOL) isStringValueExistInArray: (NSArray*) values forValue:(NSString *) checkValue
{
    for (NSString *value in values) {
        if ([value isEqualToString:checkValue]) {
            return YES;
        }
    }
    
    return NO;
}

@end
