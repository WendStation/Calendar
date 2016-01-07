//
//  NSString+NSStringCategory.h
//  Ethercap
//
//  Created by 小华 on 15/3/31.
//  Copyright (c) 2015年 Robert Dimitrov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (NSStringCategory)

- (BOOL)containsString:(NSString*)other;
//根据字体大小和固定宽度得到文本高度
- (CGFloat) calulateHeighFontType:(UIFont *) fontType RowWidth:(CGFloat) rowWidth;
+(NSString *)documentPathWithFileName:(NSString *)fileName;
- (NSUInteger)numberOfLines;
+ (CGSize)calculate:(NSString *)textStr textFont:(UIFont *)textFont contentSize:(CGSize)contentSize;

@end
