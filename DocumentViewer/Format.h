//
//  Format.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-03-18.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FormatExcel,FormatPDF,FormatWebi;

@interface Format : NSObject

@property(strong, nonatomic) FormatExcel *formatExcel;
@property(strong, nonatomic) FormatPDF *formatPdf;
@property(strong, nonatomic) FormatWebi *formatWebi;
@end
