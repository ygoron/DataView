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

#define OP_CREATE_WEBI 1
#define OP_ADD_DATA_PROVIDER 2
#define OP_UPDATE_DATA_PROVIDER 3
#define OP_GET_LIST_OF_DATA_PROVIDERS 4
#define OP_DATA_PROVIDER_DETAIL 5
#define OP_GET_QUERY_SPEC 6
#define OP_UPDATE_QUERY_SPEC 7
#define OP_UPDATE_REPORT_SPEC 8
#define OP_GET_LIST_OF_REPORTS 9
#define OP_DELETE_DATA_PROVIDER 10
#define OP_GET_DATA_PROVIDER_DETAILS 11
#define OP_GET_DOCUMENT_DETAILS 12
#define OP_SAVE_DOCUMENT 99



@interface EditWebiDocumentViewController : UITableViewController <TextTextEditViewControllerDelegate,XMLRESTProcessorDelegate,DataProviderSelectorDelegate,SelectWebiFieldsDelegate,WebiPromptsEngineDelegate,SelectReportFieldsDelegate,UniversesListViewControllerDelegate,BIGetUniverseDetailsDelegate>

@property (assign, nonatomic) NSInteger folderId;
@property (assign, nonatomic) NSInteger docId;
@property (strong, nonatomic) GDataXMLDocument *dataprovidersXml;
@property (strong, nonatomic) GDataXMLDocument *dataproviderDetailsXml;
@property (strong, nonatomic) GDataXMLDocument *documentXml;
@property (strong, nonatomic) Session *currentSession;
@property (assign, nonatomic) BOOL isNewWebiDocument;
@property (strong,nonatomic) Document *document;

@property (nonatomic, weak) id <UniversesListViewControllerDelegate> delegate;


+(GDataXMLElement *) getFirstElementForDocument: (GDataXMLDocument *) docXml withPath:(NSString *) path;



@end
