//
//  EventStoreManager.m
//
//
//  Created by 小华 on 15/9/2.
//  Copyright (c) 2015年 EtherCap. All rights reserved.
//

#import "EventStoreManager.h"
#import <CoreText/CoreText.h>
#import "Schedule.h"
#import "ScheduleManager.h"

@implementation EventStoreManager

+ (EventStoreManager *)sharedInstance
{
    static EventStoreManager *str;
    @synchronized(self){
        if (str == nil) {
            str = [[EventStoreManager alloc]init];
            str.eventStore = [[EKEventStore alloc] init];
            str.eventList = [[NSMutableArray alloc] init];
            str.scheduleIdDict = [NSMutableDictionary dictionary];
            str->queue = dispatch_queue_create("sync", DISPATCH_QUEUE_SERIAL);
        }
        return str;
    }
}


#pragma mark -
#pragma mark Access Calendar

// Check the authorization status of our application for Calendar
-(void)checkEventStoreAccessForCalendar {
    EKAuthorizationStatus status = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
    switch (status) {
            // Update our UI if the user has granted access to their Calendar
        case EKAuthorizationStatusAuthorized: [self accessGrantedForCalendar];
            break;
            // Prompt the user for access to Calendar if there is no definitive answer
        case EKAuthorizationStatusNotDetermined: [self requestCalendarAccess];
            break;
            // Display a message if the user has denied or restricted access to Calendar
        case EKAuthorizationStatusDenied:
        case EKAuthorizationStatusRestricted:
            break;
        default:
            break;
    }
}


// Prompt the user for access to their Calendar
-(void)requestCalendarAccess {
    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
         if (granted) {
             [self accessGrantedForCalendar];
         }
     }];
}


// This method is called when the user has granted permission to Calendar
-(void)accessGrantedForCalendar
{
    // Let's get the default calendar associated with our event store
    self.defaultCalendar = self.eventStore.defaultCalendarForNewEvents;
    NSMutableDictionary *dict = [[PlistCacheManager shareInstance] getScheduleIdFromCache];
    if (dict && dict.allKeys.count > 0) {
        self.scheduleIdDict = [[PlistCacheManager shareInstance] getScheduleIdFromCache];
    }
    [self updateEventListAndMap];
    [self updateAllEvent];
}


-(void)updateEventListAndMap {
    //取出下一个月的数据进行两种id的同步
    NSDate *startDate = [NSDate dateFromString:@"2015-01-01 00:00:01"];
    NSDate *endDate = [NSDate dateWithTimeIntervalSinceNow:86400*30];
    [self.eventList removeAllObjects];
    [self.eventList addObjectsFromArray:[self fetchEventsFrom:startDate to:endDate]];
    
//    for (EKEvent *event in self.eventList) {
//        NSLog(@"------:%@--%@---%@---%@",event.title,event.startDate,event.endDate, event.eventIdentifier);
//    }
    
    //[self deleteAllEvent];
}

#pragma mark -
#pragma mark Fetch events

- (NSMutableArray *)fetchEventsFrom:(NSDate *)startDate to:(NSDate *)endDate
{
    NSArray *calendarArray = [NSArray arrayWithObject:self.defaultCalendar];
    // Create the predicate
    NSPredicate *predicate = [self.eventStore predicateForEventsWithStartDate:startDate
                                                                      endDate:endDate
                                                                    calendars:calendarArray];
    
    // Fetch all events that match the predicate
    NSMutableArray *events = [NSMutableArray arrayWithArray:[self.eventStore eventsMatchingPredicate:predicate]];
    
    return events;
}


