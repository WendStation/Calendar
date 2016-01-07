//
//  UIBarButtonItem+Image.m
//  Calendar
//
//  Created by 刘花椒 on 15/11/3.
//
//

#import "UIBarButtonItem+Image.h"

@implementation UIBarButtonItem (CustomImage)

- (void)setButtonAttribute:(NSDictionary*)dic
{
    if ([self.customView isKindOfClass:[UIButton class]]) {
        UIButton* button = (UIButton*)self.customView;
        UIFont* font = [dic objectForKey:@"font"];
        if (font != nil && [font isKindOfClass:[UIFont class]]) {
            [button.titleLabel setFont:font];
        }
        NSNumber* shadowOffset = [dic objectForKey:@"shadowOffset"];
        if (shadowOffset != nil && [shadowOffset isKindOfClass:[NSNumber class]]) {
            [button.titleLabel setShadowOffset:shadowOffset.CGSizeValue];
        }
        NSNumber* buttonWidth = [dic objectForKey:@"width"];
        if (buttonWidth != nil && [buttonWidth isKindOfClass:[NSNumber class]]) {
            CGRect rc = button.frame;
            rc.size.width = buttonWidth.floatValue;
            button.frame = rc;
        }
        UIColor* titleColorNormal = [dic objectForKey:@"titleColorNormal"];
        if (titleColorNormal != nil && [titleColorNormal isKindOfClass:[UIColor class]]) {
            [button setTitleColor:titleColorNormal forState:UIControlStateNormal];
        }
        UIColor* shadowColorNormal = [dic objectForKey:@"shadowColorNormal"];
        if (shadowColorNormal != nil && [shadowColorNormal isKindOfClass:[UIColor class]]) {
            [button setTitleShadowColor:shadowColorNormal forState:UIControlStateNormal];
        }
        UIColor* titleColorHighlighted = [dic objectForKey:@"titleColorHighlighted"];
        if (titleColorHighlighted != nil && [titleColorHighlighted isKindOfClass:[UIColor class]]) {
            [button setTitleColor:titleColorHighlighted forState:UIControlStateHighlighted];
        }
        UIColor* shadowColorHightlighted = [dic objectForKey:@"shadowColorHightlighted"];
        if (shadowColorHightlighted != nil && [shadowColorHightlighted isKindOfClass:[UIColor class]]) {
            [button setTitleShadowColor:shadowColorHightlighted forState:UIControlStateHighlighted];
        }
    }
}

+ (UIBarButtonItem *)rsBarButtonItemWithTitle:(NSString *)title 
                                        image:(UIImage *)image
                             heightLightImage:(UIImage *)hlImage
                                 disableImage:(UIImage *)disImage
                                       target:(id)target
                                       action:(SEL)selector
{
    UIButton* customButton = [self rsCustomBarButtonWithTitle:title
                                                        image:image
                                             heightLightImage:hlImage
                                                 disableImage:disImage
                                                       target:target
                                                       action:selector];
    CGSize sizeOfTitle = CGSizeZero;
    if (title!=nil && ![title isEqualToString:@""]) {
        sizeOfTitle = [title sizeWithFont:customButton.titleLabel.font 
                        constrainedToSize:CGSizeMake(100.0f, 22.0f) 
                            lineBreakMode:NSLineBreakByTruncatingMiddle];
    }
    
    CGFloat width = 100.0f;
    CGFloat height = 44.0f;
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    if (customButton.currentBackgroundImage != nil) {
        width = customButton.currentBackgroundImage.size.width;
        height = customButton.currentBackgroundImage.size.height;
    }
    if (sizeOfTitle.width <= 0.0f) {
        [customButton setFrame:CGRectMake(x,
                                          y,
                                          width,
                                          height)];        
    }else {
        [customButton setFrame:CGRectMake(x,
                                          y,
                                          sizeOfTitle.width+22.0f,
                                          height)];
    }
    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc] initWithCustomView:customButton];
    barBtnItem.width = customButton.width;
    return barBtnItem;
}

