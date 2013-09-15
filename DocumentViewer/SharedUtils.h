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

//#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
//#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
//#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
//#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
//#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


+(void) adjustImageLeftMarginForIpadInTableView: (UITableView *) tableView;
+(void) adjustImageLeftMarginForIpadInTableViewCell: (UITableViewCell *) tableViewCell;
+(void) adjustImageLeftMarginForIpadInTableViewAnyLeftObjectsInCell: (UITableViewCell *) tableViewCell;
+(void) adjustLabelLeftMarginForIpadForBoldFontInTableView: (UITableView *) tableView;
+(void) adjustRighMarginsForIpad: (NSArray *) constraints;

@end
