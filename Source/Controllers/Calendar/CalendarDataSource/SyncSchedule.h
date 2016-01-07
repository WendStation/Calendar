//
//  RegisterApi.h
//  Solar
//
//  Created by TangQiao on 11/8/14.
//  Copyright (c) 2014 fenbi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseBlocks.h"
typedef void (^sync_schedule_block)(NSDictionary *response);

@interface SyncSchedule : NSObject


//同步日程
- (void)syncScheduleApi:(NSMutableArray *)scheduleArray withBlock:(sync_schedule_block)block;
//查看其他人的日程
- (void)checkOthersScheduleApi:(NSString *)userId withBlock:(sync_schedule_block)block;
- (void)getUserPhoneApi:(NSNumber *)userId type:(NSString *)type block:(Complete)block;


@end
