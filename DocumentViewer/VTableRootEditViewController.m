//
//  VTableRootEditViewController.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2014-03-02.
//  Copyright (c) 2014 APOS Systems. All rights reserved.
//

#import "VTableRootEditViewController.h"
#import "TitleLabel.h"
#import "Utils.h"
#import "DocTitleCell.h"
#import "ReportViewController.h"
#import "VTableEditViewController.h"
#import "WebViewTableViewCell.h"
#import "BIExportReport.h"




@interface VTableRootEditViewController ()

@end

@implementation VTableRootEditViewController
{
    UIActivityIndicatorView *spinner;


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
    titelLabel.text=_reportName;
    [titelLabel sizeToFit];
    
    
    
    
    UINib *nib=[UINib nibWithNibName:@"DocTitleCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"DocTitle_ID"];
    
//    nib=[UINib nibWithNibName:@"ActionCell" bundle:nil];
//    [[self tableView] registerNib:nib forCellReuseIdentifier:@"ActionCell"];
    
    nib=[UINib nibWithNibName:@"WebViewTableViewCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"WebiViewCell_ID"];
    
    spinner = [[UIActivityIndicatorView alloc]  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin);
    spinner.center = CGPointMake(self.tableView.bounds.size.width / 2.0f, self.tableView.bounds.size.height / 2.0f);
    [self.view addSubview:spinner];



    
    
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


-(void) refreshWebView
{
    [spinner startAnimating];
    NSLog (@"Load Web View");
    BIExportReport *exportReport=[[BIExportReport alloc]init];
    exportReport.delegate=self;
    ReportExportFormat formatHtml=FormatHTML;
    exportReport.exportFormat= formatHtml;
    exportReport.biSession=_currentSession;
    exportReport.isExportWithUrl=YES;
    NSURL *url= [BIExportReport getExportReportURLForDocumentId:_documentId withReportId:_reportId withSession:_currentSession];
    url=[url URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%d", @"/elements/",_elementId]];
    NSLog(@"URL To Export Element:%@",url.absoluteString);
    [exportReport exportEntityWithUrl:url withFormat:formatHtml forSession:_currentSession];
    
}
-(void) biExportReport:(BIExportReport *)biExportReport isSuccess:(BOOL)isSuccess html:(NSString *)htmlString{
    [spinner stopAnimating];

    WebViewTableViewCell *cell=  (WebViewTableViewCell *)[self.tableView cellForRowAtIndexPath:    [NSIndexPath indexPathForRow:0 inSection:1]];
    if (isSuccess==YES){
        NSLog(@"Documents Received");
        
        if (cell)
            [cell.webView loadHTMLString:htmlString baseURL:nil];
//        if (__webView){
//            [__webView loadHTMLString:htmlString baseURL:nil];
//        }
        
        
        
    }else{
        
        NSString* errorString = [NSString stringWithFormat:
                                 @"<html><center><font size=+1 color='black'>%@<br></font></center></html>",
                                 NSLocalizedString(@"Preview not available", nil)];

        if (cell)
            [cell.webView loadHTMLString:errorString baseURL:nil];

//        [__webView loadHTMLString:errorString baseURL:nil];
        
    }
    
    
    
    
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [self refreshWebView];
    [[self tableView]reloadData];
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForFooterInSection:(NSInteger)section
{
    if (section==0) return 35;
    return 0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==1) return tableView.frame.size.height-24;
    return 44;
}

-(void)biExportReportExternalFormat:(BIExportReport *)biExportReport isSuccess:(BOOL)isSuccess filePath:(NSString *)filePath WithFormat:(ReportExportFormat)format
{
    
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.]
    if (section==0) return 1;
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifierElement = @"DocTitle_ID";
//    static NSString *ActionCellIdentifier = @"ActionCell";
    static NSString *WebCellIdentifier = @"WebiViewCell_ID";


    
    
    
    // Configure the cell...
    
    if (indexPath.section==0){
        DocTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierElement];
        if (cell == nil) {
            cell = [[DocTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierElement];
        }

        if (indexPath.row==0) cell.DocNameLabel.text=NSLocalizedString(@"Columns", nil);
        cell.DocNameActualLabel.text=nil;
        return  cell;

    }else if (indexPath.section==1){
//        ActionCell *cell=[tableView dequeueReusableCellWithIdentifier:ActionCellIdentifier];
//        if (cell == nil) {
//            
//            cell = [[ActionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ActionCellIdentifier];
//        }
//
//        cell.labelActionName.text=NSLocalizedString(@"Preview", nil);
//        return cell;
        
        WebViewTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:WebCellIdentifier];
        if (cell==nil){
            cell=[[WebViewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:WebCellIdentifier];
        }
//        cell.webView.delegate=self;
//        if (!__webView) {
//            __webView=cell.webView;
//            __webView.delegate=self;
//        }
        
        [self refreshWebView];
        return  cell;


    }
    return nil;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"Start Loading");
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //    [self.navigationController setNavigationBarHidden:YES animated:YES];
    NSLog(@"Finish ViewDidFinishLoad");
    //    __webView.scalesPageToFit=YES;
    
    WebViewTableViewCell *cell=  (WebViewTableViewCell *)[self.tableView cellForRowAtIndexPath:    [NSIndexPath indexPathForRow:0 inSection:1]];

    if (cell)
        cell.webView.contentMode = UIViewContentModeScaleAspectFit;

//    __webView.contentMode = UIViewContentModeScaleAspectFit;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
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
         if (indexPath.row==0){
             NSLog(@"Display VTable Columns");
             NSURL *url= [BIExportReport getExportReportURLForDocumentId:_documentId withReportId:_reportId withSession:_currentSession];
             url=[url URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%d", @"/elements/",_elementId]];
             NSLog(@"URL To Export Element:%@",url.absoluteString);

             VTableEditViewController *vtvc=[[VTableEditViewController alloc]init];
             vtvc.documentId=_documentId;
             vtvc.reportId=_reportId;
             vtvc.currentSession=_currentSession;
             vtvc.reportName=_reportName;
             vtvc.xmlReportElements=_xmlReportElements;
             vtvc.xmlReportSpecs=_xmlReportSpecs;
             vtvc.elementId=_elementId;
             vtvc.viewUrl=url;
             [self.navigationController pushViewController:vtvc animated:YES];

             
         }
         
     }
     else if (indexPath.section==1){
         ReportViewController *rpvc = [[ReportViewController alloc] initWithNibName:@"ReportPreviewController" bundle:nil];
         
         // Pass the selected object to the new view controller.
         
         // Push the view controller.
         NSURL *url= [BIExportReport getExportReportURLForDocumentId:_documentId withReportId:_reportId withSession:_currentSession];
         url=[url URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%d", @"/elements/",_elementId]];
         NSLog(@"URL To Export Element:%@",url.absoluteString);
         rpvc.url=url;
         rpvc.exportFormat=FormatHTML;
         rpvc.titleText = _reportName;
         rpvc.currentSession=_currentSession;
         [self.navigationController pushViewController:rpvc animated:YES];
     }
 
 }
 

@end
