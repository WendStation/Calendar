//
//  RegisterApi.m
//  Solar
//
//  Created by TangQiao on 11/8/14.
//  Copyright (c) 2014 fenbi. All rights reserved.
//


#import "SyncCustomer.h"
#import "CacheManager.h"

static BOOL syncFlag = true;

@interface SyncCustomer ()

@end

@implementation SyncCustomer

- (void)syncCustomer {
    
    if (!self.syncFlag || ![[NetworkManager sharedInstance] checkNetAndToken]) {
        return;
    }
    NSDictionary *para = @{
                           @"access_token":[CacheManager sharedInstance].accessToken,
                           @"afterDate": [CacheManager sharedInstance].lastSyncCustomerTime
                           };
    //这里用于当上次请求还没完成返回时不再请求
    syncFlag = false;
    [[NetworkManager sharedInstance] postRequest:GET_UESER_URL params:para successBlock:^(NSDictionary *dict) {
        syncFlag = true;
        if (dict) {
            NSString *time = (NSString *)[[dict objectForKey:@"data"] objectForKey:@"date"];
            NSArray *users = (NSArray *)[[dict objectForKey:@"data"] objectForKey:@"users"];
            
            
            if (time) {
                [[CacheManager sharedInstance] saveSyncCustomerTime:time];
            }
            if (users && users.count > 0) {
                if ([[para objectForKey:@"afterDate"] isEqualToString:@"2000-01-01 00:00:00"]) {
                    [[CustomerManager sharedInstance] syncRemoveAllUser];
                }

                
                [[CustomerManager sharedInstance] asyncAddOrUpdateUser:users withBlock:^() {
                    [[CacheManager sharedInstance] refreshScheduleInfo: @""];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"schedulesChanged" object:nil];
                }];
            }
        }
        
    } failedBlock:^(id object){
        NSLog(@"syncCustomer请求失败");
        syncFlag = true;
    }];
}



-(BOOL)syncFlag {
    return syncFlag;
}

@end
