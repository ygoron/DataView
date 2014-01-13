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

@interface SelectWebiFieldsViewController : UITableViewController <BIGetUniverseDetailsDelegate>

@property (nonatomic,strong) Universe *universe;
@property (nonatomic, strong) NSMutableArray *unvDetails;
-(void) loadUniverseDetails;
-(void) fillArrayOfFieldbjects: (NSDictionary *) sourceDictionary resultArray:(NSMutableArray *) resultArray withPath:(NSString *) path;

@end
