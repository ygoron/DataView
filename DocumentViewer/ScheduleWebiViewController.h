//
//  ScheduleWebiViewController.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-03-10.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "BIScheduleDocument.h"
@class Document;


@interface ScheduleWebiViewController : UITableViewController <BIScheduleDocumentDelegate>
@property(strong, nonatomic) Document *document;
@property (strong, nonatomic) IBOutlet UIButton *scheduleDocumentButton;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segmentedControlFormat;


- (IBAction)scheduleDocumentTouch:(id)sender;
@end


