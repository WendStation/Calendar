//
//  KeyboardView.h
//  MessageDemo
//
//  Created by wend on 15/12/9.
//  Copyright (c) 2015年 wufei. All rights reserved.
//

#import <UIKit/UIKit.h>
@class KeyboardView;
@protocol KeyboardViewDelegate <NSObject>

-(void)KeyboardVIew:(KeyboardView*)keyboardView textViewDidChang:(UITextView*)textView;
-(void)KeyboardVIew:(KeyboardView*)keyboardView textViewBegin:(UITextView*)textView;
-(BOOL)KeyboardVIew:(KeyboardView*)keyboardView sendMessage:(UITextView*)textView
     currentMessage:(NSString*)text;
-(void)KeyboardVIew:(KeyboardView *)keyboardView textViewHeightChange:(UITextView *)textView;
-(void)sendMessage;
//开始录音
-(void)beginRecord;
//结束录音
-(void)stopRecord;

@end

@interface KeyboardView : UIView
@property (nonatomic,strong) UIImageView *backImageView;
@property (nonatomic,strong) UITextView *textView;
@property(nonatomic,assign)id<KeyboardViewDelegate>delegate;

- (void)adjustTextViewHeightBy:(CGFloat)changeInHeight;
- (CGFloat)maxHeight;

@end
