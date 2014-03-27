//
//  CellEditViewController.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2014-03-20.
//  Copyright (c) 2014 APOS Systems. All rights reserved.
//

#import "CellEditViewController.h"
#import "TitleLabel.h"
#import "Utils.h"
#import "TextEditCell.h"
#import "WebViewTableViewCell.h"
#import "BIExportReport.h"



@interface CellEditViewController ()

@end

@implementation CellEditViewController

{
    UIActivityIndicatorView *spinner;
    GDataXMLDocument *__cellXml;
    GDataXMLNode *__cellNode;
    NSURL *__elementUrl;
    BOOL __isUpdated;
    BOOL __isSuccess;
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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
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
    titelLabel.text=_elementName;
    [titelLabel sizeToFit];
    
    
    spinner = [[UIActivityIndicatorView alloc]  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin);
    spinner.center = CGPointMake(self.tableView.bounds.size.width / 2.0f, self.tableView.bounds.size.height / 2.0f);
    [self.view addSubview:spinner];
    
    UINib *nib=[UINib nibWithNibName:@"TextEditCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"TextEdit_ID"];
    
    nib=[UINib nibWithNibName:@"WebViewTableViewCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"WebiViewCell_ID"];
    
    [self loadTableDataSet];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) loadTableDataSet{
    
    NSURL *basUrl=[XMLRESTProcessor getDocumentsUrlWithSession:_currentSession];
    if (_elementId >0){
        
        __elementUrl=[basUrl URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%d%@%d%@%d",@"/",_documentId,@"/reports/",_reportId,@"/elements/",_elementId]];
        XMLRESTProcessor *xmlProcessor2=[[XMLRESTProcessor alloc] init];
        xmlProcessor2.delegate=self;
        xmlProcessor2.accept=@"application/xml";
        [xmlProcessor2 submitRequestForUrl:__elementUrl withSession:_currentSession withHttpMethod:@"GET" withXmlDoc:nil withOpCode:OP_GET_REPORT_ELEMENT_DETAIL];
        
    }
    
    
    
}
-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.delegate finishEditing:self isSuccess:__isSuccess isRefreshRequired:__isUpdated];
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
    
    
    if (isSuccess==YES){
        NSLog(@"Report Exported");
        
        WebViewTableViewCell *cell=  (WebViewTableViewCell *)[self.tableView cellForRowAtIndexPath:    [NSIndexPath indexPathForRow:0 inSection:1]];
        [cell.webView loadHTMLString:htmlString baseURL:nil];
        //        if (__webView){
        //            [__webView loadHTMLString:htmlString baseURL:nil];
        //        }else{
        //            NSLog(@"Web View is not created");
        //        }
        
        
        
    }else{
        if (biExportReport.connectorError!=nil){
            UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Load Report Failed",nil) message:[biExportReport.connectorError localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",@"OK on alert window") otherButtonTitles:nil, nil];
            [alert show];
            
        }else if (biExportReport.boxiError!=nil){
            UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Load Report Failed in BI",nil) message:biExportReport.boxiError delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil, nil];
            [alert show];
            
        } else{
            UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Load Report Failed",nil) message:NSLocalizedString(@"Server Error",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil, nil];
            [alert show];
            
        }
        
    }
    
    
    
    
}
-(void)biExportReportExternalFormat:(BIExportReport *)biExportReport isSuccess:(BOOL)isSuccess filePath:(NSString *)filePath WithFormat:(ReportExportFormat)format
{
    
}
-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //    [self.tableView setEditing: YES animated: YES];
    //    [self.tableView setAllowsSelectionDuringEditing:YES];
    [[self tableView]reloadData];
}

-(void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing: editing animated: animated];
    
    
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
    if (__cellNode)
        return 1;
    else return 0;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifierElement = @"TextEdit_ID";
    static NSString *WebCellIdentifier = @"WebiViewCell_ID";
    
    
    if (indexPath.section==0){
        TextEditCell *textEditCell=[tableView dequeueReusableCellWithIdentifier:CellIdentifierElement];
        if (textEditCell==nil){
            textEditCell=[[TextEditCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierElement];
        }
        textEditCell.TextEditField.enablesReturnKeyAutomatically=YES;
        textEditCell.TextEditField.autocorrectionType=UITextAutocorrectionTypeNo;
        textEditCell.TextEditField.clearButtonMode=UITextFieldViewModeWhileEditing;
        textEditCell.TextEditField.returnKeyType=UIReturnKeyDone;
        textEditCell.TextEditField.keyboardType=UIKeyboardTypeDefault;
        [textEditCell.TextEditField setDelegate:self];
        textEditCell.TextEditField.text=[__cellNode stringValue];
        return textEditCell;
    }if (indexPath.section==1){
        WebViewTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:WebCellIdentifier];
        if (cell==nil){
            cell=[[WebViewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:WebCellIdentifier];
        }
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        [self refreshWebView];
        
        return cell;
    }
    
    return nil;
}


-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    __cellNode.stringValue=textField.text;
    XMLRESTProcessor *xmlProcessor2=[[XMLRESTProcessor alloc] init];
    xmlProcessor2.delegate=self;
    xmlProcessor2.accept=@"application/xml";
    [xmlProcessor2 submitRequestForUrl:__elementUrl withSession:_currentSession withHttpMethod:@"PUT" withXmlDoc:__cellXml withOpCode:OP_UPDATE_REPORT_ELEMENT_DETAIL];
    
    
    return YES;
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

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"Start Loading");
    [spinner startAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //    [self.navigationController setNavigationBarHidden:YES animated:YES];
    NSLog(@"Finish ViewDidFinishLoad");
    //    __webView.scalesPageToFit=YES;
    
    WebViewTableViewCell *cell=  (WebViewTableViewCell *)[self.tableView cellForRowAtIndexPath:    [NSIndexPath indexPathForRow:0 inSection:1]];
    cell.webView.contentMode=UIViewContentModeScaleAspectFit;
    //    __webView.contentMode = UIViewContentModeScaleAspectFit;
    [spinner stopAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
}

-(void) finishedProcessing:(XMLRESTProcessor *)xmlProcessor isSuccess:(BOOL)isSuccess withReturnedXml:(GDataXMLDocument *)xmlDoc withErrorText:(NSString *)errorText forUrl:(NSURL *)url withMethod:(NSString *)method withOriginalRequestXml:(GDataXMLDocument *)originalXmlDoc withOpCode:(int)opCode
{
    
    //
    if (opCode ==OP_GET_REPORT_ELEMENT_DETAIL){
        if ([[xmlDoc nodesForXPath:@"/element/content/expression/formula/text()" error:nil] count] >0){
            __cellXml=xmlDoc;
            __cellNode=[[xmlDoc nodesForXPath:@"/element/content/expression/formula/text()" error:nil] objectAtIndex:0];
        }
    }else if(opCode==OP_UPDATE_REPORT_ELEMENT_DETAIL){
        NSLog(@"Report Element Updated");
        if ([[xmlDoc nodesForXPath:@"/error/message/text()" error:nil] count]>0){
            NSString *errorText=[[[xmlDoc nodesForXPath:@"/error/message/text()" error:nil] objectAtIndex:0] stringValue];
            UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Failed",nil) message:errorText delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil, nil];
            [alert show];
            __isSuccess=NO;
            
        }else{
            __isUpdated=YES;
            __isSuccess=YES;
            [self.tableView reloadData];
        }
        
        
        
        
        
    }
    
    
    
}



@end
