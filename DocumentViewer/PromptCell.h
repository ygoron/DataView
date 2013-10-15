//
//  PromptCell.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-10-14.
//  Copyright (c) 2013 APOS Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PromptCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *promptNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *promptValuesLabel;

@end
