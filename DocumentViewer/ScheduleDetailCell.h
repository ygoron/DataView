//
//  ScheduleDetailCell.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-03-04.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScheduleDetailCell : UITableViewCell

@property (nonatomic,strong) IBOutlet UILabel *scheduleLabelId;
@property (nonatomic,strong) IBOutlet UILabel *scheduleLabelName;
@property (nonatomic,strong) IBOutlet UIImageView *scheduleLabelFormat;
@property (nonatomic,strong) IBOutlet UILabel *scheduleLabelStatus;

@end
