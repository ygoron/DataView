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

- (void) biExportReport: (BIExportReport *) biExportReport isSuccess:(BOOL) isSuccess html:(NSString *) htmlString;
- (void) biExportReportPdf: (BIExportReport *) biExportReport isSuccess:(BOOL) isSuccess filePath:(NSString *) filePath;

@end

typedef enum ReportExportFormat {
    FormatHTML = 0,
    FormatPDF =1
} ReportExportFormat;


@interface BIExportReport : NSObject <NSURLConnectionDelegate, BIConnectorDelegate>



{
    
    NSMutableData *responseData;
}

@property (strong, nonatomic)   NSError *connectorError;
@property (strong, nonatomic)   NSString *boxiError;
@property (strong, nonatomic)   Session *biSession;
@property (strong, nonatomic)   Report *report;
@property   ReportExportFormat exportFormat;
@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) NSString *currentToken;


@property (nonatomic, weak) id <BIExportReportDelegate> delegate;

-(void) exportReport: (Report *) report withFormat: (ReportExportFormat) format;
-(void) logoOffIfNeeded;


@end
