//
//  SelectReportFieldsViewController.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2/1/2014.
//  Copyright (c) 2014 APOS Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SelectReportFieldsViewController;

@protocol SelectReportFieldsDelegate <NSObject>

-(void) reportFieldsSelected: (SelectReportFieldsViewController *) controller withSelectedFields: (NSArray *) selectedWebiFields ;

@end

@interface SelectReportFieldsViewController : UITableViewController

@property (nonatomic,strong) NSArray *selectedQueryFields;
@property (nonatomic,strong) NSArray *availableQueryFields;
@property (nonatomic, assign) int reportId;

@property (nonatomic, weak) id <SelectReportFieldsDelegate> delegate;


@end
