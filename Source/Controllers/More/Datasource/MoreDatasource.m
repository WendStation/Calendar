//
//  MoreDatasource.m
//  Calendar
//
//  Created by 刘花椒 on 15/12/21.
//
//

#import "MoreDatasource.h"
#import "User.h"

@implementation MoreDatasource

- (void)postLogin:(NSString *)userName password:(NSString *)password succeed:(PostSucceed)succeed failed:(PostFailed)failed {
    NSDictionary *para = @{
                           @"username"    :userName,
                           @"password"    :password
                           };
    NSString *requestUrl = [NSString stringWithFormat:@"%@",LOGIN_URL];
    [[NetworkManager sharedInstance] postRequest:requestUrl params:para successBlock:^(NSDictionary *dict) {
        if ([[dict objectForKey:@"code"] intValue] == NETWORK_CODE_SUCCESS) {
            NSMutableDictionary *userDict = [NSMutableDictionary dictionaryWithDictionary:[dict objectForKey:@"data"]];
            [userDict setObject:userName forKey:@"userName"];
            User *user = [[User alloc] init];
            [user setValuesForKeysWithDictionary:userDict];
            [[PlistCacheManager shareInstance] saveUserToCache:user];
        }
        succeed (dict);
    } failedBlock:^(id object) {
        failed (object);
    }];
}

@end
