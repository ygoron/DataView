//
//  ReportEditorViewController.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2/9/2014.
//  Copyright (c) 2014 APOS Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Session.h"
#import "XMLRESTProcessor.h"

@interface ReportEditorViewController : UITableViewController <XMLRESTProcessorDelegate>

@property (nonatomic,assign) int documentId;
@property (nonatomic,assign) int reportId;
@property (nonatomic,strong) NSString *reportName;
@property (nonatomic,strong) Session *currentSession;
@property (nonatomic,strong) NSMutableArray *selectedQueryFields;
@property (nonatomic,strong) NSMutableArray *availableQueryFields;
@property (nonatomic,strong) NSMutableArray *reportElements;



@end
