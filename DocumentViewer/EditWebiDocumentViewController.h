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
#define OP_CREATE_WEBI 1
#define OP_ADD_DATA_PROVIDER 2
#define OP_SAVE_DOCUMENT 3
#define OP_GET_LIST_OF_DATA_PROVIDERS 4
#define OP_DATA_PROVIDER_DETAIL 5


@interface EditWebiDocumentViewController : UITableViewController <TextTextEditViewControllerDelegate,XMLRESTProcessorDelegate,DataProviderSelectorDelegate>

@property (assign, nonatomic) NSInteger folderId;
@property (assign, nonatomic) NSInteger docId;
@property (strong, nonatomic) GDataXMLDocument *dataprovidersXml;
@property (strong, nonatomic) GDataXMLDocument *dataproviderDetailsXml;
@property (strong, nonatomic) GDataXMLDocument *documentXml;
@property (strong, nonatomic) Session *currentSession;

+(GDataXMLElement *) getFirstElementForDocument: (GDataXMLDocument *) docXml withPath:(NSString *) path;

@end
