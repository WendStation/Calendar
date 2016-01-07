//
//  UIImage+StrethImage.m
//  MessageDemo
//
//  Created by wufei on 15/12/10.
//  Copyright (c) 2015年 wufei. All rights reserved.
//

#import "UIImage+StrethImage.h"

@implementation UIImage (StrethImage)


+(instancetype)strethImageWithName:(NSString *)imageName{
    UIImage* image=[UIImage imageNamed:imageName];
    return [image resizableImageWithCapInsets:UIEdgeInsetsMake(35, 10, 10, 26)];
}
@end