+ (UIBarButtonItem *)rsBarButtonItemWithBellButton:(UIButton *)bellButton
                                             image:(UIImage *)image
                                  heightLightImage:(UIImage *)hlImage
                                      disableImage:(UIImage *)disImage
                                            target:(id)target
                                            action:(SEL)selector
{
    UIButton* customButton = [self rsCustomBarButtonWithTitle:nil
                                                        image:image
                                             heightLightImage:hlImage
                                                 disableImage:disImage
                                                       target:target
                                                       action:selector];
    CGSize sizeOfBellButton = CGSizeZero;
    if (bellButton!=nil  /*&& !bellButton.isHidden*/ ) {
        sizeOfBellButton = [bellButton size];;
    }

    CGFloat width = 100.0f;
    CGFloat height = 44.0f;
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    if (customButton.currentBackgroundImage != nil) {
        width = customButton.currentBackgroundImage.size.width;
        height = customButton.currentBackgroundImage.size.height;
    }
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0,y,sizeOfBellButton.width + width +3,  height)];
    if (sizeOfBellButton.width <= 0.0f ) {
        [customButton setFrame:CGRectMake(x,
                                          y,
                                          width,
                                          height)];
        [view addSubview:customButton];
    }else {

        CGRect inputFrame = CGRectMake(0,0,sizeOfBellButton.width,sizeOfBellButton.height);
        bellButton.frame = CGRectIntegral(inputFrame);

        
        [customButton setFrame:CGRectMake(sizeOfBellButton.width+3,
                                          y,
                                          width,
                                          height)];
        [view addSubview:bellButton];
        [view addSubview:customButton];
    }

    UIBarButtonItem *barBtnItem = [[UIBarButtonItem alloc] initWithCustomView:view];
    //    barBtnItem.width = [customButton currentBackgroundImage].size.width;
    return barBtnItem;
}

+ (UIBarButtonItem *)rsBarButtonItemWithTitle:(NSString *)title
                                       target:(id)target
                                       action:(SEL)selector{
    static UIImage * _navigationBarBg;
    if (!_navigationBarBg) {
        CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 44.0f);
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, RGBACOLOR(0, 0, 0, 0.2f).CGColor);
        CGContextFillRect(context, rect);
        _navigationBarBg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }

    static UIImage * _navigationBarBgHl; 

    if (!_navigationBarBgHl) {
        CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 44.0f);
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, RGBACOLOR(0, 0, 0, 0.4f).CGColor);
        CGContextFillRect(context, rect);
        _navigationBarBgHl = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }

    return [UIBarButtonItem rsBarButtonItemWithTitle:title
                                                   image:nil
                                        heightLightImage:_navigationBarBgHl
                                            disableImage:nil
                                                  target:target
                                                  action:selector];

}

+ (UIButton*)rsCustomBarButtonWithTitle:(NSString*)title
                                  image:(UIImage *)image
                       heightLightImage:(UIImage *)hlImage
                           disableImage:(UIImage *)disImage
                                 target:(id)target
                                 action:(SEL)selector
{
    UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    if (image != nil) {
        [customButton setBackgroundImage:image forState:UIControlStateNormal];
        [customButton setBackgroundColor:[UIColor clearColor]];
    }
    else {
//        [customButton setBackgroundColor:[UIColor blueColor]];
    }
    if (hlImage != nil) {
        [customButton setBackgroundImage:hlImage forState:UIControlStateHighlighted];
    }
    if (nil != disImage)
    {
        [customButton setBackgroundImage:disImage forState:UIControlStateDisabled];
    }
   
    [customButton.titleLabel setFont:[UIFont systemFontOfSize:17.0f]];

    [customButton.titleLabel setShadowOffset:CGSizeMake(0.0f, 0.5f)];
    if (title!=nil && ![title isEqualToString:@""]) {
        [customButton setTitle:title forState:UIControlStateNormal];
        [customButton setTitleColor:RGBCOLOR(255, 255, 255) forState:UIControlStateNormal];
    }

    //[customButton setTitleColor:RGBACOLOR(0, 0, 0, 0.3) forState:UIControlStateDisabled];
    [customButton addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    
    return customButton;
}


@end
