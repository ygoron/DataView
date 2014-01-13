//
//  UniversesListViewController.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-03-30.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BIGetUniverses.h"
#import "CoreDataHelper.h"
#import "BI4RestConstants.h"
#import "UniverseCell.h"

@class UniversesListViewController;

@protocol UniversesListViewControllerDelegate <NSObject>
-(void) UniversesListViewController: (UniversesListViewController *) controller didSelectUniverse: (Universe *) universe;
@end

@interface UniversesListViewController : UITableViewController <BIGetUniversesDelegate>

{
    
    NSManagedObjectContext *context;
    UIActivityIndicatorView *spinner;
    int offset;
    BOOL isDataLoded;
    BOOL isNoMoreDocumentsLeft;
    
}

@property (nonatomic, strong) NSMutableArray *sessions;
@property (nonatomic, strong) NSMutableArray *universes;
@property (nonatomic, assign) BOOL isWebiCreation;
@property (nonatomic, weak) id <UniversesListViewControllerDelegate> delegate;
- (IBAction)refreshUniverseList:(id)sender;


@end


