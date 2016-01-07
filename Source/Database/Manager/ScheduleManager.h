//
//  ScheduleManager.h
//  Ethercap
//
//  Created by 小华 on 15/5/15.
//  Copyright (c) 2015年 Robert Dimitrov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Schedule.h"

@interface ScheduleManager : NSObject

+ (ScheduleManager *)sharedInstance;

//将文件系统中的信息迁移到数据库中
-(void)moveSchedulesToDB:(NSArray *)array;

//同步获取
-(NSInteger)syncGetScheduleCount;
-(NSMutableArray *)syncGetAllSchedule;
-(NSMutableArray *)syncGetScheduleFor:(NSString *)userId;
-(NSArray *)syncGetUserSchedule:(NSString *)userId;
//更新信息
-(void)syncAddOrUpdateSchedule:(NSArray *)array;
-(void)asyncAddOrUpdateSchedule:(NSArray *)array withBlock:(dispatch_block_c)block;
//删除信息
-(void)syncDeleteSchedule:(NSNumber *)scheduleId;


@end
