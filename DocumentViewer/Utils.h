//
//  Utils.h
//  foody
//
//  Created by Tope Abayomi on 12/08/2013.
//
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

+(BOOL)isVersion6AndBelow;

+(UIImage*)createSolidColorImageWithColor:(UIColor*)color andSize:(CGSize)size;

+(UIImage*)createGradientImageWithSize:(CGSize)size startColor:(UIColor*)startColor andEndColor:(UIColor*)endColor;

void drawLinearGradient(CGContextRef context, CGRect rect, CGColorRef startColor, CGColorRef endColor);
@end
