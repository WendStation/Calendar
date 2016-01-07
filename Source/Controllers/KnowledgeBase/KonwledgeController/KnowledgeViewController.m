//
//  KnowledgeViewController.m
//  Calendar
//
//  Created by 小华 on 15/10/19.
//  Copyright © 2015年 Robert Dimitrov. All rights reserved.
//

#import "KnowledgeViewController.h"
#import "SearchFounderViewController.h"
#import "SearchfundViewController.h"
#import "SearchColleagueViewController.h"

@interface KnowledgeViewController ()

@property(nonatomic, strong)NSArray *knowleageAry;

@end

@implementation KnowledgeViewController

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.rdv_tabBarController.tabBarHidden) {
        [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.knowleageAry = @[@"投资人",@"基金",@"你的同事"];
    [self createKnowleageSubviews];
    // Do any additional setup after loading the view.
}

- (void)createKnowleageSubviews{
    CGFloat buttonHeight = (SCREEN_HEIGHT - 113) / self.knowleageAry.count;
    
    for (NSInteger i = 0; i < [self.knowleageAry count]; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.backgroundColor = [UIColor clearColor];
        button.frame = CGRectMake(0, buttonHeight * i, SCREEN_WIDTH, buttonHeight);
        button.tag = 100 + i;
        [button addTarget:self action:@selector(buttonBackGroundHighlighted:) forControlEvents:UIControlEventTouchDown];
        [button addTarget:self action:@selector(goKnowleageLibrary:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        
        UIImage *line = [UIImage imageNamed:@"kb_waveline"];
        UIImageView *lineView = [[UIImageView alloc] initWithImage:line];
        lineView.backgroundColor = [UIColor clearColor];
        lineView.frame = CGRectMake(0, buttonHeight - line.size.height, SCREEN_WIDTH, line.size.height);
        [button addSubview:lineView];
        
        UIImage *icon = nil;
        if (i == 0) {
            icon = [UIImage imageNamed:@"kb_icon_lp"];
        }else if (i == 1) {
            icon = [UIImage imageNamed:@"kb_icon_fund"];
        }else{
            icon = [UIImage imageNamed:@"kb_icon_colleague"];
        }
        UIImageView *knowleageType = [[UIImageView alloc] initWithImage:icon];
        knowleageType.backgroundColor = [UIColor clearColor];
        knowleageType.frame = CGRectMake(evaluate(44),(buttonHeight - line.size.height - icon.size.height)/2.0 , icon.size.width, icon.size.height);
        [button addSubview:knowleageType];
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(knowleageType.right + evaluate(29), (buttonHeight - line.size.height - 20)/2.0, 100, 20)];
        title.backgroundColor = [UIColor clearColor];
        title.text = [self.knowleageAry objectAtIndex:i];
        [button addSubview:title];
        
        UIImage *arrowIcon = [UIImage imageNamed:@"kb_arrow"];
        UIImageView *arrowView = [[UIImageView alloc] initWithImage:arrowIcon];
        arrowView.backgroundColor = [UIColor clearColor];
        arrowView.frame = CGRectMake(SCREEN_WIDTH - evaluate(44) - arrowIcon.size.width, (buttonHeight - line.size.height - arrowIcon.size.height)/2.0, arrowIcon.size.width, arrowIcon.size.height);
        [button addSubview:arrowView];
    }
}

- (void)buttonBackGroundHighlighted:(UIButton *)sender
{
    sender.backgroundColor = RGBCOLOR(210, 210, 210);
}

- (void)goKnowleageLibrary:(id)sender{
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
    UIButton *button = (UIButton *)sender;
    button.backgroundColor = [UIColor clearColor];

    if (button.tag == 100) {
        SearchFounderViewController *vc = [[SearchFounderViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }else if (button.tag == 101) {
        SearchfundViewController *vc = [[SearchfundViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }else{
        SearchColleagueViewController *vc = [[SearchColleagueViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
