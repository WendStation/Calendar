//
//  ScheduleManager.m
//  Ethercap
//
//  Created by 小华 on 15/5/15.
//  Copyright (c) 2015年 Robert Dimitrov. All rights reserved.
//

#import "ScheduleManager.h"



@implementation ScheduleManager

+ (ScheduleManager *)sharedInstance {
    static ScheduleManager *str;
    @synchronized(self){
        if (str==nil) {
            str=[[ScheduleManager alloc]init];
        }
        return str;
    }
}


-(void)updateSchedule:(Schedule *)schedule fromDictionary:(NSDictionary *)new {
    schedule.accepted = [new objectForKey:@"accepted"];
    schedule.comment = [new objectForKey:@"comment"];
    schedule.confirmed = [NSNumber numberWithInt:[[new objectForKey:@"confirmed"] intValue]];
    schedule.createBy = [NSNumber numberWithInt:[[new objectForKey:@"createBy"] intValue]];
    schedule.creationTime = [NSDate dateFromString:[new objectForKey:@"creationTime"]];
    schedule.feedback = [NSNumber numberWithInt:[[new objectForKey:@"feedback"] intValue]];
    schedule.founderId = [new objectForKey:@"founderId"];
    schedule.investorId = [new objectForKey:@"investorId"];
    schedule.city = [new objectForKey:@"city"];
    schedule.localId = [NSNumber numberWithInt:[[new objectForKey:@"localId"] intValue]];
    schedule.location = [new objectForKey:@"location"];
    schedule.meetingId = [NSNumber numberWithInt:[[new objectForKey:@"meetingId"] intValue]];
    schedule.projectId = [NSNumber numberWithInt:[[new objectForKey:@"projectId"] intValue]];
    schedule.scheduleId = [NSNumber numberWithInt:[[new objectForKey:@"scheduleId"] intValue]];
    if ([new objectForKey:@"startTime"] == nil || [[new objectForKey:@"startTime"] isEqualToString:@"0000-00-00 00:00:00"]) {
        schedule.startTime = [NSDate dateFromString:@"2000-01-01 00:00:01"];
        [AlertManager showAlertText:[NSString stringWithFormat:@"ID为%@的日程无开始时间,请联系技术部", schedule.scheduleId] withTitle:@"" sureAction:^{
            
        }];
    }
    else {
        schedule.startTime = [NSDate dateFromString:[new objectForKey:@"startTime"]];
    }
    if ([new objectForKey:@"endTime"] == nil || [[new objectForKey:@"endTime"] isEqualToString:@"0000-00-00 00:00:00"]) {
        schedule.endTime = [NSDate dateFromString:@"2000-01-01 00:00:01"];
        [AlertManager showAlertText:[NSString stringWithFormat:@"ID为%@的日程无结束时间,请联系技术部", schedule.scheduleId] withTitle:@"" sureAction:^{
            
        }];
    }
    else {
        schedule.endTime = [NSDate dateFromString:[new objectForKey:@"endTime"]];
    }
    
    schedule.status = [new objectForKey:@"status"];
    schedule.type = [NSNumber numberWithInt:[[new objectForKey:@"type"] intValue]];
    schedule.updateTime = [NSDate dateFromString:[new objectForKey:@"updateTime"]];
    schedule.userId = [new objectForKey:@"userId"];
}


