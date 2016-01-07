// RDVAppDelegate.m
// RDVTabBarController
//
// Copyright (c) 2013 Robert Dimitrov
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "AppDelegate.h"
#import "RDVTabBarController.h"
#import "RDVTabBarItem.h"

#import "APService.h"
#import "mmDAO.h"
#import "MobClick.h"

#import "ViewManager.h"
#import "NetworkManager.h"
#import "CacheManager.h"
#import "ImManager.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [[mmDAO instance] setupEnvModel:@"Model" DbFile:@"Ethercap"];
    [[NetworkManager sharedInstance] setupNetRequestFilters:BASE_NETWORK_URL_ADMIN];
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [[ViewManager sharedInstance] showMainView];
    
    
    [self.window makeKeyAndVisible];
    [self customizeInterface];
    
    [self umengTrack];
    
    
    
    //向微信注册
    [WXApi registerApp:@"wx1fe54f6fc3be589a"];
    
    [APService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound |
                                                    UIUserNotificationTypeAlert)
                                        categories:nil];
    
    // Required
    [APService setupWithOption:launchOptions];
    
    self.syncC = [[SyncCustomer alloc] init];
    self.syncS = [[SyncSchedule alloc] init];
    [self.syncC syncCustomer];
    
    return YES;
}

#pragma mark - Methods



- (void)customizeInterface {
    UINavigationBar *navigationBarAppearance = [UINavigationBar appearance];
    
    NSDictionary *textAttributes = @{
                       NSFontAttributeName: [UIFont boldSystemFontOfSize:18],
                       NSForegroundColorAttributeName: RGBCOLOR(255,255,255)
                       };
    
    [navigationBarAppearance setBarTintColor: RGBCOLOR(54,53,59)];
    [navigationBarAppearance setTitleTextAttributes:textAttributes];
    
    [navigationBarAppearance setTintColor:RGBCOLOR(255,255,255)];
}



- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [APService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Required
    [APService handleRemoteNotification:userInfo];
    [[[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"--%@", userInfo] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil] show];
//    NSLog(@"111:%@",userInfo);
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // IOS 7 Support Required
    [APService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if (!_timer) {
        _timer =  [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(timerFunction) userInfo:nil repeats:YES];
    }
    [[ImManager shareInstance] onStart];
}

-(void)applicationDidEnterBackground:(UIApplication *)application
{
    [_timer invalidate];
    _timer = nil;
    [[ImManager shareInstance] onStop];
    [self saveContext];
    
    if ([CacheManager sharedInstance].changedScheduleData.count > 0) {
        [[PlistCacheManager shareInstance] saveChangedScheduleData:[CacheManager sharedInstance].changedScheduleData];
    }
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


-(UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    if (_isFull) {
        return UIInterfaceOrientationMaskAll;
    }
    else {
        return UIInterfaceOrientationMaskPortrait;
    }
}


-(void)timerFunction
{
    [self.syncC syncCustomer];
    [self.syncS syncScheduleApi:nil withBlock:nil];
    
}

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    return [WXApi handleOpenURL:url delegate:self];

}


-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [WXApi handleOpenURL:url delegate:self];
}

-(void) onReq:(BaseReq*)req
{
}


-(void) onResp:(BaseResp*)resp
{
    NSLog(@"onResp:%@",resp);
    NSLog(@"errStr %@",[resp errStr]);
    NSLog(@"errCode %d",[resp errCode]);
    NSLog(@"type %d",[resp type]);

}



- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)saveContext
{
    NSLog(@"++++++++++++++++++++saveContext++++++++++++++++++++");
    NSError *error = nil;
    if ([[mmDAO instance].mainObjectContext hasChanges]) {
        [[mmDAO instance].mainObjectContext save:&error];
    }
    
    if ([[mmDAO instance].bgObjectContext hasChanges]) {
        [[mmDAO instance].bgObjectContext save:&error];
    }
}


- (void)umengTrack {
    [MobClick setCrashReportEnabled:NO]; // 如果不需要捕捉异常，注释掉此行
//    [MobClick setLogEnabled:YES];  // 打开友盟sdk调试，注意Release发布时需要注释掉此行,减少io消耗
    [MobClick setAppVersion:XcodeAppVersion]; //参数为NSString * 类型,自定义app版本信息，如果不设置，默认从CFBundleVersion里取
    //
    [MobClick startWithAppkey:UMENG_APPKEY reportPolicy:(ReportPolicy) REALTIME channelId:nil];
    //   reportPolicy为枚举类型,可以为 REALTIME, BATCH,SENDDAILY,SENDWIFIONLY几种
    //   channelId 为NSString * 类型，channelId 为nil或@""时,默认会被被当作@"App Store"渠道
    
//    [MobClick checkUpdate];   //自动更新检查, 如果需要自定义更新请使用下面的方法,需要接收一个(NSDictionary *)appInfo的参数
    [MobClick checkUpdateWithDelegate:self selector:@selector(updateMethod:)];
    
    [MobClick updateOnlineConfig];  //在线参数配置
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onlineConfigCallBack:) name:UMOnlineConfigDidFinishedNotification object:nil];
    
}

- (void)onlineConfigCallBack:(NSNotification *)note {
    
//    NSLog(@"online config has fininshed and note = %@", note.userInfo);
}

- (void)updateMethod:(NSDictionary *)appInfo {
    if ([appInfo objectForKey:@"path"]) {
        self.updateUrl = [NSString stringWithFormat:@"%@", [appInfo objectForKey:@"path"]];
    }
    
    if ([[appInfo objectForKey:@"update"] boolValue] && self.updateUrl && self.updateUrl.length > 10) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"最新版本：%@", [appInfo objectForKey:@"version"]] message:[NSString stringWithFormat:@"%@", [appInfo objectForKey:@"update_log"]] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"前往更新", nil];
        alert.tag = 1;
        [alert show];
    }
    
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag != 1) {
        return;
    }
    switch (buttonIndex) {
        case 0:{
            
            break;
        }
        case 1:{
            NSURL *url = [[NSURL alloc] initWithString:self.updateUrl];
            [[UIApplication sharedApplication] openURL:url];
            exit(0);
            break;
        }
        default:
            break;
    }
}


@end
