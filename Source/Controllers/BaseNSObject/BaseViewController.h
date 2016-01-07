//
//  BaseViewController.h
//  Calendar
//
//  Created by 刘花椒 on 15/11/9.
//
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

- (void)showLoading:(BOOL)show;
- (void)removeAllHUDViews:(BOOL)animated;

@end
