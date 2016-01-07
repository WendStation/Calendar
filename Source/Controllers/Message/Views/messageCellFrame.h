//
//  messageCellFrame.h
//  MessageDemo
//
//  Created by wufei on 15/12/10.
//  Copyright (c) 2015年 wufei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ChatMessageListItem.h"
#import <UIKit/UIKit.h>

@interface messageCellFrame : NSObject

@property(nonatomic,assign)CGRect iconRect;
@property(nonatomic,assign)CGRect messageViewRect;
@property(nonatomic,strong)ChatMessageListItem *model;
@property(nonatomic,assign)CGFloat cellHeight;
@property(nonatomic,assign)CGRect nameRect;
@property(nonatomic,assign)CGRect timeRect;
@property(nonatomic,assign)CGRect indicatorRect;
@property(nonatomic,assign)CGRect errorImageRect;
@property(nonatomic,assign)BOOL isTimeShow;
@property(nonatomic,assign)BOOL isIndeicatorShow;
@property(nonatomic,assign)BOOL isErrorImageShow;
@property(nonatomic,strong)NSString* currentTimeStr;

@end
