//
//  MoreViewController.m
//  Calendar
//
//  Created by 小华 on 15/10/19.
//  Copyright © 2015年 Robert Dimitrov. All rights reserved.
//

#import "MoreViewController.h"
#import "LoginViewController.h"

@interface MoreViewController ()<UITableViewDataSource,
                                   UITableViewDelegate,
                                   UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation MoreViewController

- (IBAction)changeTestServer:(id)sender {
    if ([sender isKindOfClass:[UISegmentedControl class]]) {
        UISegmentedControl *seg = (UISegmentedControl *)sender;
        switch (seg.selectedSegmentIndex) {
            case 0:
                [AlertManager showAlertText:@"只供技术部测试人员使用" withTitle:@"" sureAction:^{
                    [[NetworkManager sharedInstance] setupNetRequestFilters:BASE_NETWORK_URL_115];
                    [[ViewManager sharedInstance] showLoginView];
                } cancelAction:^{
                    
                }];
                break;
            case 1:
                [[NetworkManager sharedInstance] setupNetRequestFilters:BASE_NETWORK_URL_APLUS];
                break;
            case 2:
                [[NetworkManager sharedInstance] setupNetRequestFilters:BASE_NETWORK_URL_ADMIN];
                break;
            default:
                break;
        }
        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)syncScheduleSwitch:(UISwitch *)sender {
    if (sender.on) {
        [[EventStoreManager sharedInstance] checkEventStoreAccessForCalendar];
        [[CacheManager sharedInstance] setSyncToCalender:YES];
    } else {
        [[CacheManager sharedInstance] setSyncToCalender:NO];
    }
}

- (IBAction)logout:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"确定退出？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    alert.tag = 200;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if (alertView.tag == 200) {
            [[ViewManager sharedInstance] showLoginView];
        } else {
            NSLog(@"#######%@",alertView.message);
            if ([alertView.message isEqualToString:@"取消日程同步？"]) {
                
            } else {
                
            }
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView reloadData];
    // Do any additional setup after loading the view.
}

- (NSString *)currentVersion {
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDic objectForKey:@"CFBundleVersion"];
    return appVersion;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 3) {
        return 74.0f;
    } else {
        return 44.0f;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell0"];
        UILabel *verson = (UILabel *)[cell viewWithTag:1];
        NSString *versionStr = @"";
        if ([[NetworkManager sharedInstance].baseUrl isEqualToString:BASE_NETWORK_URL_ADMIN]) {
            versionStr = [NSString stringWithFormat:@"ADMIN  %@",[self currentVersion]];
        } else if ([[NetworkManager sharedInstance].baseUrl isEqualToString:BASE_NETWORK_URL_APLUS]) {
            versionStr = [NSString stringWithFormat:@"APLUS  %@",[self currentVersion]];
        } else  {
            versionStr = [NSString stringWithFormat:@"115  %@",[self currentVersion]];
        }
        verson.text = versionStr;

    } else if (indexPath.row == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell1"];
    } else if (indexPath.row == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell3"];
        UISwitch *control = (UISwitch *)[cell viewWithTag:2];
        [control addTarget:self action:@selector(syncScheduleSwitch:) forControlEvents:UIControlEventValueChanged];
        if ([[CacheManager sharedInstance] isSyncToCalender]) {
            control.on = YES;
        } else {
            control.on = NO;
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell2"];
    }
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
