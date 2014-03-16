//
//  EditWebiDocumentViewController.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-11-30.
//  Copyright (c) 2013 APOS Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDataXMLNode.h"
#import "TextEditViewController.h"
#import "Session.h"
#import "XMLRESTProcessor.h"
#import "DataProviderSelectorViewController.h"
#import "SelectWebiFieldsViewController.h"
#import "SelectReportFieldsViewController.h"
#import "WebiPromptsEngine.h"
#import "UniversesListViewController.h"
#import "ReportEditorViewController.h"

@class EditWebiDocumentViewController;

@protocol EditWebiDocumentDelegate <NSObject>

-(void) EditWebiDocument: (EditWebiDocumentViewController *) editWebiDocument isUpdated: (BOOL) isUpdated;

@end

@interface EditWebiDocumentViewController : UITableViewController <TextTextEditViewControllerDelegate,XMLRESTProcessorDelegate,DataProviderSelectorDelegate,SelectWebiFieldsDelegate,WebiPromptsEngineDelegate,SelectReportFieldsDelegate,UniversesListViewControllerDelegate,BIGetUniverseDetailsDelegate>

@property (assign, nonatomic) NSInteger folderId;
@property (assign, nonatomic) NSInteger docId;
@property (strong, nonatomic) GDataXMLDocument *dataprovidersXml;
@property (strong, nonatomic) GDataXMLDocument *dataproviderDetailsXml;
@property (strong, nonatomic) GDataXMLDocument *documentXml;
@property (strong, nonatomic) Session *currentSession;
@property (assign, nonatomic) BOOL isNewWebiDocument;
@property (strong,nonatomic) Document *document;
@property (strong,nonatomic) NSMutableDictionary *reportsDictionary;
@property (strong,nonatomic) ReportEditorViewController *reportEditor;

@property (nonatomic, weak) id <UniversesListViewControllerDelegate> delegate;
@property (nonatomic, weak) id <EditWebiDocumentDelegate> delegateEditWebi;


+(GDataXMLElement *) getFirstElementForDocument: (GDataXMLDocument *) docXml withPath:(NSString *) path;



@end
