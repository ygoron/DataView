//
//  PreferencesViewController.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-04-21.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PreferencesViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UITextField *textFetchSize;
@property (strong, nonatomic) IBOutlet UISlider *sliderFetch;
@property (strong, nonatomic) IBOutlet UITextField *textTimeout;

@property (strong, nonatomic) IBOutlet UISwitch *savePasswordSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *logoffInBackgrndSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *showUniversesSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *autoLogoffSwitch;

- (IBAction)sliderValueChanged:(id)sender;
- (IBAction)fetchSizeEditEnded:(id)sender;
- (IBAction)refreshUniverseTab:(id)sender;

@end
