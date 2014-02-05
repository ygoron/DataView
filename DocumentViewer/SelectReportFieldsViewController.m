//
//  SelectReportFieldsViewController.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2/1/2014.
//  Copyright (c) 2014 APOS Systems. All rights reserved.
//

#import "SelectReportFieldsViewController.h"
#import "UniverseDetailsViewControllerSolo.h"
#import "TitleLabel.h"
#import "Utils.h"
#import "QueryField.h"


@interface SelectReportFieldsViewController ()

@end

@implementation SelectReportFieldsViewController
{
    NSMutableArray *__selected;
    NSMutableArray *__availabe;
}
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    
    
    return self;
}


-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.tableView setEditing: YES animated: YES];
    [self.tableView setAllowsSelectionDuringEditing:YES];
    
}
-(void) closeView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
-(BOOL) tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) return YES;
    return NO;
}

-(UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    if (indexPath.section==0) return UITableViewCellEditingStyleDelete;
    
    return UITableViewCellEditingStyleNone;
}
-(BOOL) tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}
-(void) tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSLog(@"Move Row");
    QueryField *queryFieldToMove = [__selected objectAtIndex:sourceIndexPath.row];
    [__selected removeObjectAtIndex:sourceIndexPath.row];
    [__selected insertObject:queryFieldToMove atIndex:destinationIndexPath.row];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    __selected=[NSMutableArray arrayWithArray:_selectedQueryFields];
    __availabe=[NSMutableArray arrayWithArray:_availableQueryFields];
    
    if([Utils isVersion6AndBelow]){
        
        UIImage *backgroundImage = [UIImage imageNamed:@"leather-background.png"];
        UIColor *backgroundPattern= [UIColor colorWithPatternImage:backgroundImage];
        [self.tableView setBackgroundColor:backgroundPattern];
        
        
        UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
        background.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"leather-background.png"]];
        self.tableView.backgroundView = background;
    }
    
    
    UINib *nib=[UINib nibWithNibName:@"UniverseDetailsCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"UniverseDetails_Cell"];
    
    TitleLabel *titelLabel=[[TitleLabel alloc] initWithFrame:CGRectZero];
    self.navigationItem.titleView = titelLabel;
    //    titelLabel.text=self.title;
    titelLabel.text=NSLocalizedString(@"Edit Report Fields", nil);
    [titelLabel sizeToFit];
    
    
    [self updateValueArrays];
    [self.tableView reloadData];
    
    
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0)
        return __selected.count;
    else return __availabe.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"UniverseDetails_Cell";
    
    QueryField *field;
    
    if (indexPath.section==0) field=[__selected objectAtIndex:indexPath.row];
    else field=[__availabe objectAtIndex:indexPath.row];
    
    UniverseDetailsCellSolo *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UniverseDetailsCellSolo alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.lableName.text=field.name;
    cell.labelDescription.text=field.description;
    cell.labelType.text=[NSString stringWithFormat:@"%@%@%@", field.type,@":",field.path];
    
    
    if ([field.type isEqual:@"Dimension"]){
        [cell.myImageView setImage:[UIImage imageNamed:@"dimension.png"]];
    }else if([field.type isEqual:@"Filter"])
    {
        [cell.myImageView setImage:[UIImage imageNamed:@"filter.png"]];
    }
    else if([field.type isEqual:@"Attribute"])
    {
        [cell.myImageView setImage:[UIImage imageNamed:@"attribute.png"]];
    }
    else if([field.type isEqual:@"Measure"])
    {
        [cell.myImageView setImage:[UIImage imageNamed:@"measure.jpg"]];
    }
    
    if (indexPath.section==0) cell.showsReorderControl=YES;
    
    [cell.labelArraySize setHidden:YES];
    [cell setAccessoryType:UITableViewCellAccessoryNone];
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
        QueryField *value=[__selected objectAtIndex:indexPath.row];
        [__selected removeObject:value];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        
        [__availabe addObject:value];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    }else if (indexPath.section==1){
        
        QueryField *value=[__availabe objectAtIndex:indexPath.row];
        [__selected addObject:value];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        
        [__availabe removeObject:value];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        
    }
    
}


-(void) updateValueArrays
{
    
    for (QueryField *value  in __selected) {
        NSLog(@"Index of %@ Eq:%d",value,[__availabe indexOfObject:value]);
        if ([__availabe indexOfObject:value]!=NSNotFound){
            [__availabe removeObject:value];
        }
    }
}
-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.delegate reportFieldsSelected:self withSelectedFields:__selected];
}


@end
