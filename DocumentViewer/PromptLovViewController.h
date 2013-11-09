//
//  PromptLovViewController.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-10-14.
//  Copyright (c) 2013 APOS Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebiPrompt.h"
#import "WebiPromptsEngine.h"
#import "Document.h"
#import "EditPromptViewController.h"

@interface PromptLovViewController : UITableViewController <WebiPromptsEngineDelegate,EditPromptDelegate>

@property (strong, nonatomic) WebiPrompt *webiprompt;
@property (strong, nonatomic) Document *document;
@end
