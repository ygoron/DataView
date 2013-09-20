//
//  ExtensionPackViewController.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-09-16.
//  Copyright (c) 2013 APOS Systems. All rights reserved.
//

#import "ExtensionPackViewController.h"
#import "TitleLabel.h"
#import "WebiAppDelegate.h"
#import "SessionInfo.h"

@interface ExtensionPackViewController ()

@end

@implementation ExtensionPackViewController
{
    UIGestureRecognizer *tapper;
    BIConnector *connector;
    NSManagedObjectContext *context;
    WebiAppDelegate *appDelegate;
    UIActivityIndicatorView *spinner;
    ExtensionPack *extensionPack;
    
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
    
    
    UIImage *backgroundImage = [UIImage imageNamed:@"leather-background.png"];
    UIColor *backgroundPattern= [UIColor colorWithPatternImage:backgroundImage];
    [self.tableView setBackgroundColor:backgroundPattern];
    
    
    UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    background.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"leather-background.png"]];
    self.tableView.backgroundView = background;
    
    
    tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    [self.view addGestureRecognizer:tapper];
    tapper.cancelsTouchesInView = FALSE;
    
    TitleLabel *titelLabel=[[TitleLabel alloc] initWithFrame:CGRectZero];
    self.navigationItem.titleView = titelLabel;
    titelLabel.text=NSLocalizedString(@"Extension Pack Settings",nil);
    [titelLabel sizeToFit];
    
    
    spinner = [[UIActivityIndicatorView alloc]  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin);
    spinner.center = CGPointMake(self.tableView.bounds.size.width / 2.0f, self.tableView.bounds.size.height / 2.0f);
    [self.view addSubview:spinner];

    appDelegate = (id)[[UIApplication sharedApplication] delegate];
    context = [appDelegate managedObjectContext];
    
    [TestFlight passCheckpoint:@"Extension Pack Settings"];
    [self loadValues];
}

-(void) loadValues
{
    NSLog(@"Is Extension Pack:%d",[_session.isExtensionPack boolValue]);
    [_switchFieldIsEnabled setOn:[_session.isExtensionPack boolValue]];
    if (_session.extensionPackUrl!=nil) _textFieldUrl.text=_session.extensionPackUrl;
    
}
-(void) storeValues
{
    _session.extensionPackUrl=_textFieldUrl.text;
    _session.isExtensionPack = [NSNumber numberWithBool:_switchFieldIsEnabled.isOn];
}
-(void) viewWillDisappear:(BOOL)animated
{
    [self storeValues];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//    }
//
//    // Configure the cell...
//
//    return cell;
//}

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
    
    NSLog(@"%@",indexPath);
    if (indexPath.section==0 && indexPath.row==2){
        [self testConnection];
        NSLog(@"Check Connection to Extension Pack  With Session: %@",_session);
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES ];
        
        
    }
    
    
    //    // Navigation logic may go here, for example:
    //    // Create the next view controller.
    //    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
    //
    //    // Pass the selected object to the new view controller.
    //
    //    // Push the view controller.
    //    [self.navigationController pushViewController:detailViewController animated:YES];
}

#pragma mark Test Connection

- (void)testConnection{
    NSLog(@"Test Connection");
    connector=[[BIConnector alloc]init];
    connector.timeOut=10;
    [spinner startAnimating];

    
    // Get Token First
    if (_session.cmsToken==nil || _session.password==nil){
        NSLog(@"CMS Token is NULL - create new one");

    }else{
        NSLog(@"CMS Token is NOT NULL - Process With Logoff First");
        BILogoff *biLogoff=[[BILogoff alloc] init];
        biLogoff.biSession=_session;
        [biLogoff logoffSessionSync:_session withToken:_session.cmsToken];
    }

    
    connector=[[BIConnector alloc]init];
    connector.delegate=self;
    [connector getCmsTokenWithSession:_session];

}

#pragma mark Token Created

-(void) biConnector:(BIConnector *)biConnector didCreateCmsToken:(NSString *)cmsToken forSession:(Session *)session{
    NSLog (@"Got Token: %@",cmsToken);
    [spinner stopAnimating];
    if (cmsToken!=nil){
        _session.cmsToken=cmsToken;
        extensionPack =[[ExtensionPack alloc] init];
        extensionPack.delegate=self;
        [extensionPack getExtensionPackInfoWithToken:cmsToken forExtensionPackUrl:_textFieldUrl.text];
        
        
    }else if (biConnector.connectorError!=nil){
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connection Test Failed",nil) message:[biConnector.connectorError localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil, nil];
        [alert show];
        
    }else if (biConnector.boxiError!=nil){
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connection Test Failed in BI",nil) message:biConnector.boxiError delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil, nil];
        [alert show];
        
    } else{
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connection Test Failed",nil) message:NSLocalizedString(@"Server Error",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil, nil];
        [alert show];
        
    }
    
    //    [context deleteObject:biConnector.biSession];
    
    
}

-(void) ExtensionPack:(ExtensionPack *)extensionPack didGetSessionInfo:(SessionInfo *)extensionPackSessionInfo forToken:(NSString *)cmsToken withError:(NSString *)error withSuccess:(BOOL)isSuccess
{
    [spinner stopAnimating];
    NSLog(@"Returned from Extension is Success %d",isSuccess);

    if (isSuccess==YES){
//        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connection Test",nil) message:NSLocalizedString(@"Success!",nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil, nil];


        NSString *succesText =[NSString stringWithFormat:@"%@%@%@%d%@%@%@",NSLocalizedString(@"Success!", nil),@"\n",NSLocalizedString(@"BI Platform Build:", nil),extensionPackSessionInfo.biPlatformVersion,@"\n",NSLocalizedString(@"Extension Pack Version:", nil),extensionPackSessionInfo.mobileServiceVersion];
//        
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connection Test",nil) message:succesText delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil, nil];

        [alert show];
        
    }else{
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Connection Test Failed",nil) message:error delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",nil) otherButtonTitles:nil, nil];
        [alert show];
        
    }

    

}

#pragma mark Logoff Completed

-(void)biLogoff:(BILogoff *)biLogoff didLogoff:(BOOL)isSuccess{
    NSLog(@"Logoff Success? %d",isSuccess);
//    [context deleteObject:testSession];
    
}



- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    NSLog(@"Hanlde Single Tap");
    [self.view endEditing:YES];
}


@end
