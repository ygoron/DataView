//
//  TextEditViewController.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-12-01.
//  Copyright (c) 2013 APOS Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TextEditViewController;

@protocol TextTextEditViewControllerDelegate <UITextFieldDelegate,NSObject>

-(void) TextTextEditViewController: (TextEditViewController *) controller didFinishEditingValue: (NSString *) value;

@end

@interface TextEditViewController : UITableViewController

@property (strong, nonatomic) NSString *placeHolderText;
@property (strong, nonatomic) UILabel *valueLabel;
@property (strong, nonatomic) NSString *defaultValue;

@property (nonatomic, weak) id <TextTextEditViewControllerDelegate> delegate;
@end
