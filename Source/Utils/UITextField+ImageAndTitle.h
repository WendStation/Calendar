//
//  UITextField+ImageAndTitle.h
//  Calendar
//
//  Created by 刘花椒 on 15/11/11.
//
//

#import <UIKit/UIKit.h>


@interface UITextField (ImageAndTitle)

+ (UITextField *)addUITextFieldLeftImage:(UIImage *)image
                       leftViewFrame:(CGRect)leftViewFrame
                         placeholder:(NSString *)placeholder
                    placeholderColor:(UIColor *)placeholderColor
                     placeholderFont:(UIFont *)placeholderFont
                           textColor:(UIColor *)textColor
                            textFont:(UIFont *)textFont;


@end
