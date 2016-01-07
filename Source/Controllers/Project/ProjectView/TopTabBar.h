//
//  ProjectTopBar.h
//  Calendar
//
//  Created by 刘花椒 on 15/10/29.
//
//

#import <UIKit/UIKit.h>


@protocol ProjectTopBarDelegate <NSObject>

- (void)tabButtonDidClicked:(UIButton *)button;

@end

@interface TopTabBar : UIView

@property(nonatomic, weak) id<ProjectTopBarDelegate>delegate;
@property(nonatomic, strong)UIButton *currentSelectBtn;
@property(nonatomic, strong)UILabel *bottomLine;

- (void)initWithSubviews:(NSMutableArray *)titleAry;

@end
