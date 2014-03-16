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
#import "VTableRootEditViewController.h"
#import "ActionCell.h"
#import "WebViewTableViewCell.h"
#import "BIExportReport.h"



@interface ReportEditorViewController ()

@end

@implementation ReportEditorViewController

{
    
    UIActivityIndicatorView *spinner;
    GDataXMLDocument *currentXmlDocReportSpecs;
    GDataXMLDocument *currentXmlDocReportElements;
    NSArray *__reportElements;
    int __restCallsCounter;
    
    
    
    
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
    
    //    nib=[UINib nibWithNibName:@"ActionCell" bundle:nil];
    //    [[self tableView] registerNib:nib forCellReuseIdentifier:@"ActionCell"];
    
    nib=[UINib nibWithNibName:@"WebViewTableViewCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"WebiViewCell_ID"];
    
    
    
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
    NSURL *basUrl=[XMLRESTProcessor getDocumentsUrlWithSession:_currentSession];
    if (_xmlReportSpecs==nil){
        __restCallsCounter=0;
        NSURL *url=[basUrl URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%d%@%d%@",@"/",_documentId,@"/reports/",_reportId,@"/specification"]];
        XMLRESTProcessor *xmlProcessor1=[[XMLRESTProcessor alloc] init];
        xmlProcessor1.delegate=self;
        xmlProcessor1.accept=@"text/xml";
        [xmlProcessor1 submitRequestForUrl:url withSession:_currentSession withHttpMethod:@"GET" withXmlDoc:nil withOpCode:OP_UPDATE_REPORT_SPEC];
        
        
        NSURL *url2=[basUrl URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%d%@%d%@",@"/",_documentId,@"/reports/",_reportId,@"/elements"]];
        XMLRESTProcessor *xmlProcessor2=[[XMLRESTProcessor alloc] init];
        xmlProcessor2.delegate=self;
        xmlProcessor2.accept=@"application/xml";
        [xmlProcessor2 submitRequestForUrl:url2 withSession:_currentSession withHttpMethod:@"GET" withXmlDoc:nil withOpCode:OP_GET_REPORT_ELEMENTS];
    }
    
    
}

-(void) refreshWebView
{
    [spinner startAnimating];
    NSLog (@"Load Web View");
    BIExportReport *exportReport=[[BIExportReport alloc] init];
    exportReport.delegate=self;
    ReportExportFormat formatHtml=FormatHTML;
    exportReport.exportFormat= formatHtml;
    exportReport.biSession=_currentSession;
    exportReport.isExportWithUrl=YES;
    NSURL *url=[BIExportReport getExportReportURLForDocumentId:_documentId withReportId:_reportId withSession:_currentSession];
    if (_elementParentId>0){
        NSLog(@"Export Report Element");
        url=[url URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%d",@"/elements/",_elementParentId]];
    }
    
    [exportReport exportEntityWithUrl:url withFormat:formatHtml forSession:_currentSession];
    
}
-(void) biExportReport:(BIExportReport *)biExportReport isSuccess:(BOOL)isSuccess html:(NSString *)htmlString{
    [spinner stopAnimating];
    
    if (isSuccess==YES){
        NSLog(@"Report Exported");
        _prevWorkedUrl=biExportReport.url;
        WebViewTableViewCell *cell=  (WebViewTableViewCell *)[self.tableView cellForRowAtIndexPath:    [NSIndexPath indexPathForRow:0 inSection:1]];
        if (cell){
            [cell.webView loadHTMLString:htmlString baseURL:nil];
        }
        
        //        if (_webView){
        //            [_webView loadHTMLString:htmlString baseURL:nil];
        //        }
        
        
        
    }else{
        
        //                NSString* errorString = [NSString stringWithFormat:
        //                                         @"<html><center><font size=+1 color='black'>%@<br></font></center></html>",
        //                                         NSLocalizedString(@"Preview not available", nil)];
        //                [_webView loadHTMLString:errorString baseURL:nil];
        NSLog(@"Error Loading the preview. Trying previuos working URL");
        if (_prevWorkedUrl){
            if (spinner)
                [spinner startAnimating];
            if (biExportReport){
                biExportReport.delegate=self;
                [biExportReport exportEntityWithUrl:_prevWorkedUrl withFormat:FormatHTML forSession:_currentSession];
            }
        }
        
    }
    
    
    
    
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

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //    [self refreshWebView];
    [[self tableView]reloadData];
}

-(void) finishedProcessing:(XMLRESTProcessor *)xmlProcessor isSuccess:(BOOL)isSuccess withReturnedXml:(GDataXMLDocument *)xmlDoc withErrorText:(NSString *)errorText forUrl:(NSURL *)url withMethod:(NSString *)method withOriginalRequestXml:(GDataXMLDocument *)originalXmlDoc withOpCode:(int)opCode
{
    if (opCode == OP_UPDATE_REPORT_SPEC){
        NSLog(@"Proceed with building report specs");
        currentXmlDocReportSpecs=xmlDoc;
        //        _reportSpecElements=[[currentXmlDoc nodesForXPath:@"//VTABLE" error:nil] mutableCopy];
        _xmlReportSpecs=currentXmlDocReportSpecs;
        __restCallsCounter++;
    }else if (opCode==OP_GET_REPORT_ELEMENTS){
        // /elements/*
        currentXmlDocReportElements=xmlDoc;
        _xmlReportElements=currentXmlDocReportElements;
        __restCallsCounter++;
    }
    // /elements/element[not(parentId)]
    if (__restCallsCounter==2){
        NSLog(@"Refresh Table");
        [self.tableView reloadData];
    }
    
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
    if (_xmlReportElements==nil) return  0;
    
    if (section==0){
        
        if (_elementParentId<=0){
            __reportElements=[_xmlReportElements nodesForXPath:@"/elements/element[not(parentId)]" error:nil];
        }else{
            NSString *stringXpath=[NSString stringWithFormat:@"%@%d%@", @"/elements/element[parentId=",_elementParentId, @"]"];
            __reportElements=[_xmlReportElements nodesForXPath:stringXpath error:nil];
            
        }
        
        if (_elementParentId>0){
            __reportElements=[__reportElements sortedArrayUsingComparator:^(id obj1, id obj2) {
                NSLog(@"Object 1:%@",[[[obj1 elementsForName:@"name"] objectAtIndex:0] stringValue]);
                NSLog(@"Object 2:%@",[[[obj2 elementsForName:@"name"] objectAtIndex:0] stringValue]);
                return [[[[obj1 elementsForName:@"name"] objectAtIndex:0] stringValue]   compare:[[[obj2 elementsForName:@"name"] objectAtIndex:0] stringValue]];
            }];
        }
        
        
        
        return  __reportElements.count;
    }else if (section==1){
        //        if (_elementParentId==0) return 1;
        //        else if (__reportElements.count>0)
        return 1;
    }
    return 0;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifierElement = @"DocTitle_ID";
    //    static NSString *ActionCellIdentifier = @"ActionCell";
    static NSString *WebCellIdentifier = @"WebiViewCell_ID";
    
    
    
    
    
    
    if (indexPath.section==0){
        
        DocTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierElement];
        if (cell == nil) {
            cell = [[DocTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierElement];
        }
        
        
        NSString *elementName=[[[[__reportElements objectAtIndex:indexPath.row] elementsForName:@"name"] objectAtIndex:0] stringValue];
        int elementId=[[[[[__reportElements objectAtIndex:indexPath.row] elementsForName:@"id"] objectAtIndex:0] stringValue] integerValue];
        NSLog(@"Element Id:%d",elementId);
        
        NSString *type=[[[__reportElements objectAtIndex:indexPath.row] attributeForName:@"type"] stringValue];
        NSLog(@"Element Name:%@ Type:%@",elementName,type);
        if (_elementParentId<=0)
            cell.DocNameLabel.text=elementName;
        else
            
            cell.DocNameLabel.text=type;
        
        
        NSString *stringXpath=[NSString stringWithFormat:@"%@%d%@", @"/elements/element[parentId=",elementId, @"]"];
        NSLog(@"XPath:%@",stringXpath);
        
        //        int childCount=[[_xmlReportElements nodesForXPath:stringXpath error:nil] count];
        //cell.DocNameActualLabel.text=[NSString  stringWithFormat:@"%d", childCount] ;
        //        cell.DocNameActualLabel.text=[NSString  stringWithFormat:@"%@%@%d%@", elementName,@"(",childCount,@")"] ;
        
        cell.DocNameActualLabel.text=elementName;
        
        if ([cell.DocNameActualLabel.text isEqualToString:cell.DocNameLabel.text]) cell.DocNameActualLabel.text=@"";
        //            if (![elementName isEqualToString:type])
        //                cell.DocNameActualLabel.text=[NSString  stringWithFormat:@"%@", type] ;
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        
        return cell;
        
    }
    
    else if (indexPath.section==1){
        
        //        ActionCell *cell=[tableView dequeueReusableCellWithIdentifier:ActionCellIdentifier];
        //        if (cell == nil) {
        //
        //            cell = [[ActionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ActionCellIdentifier];
        //        }
        //
        //        cell.labelActionName.text=NSLocalizedString(@"Preview", nil);
        //        [cell setAccessoryType:UITableViewCellAccessoryNone];
        
        
        WebViewTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:WebCellIdentifier];
        if (cell==nil){
            cell=[[WebViewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:WebCellIdentifier];
        }
        //        if (!_webView) {
        //            _webView=cell.webView;
        //            _webView.delegate=self;
        //        }
        //        cell.webView.delegate=self;
        
        [self refreshWebView];
        
        return cell;
        
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
        
        int elementId=[[[[[__reportElements objectAtIndex:indexPath.row] elementsForName:@"id"] objectAtIndex:0] stringValue] integerValue];
        NSString *elementName=[[[[__reportElements objectAtIndex:indexPath.row] elementsForName:@"name"] objectAtIndex:0] stringValue];
        NSString *type=[[[__reportElements objectAtIndex:indexPath.row] attributeForName:@"type"] stringValue];
        NSLog(@"Type:%@",type);
        if ([type isEqualToString:@"VTable"]){
            VTableRootEditViewController *vtrc=[[VTableRootEditViewController alloc] init];
            
            vtrc.documentId=_documentId;
            vtrc.reportId=_reportId;
            vtrc.currentSession=_currentSession;
            vtrc.reportName=elementName;
            vtrc.xmlReportElements=_xmlReportElements;
            vtrc.xmlReportSpecs=_xmlReportSpecs;
            vtrc.elementId=elementId;
            [self.navigationController pushViewController:vtrc animated:YES];
        }else{
            ReportEditorViewController *revc=[[ReportEditorViewController alloc] init];
            revc.documentId=_documentId;
            revc.reportId=_reportId;
            revc.availableQueryFields=_availableQueryFields;
            revc.selectedQueryFields=_selectedQueryFields;
            revc.currentSession=_currentSession;
            revc.reportName=elementName;
            revc.xmlReportElements=_xmlReportElements;
            revc.xmlReportSpecs=_xmlReportSpecs;
            revc.elementParentId=elementId;
            revc.prevWorkedUrl=_prevWorkedUrl;
            [self.navigationController pushViewController:revc animated:YES];
        }
        
        
        
    } else
        if (indexPath.section==1){
            ReportViewController *rpvc = [[ReportViewController alloc] initWithNibName:@"ReportPreviewController" bundle:nil];
            
            // Pass the selected object to the new view controller.
            
            // Push the view controller.
            rpvc.url= [BIExportReport getExportReportURLForDocumentId:_documentId withReportId:_reportId withSession:_currentSession];
            if (_elementParentId>0){
                NSLog(@"Export Report Element");
                rpvc.url=[[rpvc url] URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%d",@"/elements/",_elementParentId]];
            }
            rpvc.exportFormat=FormatHTML;
            rpvc.titleText = _reportName;
            rpvc.currentSession=_currentSession;
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
