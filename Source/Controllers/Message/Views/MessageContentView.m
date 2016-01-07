//
//  MessageContentView.m
//  MessageDemo
//
//  Created by wend on 15/12/9.
//  Copyright (c) 2015年 wufei. All rights reserved.
//

#import "MessageContentView.h"
#import "MessageContentView.h"
#import "ChatMessageListItem.h"

static const float messageContent_LabelToBackground = 14;


@implementation MessageContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if (self) {
        [self createUI];
    }
    return self;
}

-(void)createUI
{
    [self addSubview:self.backImageView];
    [self addSubview:self.contentLabel];
    [self addGestureRecognizer:[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longTap:)]];
//    [self addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapPress:)]];
}
-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    //为什么要设置为self.bounds大小
    self.backImageView.frame=self.bounds;
    CGFloat contentLabelX=0;
    //判断是否是自己发送的，从而判断位置
    if (![self.model.fromUser isEqualToString:[CacheManager sharedInstance].userId]) {
        contentLabelX=messageContent_LabelToBackground+5;
    }
    else
    {
        contentLabelX=messageContent_LabelToBackground;
    }
    //这句话什么作用
    self.contentLabel.frame=CGRectMake(contentLabelX, messageContent_LabelToBackground, WIDTH-messageContent_LabelToBackground*2-5, HEIGHT-messageContent_LabelToBackground*2);
    
    //这里设置时间label
    
    //这里设置用户的label
    
}

#pragma mark - 懒加载
-(UIImageView *)backImageView
{
    if (_backImageView==nil) {
        _backImageView=[[UIImageView alloc]init];
        self.backImageView.userInteractionEnabled=YES;
    }
    return _backImageView;
    
}
-(UILabel *)contentLabel
{
    if (_contentLabel==nil) {
        _contentLabel=[[PPLabel alloc]init];
        _contentLabel.numberOfLines=0;
        _contentLabel.textAlignment=NSTextAlignmentLeft;
        _contentLabel.font=[UIFont systemFontOfSize:14];
        _contentLabel.textColor=[UIColor colorWithRed:17.0/255 green:17.0/255 blue:17.0/255 alpha:1.0];

    }
    return _contentLabel;
}

#pragma mark - 手势的实现函数
-(void)longTap:(UILongPressGestureRecognizer*)longTap
{
    if ([self.delegate respondsToSelector:@selector(messageContentViewLongPress:content:)]) {
        [self.delegate messageContentViewLongPress:self content:self.contentLabel.text];
    }
}
-(void)tapPress:(UITapGestureRecognizer*)tapPress
{
    if ([self.delegate respondsToSelector:@selector(messageContentViewTapPress:content:)]) {
        [self.delegate messageContentViewTapPress:self content:self.contentLabel.text];
    }
    
}

@end
