//
//  XmlViewController.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2/7/2014.
//  Copyright (c) 2014 APOS Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDataXMLNode.h"

@interface XmlViewController : UITableViewController

@property (strong,nonatomic) GDataXMLElement *xmlElement;

@end
