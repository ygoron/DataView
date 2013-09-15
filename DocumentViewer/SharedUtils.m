//
//  SharedUtils.m
//  DocumentViewer
//
//  Created by Yuri Goron on 2013-08-16.
//  Copyright (c) 2013 APOS Systems. All rights reserved.
//

#import "SharedUtils.h"
#import "Utils.h"

@implementation SharedUtils

+(void) adjustImageLeftMarginForIpadInTableView:(UITableView *)tableView
{
    
    if([Utils isVersion6AndBelow]){
        
        //    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        UIUserInterfaceIdiom idiom = [[UIDevice currentDevice] userInterfaceIdiom];
        if (idiom == UIUserInterfaceIdiomPad) {
            
            for (int sectionIndex=0; sectionIndex <[tableView numberOfSections]; sectionIndex++) {
                for (int rowIndex=0; rowIndex <[tableView numberOfRowsInSection:sectionIndex]; rowIndex++) {
                    UITableViewCell *cell = (UITableViewCell*)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex]];
                    for (NSLayoutConstraint *constraint in [cell constraints] ) {
                        if ([constraint.firstItem isKindOfClass:[UIImageView class]]){
                            if (constraint.secondAttribute==NSLayoutAttributeLeading)
                                constraint.constant=IPAD_GROUPPED_TABLE_OFFSET;
                        }
                    }
                    
                }
            }
        }
    }
}


+(void) adjustImageLeftMarginForIpadInTableViewCell:(UITableViewCell *)tableViewCell
{
    
    if([Utils isVersion6AndBelow]){
        //    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        for (NSLayoutConstraint *constraint in [tableViewCell constraints] ) {
            
            if ([constraint.firstItem isKindOfClass:[UISegmentedControl class]] || [constraint.firstItem isKindOfClass:[UISlider class]]){
                if (constraint.firstAttribute==NSLayoutAttributeLeading){
                    constraint.constant=IPAD_GROUPPED_TABLE_OFFSET;
                }
                
            }else
                if ([constraint.firstItem isKindOfClass:[UILabel class]]){
                    UILabel *myLabel=constraint.firstItem;
                    if ([myLabel.font.fontName rangeOfString:@"Bold"].length > 0){
                        if (constraint.firstAttribute==NSLayoutAttributeLeading){
                            constraint.constant=IPAD_GROUPPED_TABLE_OFFSET;
                            
                        }
                        
                    }
                }else if (constraint.firstAttribute==NSLayoutAttributeTrailing){
                    constraint.constant=IPAD_GROUPPED_TABLE_OFFSET;
                }
            
        }
    }
    
}
+(void) adjustImageLeftMarginForIpadInTableViewAnyLeftObjectsInCell:(UITableViewCell *)tableViewCell
{
    if([Utils isVersion6AndBelow]){
        
        //    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        
        UIUserInterfaceIdiom idiom = [[UIDevice currentDevice] userInterfaceIdiom];
        if (idiom == UIUserInterfaceIdiomPad) {
            
            for (NSLayoutConstraint *constraint in [tableViewCell constraints] ) {
                
                if ([constraint.firstItem isKindOfClass:[UISegmentedControl class]] || [constraint.firstItem isKindOfClass:[UISlider class]]){
                    if (constraint.firstAttribute==NSLayoutAttributeLeading){
                        constraint.constant=IPAD_GROUPPED_TABLE_OFFSET;
                    }
                    
                }else
                    if ([constraint.firstItem isKindOfClass:[UILabel class]]){
                        if (constraint.firstAttribute==NSLayoutAttributeLeading){
                            constraint.constant=IPAD_GROUPPED_TABLE_OFFSET;
                        }
                    }else if (constraint.firstAttribute==NSLayoutAttributeTrailing){
                        constraint.constant=IPAD_GROUPPED_TABLE_OFFSET;
                    }
                
            }
        }
    }
}
+(void) adjustLabelLeftMarginForIpadForBoldFontInTableView:(UITableView *)tableView{
    if([Utils isVersion6AndBelow]){
        //    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        {
            UIUserInterfaceIdiom idiom = [[UIDevice currentDevice] userInterfaceIdiom];
            if (idiom == UIUserInterfaceIdiomPad) {
                
                for (int sectionIndex=0; sectionIndex <[tableView numberOfSections]; sectionIndex++) {
                    for (int rowIndex=0; rowIndex <[tableView numberOfRowsInSection:sectionIndex]; rowIndex++) {
                        
                        UITableViewCell *cell = (UITableViewCell*)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex]];
                        [self adjustImageLeftMarginForIpadInTableViewCell:cell];
                    }
                    
                }
            }
            
        }
    }
}

+(void) adjustRighMarginsForIpad:(NSArray *)constraints{
    if([Utils isVersion6AndBelow]){
        //    if (SYSTEM_VERSION_LESS_THAN(@"7.0")) {
        UIUserInterfaceIdiom idiom = [[UIDevice currentDevice] userInterfaceIdiom];
        if (idiom == UIUserInterfaceIdiomPad) {
            
            for (NSLayoutConstraint *constraint in constraints ) {
                
                if (constraint.firstAttribute==NSLayoutAttributeTrailing){
                    constraint.constant=IPAD_GROUPPED_TABLE_OFFSET;
                }
                
            }
            
        }
    }
}

@end
