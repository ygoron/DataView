//
//  UniverseCell.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-03-30.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UniverseCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *univernameLabel;
@property (strong, nonatomic) IBOutlet UILabel *universeIdLabel;
@property (strong, nonatomic) IBOutlet UILabel *lableFolderId;
@property (strong, nonatomic) IBOutlet UILabel *lableType;
@property (strong, nonatomic) IBOutlet UIImageView *imageOfUnv;

@end
