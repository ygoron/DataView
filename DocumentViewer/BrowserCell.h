//
//  BrowserCell.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-05-11.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BrowserCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *labelName;
@property (strong, nonatomic) IBOutlet UILabel *labelDescription;
@property (strong, nonatomic) IBOutlet UILabel *labelType;
@property (strong, nonatomic) IBOutlet UIImageView *imageViewIcon;


@end
