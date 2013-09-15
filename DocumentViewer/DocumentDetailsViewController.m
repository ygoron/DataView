//
//  DocumentDetailsViewController.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-02-28.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import "DocumentDetailsViewController.h"
#import "DocumentDetailsCell.h"
#import "Report.h"
#import "BIGetDocumentDetails.h"
#import "BIGetReports.h"
#import "ReportViewController.h"
#import "ScheduleDetailViewController.h"
#import "ScheduleWebiViewController.h"
#import "TitleLabel.h"
#import "WebiAppDelegate.h"
#import "BILogoff.h"
#import "OpenDocumentViewController.h"
#import "BrowserMainViewController.h"
#import "BI4RestConstants.h"
#import "SharedUtils.h"
@interface DocumentDetailsViewController ()


@end


@implementation DocumentDetailsViewController


{
    
    
    NSManagedObjectContext *context;
    WebiAppDelegate *appDelegate;
    UIActivityIndicatorView *spinner;
    BOOL isDocumentRefreshing;
    BOOL isReportsRefreshing;
    int openDocumentId;
    Session *activeSession;
    BOOL isOpenWholeDocument;
    Document *documentToOpen;
    ReportExportFormat exportFormat;
    
    
}
@synthesize isInstance;
@synthesize actionButton;
@synthesize actionSheet=_actionSheet;
@synthesize picVisible;
@synthesize isExternalFormat;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        isInstance=NO;
        isOpenWholeDocument=NO;
        documentToOpen=nil;
        exportFormat=FormatPDF;
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    UIImage *backgroundImage = [UIImage imageNamed:@"leather-background.png"];
    UIColor *backgroundPattern= [UIColor colorWithPatternImage:backgroundImage];
    [self.tableView setBackgroundColor:backgroundPattern];
    
    
    UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    background.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"leather-background.png"]];
    self.tableView.backgroundView = background;
    
    TitleLabel *titelLabel=[[TitleLabel alloc] initWithFrame:CGRectZero];
    self.navigationItem.titleView = titelLabel;
    titelLabel.text=self.document.name;
    [titelLabel sizeToFit];
    
    
    
    activeSession=_document.session;
    appDelegate = (id)[[UIApplication sharedApplication] delegate];
    context = [appDelegate managedObjectContext];
    
    spinner = [[UIActivityIndicatorView alloc]  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin);
    spinner.center = CGPointMake(self.tableView.bounds.size.width / 2.0f, self.tableView.bounds.size.height / 2.0f);
    
    [self.view addSubview:spinner];
    
    if (self.document.session.opendocServer!=nil){
        UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                   target:self
                                                                                   action:@selector(performAction:)];
        
        [self.navigationItem setRightBarButtonItem:barButton animated:NO];
        self.actionButton = barButton;
        [self.actionButton setEnabled:NO];
    }
    self.picVisible = NO;
    
    //self.title=self.document.name;
    [self loadDocumentDetails];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void) viewWillAppear:(BOOL)animated{
    [SharedUtils adjustLabelLeftMarginForIpadForBoldFontInTableView:self.tableView];
    [SharedUtils adjustRighMarginsForIpad:self.tableView.constraints];
    [super viewWillAppear:animated];
}


#pragma mark Load Document Details from BOE
-(void) loadDocumentDetails{
    
    if (self.document!=nil);
    [spinner startAnimating];
    
    isDocumentRefreshing=YES;
    BIGetDocumentDetails *biGetDocumentDetails=[[BIGetDocumentDetails alloc] init];
    biGetDocumentDetails.delegate=self;
    biGetDocumentDetails.isInstance=isInstance;
    [biGetDocumentDetails getDocumentDetailForDocument:self.document];
    
    
    
    
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    if (section==1) return 0;
    else if(section==2) return 0;
	return 44.0;
}

