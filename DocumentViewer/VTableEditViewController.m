//
//  VTableEditViewController.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2014-03-02.
//  Copyright (c) 2014 APOS Systems. All rights reserved.
//

#import "VTableEditViewController.h"
#import "TitleLabel.h"
#import "Utils.h"
#import "DocTitleCell.h"
#import "WebViewTableViewCell.h"
#import "BIExportReport.h"


@interface VTableEditViewController ()
// Parent //VTABLE[@bId='13']/ROWGROUP[@type='body']/TR
// Rows //VTABLE[@bId='13']/ROWGROUP[@type='body']/TR/TDCELL
@end

@implementation VTableEditViewController
{
    UIActivityIndicatorView *spinner;
    NSMutableDictionary *__tableDict;
    NSString *__htmlString;
    BOOL __isWebViewLoaded;
    
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
    
    
    spinner = [[UIActivityIndicatorView alloc]  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin);
    spinner.center = CGPointMake(self.tableView.bounds.size.width / 2.0f, self.tableView.bounds.size.height / 2.0f);
    [self.view addSubview:spinner];
    
    UINib *nib=[UINib nibWithNibName:@"DocTitleCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"DocTitle_ID"];
    
    nib=[UINib nibWithNibName:@"WebViewTableViewCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"WebiViewCell_ID"];
    
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void) viewWillAppear:(BOOL)animated
{
    __isWebViewLoaded=NO;
    [self loadVTable];
}


-(void) loadVTable{
    
    
    NSString *xPath=[NSString stringWithFormat:@"%@%d%@",@"//VTABLE[@bId='",_elementId,@"']/ROWGROUP[@type='body']/TR/TDCELL"];
    NSLog(@"XPath:%@",xPath);
    NSArray *columnsBody=[[_xmlReportSpecs nodesForXPath:xPath error:nil] mutableCopy];
    
    
    
    NSString *parentXPath=[NSString stringWithFormat:@"%@%d%@",@"//VTABLE[@bId='",_elementId,@"']/ROWGROUP[@type='header']/TR"];
    NSLog(@"parentXPath:%@",parentXPath);
    int lastIndex=[_xmlReportSpecs nodesForXPath:parentXPath error:nil].count;
    
    //    xPath=[NSString stringWithFormat:@"%@%d%@",@"//VTABLE[@bId='",_elementId,@"']/ROWGROUP[@type='header']/TR/TDCELL"];
    xPath=[NSString stringWithFormat:@"%@%d%@%d%@",@"//VTABLE[@bId='",_elementId,@"']/ROWGROUP[@type='header']/TR[",lastIndex,@"]/TDCELL"];
    NSLog(@"XPath:%@",xPath);
    NSArray *columnsHeader=[[_xmlReportSpecs nodesForXPath:xPath error:nil] mutableCopy];
    
    xPath=[NSString stringWithFormat:@"%@%d%@",@"//VTABLE[@bId='",_elementId,@"']/ROWGROUP[@type='footer']/TR/TDCELL"];
    NSLog(@"XPath:%@",xPath);
    NSArray *columnsFooter=[[_xmlReportSpecs nodesForXPath:xPath error:nil] mutableCopy];
    
    
    //    NSArray *types=[[NSArray alloc] initWithObjects:@"header",@"body",nil];
    __tableDict=[[NSMutableDictionary alloc] initWithObjectsAndKeys:columnsHeader,@"header", columnsBody,@"body",columnsFooter,@"footer",nil];
    
}
-(void) refreshWebView
{
    if (__isWebViewLoaded==NO){
        [spinner startAnimating];
        NSLog (@"Load Web View");
        BIExportReport *exportReport=[[BIExportReport alloc]init];
        exportReport.delegate=self;
        ReportExportFormat formatHtml=FormatHTML;
        exportReport.exportFormat= formatHtml;
        exportReport.biSession=_currentSession;
        exportReport.isExportWithUrl=YES;
        [exportReport exportEntityWithUrl:_viewUrl withFormat:formatHtml forSession:_currentSession];
    }
    
}
-(void) biExportReport:(BIExportReport *)biExportReport isSuccess:(BOOL)isSuccess html:(NSString *)htmlString{
    [spinner stopAnimating];
    
    
    if (isSuccess==YES){
        NSLog(@"Report Exported");
        __isWebViewLoaded=YES;
        __htmlString=htmlString;
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
-(void) viewWillDisappear:(BOOL)animated
{
    
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
-(BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
-(BOOL) tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) return YES;
    return NO;
}

-(UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0) return UITableViewCellEditingStyleDelete;
    
    return UITableViewCellEditingStyleNone;
}
-(BOOL) tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSLog(@"Delete Column");
        if (indexPath.section>0) return;
        
        NSArray *bodyColumns=[__tableDict objectForKey:@"body"];
        NSArray *headerColumns=[__tableDict objectForKey:@"header"];
        NSArray *footerColumns=[__tableDict objectForKey:@"footer"];
        
        BOOL isDeleteHeader=bodyColumns.count!=headerColumns.count? NO:YES;
        BOOL isDeleteFooter=bodyColumns.count!=footerColumns.count? NO:YES;
        
        [self deleteTableColumnForType:@"body" withSourceIndex:indexPath.row];
        if (isDeleteHeader==YES){
            [self deleteTableColumnForType:@"header" withSourceIndex:indexPath.row];
        }else{
            NSLog(@"Header has different number of columns. Do not update it");
        }
        
        if (isDeleteFooter==YES){
            [self deleteTableColumnForType:@"footer" withSourceIndex:indexPath.row];
        }else{
            NSLog(@"Footer has different number of columns. Do not update it");
        }
        
        
        NSString *xPathParentTable=[NSString stringWithFormat:@"%@%d%@",@"//VTABLE[@bId='",_elementId,@"']"];
        GDataXMLElement *parentTable=[[_xmlReportSpecs nodesForXPath:xPathParentTable error:nil] objectAtIndex:0];
        
        NSString *xPathForCol=[NSString stringWithFormat:@"%@%d%@",@"//VTABLE[@bId='",_elementId,@"']/COL"];
        GDataXMLNode *colToDelete=[[_xmlReportSpecs nodesForXPath:xPathForCol error:nil] objectAtIndex:indexPath.row];
        
        [parentTable removeChild:colToDelete];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        [spinner startAnimating];
        NSURL *url=[XMLRESTProcessor getUpdateReportSpecsUrlWithSession:_currentSession forDocumentId:_documentId  forReportId:_reportId];
        
        XMLRESTProcessor *xmlProcessor=[[XMLRESTProcessor alloc] init];
        xmlProcessor.delegate=self;
        [xmlProcessor submitRequestForUrl:url withSession:_currentSession withHttpMethod:@"PUT" withXmlDoc:_xmlReportSpecs withOpCode:OP_UPDATE_REPORT_SPEC];
        __isWebViewLoaded=NO;
        
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    if (sourceIndexPath.section != proposedDestinationIndexPath.section) {
        NSInteger row = 0;
        if (sourceIndexPath.section < proposedDestinationIndexPath.section) {
            row = [tableView numberOfRowsInSection:sourceIndexPath.section] - 1;
        }
        return [NSIndexPath indexPathForRow:row inSection:sourceIndexPath.section];
    }
    
    return proposedDestinationIndexPath;
}
-(void) tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    
    if (destinationIndexPath.section>0) return;
    
    [self rearangeVTableColumnsForType:@"body" withSourceIndex:sourceIndexPath.row withDestinationIndex:destinationIndexPath.row];
    
    NSArray *headerColumns=[__tableDict objectForKey:@"header"];
    NSArray *bodyColumns=[__tableDict objectForKey:@"body"];
    NSArray *footerColumns=[__tableDict objectForKey:@"footer"];
    
    if (bodyColumns.count==headerColumns.count){
        [self rearangeVTableColumnsForType:@"header" withSourceIndex:sourceIndexPath.row withDestinationIndex:destinationIndexPath.row];
    }else{
        NSLog(@"Header has different number of columns. Do not update it");
    }
    
    if (bodyColumns.count==footerColumns.count){
        [self rearangeVTableColumnsForType:@"footer" withSourceIndex:sourceIndexPath.row withDestinationIndex:destinationIndexPath.row];
    }else{
        NSLog(@"Footer has different number of columns. Do not update it");
        
    }
    
    [spinner startAnimating];
    NSURL *url=[XMLRESTProcessor getUpdateReportSpecsUrlWithSession:_currentSession forDocumentId:_documentId  forReportId:_reportId];
    
    XMLRESTProcessor *xmlProcessor=[[XMLRESTProcessor alloc] init];
    xmlProcessor.delegate=self;
    [xmlProcessor submitRequestForUrl:url withSession:_currentSession withHttpMethod:@"PUT" withXmlDoc:_xmlReportSpecs withOpCode:OP_UPDATE_REPORT_SPEC];
    
    
    // //VTABLE[@bId='13']/ROWGROUP[@type='body']/TR
    
}

#pragma mark - Delete Column in the HTML Report Specs
-(void) deleteTableColumnForType:(NSString *) type withSourceIndex: (NSInteger) sourceIndex
{
    NSLog(@"Delete Column");
    
    NSMutableArray *columns=[__tableDict objectForKey:type];
    if (columns.count==0) return;
    NSLog(@"Before");
    for (GDataXMLElement *column in columns) {
        NSLog(@"Bid:%@",[[column attributeForName:@"bId"] stringValue]);
    }
    [columns removeObjectAtIndex:sourceIndex];
    
    NSLog(@"After");
    for (GDataXMLElement *column in columns) {
        NSLog(@"Bid:%@",[[column attributeForName:@"bId"] stringValue]);
    }
    
    NSString *parentXPath=[NSString stringWithFormat:@"%@%d%@%@%@",@"//VTABLE[@bId='",_elementId,@"']/ROWGROUP[@type='",type,@"']/TR"];
    NSLog(@"parentXPath:%@",parentXPath);
    int lastIndex=[_xmlReportSpecs nodesForXPath:parentXPath error:nil].count;
    GDataXMLElement *parentElement=[[_xmlReportSpecs nodesForXPath:parentXPath error:nil] objectAtIndex:lastIndex-1];
    
    NSString *childrenXPath=[NSString stringWithFormat:@"%@%d%@%@%@%d%@",@"//VTABLE[@bId='",_elementId,@"']/ROWGROUP[@type='",type,@"']/TR[",lastIndex,@"]/*"];
    NSArray *allChildrens =[_xmlReportSpecs nodesForXPath:childrenXPath error:nil];
    NSLog(@"Children Path:%@",childrenXPath);
    
    
    NSLog(@"Now insert in new order");
    for (GDataXMLElement *rowElement in columns) {
        NSLog(@"Adding Element %@",[[rowElement attributeForName:@"bId"] stringValue]);
        [parentElement addChild:rowElement];
    }
    
    NSLog(@"Remove the ones that will be replaced");
    for (GDataXMLNode *child in allChildrens) {
        [parentElement   removeChild:child];
    }
    
    
    
    NSData *xmlData = _xmlReportSpecs.XMLData;
    NSString *xmlString = [[NSString alloc]  initWithData:xmlData
                                                 encoding:NSUTF8StringEncoding];
    
    NSLog(@"%@",xmlString);
    
    NSString *xPath=[NSString stringWithFormat:@"%@%d%@%@%@",@"//VTABLE[@bId='",_elementId,@"']/ROWGROUP[@type='",type,@"']/TR/TDCELL"];
    NSLog(@"XPath:%@",xPath);
    NSArray *updatedColumns=[_xmlReportSpecs nodesForXPath:xPath error:nil] ;
    [__tableDict setValue:updatedColumns forKey:type];
            __isWebViewLoaded=NO;
    
    
}
#pragma mark - Move Columns in the HTML Report Specs
-(void) rearangeVTableColumnsForType:(NSString *) type withSourceIndex: (NSInteger) sourceIndex withDestinationIndex: (NSInteger) destIndex
{
    
    NSLog(@"Move Column");
    
    NSMutableArray *columns=[__tableDict objectForKey:type];
    if (columns.count==0) return;
    GDataXMLElement *element=[columns objectAtIndex:sourceIndex];
    NSLog(@"Before");
    for (GDataXMLElement *column in columns) {
        NSLog(@"Bid:%@",[[column attributeForName:@"bId"] stringValue]);
    }
    [columns removeObjectAtIndex:sourceIndex];
    [columns insertObject:element atIndex:destIndex];
    
    NSLog(@"After");
    for (GDataXMLElement *column in columns) {
        NSLog(@"Bid:%@",[[column attributeForName:@"bId"] stringValue]);
    }
    
    NSString *parentXPath=[NSString stringWithFormat:@"%@%d%@%@%@",@"//VTABLE[@bId='",_elementId,@"']/ROWGROUP[@type='",type,@"']/TR"];
    NSLog(@"parentXPath:%@",parentXPath);
    int lastIndex=[_xmlReportSpecs nodesForXPath:parentXPath error:nil].count;
    GDataXMLElement *parentElement=[[_xmlReportSpecs nodesForXPath:parentXPath error:nil] objectAtIndex:lastIndex-1];
    
    NSString *childrenXPath=[NSString stringWithFormat:@"%@%d%@%@%@%d%@",@"//VTABLE[@bId='",_elementId,@"']/ROWGROUP[@type='",type,@"']/TR[",lastIndex,@"]/*"];
    NSArray *allChildrens =[_xmlReportSpecs nodesForXPath:childrenXPath error:nil];
    NSLog(@"Children Path:%@",childrenXPath);
    
    NSLog(@"Now insert in new order");
    for (GDataXMLElement *rowElement in columns) {
        NSLog(@"Adding Element %@",[[rowElement attributeForName:@"bId"] stringValue]);
        [parentElement addChild:rowElement];
    }
    
    NSLog(@"Remove the ones that will be replaced");
    for (GDataXMLNode *child in allChildrens) {
        [parentElement   removeChild:child];
    }
    
    NSLog(@"Print New Report Specs:");
    
    NSData *xmlData = _xmlReportSpecs.XMLData;
    NSString *xmlString = [[NSString alloc]  initWithData:xmlData
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"%@",xmlString);
    
    NSString *xPath=[NSString stringWithFormat:@"%@%d%@%@%@%d%@",@"//VTABLE[@bId='",_elementId,@"']/ROWGROUP[@type='",type,@"']/TR[",lastIndex,@"]/TDCELL"];
    NSLog(@"XPath:%@",xPath);
    NSArray *updatedColumns=[_xmlReportSpecs nodesForXPath:xPath error:nil] ;
    [__tableDict setValue:updatedColumns forKey:type];
            __isWebViewLoaded=NO;
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    __htmlString=nil;
    NSLog(@"Released Resources");
    
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
    //    NSString *xPath=[NSString stringWithFormat:@"%@%d%@",@"//VTABLE[@bId='",_elementId,@"']/ROWGROUP[@type='body']/TR/TDCELL"];
    //    NSLog(@"XPath:%@",xPath);
    //    NSArray *vtableElements=[_xmlReportSpecs nodesForXPath:xPath error:nil];
    //    return vtableElements.count;
    if (section==0)
        return [[__tableDict objectForKey:@"body"] count];
    else if ([[__tableDict objectForKey:@"body"] count]>0)
        return 1;
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifierElement = @"DocTitle_ID";
    static NSString *WebCellIdentifier = @"WebiViewCell_ID";
    
    if (indexPath.section==0){
        DocTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifierElement];
        if (cell == nil) {
            cell = [[DocTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifierElement];
            
        }
        
        //    NSString *xPath=[NSString stringWithFormat:@"%@%d%@",@"//VTABLE[@bId='",_elementId,@"']/ROWGROUP[@type='body']/TR/TDCELL"];
        //    NSLog(@"XPath:%@",xPath);
        //    GDataXMLElement *vtableCell=[[[[_xmlReportSpecs nodesForXPath:xPath error:nil] objectAtIndex:indexPath.row] elementsForName:@"CONTENT"] objectAtIndex:0];
        NSArray *columns=[__tableDict objectForKey:@"body"];
        GDataXMLElement *vtableCell=[[[columns objectAtIndex:indexPath.row] elementsForName:@"CONTENT"] objectAtIndex:0];
        cell.DocNameLabel.text=[vtableCell stringValue];
        
        cell.DocNameActualLabel.text=nil;
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setAccessoryType:UITableViewCellAccessoryNone];
        // Configure the cell...
        
        return cell;
    }else if (indexPath.section==1){
        WebViewTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:WebCellIdentifier];
        if (cell==nil){
            cell=[[WebViewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:WebCellIdentifier];
            
        }
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        //        cell.webView.delegate=self;
        
        //        if (!__webView) {
        //            __webView=cell.webView;
        //            __webView.delegate=self;
        //        }
        
        [self refreshWebView];
        
        return cell;
    }
    
    return nil;
}

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
    NSLog(@"Navigation Logic");
}


-(void) finishedProcessing:(XMLRESTProcessor *)xmlProcessor isSuccess:(BOOL)isSuccess withReturnedXml:(GDataXMLDocument *)xmlDoc withErrorText:(NSString *)errorText forUrl:(NSURL *)url withMethod:(NSString *)method withOriginalRequestXml:(GDataXMLDocument *)originalXmlDoc withOpCode:(int)opCode
{
    [spinner stopAnimating];
    if (opCode==OP_UPDATE_REPORT_SPEC){
        if (isSuccess==YES){
            NSLog(@"Report Specs Updated. Proceed with Refresh Report List");
            [self refreshWebView];
        }
        else{
            UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Server Error", nil) message:errorText delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }else if (opCode==OP_GET_LIST_OF_REPORTS){
        
    }
}

@end
