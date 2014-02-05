//
//  SelectWebiFieldsViewController.h
//  DocumentViewer
//
//  Created by Yuri Goron on 1/12/2014.
//  Copyright (c) 2014 APOS Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Universe.h"
#import "BIGetUniverseDetails.h"

@class SelectWebiFieldsViewController;

@protocol SelectWebiFieldsDelegate <NSObject>

-(void) webiFieldsSelected: (SelectWebiFieldsViewController *) controller withSelectedFields: (NSArray *) selectedWebiFields forDataProviderId:(NSString *) dataProviderId;

@end
@interface SelectWebiFieldsViewController : UITableViewController <BIGetUniverseDetailsDelegate>

@property (nonatomic,strong) Universe *universe;
@property (nonatomic,strong) NSString *dataproviderId;

@property (nonatomic, strong) NSMutableArray *unvDetails;
@property (nonatomic,strong) NSArray *selectedQueryFields;


-(void) loadUniverseDetails;
-(void) fillArrayOfFieldbjects: (NSDictionary *) sourceDictionary resultArray:(NSMutableArray *) resultArray withPath:(NSString *) path;

@property (nonatomic, weak) id <SelectWebiFieldsDelegate> delegate;

@end
