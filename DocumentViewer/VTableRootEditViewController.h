//
//  VTableRootEditViewController.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2014-03-02.
//  Copyright (c) 2014 APOS Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDataXMLNode.h"
#import "Session.h"
#import "BIExportReport.h"


@interface VTableRootEditViewController : UITableViewController <UIWebViewDelegate,BIExportReportDelegate>

@property (nonatomic,strong) GDataXMLDocument *xmlReportSpecs;
@property (nonatomic,strong) GDataXMLDocument *xmlReportElements;
@property (nonatomic,assign) int documentId;
@property (nonatomic,assign) int reportId;
@property (nonatomic,assign) int elementId;
@property (nonatomic,strong) NSString *reportName;
@property (nonatomic,strong) Session *currentSession;



@end
