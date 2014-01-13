//
//  DataProviderSelectorViewController.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-12-12.
//  Copyright (c) 2013 APOS Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDataXMLNode.h"
#import "UniversesListViewController.h"

@class DataProviderSelectorViewController;

@protocol DataProviderSelectorDelegate <NSObject>

-(void) DataProviderSelectorViewController: (DataProviderSelectorViewController *) controller didFinishEditingWithQueryName: (NSString *) queryName UniverseId:(int) universeId ;

@end


@interface DataProviderSelectorViewController : UITableViewController <UniversesListViewControllerDelegate>

@property (strong, nonatomic) NSString *placeHolderText;
@property (strong, nonatomic) UILabel *valueLabel;
@property (strong, nonatomic) NSString *defaultValue;
@property (strong, nonatomic) GDataXMLDocument *dataprovidersXml;



@property (nonatomic, weak) id <DataProviderSelectorDelegate> delegate;

@end
