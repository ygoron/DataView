//
//  UniverseDetailsCellSolo.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-03-31.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UniverseDetailsCellSolo : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *lableName;

@property (strong, nonatomic) IBOutlet UILabel *labelType;

@property (strong, nonatomic) IBOutlet UILabel *labelDescription;
@property (strong, nonatomic) IBOutlet UIImageView *myImageView;
@property (strong, nonatomic) IBOutlet UILabel *labelArraySize;

@end
