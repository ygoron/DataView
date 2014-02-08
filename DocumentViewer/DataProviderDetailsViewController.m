//
//  DataProviderDetailsViewController.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2/6/2014.
//  Copyright (c) 2014 APOS Systems. All rights reserved.
//

#import "DataProviderDetailsViewController.h"
#import "TitleLabel.h"
#import "DocTitleCell.h"

@interface DataProviderDetailsViewController ()

@end

@implementation DataProviderDetailsViewController
{
    UIActivityIndicatorView *spinner;
    GDataXMLDocument *__dataProviderDetailsXml;
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
    
    UINib *nib=[UINib nibWithNibName:@"DocTitleCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"DocTitle_ID"];
    
    
    spinner = [[UIActivityIndicatorView alloc]  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin);
    spinner.center = CGPointMake(self.tableView.bounds.size.width / 2.0f, self.tableView.bounds.size.height / 2.0f);
    [self.view addSubview:spinner];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    UIBarButtonItem *doneButton         = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                           target:self
                                           action:@selector(closeView)];
    self.navigationItem.rightBarButtonItems =[NSArray arrayWithObjects:doneButton, nil];
    [self loadDataProviderDetails];
}


-(void) closeView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void) loadDataProviderDetails{
    NSURL *url=[XMLRESTProcessor getDataProvidersUrlWithSession:_currentSession withDocumentId:_docId];
    url=[url URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",@"/",_dataProviderId]];
    XMLRESTProcessor *xmlProcessor=[[XMLRESTProcessor alloc] init];
    xmlProcessor.delegate=self;
    [xmlProcessor submitRequestForUrl:url withSession:_currentSession withHttpMethod:@"GET" withXmlDoc:nil withOpCode:0];
    
}
-(void) finishedProcessing:(XMLRESTProcessor *)xmlProcessor isSuccess:(BOOL)isSuccess withReturnedXml:(GDataXMLDocument *)xmlDoc withErrorText:(NSString *)errorText forUrl:(NSURL *)url withMethod:(NSString *)method withOriginalRequestXml:(GDataXMLDocument *)originalXmlDoc withOpCode:(int)opCode
{
    NSLog(@"Proceed with Loading Values");
    __dataProviderDetailsXml=xmlDoc;
    [self.tableView reloadData];
}
-(void) viewWillAppear:(BOOL)animated
{
    TitleLabel *titelLabel=[[TitleLabel alloc] initWithFrame:CGRectZero];
    
    titelLabel.text=_dataProviderName;
    
    self.navigationItem.titleView = titelLabel;
    [titelLabel sizeToFit];
    
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
    NSArray *elements=[__dataProviderDetailsXml nodesForXPath:@"/dataprovider/*" error:nil];
    NSLog(@"Number of Rows:%d",elements.count);
    return elements.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
     static NSString *CellIdentifier = @"DocTitle_ID";
    DocTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[DocTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
     GDataXMLElement *element=[[__dataProviderDetailsXml nodesForXPath:@"/dataprovider/*" error:nil] objectAtIndex:indexPath.row];
    cell.DocNameLabel.text=[element name];
    cell.DocNameActualLabel.text=[[element childAtIndex:0] stringValue];
    
    cell.DocNameLabel.adjustsFontSizeToFitWidth = YES;
    cell.DocNameLabel.numberOfLines = 1;
    if ([[[element childAtIndex:0] children ] count]>0){
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }else{
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    // Configure the cell...
    
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