//-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    UILabel *label = [self getHeaderLabel];
//    if (section==0){
//
//        if (self.document.descriptiontext==nil)
//            label.text=self.document.name;
//        else
//            label.text=self.document.descriptiontext;
//        return label;
//    }else
//        //           {
//        //                label.text= @"Document Reports";
//        //            }
//        return nil;
//
//}

-(UILabel *) getHeaderLabel{
    
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor=[UIColor clearColor];
    label.shadowColor=[UIColor clearColor];
    label.textAlignment=NSTextAlignmentCenter;
    label.highlightedTextColor = [UIColor whiteColor];
    label.font=[UIFont boldSystemFontOfSize:12];
    label.textColor= [UIColor grayColor];
    label.numberOfLines=0;
    //        label.frame=CGRectMake(0.0, 0.0, 300.0, 44.0);
    return label;
    
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section==0){
        if (self.document.descriptiontext==nil){
            return self.document.name;
        }
        else return self.document.descriptiontext;
    }
    if (section==3) return NSLocalizedString(@"Reports",nil);
    else return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([indexPath section]==0) return 140;
    else return 44;
}

#pragma mark Received Reports

-(void) biGetReports:(BIGetReports *)biGetReports isSuccess:(BOOL)isSuccess reports:(NSMutableArray *)receivedReports{
    
    
    isReportsRefreshing=NO;
    if (isDocumentRefreshing==NO) {
        [spinner stopAnimating];
        [self.actionButton setEnabled:YES];
        NSLog(@"Both requestes Finished. Get Document Details First");
        //        [self logoOffIfNeeded];
        NSLog(@"Finishing Loading DocumentDetails 2");
        
        //        [self logoOffIfNeeded];
    }
    self.document.reports=[NSSet setWithArray:receivedReports];
    
    
    [self.tableView reloadData];
}
#pragma mark Received Documents

