//
//  DocumentsViewController.h
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-02-21.
//  Copyright (c) 2013 Data View Systems. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BIGetDocuments.h"
#import "BIDeleteDocument.h"
#import "Session.h"
#import "TitleLabel.h"

@interface DocumentsViewController : UITableViewController <BIGetDocumentsDelegate,BIDeleteDocumentDelegate>

@property (nonatomic, strong) NSMutableArray *sessions;
@property (nonatomic, strong) NSMutableArray *grouppedDocuments;
@property (nonatomic, strong) Session *currentSession;
@property (nonatomic, strong) TitleLabel *titleLabel;


-(void) populateFirstLetters: (NSMutableArray*) newDocuments;
-(NSMutableDictionary *) createNewDocumentGroupWithIndex: (NSString *) indexString withArray:(NSArray *) documents;
-(void)loadDocuments;
-(void)reloadDocuments;
- (IBAction)buttonRefresh:(id)sender;
@end
