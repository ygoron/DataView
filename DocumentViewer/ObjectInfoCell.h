//
//  ObjectInfoCell.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-05-18.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ObjectInfoCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *labelProperty;
@property (strong, nonatomic) IBOutlet UILabel *propertyValue;

@end