-(NSMutableDictionary *)getDictionaryfromSchedule:(Schedule *)schedule {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:schedule.accepted?schedule.accepted:@"" forKey:@"accepted"];
    [dic setObject:schedule.comment?schedule.comment:@"" forKey:@"comment"];
    [dic setObject:schedule.confirmed?schedule.confirmed:@"" forKey:@"confirmed"];
    [dic setObject:schedule.createBy forKey:@"createBy"];
    [dic setObject:schedule.creationTime forKey:@"creationTime"];
    if (schedule.endTime) {
        [dic setObject:schedule.endTime forKey:@"endTime"];
    } else {
        NSString *endTime = [NSString stringWithFormat:@"%@",schedule.scheduleId];
        [AlertManager showAlertText:@"日程结束时间错误" withTitle:endTime sureAction:^{
            
        }];
        [self syncDeleteSchedule:schedule.scheduleId];
        return nil;
    }
    if (schedule.startTime) {
        [dic setObject:schedule.startTime forKey:@"startTime"];
    } else {
        NSString *startTime = [NSString stringWithFormat:@"%@",schedule.scheduleId];
        [AlertManager showAlertText:@"日程开始时间错误" withTitle:startTime sureAction:^{

        }];
        [self syncDeleteSchedule:schedule.scheduleId];
        return nil;
    }
    [dic setObject:schedule.updateTime forKey:@"updateTime"];
    [dic setObject:schedule.feedback?schedule.feedback:@"" forKey:@"feedback"];
    [dic setObject:schedule.founderId?schedule.founderId:@"" forKey:@"founderId"];
    [dic setObject:schedule.investorId?schedule.investorId:@"" forKey:@"investorId"];
    [dic setObject:schedule.localId forKey:@"localId"];
    [dic setObject:schedule.location?schedule.location:@"" forKey:@"location"];
    [dic setObject:schedule.meetingId?schedule.meetingId:@"" forKey:@"meetingId"];
    [dic setObject:schedule.projectId?schedule.projectId:@"" forKey:@"projectId"];
    [dic setObject:schedule.scheduleId?schedule.scheduleId:@"" forKey:@"scheduleId"];
    [dic setObject:schedule.city?schedule.city:@"" forKey:@"city"];
    [dic setObject:schedule.status?schedule.status:@"" forKey:@"status"];
    [dic setObject:schedule.type?schedule.type:@"" forKey:@"type"];
    [dic setObject:schedule.userId?schedule.userId:@"" forKey:@"userId"];
    return dic;
}

-(void)moveSchedulesToDB:(NSArray *)array {
    
    for (NSDictionary *info in array) {
        Schedule *schedule = [Schedule createNew];
        [self updateSchedule:schedule fromDictionary:info];
    }
    [[mmDAO instance] save:^(NSError *error) {
        if (error) {
            NSLog(@"!!!!!!!!!!!!!!!!!!moveSchedulesToDB save error:%@", error.description);
        }
    }];
    
}

//同步获取个数
-(NSInteger)syncGetScheduleCount {
    return [Schedule filter:nil orderby:@[@"scheduleId"] offset:0 limit:0].count;
}

-(NSMutableArray *)syncGetAllSchedule {
    NSArray *array = [Schedule filter:nil orderby:@[@"scheduleId"] offset:0 limit:0];
    NSMutableArray *value = [[NSMutableArray alloc] init];
    for (Schedule *info in array) {
        NSMutableDictionary *dic = [self getDictionaryfromSchedule:info];
        if (dic) {
            [value addObject:dic];
        }
        
    }
    return value;
}


-(NSMutableArray *)syncGetScheduleFor:(NSString *)userId {
    if (userId.length == 0) {
        return [self syncGetAllSchedule];
    }
    NSString *rule = [NSString stringWithFormat:@"(^%@,.*)|(.*,%@,.*)|(.*,%@$)|(^%@$)", userId, userId, userId, userId];
    NSArray *array = [Schedule filter:[NSString stringWithFormat:@"userId MATCHES '%@'",rule] orderby:@[@"scheduleId"] offset:0 limit:0];
    NSMutableArray *value = [[NSMutableArray alloc] init];
    for (Schedule *info in array) {
        NSMutableDictionary *dic = [self getDictionaryfromSchedule:info];
        if (dic) {
            [value addObject:dic];
        }
    }
    return value;
}

-(NSArray *)syncGetUserSchedule:(NSString *)userId {
    NSArray *schedules = [NSArray array];
    if (userId.length == 0) {
        return schedules;
    }
    NSString *rule = [NSString stringWithFormat:@"(^%@,.*)|(.*,%@,.*)|(.*,%@$)|(^%@$)", userId, userId, userId, userId];
    schedules = [Schedule filter:[NSString stringWithFormat:@"userId MATCHES '%@'",rule] orderby:@[@"scheduleId"] offset:0 limit:0];
    return schedules;
}

