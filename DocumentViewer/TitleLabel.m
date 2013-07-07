//
//  TitleLabel.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-04-05.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import "TitleLabel.h"

@implementation TitleLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.font = [UIFont boldSystemFontOfSize:20.0];
        self.shadowColor = [UIColor blackColor];
        self.textAlignment=NSTextAlignmentCenter;
        self.textColor = [UIColor whiteColor];
    }
    return self;
}

-(void) setTitleText:(NSString *)text{
    self.text=text;
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
