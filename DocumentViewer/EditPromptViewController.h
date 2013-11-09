//
//  EditPromptViewController.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-11-02.
//  Copyright (c) 2013 APOS Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WebiPrompt.h"

@class EditPromptViewController;
@protocol  EditPromptDelegate <NSObject>

-(void) promptChanged:(EditPromptViewController *) editPromptController isSuccess: (BOOL) isSuccess withValue:(NSString *) value;


@end

@interface EditPromptViewController : UITableViewController <UITextFieldDelegate>

@property (strong, nonatomic) WebiPrompt *webiprompt;
@property (nonatomic, weak) id <EditPromptDelegate> delegate;

@end
