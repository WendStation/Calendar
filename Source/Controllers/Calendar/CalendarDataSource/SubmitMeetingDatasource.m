

#import "SubmitMeetingDatasource.h"


@interface SubmitMeetingDatasource ()

@end

@implementation SubmitMeetingDatasource

- (void)submitMeeting:(NSMutableDictionary *)paraDic succeed:(PostSubmitMeetingSuccessBlock)succeed
               failed:(PostSubmitMeetingFailedBlock)failed {
    
    [paraDic setObject:[CacheManager sharedInstance].accessToken forKey:@"access_token"];
    MBProgressHUD *hud = [AlertManager getAlertTextWithAss:@""];
    [hud show:YES];
    [[NetworkManager sharedInstance] postRequest:SUBMIT_MEETING_URL params:paraDic successBlock:^(NSDictionary *dict) {
        [hud hide:NO];
        succeed();
    } failedBlock:^(id object){
        [hud hide:NO];
        NSLog(@"submitMeeting请求失败");
        failed();
    }];
}


@end
