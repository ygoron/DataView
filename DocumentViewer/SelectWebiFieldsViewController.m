//
//  SelectWebiFieldsViewController.m
//  DocumentViewer
//
//  Created by Yuri Goron on 1/12/2014.
//  Copyright (c) 2014 APOS Systems. All rights reserved.
//

#import "SelectWebiFieldsViewController.h"
#import "UniverseDetailsViewControllerSolo.h"
#import "TitleLabel.h"
#import "Utils.h"
#import "QueryField.h"

@interface SelectWebiFieldsViewController ()

@end

@implementation SelectWebiFieldsViewController
{
    UIActivityIndicatorView *spinner;
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
    
    
    if([Utils isVersion6AndBelow]){
        
        UIImage *backgroundImage = [UIImage imageNamed:@"leather-background.png"];
        UIColor *backgroundPattern= [UIColor colorWithPatternImage:backgroundImage];
        [self.tableView setBackgroundColor:backgroundPattern];
        
        
        UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
        background.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"leather-background.png"]];
        self.tableView.backgroundView = background;
    }
    
    
    spinner = [[UIActivityIndicatorView alloc]  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin);
    spinner.center = CGPointMake(self.tableView.bounds.size.width / 2.0f, self.tableView.bounds.size.height / 2.0f);
    [self.view addSubview:spinner];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadUniverseDetails)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil];
    
    
    __selectedValues =[[NSMutableArray alloc]init];
    __availableValues =[[NSMutableArray alloc]init];
    
    UINib *nib=[UINib nibWithNibName:@"UniverseDetailsCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"UniverseDetails_Cell"];
    
    TitleLabel *titelLabel=[[TitleLabel alloc] initWithFrame:CGRectZero];
    self.navigationItem.titleView = titelLabel;
    //    titelLabel.text=self.title;
    titelLabel.text=NSLocalizedString(@"Select Fields", nil);
    [titelLabel sizeToFit];
    
    //    UIBarButtonItem *doneButton         = [[UIBarButtonItem alloc]
    //                                              initWithBarButtonSystemItem:UIBarButtonSystemItemDone
    //                                              target:self
    //                                           action:@selector(closeView)];
    //        self.navigationItem.rightBarButtonItems =[NSArray arrayWithObjects:doneButton, nil];
    
    
    NSLog(@"Loading Universe Details");
    [self loadUniverseDetails];
    
    
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

-(void)loadUniverseDetails{
    if (_unvDetails==nil){
        [spinner startAnimating];
        NSLog(@"First Time Opening - Load data from BI");
        BIGetUniverseDetails *getUniverseDetails=[[BIGetUniverseDetails alloc] init];
        getUniverseDetails.delegate=self;
        [getUniverseDetails getUniverseDetails:self.universe];
    }
    else{
        NSLog(@"Loading recursive");
    }
    
}

-(void) getUniverseDetails:(BIGetUniverseDetails *)biGetUniverseDetails isSuccess:(BOOL)isSuccess WithUniverseDetails:(NSMutableArray *)universeDetails{
    
    _unvDetails=[[NSMutableArray alloc] init];
    [spinner stopAnimating];
    if (isSuccess==YES){
        NSLog(@"Universe Details Received. Cound=%d",universeDetails.count);
        [_unvDetails addObjectsFromArray:universeDetails];
        for (NSDictionary *dictionary in universeDetails) {
            [SelectWebiFieldsViewController fillArrayOfFieldbjects:dictionary resultArray:__availableValues withPath:@""];
        }
        NSLog(@"Total Objects:%d",__availableValues.count);
        [self initSelectedFiedlsArrayUsingSelectedQueryFields:_selectedQueryFields];
        [self updateValueArrays];
        
        NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        __availableValues=[[__availableValues sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]] mutableCopy] ;
        
        [self.tableView reloadData];
        
    }
    else if (biGetUniverseDetails.connectorError!=nil){
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"Load Universe Failed" message:[biGetUniverseDetails.connectorError localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        self.unvDetails=nil;
        
    }else if (biGetUniverseDetails.boxiError!=nil){
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"Load Universe Failed in BI" message:biGetUniverseDetails.boxiError delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        self.unvDetails=nil;
        
    } else{
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:@"Load Universe Failed" message:@"Server Error" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        self.unvDetails=nil;
        
    }
    
    [self.tableView reloadData];
    
    
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
    
    static NSString *CellIdentifier = @"UniverseDetails_Cell";
    QueryField *field;
    
    if (indexPath.section==0) field=[__selectedValues objectAtIndex:indexPath.row];
    else field=[__availableValues objectAtIndex:indexPath.row];
    
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
        QueryField *value=[__selectedValues objectAtIndex:indexPath.row];
        [__selectedValues removeObject:value];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        //            [__availableValues addObject:[NSString stringWithFormat:@"%@", value]];
        [__availableValues addObject:value];
        NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        __availableValues=[[__availableValues sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]] mutableCopy];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    }else if (indexPath.section==1){
        
        QueryField *value=[__availableValues objectAtIndex:indexPath.row];
        
        //        [__selectedValues addObject:[NSString stringWithFormat:@"%@", value]];
        if (__selectedValues.count>0){
            QueryField *oldValue=[__selectedValues objectAtIndex:0];
            NSLog(@"Add Old Selected Value %@ to the list of available values",oldValue);
            [__availableValues addObject:oldValue];
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        }
        
        [__selectedValues addObject:value];
        
        NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
        __selectedValues=[[__selectedValues sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]] mutableCopy];
        
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        [__availableValues removeObject:value];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
        
    }
}


