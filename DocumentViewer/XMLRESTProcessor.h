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
