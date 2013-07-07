//
//  ActionCell.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-05-18.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import "ActionCell.h"

@implementation ActionCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
