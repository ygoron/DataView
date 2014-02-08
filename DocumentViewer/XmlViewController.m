//
//  XmlViewController.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2/7/2014.
//  Copyright (c) 2014 APOS Systems. All rights reserved.
//

#import "XmlViewController.h"
#import "TitleLabel.h"
#import "DocTitleCell.h"


@interface XmlViewController ()

@end

@implementation XmlViewController

{
    UIActivityIndicatorView *spinner;
    NSString *initialPath;
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
    
}

-(void) closeView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) viewWillAppear:(BOOL)animated
{
    
    NSLog(@"Xml Data \n %@",_xmlElement.XMLString);
    initialPath=[NSString stringWithFormat:@"%@%@%@",@"/",[_xmlElement name] ,@"/*"];
    NSLog(@"Initial Path:%@",initialPath);
    
    TitleLabel *titelLabel=[[TitleLabel alloc] initWithFrame:CGRectZero];
    
    titelLabel.text=[_xmlElement name];
    
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
    
    NSLog(@"Finding Elements using Path:%@ in elements:\n%@",initialPath,_xmlElement.XMLString);
    NSArray *elements=[_xmlElement nodesForXPath:initialPath error:nil];
    NSLog(@"Number of Rows:%d",elements.count);
    return elements.count;
}

-(BOOL) tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
    
    GDataXMLElement *element=[[_xmlElement nodesForXPath:initialPath error:nil] objectAtIndex:indexPath.row];
    
    return [[[element childAtIndex:0] children ] count]>0?YES:NO;
}
-(BOOL) tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DocTitle_ID";
    DocTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[DocTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    
    
    GDataXMLElement *element=[[_xmlElement nodesForXPath:initialPath error:nil] objectAtIndex:indexPath.row];
    cell.DocNameLabel.text=[element name];
    if ([[element attributes] count]>0){
        for (GDataXMLNode *attribute in [element attributes]) {
            cell.DocNameLabel.text=[NSString stringWithFormat:@"%@%@%@%@%@",cell.DocNameLabel.text,@" ",attribute.name,@"=",attribute.stringValue];
        }
    }
    
    cell.shouldIndentWhileEditing=NO;
    if ([[[element childAtIndex:0] children ] count]>0){
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        cell.DocNameActualLabel.text=nil;
    }else{
        cell.DocNameActualLabel.text=[[element childAtIndex:0] stringValue];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    

    cell.selectionStyle=UITableViewCellSelectionStyleNone;

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


// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here, for example:
    // Create the next view controller.
    GDataXMLElement *element=[[_xmlElement nodesForXPath:initialPath error:nil] objectAtIndex:indexPath.row];
    
    if ([[[element childAtIndex:0] children ] count]>0){
        XmlViewController *xmlViewCtl = [[XmlViewController alloc] init];
        xmlViewCtl.xmlElement=[element copy];
        
        // Pass the selected object to the new view controller.
        
        // Push the view controller.
        [self.navigationController pushViewController:xmlViewCtl animated:YES];
    }
}


@end
