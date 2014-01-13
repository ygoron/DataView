//

//  EditWebiDocumentViewController.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-11-30.
//  Copyright (c) 2013 APOS Systems. All rights reserved.
//

#import "EditWebiDocumentViewController.h"
#import "UniverseDetailsViewControllerSolo.h"
#import "DocTitleCell.h"
#import "TitleLabel.h"
#import "TextEditViewController.h"


@interface EditWebiDocumentViewController ()

@end

@implementation EditWebiDocumentViewController

{
    UIActivityIndicatorView *spinner;
    NSURL *__dataproviderUrl;
    
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
    
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    TitleLabel *titelLabel=[[TitleLabel alloc] initWithFrame:CGRectZero];
    if (_documentXml==nil)
        titelLabel.text=NSLocalizedString(@"New Webi Document", nil);
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
    
    
    if (_docId>0)
        return 3;
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
            return [dataproviders count]+1;
            break;
            
        case 2:
            if (dataproviders.count<=0) return 0;
            break;
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
            return NSLocalizedString(@"Queries", nil);
            break;
        case 2:
            return NSLocalizedString(@"Reports", nil);
            break;
            
            
        default:
            break;
    }
    
    return  nil;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DocTitle_ID";
    
    if (indexPath.section==0){
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
        DocTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[DocTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        NSArray *dataproviders=[_dataprovidersXml nodesForXPath:@"/dataproviders/dataprovider" error:nil];
        [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
        
        if (indexPath.row<[dataproviders count]){
            
            
            
            GDataXMLElement *element=  (GDataXMLElement *) [dataproviders objectAtIndex:indexPath.row];
            cell.DocNameLabel.text=[[[element elementsForName:@"name"] objectAtIndex:0] stringValue];
            //            cell.DocNameActualLabel.text=[[[element elementsForName:@"id"] objectAtIndex:0] stringValue];
        }else{
            
            cell.DocNameLabel.text=NSLocalizedString(@"Add", nil);
            cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
            cell.DocNameActualLabel.text=nil;
            
            
        }
        
        
        return  cell;
        
        
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
        
        
    }else{
        if (indexPath.section==1){
            NSArray *dataproviders=[_dataprovidersXml nodesForXPath:@"/dataproviders/dataprovider" error:nil];
            
            if (indexPath.row <dataproviders.count){
                GDataXMLElement *element=  (GDataXMLElement *) [dataproviders objectAtIndex:indexPath.row];
                NSString *dataproviderId=[[[element elementsForName:@"id"] objectAtIndex:0] stringValue];
                NSLog(@"Get Universe id first. Call Get DataProviders details for provider:%@",dataproviderId);
                
                NSURL    *url=[__dataproviderUrl URLByAppendingPathComponent:[NSString stringWithFormat:@"%@",dataproviderId]];
                XMLRESTProcessor *xmlProcessor=[[XMLRESTProcessor alloc] init];
                xmlProcessor.delegate=self;
                [xmlProcessor submitRequestForUrl:url withSession:_currentSession withHttpMethod:@"GET" withXmlDoc:nil withOpCode:OP_DATA_PROVIDER_DETAIL];
                
                
                
            }
            else{
                DataProviderSelectorViewController *dpVC= [[DataProviderSelectorViewController alloc] initWithNibName:@"DataProviderSelectorViewController" bundle:nil];
                dpVC.delegate=self;
                NSLog(@"Adding Data Provider");
                [self.navigationController pushViewController:dpVC animated:YES];
                dpVC.defaultValue=[NSString stringWithFormat:@"%@%d",@"Query ",indexPath.row+1];
                dpVC.placeHolderText=NSLocalizedString(@"Query Name", nil);
            }
            
        }
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
            
        }else if (opCode==OP_ADD_DATA_PROVIDER){
            NSLog(@"New Data Provider Id:%@",[idElement stringValue] );
            NSLog(@"Procceed with updating list of data providers");
            __dataproviderUrl=url;
            [spinner startAnimating];
            XMLRESTProcessor *xmlProcessor=[[XMLRESTProcessor alloc] init];
            xmlProcessor.delegate=self;
            [xmlProcessor submitRequestForUrl:url withSession:_currentSession withHttpMethod:@"GET" withXmlDoc:nil withOpCode:OP_GET_LIST_OF_DATA_PROVIDERS];
            
            //            NSLog(@"Save Document");
            //            NSURL *url=[XMLRESTProcessor getDocumentsUrlWithSession:_currentSession];
            //            url=[url URLByAppendingPathComponent:[NSString stringWithFormat:@"%d",_docId]];
            //            XMLRESTProcessor *xmlProcessor=[[XMLRESTProcessor alloc] init];
            //            xmlProcessor.delegate=self;
            //            [xmlProcessor submitRequestForUrl:url withSession:_currentSession withHttpMethod:@"PUT" withXmlDoc:nil withOpCode:OP_SAVE_DOCUMENT];
            
            
        }else if (opCode==OP_GET_LIST_OF_DATA_PROVIDERS){
            NSLog(@"Return From updated list of data providers");
            _dataprovidersXml=xmlDoc;
            NSLog(@"Refresh Section 1(Providers)");

            
        }else if (opCode==OP_DATA_PROVIDER_DETAIL){
            GDataXMLElement *dataSourceElement=[EditWebiDocumentViewController getFirstElementForDocument:xmlDoc withPath:@"/dataprovider/dataSourceId"];
            NSLog(@"Data Provider Detail Finished - Proceed with Universe Detail View. Universe Id:%@",[dataSourceElement stringValue]);
            Universe *universe =[[Universe alloc] init];
            universe.universeId=[[dataSourceElement stringValue] intValue];
            UniverseDetailsViewControllerSolo *unvDetail=[[UniverseDetailsViewControllerSolo alloc] init];
            unvDetail.universe=universe;
            unvDetail.universe.session=_currentSession;
            [self.navigationController pushViewController:unvDetail animated:YES];

        }
        
        
        
        else if(opCode==OP_SAVE_DOCUMENT){
            NSLog(@"Document Saved");
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





@end
