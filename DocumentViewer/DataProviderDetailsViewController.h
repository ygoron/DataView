//
//  DataProviderDetailsViewController.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2/6/2014.
//  Copyright (c) 2014 APOS Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Session.h"
#import "XMLRESTProcessor.h"


@interface DataProviderDetailsViewController : UITableViewController <XMLRESTProcessorDelegate>

@property (assign, nonatomic) NSInteger docId;
@property (strong, nonatomic) Session *currentSession;
@property (strong,nonatomic) NSString *dataProviderId;
@property (strong,nonatomic) NSString *dataProviderName;

@end
