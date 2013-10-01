//
//  BrowserObjectActionsViewController.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-05-17.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import "BrowserObjectActionsViewController.h"
#import "WebiAppDelegate.h"
#import "TitleLabel.h"
#import "BISDKCall.h"
#import "ObjectInfoCell.h"
#import "ActionCell.h"
#import "Action.h"
#import "ObjectInfo.h"
#import "DescriptionAndPathCell.h"
#import "BrowserChildViewController.h"
#import "OpenDocumentViewController.h"
#import "BICypressSchedule.h"
#import "ScheduleUrl.h"
#import "DashboardViewController.h"
#import "Utils.h"

@interface BrowserObjectActionsViewController ()

@end

@implementation BrowserObjectActionsViewController

{
    
    UIActivityIndicatorView *spinner;
    WebiAppDelegate *appDelegate;
    NSMutableArray *actions;
    NSMutableArray *objectInfos;
    NSMutableArray *descAndPaths;
    BICypressSchedule *biSchedule;
    SystemSoundID soundID;
    
    
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
    
    
    UINib *nib=[UINib nibWithNibName:@"ObjectInfoCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"ObjectInfoCell"];
    
    nib=[UINib nibWithNibName:@"ActionCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"ActionCell"];
    
    nib=[UINib nibWithNibName:@"DescriptionAndPath" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"DescriptionAndPath"];
    
    
    
    
    
    spinner = [[UIActivityIndicatorView alloc]  initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.autoresizingMask = (UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin);
    spinner.center = CGPointMake(self.tableView.bounds.size.width / 2.0f, self.tableView.bounds.size.height / 2.0f);
    [self.view addSubview:spinner];
    
    if ([UIRefreshControl class]){
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.attributedTitle=[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Pull To Refresh Objects List",nil)];
        self.refreshControl = refreshControl;
        [refreshControl addTarget:self action:@selector(getObjectInfo) forControlEvents:UIControlEventValueChanged];
    }
    
    appDelegate= (id)[[UIApplication sharedApplication] delegate];
    
    biSchedule=[[BICypressSchedule alloc]init];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    
    
    //    _textViewInfo.text=@"Name: Root Folder\nDescription:This a top level folder\nCUID:jkdjkdjkdkjdkd\nid:dkldkldkl";
    
    TitleLabel *titelLabel=[[TitleLabel alloc] initWithFrame:CGRectZero];
    titelLabel.text=self.title;
    self.navigationItem.titleView = titelLabel;
    [titelLabel sizeToFit];
    
    
    
    UIBarButtonItem *refreshButton         = [[UIBarButtonItem alloc]
                                              initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                              target:self
                                              action:@selector(getObjectInfo)];
    
    self.navigationItem.rightBarButtonItems =
    [NSArray arrayWithObjects:refreshButton, nil];
    [self getObjectInfo];
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section==0){
        return _selectedObject.name;
    }
    else{
        return nil;
    }
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (section==0)
        return [descAndPaths count];
    else if (section==1)
        return  [objectInfos count];
    else
        return [actions count];
    
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) return 70;
    else     if (indexPath.section==1) return 44;
    else return 44;
}


-(void) getObjectInfo
{
    [spinner startAnimating];
    actions=[[NSMutableArray alloc] initWithCapacity:10];
    objectInfos=[[NSMutableArray alloc] initWithCapacity:10];
    descAndPaths=[[NSMutableArray alloc] initWithCapacity:10];
    
    BISDKCall *biCallSelected=[[BISDKCall alloc]init];
    biCallSelected.delegate=self;
    biCallSelected.biSession=_currentSession;
    biCallSelected.isFilterByUserName=NO;
    [biCallSelected getSelectedObjectForSession:_currentSession withUrl:_objectUrl];
    
}

-(void) cypressCallForChildren:(BISDKCall *)biSDKCall withResponse:(CypressResponseHeader *)response isSuccess:(BOOL)isSuccess withChildrenObjects:(NSArray *)receivedObjects{
    
}
-(void) cypressCallSelectedObject:(BISDKCall *)biSDKCall withResponse:(CypressResponseHeader *)response isSuccess:(BOOL)isSuccess withObject:(InfoObject *)receivedObject
{
    
    if (isSuccess==YES){
        if ([UIRefreshControl class]){
            [self.refreshControl endRefreshing];
        }
        
        [spinner stopAnimating];
        
        NSLog(@"Selected Object Received ID: %d",receivedObject.objectId);
        //        [TestFlight passCheckpoint:@"Selected Object Received"];
        _selectedObject=receivedObject;
        
        if (_selectedObject.childrenUrl!=nil){
            Action *action=[[Action alloc]init];
            action.name=NSLocalizedString(@"Instances",nil);
            action.description=NSLocalizedString(@"View List of Historical Instances/Schedules",nil);
            [actions addObject:action];
        }
        
        
        if (_selectedObject.latestInstanceUrl!=nil){
            Action *action=[[Action alloc]init];
            action.name=NSLocalizedString(@"View Latest Instance",nil);
            action.description=NSLocalizedString(@"View Latest Instance Using Open Document",nil);
            [actions addObject:action];
        }
        
        if (_selectedObject.openDoc!=nil){
            if (!([_selectedObject.type isEqualToString:@"Agnostic"]||[_selectedObject.type isEqualToString:@"FullClient"])){
                Action *action=[[Action alloc]init];
                action.name=NSLocalizedString(@"View",nil);
                if (_isInstance==YES)
                    action.description=NSLocalizedString(@"View Instance Using Open Document",nil);
                else
                    action.description=NSLocalizedString(@"View Object Using Open Document",nil);
                [actions addObject:action];
            }
        }
        if (_selectedObject.scheduleFormsUrl!=nil && ![_selectedObject.type isEqualToString:@"FullClient"]){
            
            Action *action=[[Action alloc]init];
            action.name=NSLocalizedString(@"Run Now",nil);
            action.description=NSLocalizedString(@"Schedule Object to Run now",nil);
            [actions addObject:action];
            
        }
        
        
        
        ObjectInfo *objectInfo=[[ObjectInfo alloc]init];
        objectInfo.name=NSLocalizedString(@"Type",nil);
        objectInfo.value=_selectedObject.type;
        [objectInfos addObject:objectInfo];
        
        if (_isInstance==YES){
            objectInfo=[[ObjectInfo alloc]init];
            objectInfo.name=NSLocalizedString(@"Instance",nil);
            objectInfo.value=@"Yes";
            [objectInfos addObject:objectInfo];
        }
        
        
        objectInfo=[[ObjectInfo alloc]init];
        objectInfo.name=@"Id";
        objectInfo.value=[NSString stringWithFormat:@"%d",_selectedObject.objectId];
        [objectInfos addObject:objectInfo];
        
        
        
        objectInfo=[[ObjectInfo alloc]init];
        objectInfo.name=@"Cuid";
        objectInfo.value=_selectedObject.cuid;
        [objectInfos addObject:objectInfo];
        
        
        
        objectInfo=[[ObjectInfo alloc]init];
        objectInfo.value=_path;
        [descAndPaths addObject:objectInfo];
        
        if (_selectedObject.description.length>0){
            objectInfo=[[ObjectInfo alloc]init];
            objectInfo.value=_selectedObject.description;
            [descAndPaths addObject:objectInfo];
        }
        
        
        NSLog(@"Property: %@",objectInfo.name);
        [self.tableView reloadData];
        
    }
    else {
        
        if (biSDKCall.connectorError!=nil){
            UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Load Selected Object Failed",nil) message:[biSDKCall.connectorError localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
        }else if (biSDKCall.boxiError!=nil){
            UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Load Selected Object Failed in BI",nil) message:biSDKCall.boxiError delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
        } else{
            UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Load Selected Object Failed",nil) message:@"Server Error" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
        }
    }
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section==0){
        
        static NSString *CellIdentifier = @"DescriptionAndPath";
        ObjectInfo *objectInfo=[descAndPaths objectAtIndex:indexPath.row];
        
        DescriptionAndPathCell *descAndPathCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (descAndPathCell == nil) {
            descAndPathCell = [[DescriptionAndPathCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        // Configure the cell...
        
        descAndPathCell.textViewMiscText.text=objectInfo.value;
        return descAndPathCell;
        
    }
    if (indexPath.section==1){
        static NSString *CellIdentifier = @"ObjectInfoCell";
        ObjectInfo *objectInfo=[objectInfos objectAtIndex:indexPath.row];
        
        ObjectInfoCell *objectInfoCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (objectInfoCell == nil) {
            objectInfoCell = [[ObjectInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        // Configure the cell...
        
        objectInfoCell.labelProperty.text=objectInfo.name;
        objectInfoCell.propertyValue.text=objectInfo.value;
        
        return objectInfoCell;
    }else if (indexPath.section==2){
        static NSString *CellIdentifier = @"ActionCell";
        ActionCell *actionCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (actionCell == nil) {
            actionCell = [[ActionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        Action *action=[actions objectAtIndex:[indexPath row]];
        actionCell.labelActionName.text=action.name;
        //        actionCell.labelActionDescription.text=action.description;
        if ([action.name isEqualToString:NSLocalizedString(@"Run Now",nil)]) {
            //            actionCell.labelActionName.textAlignment=NSTextAlignmentCenter;
            //            actionCell.labelActionDescription.textAlignment=NSTextAlignmentCenter;
            //         [actionCell setAccessoryType:UITableViewCellAccessoryNone];
            //            [actionCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        return actionCell;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==2){
        ActionCell *actionCell=(ActionCell*)[tableView cellForRowAtIndexPath:indexPath];
        [TestFlight passCheckpoint:[NSString stringWithFormat:@"%@%@",@"Action Selected:",actionCell.labelActionName.text]];
        if ([actionCell.labelActionName.text isEqualToString:NSLocalizedString(@"Instances",nil)]){
            BrowserChildViewController *vc=[[BrowserChildViewController alloc] initWithNibName:@"BrowserChildViewController" bundle:nil];
            NSURL *urlForChildren=[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%d",[_selectedObject.childrenUrl absoluteString],@"?pageSize=",[appDelegate.globalSettings.fetchDocumentLimit intValue] ]];
            //    NSLog("Children url: %@",_selectedObject.childrenUrl);
            //    NSURL *urlForChildren=_selectedObject.childrenUrl;
            vc.urlForChildren=urlForChildren;
            vc.currentSession=appDelegate.activeSession;
            vc.title=_selectedObject.name;
            vc.isInstance=YES;
            vc.displayPath=[NSString stringWithFormat:@"%@%@%@",_path,@"/",_selectedObject.name];
            [self.navigationController pushViewController:vc animated:YES];
            
        }else if ([actionCell.labelActionName.text isEqualToString:NSLocalizedString(@"View",nil)]){
            if (![_selectedObject.type isEqualToString:@"XL.XcelsiusEnterprise"]){
                NSLog (@"Open Document Call");
                OpenDocumentViewController *opdv=[[OpenDocumentViewController alloc] init];
                //            NSURL *openDocUrl=[NSURL URLWithString: [NSString stringWithFormat:@"%@",_selectedObject.openDoc]];
                opdv.openDocUrl=_selectedObject.openDoc;
                if (![_selectedObject.type isEqualToString:@"CrystalReport"])
                {
                    if ([appDelegate.activeSession.isExtensionPack boolValue]==NO || appDelegate.activeSession.extensionPackUrl==nil){
                        opdv.isOpenDocumentManager=YES;
                    }else{
                        
                        NSLog (@"Apos Extension Pack");
                        NSString *pocUrlString=[NSString stringWithFormat:@"%@%@%d", appDelegate.activeSession.extensionPackUrl, @"/instance.content/",_selectedObject.objectId];
                        NSURL *pocUrl=[[NSURL alloc] initWithString:pocUrlString];
                        
                        opdv.openDocUrl=pocUrl;
                        opdv.isOpenDocumentManager=NO;
                        
                    }
                    
                    
                }else{
                    opdv.isOpenDocumentManager=NO;
                }
                opdv.cmsToken=_currentSession.cmsToken;
                opdv.currentSession=_currentSession;
                opdv.isGetOpenDocRequired=NO;
                opdv.infoObject=_selectedObject;
                //                [self.navigationController pushViewController:opdv animated:YES];
                
                
                [opdv setTitle:_selectedObject.name];
                opdv.hidesBottomBarWhenPushed=YES;
                //                UINavigationController *nav = [[UINavigationController alloc]
                //                                               initWithRootViewController:opdv] ;
                //                [self presentViewController:nav animated:YES completion:NULL];
                [self.navigationController pushViewController:opdv animated:YES];
            }else{
                
                NSLog(@"DashBoard Viewer");
                DashboardViewController *dvc= [[DashboardViewController alloc] initWithNibName:@"DashboardViewController" bundle:nil];
                [dvc setDashboardCuid:_selectedObject.cuid];
                [dvc setTitle:_selectedObject.name];
                
                dvc.hidesBottomBarWhenPushed=YES;
                
                [self.navigationController  pushViewController:dvc animated:YES];
                //                UINavigationController *nav = [[UINavigationController alloc]
                //                                               initWithRootViewController:dvc];
                //
                //                [self presentViewController:nav animated:YES completion:NULL];
                
                
            }
            
            
        }else if ([actionCell.labelActionName.text isEqualToString:NSLocalizedString(@"View Latest Instance",nil)]){
            NSLog (@"Open Document Call -View Latest Instance. Latest instance Object. URL:%@",[_selectedObject.latestInstanceUrl absoluteString]);
            OpenDocumentViewController *opdv=[[OpenDocumentViewController alloc] init];
            NSURL *getOpenDocUrl=_selectedObject.latestInstanceUrl;
            opdv.openDocUrl=getOpenDocUrl;
            opdv.selectedObjectUrl=_selectedObject.latestInstanceUrl;
            opdv.cmsToken=_currentSession.cmsToken;
            opdv.currentSession=_currentSession;
            opdv.isGetOpenDocRequired=YES;
            
            //            UINavigationController *nav = [[UINavigationController alloc]
            //                                           initWithRootViewController:opdv];
            //
            [opdv setTitle:_selectedObject.name];
            opdv.hidesBottomBarWhenPushed=YES;
            
            //            [self presentViewController:nav animated:YES completion:NULL];
            
            [self.navigationController pushViewController:opdv animated:YES];
            
        }else if ([actionCell.labelActionName.text isEqualToString:NSLocalizedString(@"Run Now",nil)]){
            biSchedule.delegate=self;
            NSLog(@"Schedule For Current Session %@",_currentSession.name);
            [biSchedule getScheduleFormsWithUrl:_selectedObject.scheduleFormsUrl forSession:_currentSession];
            
        }
        
        
    }
    
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

-(void)availableSchedules:(BICypressSchedule *)biCypressSchedule withUrls:(NSArray *)urls isSuccess:(BOOL)isSucess{
    NSLog(@"Schedule Urls Received. Count: %d",urls.count);
    // Find Run Now URL
    if (isSucess){
        NSURL *runNowUrl;
        for (ScheduleUrl *scheduleUrl in urls) {
            if ([scheduleUrl.name isEqualToString:@"Now"]){
                runNowUrl=scheduleUrl.url;
                break;
            }
        }
        
        if (runNowUrl!=nil){
            NSArray *keys = [NSArray arrayWithObjects:@"retriesAllowed", @"retryIntervalInSeconds", nil];
            NSArray *objects = [NSArray arrayWithObjects:@"0", @"1800", nil];
            
            NSLog(@"Objects %@",objects);
            NSDictionary *jsonDictionary = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
            
            [biSchedule scheduleWithUrl:runNowUrl withData:jsonDictionary forSession:_currentSession];
        }
    }    else if (biSchedule.connectorError!=nil){
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Get Schedule Forms Failed",nil) message:[biSchedule.connectorError localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
    }else if (biSchedule.boxiError!=nil){
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Get Schedule Forms Failed in BI",nil) message:biSchedule.boxiError delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
    } else{
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Get Schedule Forms Failed",nil) message:NSLocalizedString(@"Server Error",nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
    }
    
    
}
-(void) scheduleResult:(BICypressSchedule *)biCypressSchedule withData:(NSDictionary *)data withUrl:(NSURL *)scheduleUrl isSuccess:(BOOL)isSucess
{
    NSLog(@"Return From Schedule: %@",data);
    if (isSucess){
        NSLog(@"Scheduled!");
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Schedule Report",nil) message:NSLocalizedString(@"Success!",@"Scheduled with success") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle]
                                                                                    pathForResource: @"ScheduleSound" ofType:@"wav"]], &soundID);
        AudioServicesPlaySystemSound(soundID);
        AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
        
        
    }        else if (biSchedule.connectorError!=nil){
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Schedule Failed",nil) message:[biSchedule.connectorError localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
    }else if (biSchedule.boxiError!=nil){
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Schedule Failed in BI",nil) message:biSchedule.boxiError delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
    } else{
        //        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Schedule Failed",nil) message:NSLocalizedString(@"Server Error",nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        UIAlertView *alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Schedule Failed",nil) message:[data valueForKey:@"message"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alert show];
        
    }
}
@end
