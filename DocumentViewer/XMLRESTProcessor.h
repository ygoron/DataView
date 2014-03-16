//
//  XMLRESTProcessor.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-12-01.
//  Copyright (c) 2013 APOS Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GDataXMLNode.h"
#import "BIConnector.h"

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
#define OP_GET_DOCUMENT_DETAILS_PRE_SAVE 13
#define OP_GET_REPORT_ELEMENTS 14
#define OP_SAVE_DOCUMENT 99


@class XMLRESTProcessor;
@protocol XMLRESTProcessorDelegate  <NSObject>

-(void) finishedProcessing: (XMLRESTProcessor *) xmlProcessor isSuccess:(BOOL) isSuccess withReturnedXml: (GDataXMLDocument *) xmlDoc withErrorText:(NSString *) errorText forUrl: (NSURL *) url withMethod: (NSString *) method withOriginalRequestXml:(GDataXMLDocument *) originalXmlDoc withOpCode:(int) opCode;

@end


@interface XMLRESTProcessor :  NSObject <NSURLConnectionDataDelegate,BIConnectorDelegate>
+(NSURL *) getDocumentsUrlWithSession: (Session *) session;
+(NSURL *) getDataProvidersUrlWithSession: (Session *) session withDocumentId: (int) documentId;
+(NSURL *) getUpdateReportSpecsUrlWithSession: (Session *) session forDocumentId: (int) documentId forReportId: (int) reportId;

-(void) submitRequestForUrl: (NSURL *) url withSession: (Session *) session withHttpMethod: (NSString *) method withXmlDoc: (GDataXMLDocument *) doc withOpCode: (int) opCode;

@property(nonatomic,strong) NSString *contentType;
@property(nonatomic,strong) NSString *accept;
@property (nonatomic, weak) id <XMLRESTProcessorDelegate> delegate;

@end
