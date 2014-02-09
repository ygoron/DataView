//

//  EditWebiDocumentViewController.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-11-30.
//  Copyright (c) 2013 APOS Systems. All rights reserved.
//

#import "EditWebiDocumentViewController.h"
//#import "UniverseDetailsViewControllerSolo.h"
#import "DocTitleCell.h"
#import "TitleLabel.h"
#import "TextEditViewController.h"
#import "SelectWebiFieldsViewController.h"
#import "QueryField.h"
#import "ReportXml.h"
#import "ActionCell.h"
#import "ReportViewController.h"
#import "WebiPromptViewController.h"
#import "WebiAppDelegate.h"
#import "XmlViewController.h"



@interface EditWebiDocumentViewController ()

@end

@implementation EditWebiDocumentViewController

{
    UIActivityIndicatorView *spinner;
    NSURL *__dataproviderUrl;
    NSURL *__getReportsUrl;
    NSString *__docName;
    int __universeId;
    NSString *__dataproviderId;
    NSMutableDictionary *__selectFieldsForProviderId;
    NSMutableDictionary *__selectFieldsForReportId;
    NSMutableArray *__reports;
    NSArray *__webiPrompts;
    
}

+(GDataXMLElement *)getFirstElementForDocument:(GDataXMLDocument *)docXml withPath:(NSString *)path
{
    
    NSArray *elements = [docXml nodesForXPath:path error:nil];
    
    if (elements.count>0 ){
        GDataXMLElement *nameElement=  (GDataXMLElement *) [elements objectAtIndex:0];
        return nameElement;
    }
    
    return nil;
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
    UINib *nib=[UINib nibWithNibName:@"DocTitleCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"DocTitle_ID"];
    
    NSLog(@"Parent Folder Id:%d",_folderId);
    
    spinner = [[UIActivityIndicatorView alloc]  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin);
    spinner.center = CGPointMake(self.tableView.bounds.size.width / 2.0f, self.tableView.bounds.size.height / 2.0f);
    [self.view addSubview:spinner];
    
    
    
    UIBarButtonItem *doneButton         = [[UIBarButtonItem alloc]
                                           initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                           target:self
                                           action:@selector(closeView)];
    self.navigationItem.rightBarButtonItems =[NSArray arrayWithObjects:doneButton, nil];
    
    nib=[UINib nibWithNibName:@"ActionCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"ActionCell"];
    
    __selectFieldsForProviderId=[[NSMutableDictionary alloc] init];
    __reports =[[NSMutableArray alloc] init];
    
    
}

-(void) closeView
{
    [self saveDocumentWithDelegate:self];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) saveDocumentWithDelegate: (id) delegateObject {
    
    if (_docId>0){
        NSLog(@"Saving Report with Id: %d",_docId);
        
        NSURL *urlForDocument=[XMLRESTProcessor getDocumentsUrlWithSession:_currentSession];
        urlForDocument=[urlForDocument URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%d",@"/",_docId]];
        XMLRESTProcessor *xmlProcessor=[[XMLRESTProcessor alloc] init];
        xmlProcessor.delegate=delegateObject;
        [xmlProcessor submitRequestForUrl:urlForDocument withSession:_currentSession withHttpMethod:@"PUT" withXmlDoc:_documentXml withOpCode:OP_SAVE_DOCUMENT];
        
        
    }
    
}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!__docName){
        TitleLabel *titelLabel=[[TitleLabel alloc] initWithFrame:CGRectZero];
        
        titelLabel.text=NSLocalizedString(@"New Webi Document", nil);
        
        self.navigationItem.titleView = titelLabel;
        [titelLabel sizeToFit];
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
    
    
    if (_docId>0)
        return 4;
    else
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    NSArray *dataproviders=[_dataprovidersXml nodesForXPath:@"/dataproviders/dataprovider" error:nil];
    
    switch (section) {
        case 0: // Always have document name section
            return 1;
            break;
            
        case 1:
//            return [dataproviders count]+1;
            return 1;
            break;
            
        case 2:
            if ([dataproviders count]>0 )
                return  [__reports count];
            break;
            
        case 3:
            if ([[__selectFieldsForProviderId objectForKey:__dataproviderId] count]>0  && __reports.count >0)
                return 1;
            
        default:
            break;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if([view isKindOfClass:[UITableViewHeaderFooterView class]]){
        UITableViewHeaderFooterView *tableViewHeaderFooterView = (UITableViewHeaderFooterView *) view;
        tableViewHeaderFooterView.textLabel.text = [tableViewHeaderFooterView.textLabel.text capitalizedString];
    }
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    switch (section) {
        case 0:
            return NSLocalizedString(@"Document", nil);
            break;
        case 1:
            return NSLocalizedString(@"Query", nil);
            break;
        case 2:
            return NSLocalizedString(@"Report", nil);
            break;
            
            
        default:
            break;
    }
    
    return  nil;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    if (indexPath.section==1){
//        NSArray *dataproviders=[_dataprovidersXml nodesForXPath:@"/dataproviders/dataprovider" error:nil];
//        if (indexPath.row<[dataproviders count]) return YES;
//    }
    
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath

{
    if (indexPath.section==1){
        
        NSURL    *url=[__dataproviderUrl URLByAppendingPathComponent:[NSString stringWithFormat:@"%@",[self getDataProviderIdForRow:indexPath.row]]];
        NSLog(@"URL to Delete Dataprovider:%@",url);
        XMLRESTProcessor *xmlProcessor=[[XMLRESTProcessor alloc] init];
        xmlProcessor.delegate=self;
        [xmlProcessor submitRequestForUrl:url withSession:_currentSession withHttpMethod:@"DELETE" withXmlDoc:nil withOpCode:OP_DELETE_DATA_PROVIDER];
    }
    
}

-(void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==1){
        NSString *dataProviderId=[self getDataProviderIdForRow:indexPath.row];
        NSURL *url=[XMLRESTProcessor getDataProvidersUrlWithSession:_currentSession withDocumentId:_docId];
        url=[url URLByAppendingPathComponent:[NSString stringWithFormat:@"%@%@",@"/",dataProviderId]];
        XMLRESTProcessor *xmlProcessor=[[XMLRESTProcessor alloc] init];
        xmlProcessor.delegate=self;
        [xmlProcessor submitRequestForUrl:url withSession:_currentSession withHttpMethod:@"GET" withXmlDoc:nil withOpCode:OP_GET_DATA_PROVIDER_DETAILS];
        
        //        NSString *dataProviderId=[self getDataProviderIdForRow:indexPath.row];
        //        DataProviderDetailsViewController *dpDetails=[[DataProviderDetailsViewController alloc] init];
        //        dpDetails.docId=_docId;
        //        dpDetails.dataProviderId=dataProviderId;
        //        dpDetails.currentSession=_currentSession;
        //        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:dpDetails];
        //        [self presentViewController:navController animated:YES completion:nil];
        
        
    }
}

-(NSString *) getDataProviderNameForRow: (int) row
{
    
    NSArray *dataproviders=[_dataprovidersXml nodesForXPath:@"/dataproviders/dataprovider" error:nil];
    GDataXMLElement *element=  (GDataXMLElement *) [dataproviders objectAtIndex:row];
    NSString *dataproviderName=[[[element elementsForName:@"name"] objectAtIndex:0] stringValue];
    NSLog(@"Data Provider Id:%@",dataproviderName);
    return dataproviderName;
    
}

-(NSString *) getDataProviderIdForRow: (int) row
{
    
    NSArray *dataproviders=[_dataprovidersXml nodesForXPath:@"/dataproviders/dataprovider" error:nil];
    GDataXMLElement *element=  (GDataXMLElement *) [dataproviders objectAtIndex:row];
    NSString *dataproviderId=[[[element elementsForName:@"id"] objectAtIndex:0] stringValue];
    NSLog(@"Data Provider Id:%@",dataproviderId);
    return dataproviderId;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DocTitle_ID";
    static NSString *ActionCellIdentifier = @"ActionCell";
    
    if (indexPath.section==0){
        // Document Cell
        DocTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[DocTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        cell.DocNameLabel.text=NSLocalizedString(@"Name", nil);
        
        
        GDataXMLElement *nameElement=[EditWebiDocumentViewController getFirstElementForDocument:_documentXml withPath:@"/document/name"];
        if ([[nameElement stringValue] length]>0){
            cell.DocNameActualLabel.text=nameElement.stringValue;
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
        }else{
            cell.DocNameActualLabel.text=nil;
        }
        
        
        
        return cell;
    }else if (indexPath.section==1){
        // DataProvider Cell
        DocTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[DocTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        NSArray *dataproviders=[_dataprovidersXml nodesForXPath:@"/dataproviders/dataprovider" error:nil];
        [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
        
//        if (indexPath.row<[dataproviders count]){
        if (dataproviders.count >0){
            
            
            
            GDataXMLElement *element=  (GDataXMLElement *) [dataproviders objectAtIndex:indexPath.row];
            cell.DocNameLabel.text=[[[element elementsForName:@"name"] objectAtIndex:0] stringValue];
            
            NSString *dataProviderId=[[[element elementsForName:@"id"] objectAtIndex:0] stringValue];
            int selectedFieldsCount=[[__selectFieldsForProviderId valueForKey:dataProviderId] count];
            cell.DocNameActualLabel.text=[NSString stringWithFormat:@"%d",selectedFieldsCount];
            cell.accessoryType=UITableViewCellAccessoryDetailDisclosureButton;
            cell.shouldIndentWhileEditing=NO;
            
        }else{
            
            cell.DocNameLabel.text=NSLocalizedString(@"Add", nil);
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            cell.DocNameActualLabel.text=nil;
            
            
        }
        
        return  cell;
        
        
    } else if (indexPath.section==2){
        
        //Report Cell
        
        DocTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[DocTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
        
        if (indexPath.row<[__reports count]){
            ReportXml *report=  [__reports objectAtIndex:indexPath.row];
            cell.DocNameLabel.text=report.name;
            cell.DocNameActualLabel.text=nil;
        }else{
            
            cell.DocNameLabel.text=NSLocalizedString(@"Add", nil);
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            cell.DocNameActualLabel.text=nil;
            
            
        }
        
        return  cell;
        
    } else if (indexPath.section==3){
        ActionCell *cell=[tableView dequeueReusableCellWithIdentifier:ActionCellIdentifier];
        
        if (indexPath.row==0){
            
            if (cell == nil) {
                cell = [[ActionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            cell.labelActionName.text=NSLocalizedString(@"Refresh Document",nil);
        }
        return cell;
        
    }
    
    DocTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[DocTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
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
        // Create the next view controller.
        TextEditViewController *textEditCell = [[TextEditViewController alloc] initWithNibName:@"TextEditViewController" bundle:nil];
        textEditCell.delegate=self;
        NSLog(@"Processing Document Name Section");
        textEditCell.placeHolderText=NSLocalizedString(@"Document Name", nil);
        
        
        GDataXMLElement *nameElement=[EditWebiDocumentViewController getFirstElementForDocument:_documentXml withPath:@"/document/name"];
        if ([[nameElement stringValue] length] >0) {
            NSLog(@"Name Element is not empty");
            textEditCell.defaultValue=[nameElement stringValue];
        }else{
            // Push the view controller.
            [self.navigationController pushViewController:textEditCell animated:YES];
            
        }
        
        
    }else if (indexPath.section==1){
        NSArray *dataproviders=[_dataprovidersXml nodesForXPath:@"/dataproviders/dataprovider" error:nil];
        
        if (indexPath.row <dataproviders.count){
            
            GDataXMLElement *element=  (GDataXMLElement *) [dataproviders objectAtIndex:indexPath.row];
            NSString *dataproviderId=[[[element elementsForName:@"id"] objectAtIndex:0] stringValue];
            
            NSLog(@"Get Universe id first. Call Get DataProviders details for provider:%@",dataproviderId);
            
            NSURL    *url=[__dataproviderUrl URLByAppendingPathComponent:[NSString stringWithFormat:@"%@",dataproviderId]];
            NSLog(@"Path Components%@",[url pathComponents]);
            XMLRESTProcessor *xmlProcessor=[[XMLRESTProcessor alloc] init];
            xmlProcessor.delegate=self;
            [xmlProcessor submitRequestForUrl:url withSession:_currentSession withHttpMethod:@"GET" withXmlDoc:nil withOpCode:OP_DATA_PROVIDER_DETAIL];
            
            
            
        }
        else if(indexPath.section==1){
            //                DataProviderSelectorViewController *dpVC= [[DataProviderSelectorViewController alloc] initWithNibName:@"DataProviderSelectorViewController" bundle:nil];
            //                dpVC.delegate=self;
            //                NSLog(@"Adding Data Provider");
            //                [self.navigationController pushViewController:dpVC animated:YES];
            //                dpVC.defaultValue=[NSString stringWithFormat:@"%@%d",@"Query ",indexPath.row+1];
            //                dpVC.placeHolderText=NSLocalizedString(@"Query Name", nil);
            
            
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
            UniversesListViewController *unvVC = (UniversesListViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"UniverseList"];
            unvVC.delegate=self;
            
            [unvVC setIsWebiCreation:YES];
            // Configure the new view controller here.
            [self.navigationController pushViewController:unvVC animated:YES];
            
        }
        
    }else if (indexPath.section==2){
        int reportId=[[__reports objectAtIndex:indexPath.row] reportId];
        NSLog(@"Edit Report %d",reportId);
        NSMutableArray *reportFields=[__selectFieldsForReportId valueForKey:[NSString stringWithFormat:@"%d",reportId]];
        
        SelectReportFieldsViewController *swf=[[SelectReportFieldsViewController alloc] initWithNibName:@"SelectReportFieldsViewController" bundle:nil];
        swf.selectedQueryFields=reportFields;
        //TODO Combine fields from all Data Providers;
        
        NSMutableArray *allAvailableFields=[[NSMutableArray alloc]init];
        NSArray *providerIds=[__selectFieldsForProviderId allKeys];
        for (NSString *providerId in providerIds ) {
            NSArray *fields = [__selectFieldsForProviderId objectForKey:providerId];
            for (QueryField *queryField in fields) {
                [allAvailableFields addObject:queryField];
                NSLog(@"Available Field:%@",queryField.name);
            }
        }
        swf.availableQueryFields=allAvailableFields;
        swf.delegate=self;
        swf.reportId=reportId;
        [self.navigationController pushViewController:swf animated:YES];
        
    }
    
    else if (indexPath.section==3){
        NSLog(@"Select Refresh Report");
        
        WebiPromptsEngine *promptEngine=[[WebiPromptsEngine alloc] init];
        promptEngine.delegate=self;
        [promptEngine getPromptsForDocId:_docId withSession:_currentSession];
        
        
    }
    
    
    
}

-(void)UniversesListViewController:(UniversesListViewController *)controller didSelectUniverse:(Universe *)universe
{
    [self DataProviderSelectorViewController:nil didFinishEditingWithQueryName:[NSString stringWithFormat:@"%@%@%d",universe.name,@"-",universe.universeId] UniverseId:universe.universeId] ;
}
-(void)reportFieldsSelected:(SelectReportFieldsViewController *)controller withSelectedFields:(NSArray *)selectedWebiFields
{
    NSLog(@"Report Updated:%d",controller.reportId);
    
    [__selectFieldsForReportId setValue:selectedWebiFields forKey:[NSString stringWithFormat:@"%d",controller.reportId]];
    GDataXMLDocument *reportSpecsXml=[self createReportUsingSelectedFields:selectedWebiFields];
    NSURL *url=[XMLRESTProcessor getUpdateReportSpecsUrlWithSession:_currentSession forDocumentId:_docId forReportId:controller.reportId];
    
    XMLRESTProcessor *xmlProcessor=[[XMLRESTProcessor alloc] init];
    xmlProcessor.delegate=self;
    [xmlProcessor submitRequestForUrl:url withSession:_currentSession withHttpMethod:@"PUT" withXmlDoc:reportSpecsXml withOpCode:OP_UPDATE_REPORT_SPEC];
    
}

-(void) didGetPrompts:(WebiPromptsEngine *)webiPromptsEngine isSuccess:(BOOL)isSuccess withPrompts:(NSArray *)webiPrompts withErrorText:(NSString *)errorText
{
    __webiPrompts=webiPrompts;
    NSLog(@"Prompts in Modified Report:%d",__webiPrompts.count);
    
    if(__webiPrompts.count==0){
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
        
        ReportViewController *reportExportView = (ReportViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"ReportView"];
        UINavigationController *cntrol = [[UINavigationController alloc] initWithRootViewController:reportExportView];
        
        reportExportView.isRefreshDocument=YES;
        reportExportView.webiPrompts=nil;
        reportExportView.document=_document;
        reportExportView.titleText=_document.name;
        [self presentViewController:cntrol animated:YES completion:nil];
        
    }else{
        WebiPromptViewController *promptVC=[[WebiPromptViewController alloc]initWithNibName:@"WebiPromptViewController" bundle:nil];
        promptVC.webiPrompts=__webiPrompts;
        promptVC.document=_document;
        [self.navigationController pushViewController:promptVC animated:YES];
        
    }
    
}

-(void) TextTextEditViewController:(TextEditViewController *)controller didFinishEditingValue:(NSString *)value
{
    NSLog (@"Received Valued:%@",value);
    if ([value length] ==0) return;
    GDataXMLElement *nameElement=[EditWebiDocumentViewController getFirstElementForDocument:_documentXml withPath:@"/document/name"];
    [nameElement setStringValue:value];
    
    if (_docId <=0){
        NSLog(@"Create New Webi Document");
        [spinner startAnimating];
        NSURL *urlDocuments=[XMLRESTProcessor getDocumentsUrlWithSession:_currentSession];
        XMLRESTProcessor *xmlProcessor=[[XMLRESTProcessor alloc] init];
        xmlProcessor.delegate=self;
        [xmlProcessor submitRequestForUrl:urlDocuments withSession:_currentSession withHttpMethod:@"POST" withXmlDoc:_documentXml withOpCode:OP_CREATE_WEBI];
    }
    
    
    
#ifdef Trace
    NSData *xmlData = _documentXml.XMLData;
    NSString *xmlString = [[NSString alloc]  initWithData:xmlData
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"Document XML:%@",xmlString);
#endif
    
    
    NSRange range = NSMakeRange(0, 1);
    NSIndexSet *sectionToReload = [NSIndexSet indexSetWithIndexesInRange:range];
    [self.tableView  reloadSections:sectionToReload withRowAnimation:UITableViewRowAnimationFade];
    
    
    
}

-(void)DataProviderSelectorViewController:(DataProviderSelectorViewController *)controller didFinishEditingWithQueryName:(NSString *)queryName UniverseId:(int)universeId
{
    NSLog(@"Ready for REST Call. Universe ID:%d",universeId);
    _dataprovidersXml=[self addDataProviderWithUniverse:universeId withQueryName:queryName];
    NSURL *dataprovidersUrl=[XMLRESTProcessor getDataProvidersUrlWithSession:_currentSession withDocumentId:_docId];
    NSLog(@"Add Data Provider");
    [spinner startAnimating];
    XMLRESTProcessor *xmlProcessor=[[XMLRESTProcessor alloc] init];
    xmlProcessor.delegate=self;
    [xmlProcessor submitRequestForUrl:dataprovidersUrl withSession:_currentSession withHttpMethod:@"POST" withXmlDoc:_dataprovidersXml withOpCode:OP_ADD_DATA_PROVIDER];
    
    
}

-(void) finishedProcessing:(XMLRESTProcessor *)xmlProcessor isSuccess:(BOOL)isSuccess withReturnedXml:(GDataXMLDocument *)xmlDoc withErrorText:(NSString *)errorText forUrl:(NSURL *)url withMethod:(NSString *)method withOriginalRequestXml:(GDataXMLDocument *)originalXmlDoc withOpCode:(int)opCode
{
    
    [spinner stopAnimating];
    
    NSLog(@"Returned with Operation Code:%d",opCode);
    
    if (isSuccess==YES){
        [TestFlight passCheckpoint:[NSString stringWithFormat: @"XML Processor Success for URL:%@ With Method %@",url,method]];
        GDataXMLElement *idElement=[EditWebiDocumentViewController getFirstElementForDocument:xmlDoc withPath:@"/success/id"];
        NSLog(@"New Id:%@",[idElement stringValue]);
        if(opCode==OP_CREATE_WEBI){
            _docId=[[idElement stringValue] integerValue];
            NSLog(@"Document with Id %d created. in folderId %d",_docId,_folderId);
            
            GDataXMLElement *nameElement=[EditWebiDocumentViewController getFirstElementForDocument:originalXmlDoc withPath:@"/document/name"];
            __docName=[nameElement stringValue];
            TitleLabel *titleLabel= (TitleLabel*) self.navigationItem.titleView;
            if (titleLabel){
                titleLabel.text=__docName;
                
            }
            
            WebiAppDelegate   *appDelegate = (id)[[UIApplication sharedApplication] delegate];
            NSManagedObjectContext      *context = [appDelegate managedObjectContext];
            
            _document = [NSEntityDescription
                         insertNewObjectForEntityForName:@"Document"
                         inManagedObjectContext:context];
            _document.session=_currentSession;
            _document.id=[NSNumber numberWithInt:_docId];
            _document.name=__docName;
            _document.folderid=[NSNumber numberWithInt:_folderId];
            
            XMLRESTProcessor *xmlProcessor=[[XMLRESTProcessor alloc] init];
            xmlProcessor.delegate=self;
            __getReportsUrl=[url URLByAppendingPathComponent:[NSString stringWithFormat:@"%d%@",_docId,@"/reports"]];
            [xmlProcessor submitRequestForUrl:__getReportsUrl withSession:_currentSession withHttpMethod:@"GET" withXmlDoc:nil withOpCode:OP_GET_LIST_OF_REPORTS];
            
            
        }else if (opCode==OP_GET_LIST_OF_REPORTS){
            NSLog(@"Return from List of Reports");
            
            NSArray *reportElements=[xmlDoc nodesForXPath:@"/reports/report" error:nil];
            NSLog(@"Number of Reports:%d",reportElements.count);
            
            for (GDataXMLElement *reportElement in reportElements) {
                int reportId=[[[[reportElement elementsForName:@"id"]objectAtIndex:0] stringValue] integerValue];
                NSLog(@"Report Id:%d",reportId);
                ReportXml *reportXml=[[ReportXml alloc]init];
                reportXml.reportId=reportId;
                reportXml.name=[[[reportElement elementsForName:@"name"]objectAtIndex:0] stringValue];
                NSLog(@"Report Name:%@",reportXml.name);
                [__reports addObject:reportXml];
            }
            
            
            
        }
        else if (opCode==OP_ADD_DATA_PROVIDER){
            NSLog(@"New Data Provider Id:%@",[idElement stringValue] );
            NSLog(@"Procceed with updating list of data providers");
            __dataproviderUrl=url;
            [spinner startAnimating];
            XMLRESTProcessor *xmlProcessor=[[XMLRESTProcessor alloc] init];
            xmlProcessor.delegate=self;
            [xmlProcessor submitRequestForUrl:url withSession:_currentSession withHttpMethod:@"GET" withXmlDoc:nil withOpCode:OP_GET_LIST_OF_DATA_PROVIDERS];
            
        }else if (opCode==OP_GET_LIST_OF_DATA_PROVIDERS){
            NSLog(@"Return From updated list of data providers");
            GDataXMLElement *idElement=[EditWebiDocumentViewController getFirstElementForDocument:xmlDoc withPath:@"/dataproviders/dataprovider/id"];
            NSLog(@"Data Provider Id:%@",[idElement stringValue]);
            _dataprovidersXml=xmlDoc;
            __dataproviderId=[idElement stringValue];
            NSLog(@"Refresh Section 1(Providers)");
            
            
        }else if (opCode==OP_DATA_PROVIDER_DETAIL){
            GDataXMLElement *dataSourceElement=[EditWebiDocumentViewController getFirstElementForDocument:xmlDoc withPath:@"/dataprovider/dataSourceId"];
            NSLog(@"Data Provider Detail Finished - Proceed with Select Fields for Webi Report. Universe Id:%@",[dataSourceElement stringValue]);
            
            NSLog(@"URL Components:%@",[url pathComponents]);
            
            __dataproviderId=[[url pathComponents] objectAtIndex:[[url pathComponents] count]-1];
            NSLog(@"Selected Data Provider Id:%@",__dataproviderId);
            
            __universeId=[[dataSourceElement stringValue] intValue];
            NSLog(@"Current Univer Id:%d",__universeId);
            
            
            NSURL    *url=[__dataproviderUrl URLByAppendingPathComponent:[NSString stringWithFormat:@"%@",__dataproviderId]];
            url=[url URLByAppendingPathComponent:[NSString stringWithFormat:@"%@",@"/specification"]];
            NSLog(@"Update QuerySpec URL:%@",url);
            
            XMLRESTProcessor *xmlProcessor=[[XMLRESTProcessor alloc] init];
            xmlProcessor.delegate=self;
            xmlProcessor.accept=@"text/xml";
            [xmlProcessor submitRequestForUrl:url withSession:_currentSession withHttpMethod:@"GET" withXmlDoc:nil withOpCode:OP_GET_QUERY_SPEC];
            
            
            
            
        }else if (opCode==OP_GET_QUERY_SPEC){
            NSLog(@"Return From Get Query Spec");
            
            NSArray *selectedQueryFields=[self getSelectedQueryFieldAndFiltersWithXML:xmlDoc];
            
            Universe *universe =[[Universe alloc] init];
            universe.universeId=__universeId;
            universe.session=_currentSession;
            SelectWebiFieldsViewController *swf=[[SelectWebiFieldsViewController alloc] initWithNibName:@"SelectWebiFieldsViewController" bundle:nil];
            swf.universe=universe;
            swf.dataproviderId=__dataproviderId;
            swf.selectedQueryFields=selectedQueryFields;
            swf.delegate=self;
            [self.navigationController pushViewController:swf animated:YES];
            
            
        }
        
        
        
        
        else if (opCode==OP_UPDATE_QUERY_SPEC){
            NSLog(@"Return from Update Query Spec. Update Data Provider Next");
            
            NSURL    *url=[__dataproviderUrl URLByAppendingPathComponent:[NSString stringWithFormat:@"%@",__dataproviderId]];
            NSString *urlString=[[url absoluteString] stringByAppendingString:@"?purge=true"];
            url=[url initWithString:urlString];
            NSLog(@"URL to update Dataprovider:%@",url);
            XMLRESTProcessor *xmlProcessor=[[XMLRESTProcessor alloc] init];
            xmlProcessor.delegate=self;
            [xmlProcessor submitRequestForUrl:url withSession:_currentSession withHttpMethod:@"GET" withXmlDoc:nil withOpCode:OP_UPDATE_DATA_PROVIDER];
            
        }else if (opCode==OP_UPDATE_DATA_PROVIDER){
            NSLog(@"Return From Update Data Provider");
            NSLog(@"Test Creating Report - Adjust Later");
            //TODO: adjust later - Need loop for all objects in dictionary insetead of last data providerId
            
            NSArray *selectFields=  [__selectFieldsForProviderId objectForKey:__dataproviderId];
            if (selectFields.count>0){
                GDataXMLDocument *reportSpecsXml=[self createReportUsingSelectedFields:selectFields];
                //TODO: Change Report Id from hard coded "1"
                __selectFieldsForReportId=[[NSMutableDictionary alloc]init];
                [__selectFieldsForReportId setValue:selectFields forKey:@"1"];
                
                NSURL *url=[XMLRESTProcessor getUpdateReportSpecsUrlWithSession:_currentSession forDocumentId:_docId forReportId:1];
                
                XMLRESTProcessor *xmlProcessor=[[XMLRESTProcessor alloc] init];
                xmlProcessor.delegate=self;
                [xmlProcessor submitRequestForUrl:url withSession:_currentSession withHttpMethod:@"PUT" withXmlDoc:reportSpecsXml withOpCode:OP_UPDATE_REPORT_SPEC];
            }
            
        }
        else if (opCode==OP_UPDATE_REPORT_SPEC){
            NSLog(@"Report Specs Updated");
        }
        else if(opCode==OP_SAVE_DOCUMENT){
            NSLog(@"Document Saved");
        }
        
        else if(opCode==OP_DELETE_DATA_PROVIDER){
            NSLog(@"Delete Data Provider");
            
            NSString *xpath=[NSString stringWithFormat:@"%@%@%@",@"/dataproviders/dataprovider[id=\"" , [idElement stringValue],@"\"]"] ;
            NSLog(@"XPath Expression:%@",xpath);
            GDataXMLElement *providerToDelete=[[_dataprovidersXml nodesForXPath:xpath error:nil] objectAtIndex:0];
            NSLog(@"XML To Delete:%@",providerToDelete.XMLString);
            [[_dataprovidersXml rootElement] removeChild:providerToDelete];
        }else if (opCode==OP_GET_DATA_PROVIDER_DETAILS){
            NSLog(@"Display Data Provider Details");
            XmlViewController *xmlViewCtl=[[XmlViewController alloc] init];
            GDataXMLElement *elementToShow=[[xmlDoc rootElement] copy];
            xmlViewCtl.xmlElement=elementToShow;
            UINavigationController *unvc=[[UINavigationController alloc] initWithRootViewController:xmlViewCtl];
            [self presentViewController:unvc animated:YES completion:nil];
        }
        
        
        [self.tableView reloadData];
        
    }
    else {
        
        if (errorText!=nil){
            
            NSArray *document = [originalXmlDoc nodesForXPath:@"/document" error:NULL];
            
            if (document.count>0){
                
                GDataXMLElement *nameElement=[EditWebiDocumentViewController getFirstElementForDocument:_documentXml withPath:@"/document/name"];
                
                NSLog(@"This was create new document transaction. Reset document name");
                nameElement.stringValue=@"";
                NSRange range = NSMakeRange(0, 1);
                NSIndexSet *sectionToReload = [NSIndexSet indexSetWithIndexesInRange:range];
                [self.tableView  reloadSections:sectionToReload withRowAnimation:UITableViewRowAnimationFade];
                
                
            }
            
            
            UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Server Error",@"Failed") message:errorText delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
            
        }
    }
    
    
}
#pragma mark - WebiFieldSelected
-(void)webiFieldsSelected:(SelectWebiFieldsViewController *)controller withSelectedFields:(NSArray *)selectedWebiFields forDataProviderId:(NSString *)dataProviderId
{
    NSLog(@"Select %d fields",selectedWebiFields.count);
    
    NSLog(@"Update Dictionary...");
    [__selectFieldsForProviderId setValue:selectedWebiFields forKey:dataProviderId];
    
    NSLog(@"Build Query Spec Startig with Template");
    
    NSString *path= [[NSBundle mainBundle] pathForResource:@"QuerySpec1" ofType:@"xml"];
    NSLog(@"Path:%@. Data Provider Id:%@",path,dataProviderId);
    
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:[NSData dataWithContentsOfFile:path] encoding:NSUTF8StringEncoding  error:NULL];
    if (doc){
        NSData *xmlData = doc.XMLData;
        NSString *xmlString = [[NSString alloc]  initWithData:xmlData
                                                     encoding:NSUTF8StringEncoding];
        NSLog(@"Original XML template:%@",xmlString);
        
        NSArray *querySpecArray =[doc.rootElement nodesForXPath:@"/*" error:NULL ];
        
        GDataXMLElement *querySpec=[querySpecArray objectAtIndex:0];
        NSLog(@"element Name:%@",[querySpec name]);
        GDataXMLNode *attribute =[GDataXMLNode attributeWithName:@"dataProviderId"  stringValue:dataProviderId];
        [querySpec addAttribute:attribute];
        
        
        GDataXMLElement *queriesTree =[GDataXMLNode elementWithName:@"queriesTree"];
        attribute=[GDataXMLNode attributeWithName:@"queryOperator" stringValue:@"Union"];
        [queriesTree addAttribute:attribute];
        
        attribute =[GDataXMLNode attributeWithName:@"xsi:type"  stringValue:@"queryspec:QueryOperatorNode"];
        [queriesTree addAttribute:attribute];
        
        
        GDataXMLElement *children=[GDataXMLNode elementWithName:@"children"] ;
        attribute =[GDataXMLNode attributeWithName:@"xsi:type"  stringValue:@"queryspec:QueryDataNode"];
        [children addAttribute:attribute];
        
        
        
        
        GDataXMLElement *boQuery=[GDataXMLNode elementWithName:@"bOQuery"] ;
        attribute =[GDataXMLNode attributeWithName:@"name"  stringValue:@"Query"];
        [boQuery addAttribute:attribute];
        
        //TODO: Replace with Unique Identifier
        attribute =[GDataXMLNode attributeWithName:@"identifier"  stringValue:dataProviderId];
        [boQuery addAttribute:attribute];
        
        
        
        GDataXMLElement *conditionPart=[GDataXMLNode elementWithName:@"conditionPart"] ;
        
        GDataXMLElement *conditionTree=[GDataXMLNode elementWithName:@"conditionTree"] ;
        
        attribute =[GDataXMLNode attributeWithName:@"xsi:type"  stringValue:@"queryspec:ConditionOperatorNode"];
        [conditionTree addAttribute:attribute];
        
        attribute =[GDataXMLNode attributeWithName:@"logicalOperator"  stringValue:@"And"];
        [conditionTree addAttribute:attribute];
        
        
        
        for (QueryField *queryField  in selectedWebiFields) {
            NSLog(@"Field Type:%@",queryField.type);
            if ([queryField.type isEqualToString:@"Filter"]==NO){
                
                GDataXMLElement *resultObject=[GDataXMLNode elementWithName:@"resultObjects"];
                attribute =[GDataXMLNode attributeWithName:@"identifier"  stringValue:queryField.fieldId];
                [resultObject addAttribute:attribute];
                
                attribute =[GDataXMLNode attributeWithName:@"name"  stringValue:queryField.name];
                [resultObject addAttribute:attribute];
                
                [boQuery addChild:resultObject];
            }else{
                
                
                GDataXMLElement *childrenCondition=[GDataXMLNode elementWithName:@"children"] ;
                attribute =[GDataXMLNode attributeWithName:@"xsi:type"  stringValue:@"queryspec:ConditionDataNode"];
                [childrenCondition addAttribute:attribute];
                
                attribute =[GDataXMLNode attributeWithName:@"logicalOperator"  stringValue:@"Null"];
                [childrenCondition addAttribute:attribute];
                
                GDataXMLElement *condition=[GDataXMLNode elementWithName:@"condition"] ;
                attribute =[GDataXMLNode attributeWithName:@"xsi:type"  stringValue:@"queryspec:PredefinedCondition"];
                [condition addAttribute:attribute];
                
                attribute =[GDataXMLNode attributeWithName:@"conditionType"  stringValue:@"Predefined"];
                [condition addAttribute:attribute];
                
                attribute =[GDataXMLNode attributeWithName:@"itemIdentifier"  stringValue:queryField.fieldId];
                [condition addAttribute:attribute];
                
                [childrenCondition addChild:condition];
                [conditionTree addChild:childrenCondition];
                
                
            }
            
            
        }
        
        [conditionPart addChild:conditionTree];
        [boQuery addChild:conditionPart];
        [children addChild:boQuery];
        [queriesTree addChild:children];
        [querySpec addChild:queriesTree];
        
        
        xmlString = [[NSString alloc]  initWithData:doc.XMLData
                                           encoding:NSUTF8StringEncoding];
        
        NSLog(@"Resulted XML:%@",xmlString);
        
        
        NSURL    *url=[__dataproviderUrl URLByAppendingPathComponent:[NSString stringWithFormat:@"%@",dataProviderId]];
        url=[url URLByAppendingPathComponent:[NSString stringWithFormat:@"%@",@"/specification"]];
        NSLog(@"Update QuerySpec URL:%@",url);
        
        XMLRESTProcessor *xmlProcessor=[[XMLRESTProcessor alloc] init];
        xmlProcessor.delegate=self;
        xmlProcessor.contentType=@"text/xml";
        [xmlProcessor submitRequestForUrl:url withSession:_currentSession withHttpMethod:@"PUT" withXmlDoc:doc withOpCode:OP_UPDATE_QUERY_SPEC];
        
        
    }
    
    
}

//-(GDataXMLDocument *) createReportForQuery: (GDataXMLDocument *) querySpecsDoc
//{
//
//
//    NSString *path= [[NSBundle mainBundle] pathForResource:@"QuerySpec1" ofType:@"xml"];
//    NSLog(@"Path:%@ ",path);
//
//    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:[NSData dataWithContentsOfFile:path] encoding:NSUTF8StringEncoding  error:NULL];
//    if (doc){
//
//    }
//
//    return  doc;
//}

-(NSArray *) getSelectedQueryFieldAndFiltersWithXML: (GDataXMLDocument *) querySpecsDoc
{
    NSMutableArray *selectedFields=[[NSMutableArray alloc]init];
    
    NSArray *resultObjects=[querySpecsDoc nodesForXPath:@"////children/bOQuery/resultObjects" error:nil];
    NSLog(@"Found %d query objects", resultObjects.count);
    
    
    for (GDataXMLElement *resultObject in resultObjects) {
        NSLog(@"Selected Query Field:%@",[[resultObject attributeForName:@"identifier"] stringValue]);
        [selectedFields addObject:[[resultObject attributeForName:@"identifier"] stringValue]];
    }
    
    NSArray *conditions = [querySpecsDoc nodesForXPath:@"////children/bOQuery/conditionPart/conditionTree/children/*" error:NULL];
    NSLog(@"Found Conditions:%d",[conditions count]);
    
    for (GDataXMLElement *condition in conditions) {
        NSLog(@"Selected Query Filter:%@",[[condition attributeForName:@"itemIdentifier"] stringValue]);
        [selectedFields addObject:[[condition attributeForName:@"itemIdentifier"] stringValue]];
    }
    
    NSLog(@"Total Selected Elements: %d",selectedFields.count);
    
    return [selectedFields mutableCopy];
}

#pragma add new dataprovider XML
-(GDataXMLDocument *)addDataProviderWithUniverse:(int)dataSourceId withQueryName: (NSString *)queryName
{
    GDataXMLElement *root =[GDataXMLNode elementWithName:@"dataprovider"];
    
    GDataXMLNode *name= [GDataXMLNode elementWithName:@"name" stringValue:queryName];
    [root addChild:name];
    
    GDataXMLNode *universeId= [GDataXMLNode elementWithName:@"dataSourceId" stringValue:[NSString stringWithFormat:@"%d",dataSourceId]];
    [root addChild:universeId];
    GDataXMLDocument *doc=[[GDataXMLDocument alloc] initWithRootElement:root];
    
#ifdef Trace
    NSData *xmlData = doc.XMLData;
    NSString *xmlString = [[NSString alloc]  initWithData:xmlData
                                                 encoding:NSUTF8StringEncoding];
    NSLog(@"XML String:%@",xmlString);
#endif
    
    return doc;
}

-(GDataXMLDocument *)createReportUsingSelectedFields: (NSArray *) resultObjects
{
    
    
    NSString *path= [[NSBundle mainBundle] pathForResource:@"ReportTemplate" ofType:@"xml"];
    GDataXMLDocument *reportSpecsDoc = [[GDataXMLDocument alloc] initWithData:[NSData dataWithContentsOfFile:path] encoding:NSUTF8StringEncoding  error:NULL];
    if (reportSpecsDoc){
        NSArray *elements = [reportSpecsDoc nodesForXPath:@"///AXIS/EXPRS" error:NULL];
        NSLog(@"AXIS:%d",[elements count]);
        GDataXMLElement *exprs=[elements objectAtIndex:0];
        NSLog(@"Setting AXIS");
        
        for (QueryField *resultObject in resultObjects) {
            if (![resultObject.type isEqualToString:@"Filter"]){
                NSLog(@"Selected Query Field:%@",[resultObject fieldId]);
                GDataXMLElement *axis_Expr=[GDataXMLElement elementWithName:@"AXIS_EXPR" stringValue:[NSString stringWithFormat:@"%@%@%@",@"=[",[resultObject name] ,@"]"]];
                [exprs addChild:axis_Expr];
            }
            
        }
        
        NSLog(@"Setting COL width");
        elements = [reportSpecsDoc nodesForXPath:@"//VTABLE" error:NULL];
        GDataXMLElement *vtable=[elements objectAtIndex:0];
        
        for (QueryField *resultObject in resultObjects)
        {
            if (![resultObject.type isEqualToString:@"Filter"]){
                GDataXMLElement *colElement=[GDataXMLElement elementWithName:@"COL"];
                GDataXMLNode *attribute=[GDataXMLNode attributeWithName:@"width" stringValue:@"0"];
                [colElement addAttribute:attribute];
                [vtable addChild:colElement];
            }
        }
        
        
        NSLog(@"Setting Row Group Header");
        
        GDataXMLElement *rowGroup=[GDataXMLElement elementWithName:@"ROWGROUP"];
        GDataXMLNode *attribute=[GDataXMLNode attributeWithName:@"type" stringValue:@"header"];
        [rowGroup addAttribute:attribute];
        
        
        GDataXMLElement *tr=[GDataXMLElement elementWithName:@"TR"];
        attribute =[GDataXMLNode attributeWithName:@"height" stringValue:@"0"];
        [tr addAttribute:attribute];
        
        int bid=10;
        for (QueryField *resultObject in resultObjects)
        {
            if (![resultObject.type isEqualToString:@"Filter"]){
                GDataXMLElement *tdcell=[GDataXMLElement elementWithName:@"TDCELL"];
                attribute =[GDataXMLNode attributeWithName:@"bId" stringValue:[NSString stringWithFormat:@"%d",bid]];
                [tdcell addAttribute:attribute];
                
                GDataXMLElement *content=[GDataXMLElement elementWithName:@"CONTENT" stringValue:[NSString stringWithFormat:@"%@%@%@",@"=NameOf([",[resultObject name],@"])"]] ;
                
                [tdcell addChild:content];
                
                [tr addChild:tdcell];
                bid++;
            }
            
        }
        
        [rowGroup addChild:tr];
        [vtable addChild:rowGroup];
        
        
        
        rowGroup=[GDataXMLElement elementWithName:@"ROWGROUP"];
        attribute=[GDataXMLNode attributeWithName:@"type" stringValue:@"body"];
        [rowGroup addAttribute:attribute];
        
        
        tr=[GDataXMLElement elementWithName:@"TR"];
        attribute =[GDataXMLNode attributeWithName:@"height" stringValue:@"0"];
        [tr addAttribute:attribute];
        
        for (QueryField *resultObject in resultObjects)
        {
            if (![resultObject.type isEqualToString:@"Filter"]){
                GDataXMLElement *tdcell=[GDataXMLElement elementWithName:@"TDCELL"];
                attribute =[GDataXMLNode attributeWithName:@"bId" stringValue:[NSString stringWithFormat:@"%d",bid]];
                [tdcell addAttribute:attribute];
                
                GDataXMLElement *content=[GDataXMLElement elementWithName:@"CONTENT" stringValue:[NSString stringWithFormat:@"%@%@%@",@"=[",[resultObject name],@"]"]] ;
                
                [tdcell addChild:content];
                
                [tr addChild:tdcell];
                bid++;
            }
            
        }
        
        
        
        [rowGroup addChild:tr];
        [vtable addChild:rowGroup];
        
        return reportSpecsDoc;
    }
    return nil;
}





@end