#pragma mark -
#pragma mark Add a new event
//                    canceled  arranged
- (void)updateAllEvent {
    if ([_eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
        // the selector is available, so we must be on iOS 6 or newer
        [_eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if (error) {
                NSLog(@"updateEvent 错误信息:%@",error);
            } else if (!granted) {
                NSLog(@"updateEvent 被用户拒绝，不允许访问日历");
            } else {
                NSArray *schedules = [[ScheduleManager sharedInstance] syncGetUserSchedule:[[CacheManager sharedInstance] userId]];
                if (schedules && [schedules count] > 0) {
                    for (Schedule *schedule in schedules) {
                        EKEvent *targetEvent = [self searchEventBySchedule:schedule];
                        if (targetEvent != nil) {
                            [self updateEvent:targetEvent WithSchedule:schedule];
                        } else {
                            [self addEvent:schedule];
                        }
                    }
                }
            }
            
        }];
    }
}

- (void)addEvent:(Schedule *)schedule {
    if ([_eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)])
    {
        // the selector is available, so we must be on iOS 6 or newer
        [_eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            dispatch_async(queue, ^{
                if (error) {
                    NSLog(@"addEvent 错误信息:%@",error);
                } else if (!granted) {
                    NSLog(@"addEvent 被用户拒绝，不允许访问日历");
                } else {
                    EKEvent *event  = [EKEvent eventWithEventStore:_eventStore];
                    event.location = schedule.location;
                    event.title     = [NSString stringWithFormat:@"%@-%@",schedule.comment,schedule.scheduleId];
                    event.startDate = schedule.startTime;
                    event.endDate   = schedule.endTime;
                    Customer *founder = (Customer *)[[CustomerManager sharedInstance] searchUserFromId:[schedule.founderId integerValue]];
                    Customer *investor = (Customer *)[[CustomerManager sharedInstance] searchUserFromId:[schedule.investorId integerValue]];
                    NSArray *attendeesAry = [NSArray arrayWithObjects:founder.name,investor.name, nil];
                    [event.attendees arrayByAddingObjectsFromArray:attendeesAry];
                    if (event.startDate.year < 2015) {
                        return;
                    }
                    [event setCalendar:[_eventStore defaultCalendarForNewEvents]];
                    NSError *err;
                    BOOL result = [_eventStore saveEvent:event span:EKSpanThisEvent error:&err];
                    if (err == nil || result) {
                        [self.scheduleIdDict setObject:event.eventIdentifier forKey:schedule.scheduleId];
                        [[PlistCacheManager shareInstance] saveScheduleIdToCache:self.scheduleIdDict];
                    }
                    else {
                        NSLog(@"%@ - %@ - %@ 添加失败原因：%@",schedule.comment,schedule.scheduleId,schedule.startTime,err);
                    }
                }
            });
         }];
    }
}

-(void)updateEvent:(EKEvent *)event WithSchedule:(Schedule *)schedule {
    if ([_eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
        [_eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            dispatch_async(queue, ^{
                if (error) {
                    NSLog(@"updateEvent 错误信息:%@",error);
                } else if (!granted) {
                    NSLog(@"updateEvent 被用户拒绝，不允许访问日历");
                } else  {
                    NSError *err;
                    event.location = schedule.location;
                    event.allDay = NO;
//                    if (event.hasAlarms) {
//                        NSArray *alarms = event.alarms;
//                        for (EKAlarm *alarm in alarms) {
//                            [event removeAlarm:alarm];
//                        }
//                    }
                    if (event.hasRecurrenceRules) {
                        NSArray *rules = event.recurrenceRules;
                        for (EKRecurrenceRule *rule in rules) {
                            [event removeRecurrenceRule:rule];
                        }
                    }
                    
                    event.title     = [NSString stringWithFormat:@"%@-%@",schedule.comment,schedule.scheduleId];
                    event.startDate = schedule.startTime;
                    event.endDate   = schedule.endTime;
                    Customer *founder = (Customer *)[[CustomerManager sharedInstance] searchUserFromId:[schedule.founderId integerValue]];
                    Customer *investor = (Customer *)[[CustomerManager sharedInstance] searchUserFromId:[schedule.investorId integerValue]];
                    NSArray *attendeesAry = [NSArray arrayWithObjects:founder.name,investor.name, nil];
                    [event.attendees arrayByAddingObjectsFromArray:attendeesAry];
                    BOOL result = [_eventStore saveEvent:event span:EKSpanFutureEvents error:&err];
                    if (err == nil || result) {
                        [self.scheduleIdDict setObject:event.eventIdentifier forKey:schedule.scheduleId];
                        [[PlistCacheManager shareInstance] saveScheduleIdToCache:self.scheduleIdDict];
                    }
                    else {
                        NSLog(@"%@ - %@ - %@ 更新失败原因：%@",schedule.comment,schedule.scheduleId,schedule.startTime,err);
                    }
                }
            });
        }];
    }
}

