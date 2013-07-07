//
//  SessionCell.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-02-16.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SessionCell : UITableViewCell

@property (nonatomic,strong) IBOutlet UILabel *sessionNameLabel;
@property (nonatomic,strong) IBOutlet UILabel *sessionWCALabel;
@property (nonatomic,strong) IBOutlet UILabel *sessionActive;

@end
