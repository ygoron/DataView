//
//  UniverseDetailsViewController.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-03-31.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Universe.h"
#import "BIGetUniverseDetails.h"
#import "UniverseDetailsCell.h"
@interface UniverseDetailsViewController : UITableViewController <BIGetUniverseDetailsDelegate>
{
    UIActivityIndicatorView *spinner;
    
}

@property (nonatomic, strong) Universe *universe;
@property (nonatomic, strong) NSMutableArray *unvDetails;
-(void) loadUniverseDetails;

-(UniverseDetailsCell*) setUniverseCell: (UniverseDetailsCell*) sourceCell withDictionary:(NSDictionary *) dictionary;

@end
