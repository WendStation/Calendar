//
//  CacheManager.h
//  Calendar
//
//  Created by 小华 on 15/10/22.
//
//

#import <Foundation/Foundation.h>
#import "User.h"


@interface CacheManager : NSObject

//可用的城市信息
@property (nonatomic, strong) NSArray *cityListData;

//缓存的用户信息
@property(nonatomic, strong) User *user;
@property(nonatomic, strong) NSString *accessToken;
@property(nonatomic, strong) NSString *userId;
@property(nonatomic, strong) NSString *userName;

//按userid存储日程信息
@property (nonatomic, strong) NSMutableDictionary *localScheduleData;
@property (nonatomic, strong) NSMutableArray *changedScheduleData;
@property (nonatomic, copy) NSString *lastSyncSchedulesTime;
@property (nonatomic, copy) NSString *lastSyncCustomerTime;

@property (nonatomic, strong) NSDate *scheduleStartDate;
@property (nonatomic, strong) NSDate *scheduleEndDate;

@property (nonatomic, strong) NSMutableDictionary *projectStatusDefine;
@property (nonatomic, strong) NSMutableDictionary *investorStatusDefine;
@property (nonatomic, strong) NSMutableDictionary *categoryDefine;
@property (nonatomic, strong) NSMutableDictionary *subCategoryDefine;


+ (CacheManager *)sharedInstance;

-(void)refreshScheduleInfo:(NSString *)userId;
-(void)saveSyncScheduleTime:(NSString *)time;
-(void)saveSyncCustomerTime:(NSString *)time;

-(void)getUserLoginInfo;
-(void)initData;
-(BOOL)hasLogin;
-(void)removeUser;

- (NSString *)getProjectStatusDescritionForCode:(NSString *)code;
- (NSMutableArray *)getInvestorStatusDescritionForCode:(NSString *)code;
- (NSString *)getCategoryDefineNameForCode:(NSString *)code;
- (NSMutableArray *)getFirstGradeCategory;
- (NSMutableArray *)getSecondGradeCategory:(NSString *)name;
- (NSString *)getSecondGradeCategoryId:(NSArray *)array;


//同步到日历
-(NSString *)getSyncToCalender;
-(void)setSyncToCalender:(BOOL) value;
-(BOOL)isNeedAlertSyncToCalender;
-(BOOL)isSyncToCalender;


@end
