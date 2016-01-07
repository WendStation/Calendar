//
//  Schedule.h
//  Ethercap
//
//  Created by 小华 on 15/5/15.
//  Copyright (c) 2015年 Robert Dimitrov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Schedule : NSManagedObject

@property (nonatomic, retain) NSString * accepted;
@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSNumber * confirmed;
@property (nonatomic, retain) NSNumber * createBy;
@property (nonatomic, retain) NSDate * creationTime;
@property (nonatomic, retain) NSDate * endTime;
@property (nonatomic, retain) NSNumber * feedback;
@property (nonatomic, retain) NSString * founderId;
@property (nonatomic, retain) NSString * investorId;
@property (nonatomic, retain) NSString * city;
@property (nonatomic, retain) NSNumber * localId;
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSNumber * meetingId;
@property (nonatomic, retain) NSNumber * projectId;
@property (nonatomic, retain) NSNumber * scheduleId;
@property (nonatomic, retain) NSDate * startTime;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSDate * updateTime;
@property (nonatomic, retain) NSString * userId;

@end
