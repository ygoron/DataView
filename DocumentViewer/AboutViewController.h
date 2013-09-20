//
//  AboutViewController.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-04-28.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ExtensionPack.h"
#import "BIConnector.h"
#import "BILogoff.h"

@interface AboutViewController : UIViewController <ExtensionPackDelegate,BIConnectorDelegate,BILogoffDelegate>
    @property (strong, nonatomic) IBOutlet UITextView *textViewAboutText;
    
    @end