+(void) fillArrayOfFieldbjects: (NSDictionary *) sourceDictionary resultArray:(NSMutableArray *) resultArray withPath:(NSString *)path
{
    
    
    if (![sourceDictionary objectForKey:@"@type"]) {
        NSLog(@"Found Folder. Recursive Call");
        if ([sourceDictionary objectForKey:@"name"]){
            path=   [NSString stringWithFormat:@"%@%@%@",path,@"/",[sourceDictionary objectForKey:@"name"]];
        }
        if ([sourceDictionary objectForKey:@"item"]!=nil) {
            if ([[sourceDictionary objectForKey:@"item"] isKindOfClass:[NSArray class]]){
                NSArray *dicArray=[sourceDictionary objectForKey:@"item"] ;
                for (NSDictionary *dictionary in dicArray) {
                    [self fillArrayOfFieldbjects:dictionary resultArray:resultArray withPath:path];
                }
                
            }else{
                [self fillArrayOfFieldbjects:[sourceDictionary objectForKey:@"item"] resultArray:resultArray withPath:path];
            }
            
        }
    }
    if ([sourceDictionary objectForKey:@"name"]){
        
        QueryField *field=[[QueryField alloc] init];
        field.name=[sourceDictionary objectForKey:@"name"];
        field.path=path;
        
        if ([sourceDictionary objectForKey:@"description"])
            field.description=[sourceDictionary objectForKey:@"description"];
        else
            field.description=NSLocalizedString(@"Description not available",nil);
        
        if ([sourceDictionary objectForKey:@"@type"])
            field.type=[sourceDictionary objectForKey:@"@type"];
        
        if ([sourceDictionary objectForKey:@"@dataType"])
            field.datatype=[sourceDictionary objectForKey:@"@dataType"];
        
        if ([sourceDictionary objectForKey:@"id"])
            field.fieldId=[sourceDictionary objectForKey:@"id"];
        
        
        
        
        if (field.fieldId){
            [resultArray addObject:field];
            NSLog(@"Object %@ added. Path:%@ Id:%@",field.name,field.path,field.fieldId);
        }
        
    }
    
    
    
    
}

+(QueryField *) findQueryFieldInArray: (NSArray *) array withIdentifier:(NSString *) identifier
{
    for (QueryField *queryField in array) {
        if ([queryField.fieldId isEqualToString:identifier])
            return  queryField;
    }
    return nil;
}
-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.delegate webiFieldsSelected:self withSelectedFields:__selectedValues forDataProviderId:_dataproviderId];
}

-(void) initSelectedFiedlsArrayUsingSelectedQueryFields: (NSArray *) queryFields
{
    for (NSString *identifier in queryFields) {
        NSLog(@"Check if this field is not already in selected fields");
        if (![SelectWebiFieldsViewController findQueryFieldInArray:__selectedValues withIdentifier:identifier]){
            NSLog(@"Find that fiedl in avaiable array");
            QueryField *selectedQueryField= [SelectWebiFieldsViewController findQueryFieldInArray:__availableValues withIdentifier:identifier];
            if (selectedQueryField){
                NSLog(@"Field %@ found. Insert it.",selectedQueryField.name);
                [__selectedValues addObject:selectedQueryField];
            }
        }
    }
}

+(NSMutableArray *) getSelectedFiedlsArrayUsingSelectedQueryFields: (NSArray *) queryFields withAvailableValues:(NSArray *) availableValues
{
    NSMutableArray *selectedValues=[[NSMutableArray alloc] init];
    for (NSString *identifier in queryFields) {
        NSLog(@"Check if this query field:%@ is not already in selected fields",identifier);
        if (![self findQueryFieldInArray:selectedValues withIdentifier:identifier]){
            NSLog(@"Find that field in avaiable array");
            QueryField *selectedQueryField= [self findQueryFieldInArray:availableValues withIdentifier:identifier];
            if (selectedQueryField){
                NSLog(@"Field %@ found. Insert it.",selectedQueryField.name);
                [selectedValues addObject:selectedQueryField];
            }else{
                NSLog(@"Field Not Found");
            }
        }
    }
    
    return  selectedValues;
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