-(void) biGetDocumentDetails:(BIGetDocumentDetails *)biGetDocumentDetails isSuccess:(BOOL)isSuccess document:(Document *)receivedDocument{
    
    
    if (self.isExternalFormat==NO){
        isReportsRefreshing=YES;
        [self.actionButton setEnabled:NO];
        BIGetReports *biGetReports=[[BIGetReports alloc]init];
        biGetReports.delegate=self;
        biGetReports.context=context;
        [biGetReports getReportsForDocument:self.document];
    }else{
        isReportsRefreshing=NO;
        [self.actionButton setEnabled:YES];
    }
    
    
    isDocumentRefreshing=NO;
    if (isReportsRefreshing==NO){
        NSLog(@"Both requestes Finished. Get Document Reports First");
        [spinner stopAnimating];
        //        [self logoOffIfNeeded];
        NSLog(@"Finishing Loading DocumentDetails 2");
        //        [self logoOffIfNeeded];
    }
    if (isSuccess==YES){
        NSLog(@"Document Loaded!");
        self.document=receivedDocument;
    }    else if (biGetDocumentDetails.connectorError!=nil){
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Load Document Details Failed",nil) message:[biGetDocumentDetails.connectorError localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
    }else if (biGetDocumentDetails.boxiError!=nil){
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Load Document Details Failed in BI",nil) message:biGetDocumentDetails.boxiError delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil, nil];
        [alert show];
        
    } else{
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Load Document Details Failed",nil) message:NSLocalizedString(@"Server Error",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil, nil];
        [alert show];
        
    }
    
    
    [self.tableView reloadData];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (self.isExternalFormat==NO)
        return 4;
    else return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section==0) return 1;
    else     if (section==1) return 1;
    else if (section==2) {
        if (!isInstance)return 1;
        else return 0; // Hide Historical Instance for Instance Detail
    }
    else if (section==3)  return [self.document.reports count];
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier1 = @"DocumentDetails_DocInfo";
    static NSString *CellIdentifier2 = @"ReportsList_Ident";
    static NSString *CellIdentifier3 = @"HistoricalInstances_Ident";
    static NSString *CellIdentifier4 = @"DocumentDetails_Static_Schedule";
    
    if (indexPath.section==0){
        DocumentDetailsCell *cell;
        if ([self.tableView respondsToSelector:@selector(dequeueReusableCellWithIdentifier:forIndexPath:)])
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1 forIndexPath:indexPath];
        else
            cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
        cell.documentIDLabel.text=[self.document.id stringValue];
        cell.documentNameLabel.text=[self.document name];
        cell.labelPath.text=[self.document path];
        cell.textViewPath.text= [self.document path];
        cell.labelCreated.text=self.document.createdby;
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MMM-dd HH:mm:ss"];
        cell.labelUpdated.text=[formatter stringFromDate:self.document.updated] ;
        cell.labelSize.text=[self.document.size stringValue];
        
        float redC=63.0/255;
        float greenC=114.0/255;
        float blueC=173.0/255;
        
        //        [[cell documentIDLabel]setTextColor:[UIColor colorWithRed:163.0/255 green:117.0/255 blue:89.0/255 alpha:1.0]];
        //        [[cell documentNameLabel]setTextColor:[UIColor colorWithRed:163.0/255 green:117.0/255 blue:89.0/255 alpha:1.0]];
        //        [[cell labelPath]setTextColor:[UIColor colorWithRed:163.0/255 green:117.0/255 blue:89.0/255 alpha:1.0]];
        //        [[cell labelCreated]setTextColor:[UIColor colorWithRed:163.0/255 green:117.0/255 blue:89.0/255 alpha:1.0]];
        //        [[cell labelUpdated]setTextColor:[UIColor colorWithRed:163.0/255 green:117.0/255 blue:89.0/255 alpha:1.0]];
        //        [[cell labelSize]setTextColor:[UIColor colorWithRed:163.0/255 green:117.0/255 blue:89.0/255 alpha:1.0]];
        //        [[cell textViewPath]setTextColor:[UIColor colorWithRed:163.0/255 green:117.0/255 blue:89.0/255 alpha:1.0]];
        
        [[cell documentIDLabel]setTextColor:[UIColor colorWithRed:redC green:greenC blue:blueC alpha:1.0]];
        [[cell documentNameLabel]setTextColor:[UIColor colorWithRed:redC green:greenC blue:blueC alpha:1.0]];
        [[cell labelPath]setTextColor:[UIColor colorWithRed:redC green:greenC blue:blueC alpha:1.0]];
        [[cell labelCreated]setTextColor:[UIColor colorWithRed:redC green:greenC blue:blueC alpha:1.0]];
        [[cell labelUpdated]setTextColor:[UIColor colorWithRed:redC green:greenC blue:blueC alpha:1.0]];
        [[cell labelSize]setTextColor:[UIColor colorWithRed:redC green:greenC blue:blueC alpha:1.0]];
        [[cell textViewPath]setTextColor:[UIColor colorWithRed:redC green:greenC blue:blueC alpha:1.0]];
        
        
        return cell;
        
    }else
        if (indexPath.section==3){
            UITableViewCell *cell;
            if ([self.tableView respondsToSelector:@selector(dequeueReusableCellWithIdentifier:forIndexPath:)])
                cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2 forIndexPath:indexPath];
            else
                cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier2];
            
            Report *report=[[self.document.reports allObjects] objectAtIndex:[indexPath row]];
            //cell.labelReportName.text=report.name;
            cell.textLabel.text=report.name;
            //            [[cell textLabel]setTextColor:[UIColor colorWithRed:163.0/255 green:117.0/255 blue:89.0/255 alpha:1.0]];
            
            return cell;
        }else if (indexPath.section==2){
            DocumentCell *cell;
            if ([self.tableView respondsToSelector:@selector(dequeueReusableCellWithIdentifier:forIndexPath:)])
                cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier3 forIndexPath:indexPath];
            else
                cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier3 ];
            
            //            [[cell textLabel]setTextColor:[UIColor colorWithRed:163.0/255 green:117.0/255 blue:89.0/255 alpha:1.0]];
            
            return cell;
            
        }else if(indexPath.section==1){
            //DocumentCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier4 forIndexPath:indexPath];
            UITableViewCell *cell;
            if ([self.tableView respondsToSelector:@selector(dequeueReusableCellWithIdentifier:forIndexPath:)])
                cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier4 forIndexPath:indexPath];
            else
                cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier4];
            if (isInstance) cell.textLabel.text=NSLocalizedString(@"Re-Schedule",nil);
            else cell.textLabel.text=NSLocalizedString(@"Schedule",nil);
            //            [[cell textLabel]setTextColor:[UIColor colorWithRed:163.0/255 green:117.0/255 blue:89.0/255 alpha:1.0]];
            
            return cell;
            
        }else{
            UITableViewCell *cell;
            if ([self.tableView respondsToSelector:@selector(dequeueReusableCellWithIdentifier:forIndexPath:)])
                cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier4 forIndexPath:indexPath];
            else
                cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier4];
            //            [[cell textLabel]setTextColor:[UIColor colorWithRed:163.0/255 green:117.0/255 blue:89.0/255 alpha:1.0]];
            
            return cell;
        }
    
    
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


