//
//  BaseViewController.m
//  Calendar
//
//  Created by 刘花椒 on 15/11/9.
//
//

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)showLoading:(BOOL)show{
    if (show) {
        CGRect hudFrame = self.view.bounds;
        MBProgressHUD *hud = [[MBProgressHUD alloc] initWithFrame:hudFrame];
        hud.detailsLabelText = NSLocalizedStringFromTable(@"载入中...", RS_CURRENT_LANGUAGE_TABLE, nil);
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.removeFromSuperViewOnHide = YES;
        [self.view addSubview:hud];
        [hud show:YES];
    } else {
        [self removeAllHUDViews:NO];
    }
}

- (void)removeAllHUDViews:(BOOL)animated
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
