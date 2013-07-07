//
//  DocumentDetailsCell.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-02-28.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import "DocumentCell.h"

@interface DocumentDetailsCell : DocumentCell
@property (strong, nonatomic) IBOutlet UILabel *labelPath;
@property (strong, nonatomic) IBOutlet UILabel *labelCreated;
@property (strong, nonatomic) IBOutlet UILabel *labelUpdated;
@property (strong, nonatomic) IBOutlet UILabel *labelSize;
@property (strong, nonatomic) IBOutlet UITextView *textViewPath;

@end
