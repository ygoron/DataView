//
//  SessionCell.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-02-16.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import "SessionCell.h"

@implementation SessionCell

@synthesize sessionNameLabel;
@synthesize sessionWCALabel;
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
