//
//  PremiumFeaturesViewController.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-07-20.
//  Copyright (c) 2013 APOS Systems. All rights reserved.
//

#import "PremiumFeaturesViewController.h"
#import "BIMobileIAPHelper.h"
#import <StoreKit/StoreKit.h>
#import "InAppPucrhaseCell.h"
#import "TitleLabel.h"
#import "SharedUtils.h"
#import "Products.h"
#import "Utils.h"

@interface PremiumFeaturesViewController ()
{
    NSArray *_products;
    NSNumberFormatter * _priceFormatter;
}

@end

@implementation PremiumFeaturesViewController

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
    titelLabel.text=NSLocalizedString(@"Purchases",nil);
    [titelLabel sizeToFit];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(reload) forControlEvents:UIControlEventValueChanged];
    [self reload];
    [self.refreshControl beginRefreshing];
    _priceFormatter = [[NSNumberFormatter alloc] init];
    [_priceFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [_priceFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Restore",nil) style:UIBarButtonItemStyleBordered target:self action:@selector(restoreTapped:)];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)restoreTapped:(id)sender {
    NSLog (@"Restore Transaction tapped");
    [[BIMobileIAPHelper sharedInstance] restoreCompletedTransactions];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)productPurchased:(NSNotification *)notification {
    
    //    NSString * productIdentifier = notification.object;
    [_products enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
        //        if ([product.productIdentifier isEqualToString:productIdentifier]) {
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:idx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        //            *stop = YES;
        //        }
    }];
    
}

- (void)reload {
    _products = nil;
    [self.tableView reloadData];
    [[BIMobileIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            _products = products;
            NSLog(@"Recieved %d products",_products.count);
            [self.tableView reloadData];
        }
        [self.refreshControl endRefreshing];
    }];
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
    return _products.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    SKProduct * product = (SKProduct *) _products[indexPath.row];
    InAppPucrhaseCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    [_priceFormatter setLocale:product.priceLocale];
    cell.detailTextLabel.text = [_priceFormatter stringFromNumber:product.price];
    
    if ([[BIMobileIAPHelper sharedInstance] productPurchased:product.productIdentifier]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        cell.accessoryView = nil;
    } else {
        UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//        UIImage *buyButtonImage = [[UIImage imageNamed:@"back-button.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 4)];
//        UIImage *barButton = [UIImage imageNamed:@"button.png"];
//        [buyButton setBackgroundImage:buyButtonImage forState:UIControlStateNormal];
//        [buyButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        
        buyButton.frame = CGRectMake(0, 0, 54, 32);
        //        [buyButton setTitle:@"Buy" forState:UIControlStateNormal];
        [buyButton setTitle:[_priceFormatter stringFromNumber:product.price] forState:UIControlStateNormal];
        buyButton.tag = indexPath.row;
        [buyButton addTarget:self action:@selector(buyButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        NSLog(@"Manage Connections:%d",[[BIMobileIAPHelper sharedInstance] productPurchased:MANAGE_CONNECTIONS]);
        NSLog(@"Advanced Viewing:%d",[[BIMobileIAPHelper sharedInstance] productPurchased:ADVANCED_VIEWING]);
        NSLog(@"Upgrade to Advanced Viewing:%d",[[BIMobileIAPHelper sharedInstance] productPurchased:ADVANCED_VIEWING_UPGRADE]);
        
        if ([product.productIdentifier isEqualToString:MANAGE_CONNECTIONS]){
            if ([[BIMobileIAPHelper sharedInstance] productPurchased:ADVANCED_VIEWING]) [buyButton setEnabled:NO];
        }else if ([product.productIdentifier isEqualToString:ADVANCED_VIEWING]){
            if ([[BIMobileIAPHelper sharedInstance] productPurchased:ADVANCED_VIEWING_UPGRADE] || [[BIMobileIAPHelper sharedInstance] productPurchased:MANAGE_CONNECTIONS]) [buyButton setEnabled:NO];
        }else if ([product.productIdentifier isEqualToString:ADVANCED_VIEWING_UPGRADE]){
            if (![[BIMobileIAPHelper sharedInstance] productPurchased:MANAGE_CONNECTIONS]) [buyButton setEnabled:NO];
        }
        //        if (![product.productIdentifier isEqualToString:MANAGE_CONNECTIONS] && [[BIMobileIAPHelper sharedInstance] productPurchased:MANAGE_CONNECTIONS]==NO){
        //            [buyButton setEnabled:NO];
        //        }
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryView = buyButton;
    }
    
    
    cell.productNameLabel.text = product.localizedTitle;
    cell.productDescriptionLabel.text=product.localizedDescription;
    [SharedUtils adjustImageLeftMarginForIpadInTableViewAnyLeftObjectsInCell:cell];
    
    return cell;
}


- (void)buyButtonTapped:(id)sender {
    
    UIButton *buyButton = (UIButton *)sender;
    SKProduct *product = _products[buyButton.tag];
    
    NSLog(@"Buying %@...", product.productIdentifier);
    [[BIMobileIAPHelper sharedInstance] buyProduct:product];
    
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

@end
