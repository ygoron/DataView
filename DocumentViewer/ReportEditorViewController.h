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
#import "BIExportReport.h"


@interface ReportEditorViewController : UITableViewController <XMLRESTProcessorDelegate,UIWebViewDelegate,BIExportReportDelegate>

@property (nonatomic,assign) int documentId;
@property (nonatomic,assign) int reportId;
@property (nonatomic,assign) int elementParentId;
@property (nonatomic,strong) NSString *reportName;
@property (nonatomic,strong) NSURL *prevWorkedUrl;
@property (nonatomic,strong) Session *currentSession;
@property (nonatomic,strong) NSMutableArray *selectedQueryFields;
@property (nonatomic,strong) NSMutableArray *availableQueryFields;
@property (nonatomic,strong) GDataXMLDocument *xmlReportSpecs;
@property (nonatomic,strong) GDataXMLDocument *xmlReportElements;




@end
