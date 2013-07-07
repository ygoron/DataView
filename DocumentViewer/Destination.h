//
//  Destination.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-03-18.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DestinationInbox;

@interface Destination : NSObject
@property (nonatomic,strong) DestinationInbox *destinationInbox;
@end
