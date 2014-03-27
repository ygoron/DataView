//
//  BIExportReport.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-03-01.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BIConnector.h"
#import "Report.h"

@class BIExportReport;

@protocol BIExportReportDelegate <NSObject>

typedef enum ReportExportFormat {
    FormatHTML = 0,
    FormatPDF =1,
    FormatEXCEL=2
} ReportExportFormat;

- (void) biExportReport: (BIExportReport *) biExportReport isSuccess:(BOOL) isSuccess html:(NSString *) htmlString;
- (void) biExportReportExternalFormat: (BIExportReport *) biExportReport isSuccess:(BOOL) isSuccess filePath:(NSString *) filePath WithFormat:(ReportExportFormat) format;

@end



@interface BIExportReport : NSObject <NSURLConnectionDelegate, BIConnectorDelegate>



{
    
    NSMutableData *responseData;
}

@property (strong, nonatomic)   NSError *connectorError;
@property (strong, nonatomic)   NSString *boxiError;
@property (strong, nonatomic)   Session *biSession;
@property (strong, nonatomic)   Report *report;
@property (strong, nonatomic)   Document *document;
@property   ReportExportFormat exportFormat;
@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) NSString *currentToken;
@property (assign, nonatomic) BOOL isExportWithUrl;
@property (strong, nonatomic) NSURL *url;




@property (nonatomic, weak) id <BIExportReportDelegate> delegate;


+(NSURL *) getExportReportURLForDocumentId: (int) documentId withReportId: (int) reportId withSession:(Session *) session;
-(void) exportDocument: (Document *) document withFormat: (ReportExportFormat) format;
-(void) exportReport: (Report *) report withFormat: (ReportExportFormat) format;
-(void) exportEntityWithUrl: (NSURL *) url withFormat: (ReportExportFormat)format  forSession:(Session *) currentSession;
-(void) logoOffIfNeeded;


@end