//更新信息
-(void)syncAddOrUpdateSchedule:(NSArray *)array {
    for (NSDictionary* info in array) {
        int scheduleId = [[info objectForKey:@"scheduleId"] intValue];
        NSArray *results = [Schedule filter:[NSString stringWithFormat:@"scheduleId=%d",scheduleId] orderby:@[@"scheduleId"] offset:0 limit:0];
        if (results && results.count == 1) {
            Schedule *schedule = [results objectAtIndex:0];
            [self updateSchedule:schedule fromDictionary:info];
        }
        else {
            if(results && results.count > 1){
                for (id tmp in results) {
                    NSLog(@"!!!!!!!!!!!!!!!error search mult schedule!!!!!!!!!:%d",scheduleId);
                    [[mmDAO instance].mainObjectContext deleteObject:tmp];
                }
            }
            Schedule *schedule = [Schedule createNew];
            [self updateSchedule:schedule fromDictionary:info];
        }
    }
    [[mmDAO instance] save:^(NSError *error) {
        if (error) {
            NSLog(@"!!!!!!!!!!!!!!!!!!syncAddOrUpdateSchedule save error:%@", error.description);
        }
    }];
    
}


-(void)syncDeleteSchedule:(NSNumber *)scheduleId {
    NSArray *results = [Schedule filter:[NSString stringWithFormat:@"scheduleId=%@",scheduleId] orderby:@[@"scheduleId"] offset:0 limit:0];
    for (id obj in results) {
        [[mmDAO instance].mainObjectContext deleteObject:obj];
    }
    [[mmDAO instance] save:^(NSError *error) {
        if (error) {
            NSLog(@"!!!!!!!!!!!!!!!!!!moveUsersToDB save error:%@", error.description);
        }
    }];
}

-(void)asyncAddOrUpdateSchedule:(NSArray *)array withBlock:(dispatch_block_c)block {
    [Schedule async:^id(NSManagedObjectContext *ctx, NSString *className) {
        NSMutableArray *objArray = [[NSMutableArray alloc] init];
        NSMutableArray *scheduleIdArray = [[NSMutableArray alloc] init];
        for (NSDictionary* info in array) {
            if ([info objectForKey:@"scheduleId"]) {
                int scheduleId = [[info objectForKey:@"scheduleId"] intValue];
                if (scheduleId > 0) {
                    [scheduleIdArray addObject:[NSNumber numberWithInt:scheduleId]];
                }
            }
        }
        if (scheduleIdArray.count > 0) {
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithManagedObjectContext:ctx EntityName:className SortByAttributeName:@"scheduleId" Predicate:[NSPredicate predicateWithFormat:@"scheduleId IN %@",scheduleIdArray]];
            NSError *error = nil;
            NSArray *dataArray = [ctx executeFetchRequest:request error:&error];
            if (error) {
                [objArray addObject:error];
            }else{
                [objArray addObjectsFromArray:dataArray];
            }
            
        }
    
        return objArray;
    } result:^(NSArray *results, NSError *error) {
        
        if (error || !results) {
            NSLog(@"!!!!!!!!!!!!!!!!!!!asyncAddOrUpdateSchedule error!!!!!!!!!!!!!!!!!!!");
            return;
        }
        
        NSMutableDictionary *objDic = [[NSMutableDictionary alloc] init];
        for (id result in results) {
            if ([result isKindOfClass:[NSError class]]) {
                NSError *tmpErr = (NSError *)result;
                NSLog(@"!!!!!!!!!!!!!!!!!!!asyncAddOrUpdateSchedule error:%@", tmpErr.description);
            }
            else if ([result isKindOfClass:[Schedule class]]) {
                Schedule *schedule = (Schedule *)result;
                [objDic setObject:schedule forKey:schedule.scheduleId];
            }
        }
        for (NSDictionary* info in array) {
            NSNumber *scheduleId = [NSNumber numberWithInt:[[info objectForKey:@"scheduleId"] intValue]];
            if ([objDic objectForKey:scheduleId]) {
                [self updateSchedule:[objDic objectForKey:scheduleId] fromDictionary:info];
            }
            else {
                Schedule *schedule = [Schedule createNew];
                [self updateSchedule:schedule fromDictionary:info];
            }
        }
        
        [[mmDAO instance] save:^(NSError *error) {
            if (error) {
                NSLog(@"!!!!!!!!!!!!!!!!!!asyncAddOrUpdateSchedule save error:%@", error.description);
            }
            else {
                if (block) {
                    block();
                }
            }
            
        }];
        
        
    }];
    
    
}

@end