- (void)performAction:(id)sender {
    
    NSLog(@"Perform Action");
    
    if ([self.actionSheet isVisible]) {
        [self.actionSheet dismissWithClickedButtonIndex:-1 animated:NO];
        
    } else if ([self isPicVisible]) {
        UIPrintInteractionController *pc = [UIPrintInteractionController sharedPrintController];
        [pc dismissAnimated:YES];
        self.picVisible = NO;
        
    } else {
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            
            [self.actionSheet showFromBarButtonItem:self.actionButton animated:NO];
            
        } else {
            
            //            [self.actionSheet showInView:[self view]];
            UITabBarController *tabBarController =(UITabBarController *)self.tableView.window.rootViewController;
            [self.actionSheet showFromTabBar: tabBarController.tabBar];
        }
	}
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (actionSheet.cancelButtonIndex==buttonIndex) return ;
    switch (buttonIndex) {
            //        case 0:
            //            [self openInBrowser];
            //            break;
            
            
        case 0:
            [TestFlight passCheckpoint:@"View Webi in OpenDoc Action"];
            [self openInSafari];
            break;
            
        case 1:
            [TestFlight passCheckpoint:@"View Document in PDF"];
            [self exportDocumentWithFormat: FormatPDF];
            break;
        case 2:
            [TestFlight passCheckpoint:@"Export to Excel"];
            [self exportDocumentWithFormat: FormatEXCEL];
            break;
            
            
            
        default:
            break;
    }
}
-(void) exportDocumentWithFormat: (ReportExportFormat) format
{
    
    //    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
    //    ReportViewController *rvc = (ReportViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"ReportView"];
    
    isOpenWholeDocument=YES;
    documentToOpen=_document;
    //    rvc.exportFormat=FormatPDF;
    exportFormat=format;
    //    [self.navigationController pushViewController:rvc animated:YES];
    [self performSegueWithIdentifier:@"ExportReport_Ident" sender:self];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog (@"Seque: %@",segue.identifier);
    
    [TestFlight passCheckpoint:[NSString stringWithFormat:@"%@%@",@"Webi Document Action:",segue.identifier]];
    
	if ([segue.identifier isEqualToString:@"ExportReport_Ident"])
        
	{
        UINavigationController *nav=segue.destinationViewController;
        ReportViewController    *reportExportView =[nav.viewControllers objectAtIndex:0];
        
        if (!isOpenWholeDocument==YES){
            //        ReportViewController    *reportExportView =segue.destinationViewController;
            reportExportView.exportFormat=FormatPDF;
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            reportExportView.report=[[self.document.reports allObjects] objectAtIndex:[indexPath row]];
            reportExportView.titleText=reportExportView.report.name;
        }
        else {
            reportExportView.isOpenWholeDocument=isOpenWholeDocument;
            reportExportView.document=documentToOpen;
            reportExportView.exportFormat=exportFormat;
            reportExportView.titleText=documentToOpen.name;
        }
        isOpenWholeDocument=NO;
	}else if ([segue.identifier isEqualToString:@"ScheduleDetail_Ident"]){
        ScheduleDetailViewController *scheduleDetail= segue.destinationViewController;
        scheduleDetail.document=self.document;
        
    }else if ([segue.identifier isEqualToString:@"ShowScheduleScene_Ident"]){
        ScheduleWebiViewController *scheduleWebi= segue.destinationViewController;
        scheduleWebi.document=self.document;
        
    }
    
    
}

