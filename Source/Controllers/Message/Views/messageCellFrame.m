//
//  messageCellFrame.m
//  MessageDemo
//
//  Created by wufei on 15/12/10.
//  Copyright (c) 2015年 wufei. All rights reserved.
//

#import "messageCellFrame.h"

static const float labelMaxWidth = 200.0f;
static const float labelMaxHeight = 50.0f;
static const float timeLabelToTop_Y = 15.0f;
static const float iconMarginX = 10.0f;
static const float iconMarginY = 15.0f;
static const float iconWidth = 44.0f;
static const float iconHeight = 44.0f;
static const float blankSpace = 10.0f; //控件之间间距
static const float messageContent_LabelToBackground = 14.0f;
static const float errorImage_Width = 30.0f;
static const float cellMaxYToContentMaxY = 10.0f;


@implementation messageCellFrame

-(void)setModel:(ChatMessageListItem *)model
{
    CGSize winSize = [UIScreen mainScreen].bounds.size;
    if (self.isTimeShow) {
        CGSize size = CGSizeMake(labelMaxWidth, labelMaxHeight);
        if (self.currentTimeStr) {
            CGRect labelRect = [self.currentTimeStr boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine attributes:nil context:nil];
            self.timeRect = CGRectMake(SCREEN_WIDTH/2.0-(labelRect.size.width+10)/2, timeLabelToTop_Y, labelRect.size.width, labelRect.size.height+4);
        }
    } else {
        self.timeRect = CGRectZero;
    }
    _model = model;
    
    CGFloat iconX = iconMarginX;
    CGFloat iconY = iconMarginY;
    CGFloat contentX = CGFLOAT_MIN;
    if(![model.fromUser isEqualToString:[[CacheManager sharedInstance] userId]]){
        self.iconRect = CGRectMake(iconX, iconY + CGRectGetMaxY(self.timeRect), iconWidth, iconHeight);
        contentX = CGRectGetMaxX(self.iconRect) + blankSpace;
    }else{
        iconX = winSize.width - iconMarginX - iconWidth;
        self.iconRect = CGRectMake(iconX, iconY+ CGRectGetMaxY(self.timeRect), iconWidth, iconHeight);
    }
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:14]};
    CGSize contentSize = [model.content boundingRectWithSize:CGSizeMake(labelMaxWidth, MAXFLOAT) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attributes context:nil].size;
    if([model.fromUser isEqualToString:[[CacheManager sharedInstance] userId]]){
        contentX = iconX - blankSpace - contentSize.width - 2 * messageContent_LabelToBackground;
         self.messageViewRect = CGRectMake(contentX - 5, CGRectGetMinY(self.iconRect) + 1, contentSize.width + 2 *messageContent_LabelToBackground + 2 + 8, contentSize.height + 2 * messageContent_LabelToBackground + 2);
        //设置菊花的位置
        self.indicatorRect = CGRectMake(contentX - errorImage_Width - blankSpace, CGRectGetMinY(self.messageViewRect) + CGRectGetHeight(self.messageViewRect) / 2- errorImage_Width / 2, errorImage_Width, errorImage_Width);
        //设置错误图片的位置
        self.errorImageRect = CGRectMake(contentX - errorImage_Width - blankSpace, CGRectGetMinY(self.messageViewRect) + CGRectGetHeight(self.messageViewRect) / 2-errorImage_Width / 2, errorImage_Width, errorImage_Width);
        self.nameRect = CGRectZero;
    } else {
        //设置姓名的位置
        CGSize size = CGSizeMake(labelMaxWidth, labelMaxHeight);
        NSString *name = model.name;
        CGRect labelRect = [name boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine attributes:nil context:nil];
        self.nameRect = CGRectMake(contentX, CGRectGetMinY(self.iconRect), labelRect.size.width + 2, labelRect.size.height);
        self.messageViewRect = CGRectMake(contentX - 5, CGRectGetMaxY(self.nameRect) + 5,contentSize.width + 2 *messageContent_LabelToBackground + 2 + 8, contentSize.height + 2 * messageContent_LabelToBackground + 2);
    }
    self.cellHeight = MAX(CGRectGetMaxY(self.messageViewRect), CGRectGetMaxY(self.iconRect)) + cellMaxYToContentMaxY;
}


@end
