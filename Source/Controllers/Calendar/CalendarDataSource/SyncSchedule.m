//
//  Registerself.m
//  Solar
//
//  Created by TangQiao on 11/8/14.
//  Copyright (c) 2014 fenbi. All rights reserved.
//

#import "SyncSchedule.h"
#import "CacheManager.h"
#import "ScheduleManager.h"

//这个字符串类型是为了网络请求传参数
static NSString *forceSync = @"true";

@interface SyncSchedule ()


@end

@implementation SyncSchedule

- (instancetype)init{
    if (self = [super init]) {
    }
    return self;
}


- (void)syncScheduleApi:(NSMutableArray *)scheduleArray withBlock:(sync_schedule_block)block {
    if (![[NetworkManager sharedInstance] checkNetAndToken]) {
        return;
    }
    if (!scheduleArray) {
        scheduleArray = [[NSMutableArray alloc] init];
    }
    if ([CacheManager sharedInstance].changedScheduleData.count > 0) {
        NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!changedScheduleData 不该有数据的!!!!!!!!!!!!!!!!!!!!!!!:%@", [CacheManager sharedInstance].changedScheduleData);
        [scheduleArray addObjectsFromArray:[CacheManager sharedInstance].changedScheduleData];
    }
    
    NSString *dataStr = @"[]";
    if (scheduleArray.count > 0) {
        dataStr = [CommonAPI jsonStringWithArray:scheduleArray];
    }
    NSDictionary *para = @{
                           @"access_token":[CacheManager sharedInstance].accessToken,
                           @"forceSync": forceSync,
                           @"lastSyncTime": [CacheManager sharedInstance].lastSyncSchedulesTime,
                           @"data": dataStr
                           };
    
    MBProgressHUD *hud = [AlertManager getAlertTextWithAss:@""];
    if ([self forceSync] || scheduleArray.count > 0) {
        [hud show:YES];
    }
    
    [[NetworkManager sharedInstance] postRequest:SUBMIT_SCHEDULES_URL params:para successBlock:^(NSDictionary *dict) {
        [hud hide:NO];
        
//        NSLog(@"日程请求参数：%@",para);
//        NSLog(@"日程请求接口：%@",SUBMIT_SCHEDULES_URL);
        
        forceSync = @"false";
        if (dict) {
            NSString *time = (NSString *)[[dict objectForKey:@"data"] objectForKey:@"time"];
            NSArray *schedules = (NSArray *)[[dict objectForKey:@"data"] objectForKey:@"schedules"];
            NSArray *s = (NSArray *)[[dict objectForKey:@"data"] objectForKey:@"s"];
            NSArray *scheduleIds = (NSArray *)[[dict objectForKey:@"data"] objectForKey:@"scheduleIds"];
            
            if (time) {
                [[CacheManager sharedInstance] saveSyncScheduleTime:time];
            }
            
            //更新发生修改的日程缓存
            if (schedules || s) {
                if (scheduleIds) {
                    for (id tmp in scheduleIds) {
                        int number = [tmp intValue];
                        for (id tmp2 in [[CacheManager sharedInstance] changedScheduleData]) {
                            NSDictionary *dic = (NSDictionary *)tmp2;
                            if ([[dic objectForKey:@"scheduleId"] intValue] == number) {
                                [[[CacheManager sharedInstance] changedScheduleData] removeObject:tmp2];
                                NSLog(@"remove changedSchedulesData scheduleId:%d----left:%ld",number, [[CacheManager sharedInstance] changedScheduleData].count);
                                break;
                            }
                        }
                    }
                }
                
                //更新日程数据库
                NSMutableArray *array = [[NSMutableArray alloc] init];
                if (s && s.count > 0) {
                    [array addObjectsFromArray:s];
                }
                if (array.count == 0) {
                    [array addObjectsFromArray:schedules];
                }
                
                if (array.count > 0) {
                    for (id new in array) {
                        NSDictionary *newDic = (NSDictionary *)new;
                        //这里要处理增加日程时_changedSchedulesData里的缓存没有日程id的情况
                        for (id tmp2 in [[CacheManager sharedInstance] changedScheduleData]) {
                            NSDictionary *dic = (NSDictionary *)tmp2;
                            if ([[dic objectForKey:@"scheduleId"] intValue] == 0 &&
                                [[NSString stringWithFormat:@"%@", [newDic objectForKey:@"localId"]] longLongValue] == [[dic objectForKey:@"localId"] longValue]) {
                                [[[CacheManager sharedInstance] changedScheduleData] removeObject:tmp2];
                                NSLog(@"remove changedSchedulesData localId:%ld----left:%ld",[[dic objectForKey:@"localId"] longValue], [[CacheManager sharedInstance] changedScheduleData].count);
                                break;
                            }
                        }
                        
                    }
                    
                    [[ScheduleManager sharedInstance] syncAddOrUpdateSchedule:array];
                    
                    [[CacheManager sharedInstance] refreshScheduleInfo:[CacheManager sharedInstance].userId];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"schedulesChanged" object:nil];
                    
                }
            }
            
            if (block != nil) {
                block(dict);
            }
             
        }
        
        
    } failedBlock:^(id object){
        [hud hide:NO];
        if(scheduleArray && scheduleArray.count > 0) {
            [[CacheManager sharedInstance].changedScheduleData addObjectsFromArray: scheduleArray];
        }//去重
        NSLog(@"syncScheduleApi请求失败");
        
    }];
}


- (void)checkOthersScheduleApi:(NSString *)userId withBlock:(sync_schedule_block)block {
    NSDictionary *para = @{@"access_token":[CacheManager sharedInstance].accessToken};
    
    MBProgressHUD *hud = [AlertManager getAlertTextWithAss:@""];
    [hud show:YES];
    NSString *url = [NSString stringWithFormat:@"%@%@",GET_OTHERS_SCHEDULE_INFO_URL, userId];
    [[NetworkManager sharedInstance] postRequest:url params:para successBlock:^(NSDictionary *dict) {
        [hud hide:NO];
        if (dict) {
            NSArray *schedules = (NSArray *)[dict objectForKey:@"data"];
            //更新发生修改的日程缓存
            if (schedules) {
                //更新日程数据库
                if (schedules.count > 0) {
                    [[ScheduleManager sharedInstance] syncAddOrUpdateSchedule:schedules];
                    [[CacheManager sharedInstance] refreshScheduleInfo:userId];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"schedulesChanged" object:nil];
                }
            }
            if (block != nil) {
                block(dict);
            }
            
        }
        
        
    } failedBlock:^(id object){
        [hud hide:NO];
        NSLog(@"syncScheduleApi请求失败");
        
    }];
}

- (BOOL)forceSync{
    return [forceSync isEqualToString:@"true"];
}

- (void)getUserPhoneApi:(NSNumber *)userId type:(NSString *)type block:(Complete)block {
    NSDictionary *para = @{@"access_token":[CacheManager sharedInstance].accessToken};
    NSString *url = [NSString stringWithFormat:@"%@%@/%@",GET_UESER_PRIVACY_URL, userId,type];
    [[NetworkManager sharedInstance] postRequest:url params:para successBlock:^(NSDictionary *dict) {
        if (dict) {
            NSString *result;
            if ([dict objectForKey:@"data"] && [[dict objectForKey:@"data"] objectForKey:type]) {
                result = [[dict objectForKey:@"data"] objectForKey:type];
            }
            block (result);
        }
    } failedBlock:^(id object) {
        
    }];
}

@end
