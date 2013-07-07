//
//  ScheduleDetailViewController.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-03-04.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Document.h"
#import "BIGetScheduleDetail.h"
#import "BIDeleteDocument.h"

@interface ScheduleDetailViewController : UITableViewController <BIGetScheduleDetailDelegate,BIDeleteDocumentDelegate>
@property (nonatomic,strong) Document *document;
@property (nonatomic, strong) NSMutableArray *scheduleDetailsArray;
@end

NSManagedObjectContext *context;