- (void)printInteractionControllerDidPresentPrinterOptions:(UIPrintInteractionController *)printInteractionController {
    self.picVisible = YES;
}

- (void)printInteractionControllerDidDismissPrinterOptions:(UIPrintInteractionController *)printInteractionController {
    self.picVisible = NO;
}


-(void) openInSafari
{
    //    Session *session=self.document.session;
    
    //    int documentId=[self.document.id intValue];
    
    if ([appDelegate.globalSettings.autoLogoff boolValue]==YES) [self createTokenAndLaunchOpenDocWithSession:activeSession forDocument:_document];
    else [self launchOpenDocWithSession:activeSession forDocument:_document];
    
}

-(void) launchOpenDocWithSession:(Session *)session2 forDocument:(Document *) document
{
    
#ifdef Trace
    NSString *encodedToken = (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                          (__bridge CFStringRef)activeSession.cmsToken,
                                                                                          NULL,
                                                                                          (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                          kCFStringEncodingUTF8);
    
    //    NSString *encodedToken=[session.cmsToken stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"Simple Token:%@",activeSession.cmsToken);
    NSLog(@"Encoded Token:%@",encodedToken);
#endif
    
    //    NSString *openDocumentURL;
    
    //    if (activeSession.isHttps==[NSNumber numberWithBool:YES])
    //        openDocumentURL=[NSString stringWithFormat:@"https://%@:%@/BOE/OpenDocument/opendoc/openDocument.jsp?iDocID=%d",activeSession.opendocServer,activeSession.opendocPort,id];
    //    else  openDocumentURL=[NSString stringWithFormat:@"http://%@:%@/BOE/OpenDocument/opendoc/openDocument.jsp?iDocID=%d",activeSession.opendocServer,activeSession.opendocPort,id];
    
    
    NSURL *urlSelected=[BrowserMainViewController buildUrlFromSession:appDelegate.activeSession forEntity:[NSString stringWithFormat:@"%@%d",infoStorePoint,_document.id.intValue ] withPageSize:[appDelegate.globalSettings.fetchDocumentLimit intValue]];
    
    OpenDocumentViewController *opdv=[[OpenDocumentViewController alloc] init];
    
    if (self.isInstance && self.isExternalFormat){
        
        BOOL isPOC=YES;
        if (isPOC==NO){
            
            opdv.selectedObjectUrl=urlSelected;
            opdv.cmsToken=activeSession.cmsToken;
            opdv.currentSession=activeSession;
            opdv.isGetOpenDocRequired=NO;
            opdv.isOpenDocumentManager=YES;
            opdv.objectId=document.id;
        }
        else{
            //********************************** POC REMOVE/CONTINUE *****************************************
            NSLog (@"POC of Apos Extension Pack");
            NSString *pocUrlString=[NSString stringWithFormat:@"%@%d", @"http://win-bi41rampup:8080/AposMobileServices/instance.content/",document.id.intValue];
            NSURL *pocUrl=[[NSURL alloc] initWithString:pocUrlString];
            
            opdv.openDocUrl=pocUrl;
            opdv.selectedObjectUrl=urlSelected;
            opdv.cmsToken=activeSession.cmsToken;
            opdv.currentSession=activeSession;
            opdv.isGetOpenDocRequired=NO;
            opdv.isOpenDocumentManager=NO;
            opdv.objectId=document.id;
            
            
        }
    }
    
    
    else if (urlSelected) {
        NSLog(@"URL Selected: %@", urlSelected);
        
        //            NSURL *openDocUrl=[NSURL URLWithString: [NSString stringWithFormat:@"%@",_selectedObject.openDoc]];
        //        opdv.openDocUrl=urlSelected;
        opdv.selectedObjectUrl=urlSelected;
        opdv.cmsToken=activeSession.cmsToken;
        opdv.currentSession=activeSession;
        opdv.isGetOpenDocRequired=YES;
        opdv.isOpenDocumentManager=NO;
    }
    
    [self.navigationController pushViewController:opdv animated:YES];
    
    
}
-(void) createTokenAndLaunchOpenDocWithSession:(Session *)session forDocument: (Document *) document;
{
    BIConnector *biConnector=[[BIConnector alloc]init];
    openDocumentId=[document.id intValue];
    biConnector.delegate=self;
    [biConnector getCmsTokenWithSession:session];
    
}

-(void) biConnector:(BIConnector *)biConnector didCreateCmsToken:(NSString *)cmsToken forSession:(Session *)session
{
    NSLog(@"Token Created: for Session%@",session);
    [self launchOpenDocWithSession:session forDocument: _document];
}


- (UIActionSheet *)actionSheet {
    
    if (_actionSheet == nil) {
        
        NSString *cancelButtonTitle = NSLocalizedString(@"Cancel",nil);
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            cancelButtonTitle = nil;
        }
        
        NSLog(@"Reports: %d",_document.reports.count);
        //        if (_document.reports.count>0){
        if (self.isExternalFormat==NO){
            _actionSheet = [[UIActionSheet alloc]
                            initWithTitle:nil
                            delegate:self
                            cancelButtonTitle:cancelButtonTitle
                            destructiveButtonTitle:nil
                            otherButtonTitles:NSLocalizedString(@"Open Document",@"Use Open Document Call to View document"), NSLocalizedString(@"View Document in PDF",@"Export Document in PDF"),NSLocalizedString(@"Export to Excel",@"Export Document to Excel"),nil];
        }else{
            _actionSheet = [[UIActionSheet alloc]
                            initWithTitle:nil
                            delegate:self
                            cancelButtonTitle:cancelButtonTitle
                            destructiveButtonTitle:nil
                            otherButtonTitles:NSLocalizedString(@"Open Document",@"Use Open Document Call to View document"), nil];
            
        }
    }
    
    return _actionSheet;
}


- (void)viewWillDisappear:(BOOL)animated {
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        if ([self isPicVisible]) {
            //            UIPrintInteractionController *pc = [UIPrintInteractionController sharedPrintController];
            //            [pc dismissAnimated:animated];
            self.picVisible = NO;
        }
        
        if ([self.actionSheet isVisible]) {
            [self.actionSheet dismissWithClickedButtonIndex:-1 animated:NO];
        }
    }
}

-(void) logoOffIfNeeded{
    if ([appDelegate.globalSettings.autoLogoff integerValue]==1){
        if (self.document.session!=nil && self.document.session.cmsToken!=nil){
            [self logoffWithSession:self.document.session];
        }
    }
    
}
-(void) logoffWithSession:(Session *)session{
    if (session.cmsToken!=nil){
        BILogoff *biLogoff=[[BILogoff alloc] init];
        [biLogoff logoffSession:session withToken:session.cmsToken];
        NSLog(@"Logoff Session:%@",session.name);
    }
    
}


- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
