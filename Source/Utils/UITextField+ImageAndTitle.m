//
//  UITextField+ImageAndTitle.m
//  Calendar
//
//  Created by 刘花椒 on 15/11/11.
//
//

#import "UITextField+ImageAndTitle.h"

@implementation UITextField (ImageAndTitle)

+ (UITextField *)addUITextFieldLeftImage:(UIImage *)image leftViewFrame:(CGRect)leftViewFrame placeholder:(NSString *)placeholder placeholderColor:(UIColor *)placeholderColor placeholderFont:(UIFont *)placeholderFont  textColor:(UIColor *)textColor  textFont:(UIFont *)textFont{
    
    UITextField *searchTextField = [[UITextField alloc]init];
    searchTextField.backgroundColor = [UIColor whiteColor];
    searchTextField.tintColor = [UIColor blackColor];
    searchTextField.textColor = textColor;
    searchTextField.font = textFont;
    
    NSMutableAttributedString * attrS = [[NSMutableAttributedString alloc] initWithString:placeholder];
    NSDictionary *attribute = @{NSFontAttributeName:placeholderFont,NSForegroundColorAttributeName:placeholderColor};
    [attrS addAttributes:attribute range:NSMakeRange(0, placeholder.length)];
    searchTextField.attributedPlaceholder = attrS;
    
    searchTextField.leftView = [[UIView alloc]initWithFrame:leftViewFrame];
    searchTextField.leftView.backgroundColor = [UIColor clearColor];
    searchTextField.leftViewMode = UITextFieldViewModeAlways;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(evaluate(10), (54 - image.size.width) / 2.0, image.size.width, image.size.height);
    imageView.backgroundColor = [UIColor clearColor];
    [searchTextField.leftView addSubview:imageView];
    return searchTextField;
}


@end
