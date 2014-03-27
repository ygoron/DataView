//
//  CellEditViewController.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2014-03-20.
//  Copyright (c) 2014 APOS Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Session.h"
#import "XMLRESTProcessor.h"
#import "BIExportReport.h"

@class CellEditViewController;

@protocol CellEditViewDelegate <NSObject>

-(void) finishEditing: (CellEditViewController *) cellEditViewController isSuccess:(BOOL) isSuccess isRefreshRequired:(BOOL) isRefreshRequired;


@end

@interface CellEditViewController : UITableViewController <XMLRESTProcessorDelegate,UIWebViewDelegate,BIExportReportDelegate,UITextFieldDelegate>

@property (nonatomic,assign) int documentId;
@property (nonatomic,assign) int reportId;
@property (nonatomic,assign) int elementId;
@property (nonatomic,strong) NSString *elementName;
@property (nonatomic,strong) NSString *elementText;
@property (nonatomic,strong) Session *currentSession;
@property (weak,nonatomic) id<CellEditViewDelegate> delegate;



@end
