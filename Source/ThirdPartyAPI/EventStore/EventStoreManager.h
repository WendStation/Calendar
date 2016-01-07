//
//  EventStoreManager.h
//  以太优选
//
//  Created by 小华 on 15/9/2.
//  Copyright (c) 2015年 EtherCap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>
#import <UIKit/UIKit.h>

@interface EventStoreManager : NSObject
{
    dispatch_queue_t queue;
}

// EKEventStore instance associated with the current Calendar application
@property (nonatomic, strong) EKEventStore *eventStore;
// Default calendar associated with the above event store
@property (nonatomic, strong) EKCalendar *defaultCalendar;

@property (nonatomic, strong) NSMutableArray *eventList;

@property (nonatomic, strong) NSMutableDictionary *scheduleIdDict;

+ (EventStoreManager *)sharedInstance;
-(void)checkEventStoreAccessForCalendar;

@end
