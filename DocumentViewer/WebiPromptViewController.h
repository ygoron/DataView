//
//  WebiPromptViewController.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-10-14.
//  Copyright (c) 2013 APOS Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Document.h"
#import "EditPromptViewController.h"

@interface WebiPromptViewController : UITableViewController <EditPromptDelegate>

@property (nonatomic, strong) NSArray *webiPrompts;
@property (nonatomic,strong) Document *document;

@end
