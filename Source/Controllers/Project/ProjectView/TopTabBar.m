//
//  ProjectTopBar.m
//  Calendar
//
//  Created by 刘花椒 on 15/10/29.
//
//

#import "TopTabBar.h"

#define topButtonWidth ([[UIScreen mainScreen]bounds].size.width) / 3.0

static const NSInteger topButtonHeight = 44;

@interface TopTabBar ()

@property(nonatomic, strong)NSMutableArray *titleAry;
@property(nonatomic, strong)NSMutableArray *buttonsAry;

@end

@implementation TopTabBar

- (void)initWithSubviews:(NSMutableArray *)titleAry{
    self.backgroundColor = [UIColor whiteColor];
    self.titleAry = [[NSMutableArray alloc] initWithArray:titleAry];
    self.buttonsAry = [[NSMutableArray alloc ] initWithCapacity:0];
    [self buildSubViews];
    
}

- (void)buildSubViews{
    
    UIImageView *segmentLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, 43, SCREEN_WIDTH, 1)];
    segmentLine.backgroundColor = [UIColor clearColor];
    segmentLine.image = [UIImage imageNamed:@"line"];
    [self addSubview:segmentLine];
    
    for (NSInteger i = 0; i < [self.titleAry count]; i ++) {
        UIButton *tabButton = [UIButton buttonWithType:UIButtonTypeCustom];
        tabButton.frame = CGRectMake(i * topButtonWidth, 0, topButtonWidth, topButtonHeight);
        tabButton.backgroundColor = [UIColor clearColor];
        [tabButton setTitle:[self.titleAry objectAtIndex:i] forState:UIControlStateNormal];
        [tabButton setTitleColor:BLACK_COLOR forState:UIControlStateNormal];
        tabButton.titleLabel.textAlignment = NSTextAlignmentNatural;
        tabButton.tag = 100 + i;
        [tabButton addTarget:self action:@selector(tabBtnDidClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:tabButton];
        [self.buttonsAry addObject:tabButton];
        if (i == 0) {
            tabButton.selected = YES;
            [tabButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16]];
            [tabButton addSubview:self.bottomLine];
            self.currentSelectBtn = tabButton;
        }else {
            [tabButton.titleLabel setFont:[UIFont systemFontOfSize:16]];
        }
    }
    
}

- (void)tabBtnDidClicked:(UIButton *)button{
    if (self.currentSelectBtn == button) {
        return;
    }
    button.selected = YES;
    [self.currentSelectBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    self.currentSelectBtn.selected = NO;
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        [button.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:16]];
        [button addSubview:self.bottomLine];
        
    } completion:^(BOOL finished) {
    }];
    self.currentSelectBtn = button;
    if (self.delegate && [self.delegate respondsToSelector:@selector(tabButtonDidClicked:)]) {
        [self.delegate tabButtonDidClicked:button];
    }
}


- (UILabel *)bottomLine{
    if (!_bottomLine) {
        _bottomLine = [[UILabel alloc] initWithFrame:CGRectMake((topButtonWidth - evaluate(68)) / 2.0, 42, evaluate(68), 2)];
        _bottomLine.backgroundColor = BLUE_COLOR;
    }
    return _bottomLine;
}

@end
