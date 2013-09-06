//
//  SharedUtils.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-08-16.
//  Copyright (c) 2013 APOS Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedUtils : NSObject
#define IPAD_GROUPPED_TABLE_OFFSET 60

+(void) adjustImageLeftMarginForIpadInTableView: (UITableView *) tableView;
+(void) adjustImageLeftMarginForIpadInTableViewCell: (UITableViewCell *) tableViewCell;
+(void) adjustImageLeftMarginForIpadInTableViewAnyLeftObjectsInCell: (UITableViewCell *) tableViewCell;
+(void) adjustLabelLeftMarginForIpadForBoldFontInTableView: (UITableView *) tableView;
+(void) adjustRighMarginsForIpad: (NSArray *) constraints;

@end
