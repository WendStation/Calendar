//
//  NSString+NSStringCategory.m
//  Ethercap
//
//  Created by 小华 on 15/3/31.
//  Copyright (c) 2015年 Robert Dimitrov. All rights reserved.
//

#import "NSString+NSStringCategory.h"

@implementation NSString (NSStringCategory)

- (BOOL)containsString:(NSString*)other {
    NSRange range = [self rangeOfString:other];
    return range.length != 0;
}

- (CGFloat) calulateHeighFontType:(UIFont *) fontType RowWidth:(CGFloat) rowWidth
{
    if (self==nil)
    {
        return 0;
    }
    CGSize maxSize=CGSizeMake(rowWidth, MAXFLOAT);
    CGSize  strSize=[self sizeWithFont:fontType constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping];
    
    return strSize.height;
}

+(NSString *)documentPathWithFileName:(NSString *)fileName
{
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:fileName];
}
- (NSUInteger)numberOfLines
{
    return [self componentsSeparatedByString:@"\n"].count;
}

+ (CGSize)calculate:(NSString *)textStr textFont:(UIFont *)textFont contentSize:(CGSize)contentSize{
    if (![textStr isKindOfClass:[NSNull class]] && textStr.length > 0) {
        NSString *content = [textStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSMutableAttributedString * attrS = [[NSMutableAttributedString alloc] initWithString:content];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 10;
        NSDictionary *attribute = @{NSFontAttributeName:textFont,NSParagraphStyleAttributeName:style};
        [attrS addAttributes:attribute range:NSMakeRange(0, content.length)];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, contentSize.width, CGFLOAT_MAX)];
        label.attributedText = attrS;
        label.numberOfLines = 0;
        [label sizeToFit];
        return label.size;
    } else {
        return CGSizeZero;
    }
}

@end