-(void)deleteEvent:(EKEvent *)event WithMeeting:(Schedule *)schedule {
    if ([_eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)]) {
        [_eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            dispatch_async(queue, ^{
                if (error)
                {
                    NSLog(@"updateEvent 错误信息:%@",error);
                }
                else if (!granted)
                {
                    NSLog(@"updateEvent 被用户拒绝，不允许访问日历");
                }
                else
                {
                    NSError *err;
                    BOOL result = [_eventStore removeEvent:event span:EKSpanFutureEvents error:&err];

                    if (err == nil || result) {
                        [self.scheduleIdDict removeObjectForKey:schedule.scheduleId];
                        [[PlistCacheManager shareInstance] saveScheduleIdToCache:self.scheduleIdDict];
                    } else {
                        NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!deleteEvent !!!!!!!!!!!!!!!!!!!!!!!!!!!");
                    }
                }
            });
        }];
    }
}

-(void)deleteAllEvent {
    if ([_eventStore respondsToSelector:@selector(requestAccessToEntityType:completion:)])
    {
        [_eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            dispatch_async(queue, ^{
                if (error) {
                    NSLog(@"updateEvent 错误信息:%@",error);
                } else if (!granted) {
                    NSLog(@"updateEvent 被用户拒绝，不允许访问日历");
                } else {
                    NSArray *array = [NSArray arrayWithArray:self.eventList];
                    for (EKEvent *event in array) {
                        NSError *err;
                        [_eventStore removeEvent:event span:EKSpanThisEvent error:&err];
                    }
                }
            });
        }];
    }
}

//按字段查找
-(EKEvent *)searchEventBySchedule:(Schedule *)schedule {
    //先按eventIdAndCalendarItemIdMap同步，找不到再按字段找
    if ([self.scheduleIdDict objectForKey:schedule.scheduleId]) {
        NSString *identifier = [NSString stringWithFormat:@"%@", [self.scheduleIdDict objectForKey:schedule.scheduleId]];
        if ([self.eventStore eventWithIdentifier:identifier]) {
            return [self.eventStore eventWithIdentifier:identifier];
        } else {
            [self.scheduleIdDict removeObjectForKey:schedule.scheduleId];
            NSLog(@"###########被用户删掉了############:%@--%@--%@",schedule.startTime, schedule.comment, schedule.scheduleId);
        }
    } else {
        NSLog(@"###########calendarIDMap里找不到#######:--%@ %@--%@", schedule.startTime, schedule.comment, schedule.scheduleId);
    }
    
    NSArray *array = [NSArray arrayWithArray:self.eventList];
    for (EKEvent *event in array) {
        NSDate *startDate = nil;
        NSDate *endDate = nil;
        startDate = schedule.startTime;
        endDate = schedule.endTime;
        if (startDate == nil || startDate.year < 2015) {
            break;
        } else {
            if ([event.location isEqualToString:schedule.location] && [event.startDate isEqualToDate:startDate] && [event.endDate isEqualToDate:endDate] && [event.title isEqualToString:[NSString stringWithFormat:@"%@-%@",schedule.comment,schedule.scheduleId]]) {
                return event;
            }
        }
    }
    return nil;
}

@end
