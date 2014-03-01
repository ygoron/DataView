//
//  ReportEditorViewController.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2/9/2014.
//  Copyright (c) 2014 APOS Systems. All rights reserved.
//

#import "ReportEditorViewController.h"
#import "DocTitleCell.h"
#import "XMLRESTProcessor.h"
#import "TitleLabel.h"
#import "Utils.h"
#import "ReportViewController.h"


@interface ReportEditorViewController ()

@end

@implementation ReportEditorViewController

{
    
    UIActivityIndicatorView *spinner;
    GDataXMLDocument *currentXmlDoc;
    
}
UIActivityIndicatorView *spinner;

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
    titelLabel.text=_reportName;
    [titelLabel sizeToFit];
    
    UINib *nib=[UINib nibWithNibName:@"DocTitleCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"DocTitle_ID"];
    
    
    
    spinner = [[UIActivityIndicatorView alloc]  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin);
    spinner.center = CGPointMake(self.tableView.bounds.size.width / 2.0f, self.tableView.bounds.size.height / 2.0f);
    [self.view addSubview:spinner];
    
    
    
    UIBarButtonItem *addButton         = [[UIBarButtonItem alloc]
                                          initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                          target:self
                                          action:@selector(addReportElement)];
    
    UIBarButtonItem *editButton         = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                           target:self
                                           action:@selector(editReportElements)];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    //    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    
    
    self.navigationItem.rightBarButtonItems =[NSArray arrayWithObjects:addButton,editButton,nil];
    
    [self getReportStructure];
}

-(void) getReportStructure{
    
    NSURL *url=[XMLRESTProcessor getDocumentsUrlWithSession:_currentSession];
    url=[url URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%d%@%d%@",@"/",_documentId,@"/reports/",_reportId,@"/specification"]];
    XMLRESTProcessor *xmlProcessor=[[XMLRESTProcessor alloc] init];
    xmlProcessor.delegate=self;
    xmlProcessor.accept=@"text/xml";
    [xmlProcessor submitRequestForUrl:url withSession:_currentSession withHttpMethod:@"GET" withXmlDoc:nil withOpCode:0];
    
}
-(void) finishedProcessing:(XMLRESTProcessor *)xmlProcessor isSuccess:(BOOL)isSuccess withReturnedXml:(GDataXMLDocument *)xmlDoc withErrorText:(NSString *)errorText forUrl:(NSURL *)url withMethod:(NSString *)method withOriginalRequestXml:(GDataXMLDocument *)originalXmlDoc withOpCode:(int)opCode
{
    NSLog(@"Proceed with building report specs");
    currentXmlDoc=xmlDoc;
    //    _reportElements=[[currentXmlDoc nodesForXPath:@"/REPORT/PAGE_BODY/*" error:nil] mutableCopy];
    _reportElements=[[currentXmlDoc nodesForXPath:@"//VTABLE" error:nil] mutableCopy];
    
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
        return _reportElements.count;
    else return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifierElement = @"DocTitle_ID";
    
    
    DocTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierElement];
    if (cell == nil) {
        cell = [[DocTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierElement];
    }
    
    
    
    if (indexPath.section==0){
        
        cell.DocNameLabel.text=[[_reportElements objectAtIndex:indexPath.row] name];
        cell.DocNameActualLabel.text=[self getVtableHeadersWithElement:[_reportElements objectAtIndex:indexPath.row]];
        if ([cell.DocNameLabel.text isEqualToString:@"VTABLE"]){
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        }else{
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }
        
        
        
        return cell;
        
    }
    
    else if (indexPath.section==1){
        
        cell.DocNameLabel.text=NSLocalizedString(@"Preview", nil);
        cell.DocNameActualLabel.text=nil;
        return cell;
        
    }
    
    return nil;
    
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
    if (indexPath.section==1){
        ReportViewController *rpvc = [[ReportViewController alloc] initWithNibName:@"ReportPreviewController" bundle:nil];
        
        // Pass the selected object to the new view controller.
        
        // Push the view controller.
        rpvc.url= [BIExportReport getExportReportURLForDocumentId:_documentId withReportId:_reportId withSession:_currentSession];
        rpvc.exportFormat=FormatHTML;
        rpvc.titleText = _reportName;
        [self.navigationController pushViewController:rpvc animated:YES];
    }
}
#pragma mark get VTABLE headers
-(NSString *) getVtableHeadersWithElement: (GDataXMLElement *) element{
    //          //VTABLE/ROWGROUP[@type='header']//CONTENT
    NSArray *headers=[element nodesForXPath:@"//ROWGROUP[@type='header']//CONTENT" error:nil];
    NSMutableString *returnString = [[NSMutableString alloc] init];
    for (GDataXMLElement *header in headers) {
        [returnString appendString:[header stringValue]];
        NSLog(@"Appending Header:%@",returnString);
        [returnString appendString:@";"];
    }
    return  returnString;
}

@end
