//
//  UIPlaceHolderTextView.h
//  Calendar
//
//  Created by 刘花椒 on 15/11/13.
//
//

#import <UIKit/UIKit.h>

@interface UIPlaceHolderTextView : UITextView

@property(nonatomic, strong) UILabel *placeHolderLabel;
@property(nonatomic, strong) NSString *placeholder;
@property(nonatomic, strong) UIColor *placeholderColor;

-(void)textChanged:(NSNotification*)notification;


@end
