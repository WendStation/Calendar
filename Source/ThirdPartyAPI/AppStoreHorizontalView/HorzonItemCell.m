//
//  GoodsCollectionCell.m
//  BanTang
//
//  Created by liaoyp on 15/4/13.
//  Copyright (c) 2015年 JiuZhouYunDong. All rights reserved.
//

#import "HorzonItemCell.h"
#import "UIView+ViewConstraint.h"
#import "BaseModel.h"
#import "CollectModel.h"
#import "MacroDefinition.h"

@implementation HorzonItemCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setUpView];
    }
    return self;
}

- (void)setUpView
{
    UIView *superView = self.contentView;
    _mCoverView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _mCoverView.backgroundColor = [UIColor whiteColor];
    _mCoverView.layer.cornerRadius =0;
    _mCoverView.layer.masksToBounds = YES;
    _mCoverView.contentMode = UIViewContentModeScaleAspectFill;
    _mCoverView.opaque = YES;
    [superView addSubview:_mCoverView];
    
    _mTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _mTitleLabel.textAlignment = NSTextAlignmentCenter;
    _mTitleLabel.textColor = LIGHTGRAY_COLOR;
    _mTitleLabel.font = [UIFont systemFontOfSize:12];
    [superView addSubview:_mTitleLabel];
    
    _mDecLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _mDecLabel.textAlignment = NSTextAlignmentCenter;
    _mDecLabel.textColor = LIGHTGRAY_COLOR;
    _mDecLabel.font = [UIFont systemFontOfSize:12];;
    [superView addSubview:_mDecLabel];
    
    /*
        基本原理：
        View1（上下左右） -(相对于)- View2(上下左右) 距离值（XXX）
     */
    _mCoverView.translatesAutoresizingMaskIntoConstraints = NO;
    // 封面的长宽为44
    [_mCoverView addConstraintWidthWithValue:superView.frame.size.height / 2];
    [_mCoverView addConstraintHeightWithValue:superView.frame.size.height / 2];
    
    // 封面横纵居中
    [_mCoverView addConstraint:NSLayoutAttributeCenterX toItem:superView targetlayoutAttribte:NSLayoutAttributeCenterX withValue:0];
    [_mCoverView addConstraint:NSLayoutAttributeCenterY toItem:superView targetlayoutAttribte:NSLayoutAttributeCenterX withValue:0];
    
    _mTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_mTitleLabel addConstraint:NSLayoutAttributeTop toItem:_mCoverView targetlayoutAttribte:NSLayoutAttributeBottom withValue:10];
    [_mTitleLabel addConstraint:NSLayoutAttributeWidth toItem:superView targetlayoutAttribte:NSLayoutAttributeWidth withValue:0];
    [_mTitleLabel addConstraint:NSLayoutAttributeCenterX toItem:superView targetlayoutAttribte:NSLayoutAttributeCenterX withValue:0];

    _mDecLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [_mDecLabel addConstraint:NSLayoutAttributeTop toItem:_mTitleLabel targetlayoutAttribte:NSLayoutAttributeBottom withValue:2];
    [_mDecLabel addConstraint:NSLayoutAttributeWidth toItem:_mCoverView targetlayoutAttribte:NSLayoutAttributeWidth withValue:0];
    [_mDecLabel addConstraint:NSLayoutAttributeCenterX toItem:_mCoverView targetlayoutAttribte:NSLayoutAttributeCenterX withValue:0];

}

- (void)awakeFromNib {
    // Initialization code
}

- (void)hiddenDescView:(BOOL)hidden
{
    _mTitleLabel.hidden = hidden;
    _mDecLabel.hidden = hidden;

}

- (BOOL)isEmpty:(NSString *)str
{
    return ((str == nil)||[str isKindOfClass:[NSNull class]]);
}


- (void)isNormalCell:(BaseModel *)model
{
    [self hiddenDescView:NO];

    CollectModel *likeItem = (CollectModel *)model;
    _mTitleLabel.text = likeItem.title;
    
    if (![self isEmpty:likeItem.desc])
    {
        _mDescView.hidden = NO;
        _mDecLabel.text  = likeItem.desc;
        
    }else
    {
        _mDecLabel.hidden = YES;

    }
//    _mCoverView.backgroundColor = [likeItem backgroundColor];
    _mCoverView.image = [UIImage imageNamed:likeItem.pic];
}

- (UIColor *)randomColor {
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

@end
