//
//  ViewManager.m
//  Calendar
//
//  Created by 小华 on 15/10/20.
//
//

#import "ViewManager.h"
#import "RDVTabBarController.h"
#import "RDVTabBarItem.h"
#import "CLWeeklyCalendarView.h"
#import "CacheManager.h"
#import "ImManager.h"

@implementation ViewManager


+ (ViewManager *)sharedInstance
{
    static ViewManager *str;
    @synchronized(self){
        if (str==nil) {
            str=[[ViewManager alloc]init];
        }
        return str;
    }
}

-(AppDelegate *)getAppDelegate{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

-(void)showMainView {
    [[CacheManager sharedInstance] initData];
    if ([[CacheManager sharedInstance] hasLogin]) {
        [self showMainTabView];
    } else {
        [self showLoginView];
    }
}

-(void)showLoginView {
    [[CacheManager sharedInstance] removeUser];
    [self getAppDelegate].window.rootViewController = [self getLoginViewController];
}

- (void)showMainTabView {
    [[CacheManager sharedInstance] getUserLoginInfo];
    [self sendRequest];
    [[ImManager shareInstance] onStart];
    
    if([[CacheManager sharedInstance] isNeedAlertSyncToCalender]){
        [AlertManager showAlertText:@"是否开启同步日程？" withTitle:@"" sureAction:^{
            [[EventStoreManager sharedInstance] checkEventStoreAccessForCalendar];
            [[CacheManager sharedInstance] setSyncToCalender:YES];
        } cancelAction:^{
            [[CacheManager sharedInstance] setSyncToCalender:NO];
        }];
    }
    
    UIViewController *first = [CommonAPI getUIViewControllerForID:@"Calendar" formStoryboard:@"CalendarStoryboard"];
    UIViewController *second = [CommonAPI getUIViewControllerForID:@"Project" formStoryboard:@"ProjectStoryboard"];
    UIViewController *third = [CommonAPI getUIViewControllerForID:@"Knowledge" formStoryboard:@"KnowledgeStoryboard"];
    UIViewController *forth = [CommonAPI getUIViewControllerForID:@"Message" formStoryboard:@"MessageStoryboard"];
    UIViewController *fifth = [CommonAPI getUIViewControllerForID:@"More" formStoryboard:@"MoreStoryboard"];
    
    RDVTabBarController *tabBarController = [[RDVTabBarController alloc] init];
    [tabBarController setViewControllers:@[first, second, third,forth,fifth]];
    [self customizeTabBarForController:tabBarController];
    
    [self getAppDelegate].window.rootViewController = tabBarController;
}

- (void)customizeTabBarForController:(RDVTabBarController *)tabBarController {
    NSArray *tabBarItemImages = @[@"tabbar_icon_calendar", @"tabbar_icon_project", @"tabbar_icon_knowledge",@"tabbar_icon_im",@"tabbar_icon_more"];
    NSInteger index = 0;
    for (RDVTabBarItem *item in [[tabBarController tabBar] items]) {
        UIImage *selectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_selected",
                                                      [tabBarItemImages objectAtIndex:index]]];
        UIImage *unselectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_normal",
                                                        [tabBarItemImages objectAtIndex:index]]];
        [item setFinishedSelectedImage:selectedimage withFinishedUnselectedImage:unselectedimage];
        
        index++;
    }
    
}

- (CalendarViewController *)getScheduleViewController {
    return (CalendarViewController *)[CommonAPI getUIViewControllerForID:@"CalendarViewController" formStoryboard:@"CalendarStoryboard"];
}

- (LoginViewController *)getLoginViewController {
    return (LoginViewController *)[CommonAPI getUIViewControllerForID:@"LoginViewController" formStoryboard:@"MoreStoryboard"];
}


-(void)sendRequest {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[NetworkManager sharedInstance] syncAllStatusDefinitionDatas];
    });
}

@end
