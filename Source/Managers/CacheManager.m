//
//  CacheManager.m
//  Calendar
//
//  Created by 小华 on 15/10/22.
//
//

#import "CacheManager.h"
#import "ScheduleManager.h"
#import "Customer.h"
#import "CustomerManager.h"

@implementation CacheManager


+ (CacheManager *)sharedInstance
{
    static CacheManager *str;
    @synchronized(self){
        if (str==nil) {
            str=[[CacheManager alloc] init];
            //[str initData];//app完成后需要删除
        }
        return str;
    }
}

-(void)setValue:(id)value forKey:(NSString *)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:value forKey:key];
    [defaults synchronize];
}


-(NSString *)getStringForkey:(NSString *)key {
    return  [[NSUserDefaults standardUserDefaults] stringForKey:key];
}

-(id)getObjectForkey:(NSString *)key {
    return  [[NSUserDefaults standardUserDefaults] objectForKey:key];
}

-(void)initData {
    
    self.cityListData = [NSArray arrayWithObjects:@"北京",@"上海",@"广州",@"深圳",@"杭州",@"成都",@"武汉",@"南京",@"厦门", nil];
    
    [self getUserLoginInfo];
    
    //获取缓存的日程信息
    [self refreshScheduleInfo:self.userId];

    self.changedScheduleData = [[PlistCacheManager shareInstance] getChangedScheduleData];
    if (self.changedScheduleData == nil) {
        self.changedScheduleData = [[NSMutableArray alloc] init];
    }
    
    if ([self getObjectForkey:@"lastSyncSchedulesTime"] != nil) {
        self.lastSyncSchedulesTime = [self getStringForkey:@"lastSyncSchedulesTime"];
    }
    else {
        self.lastSyncSchedulesTime = @"2000-01-01 00:00:00";
    }
    
    if ([self getObjectForkey:@"lastSyncCustomerTime"] != nil) {
        self.lastSyncCustomerTime = [self getStringForkey:@"lastSyncCustomerTime"];
    }
    else {
        self.lastSyncCustomerTime = @"2000-01-01 00:00:00";
    }
    
    
    self.projectStatusDefine = [[NSMutableDictionary alloc] init];
    self.investorStatusDefine = [[NSMutableDictionary alloc] init];
    self.categoryDefine = [[NSMutableDictionary alloc] init];
    self.subCategoryDefine = [[NSMutableDictionary alloc] init];
    
    [self.projectStatusDefine addEntriesFromDictionary:[[PlistCacheManager shareInstance] getProjectInfoFromCacheFolderName:KProjectStatusCacheFolder cacheKey:KProjectStatusCache]];
    [self.investorStatusDefine addEntriesFromDictionary:[[PlistCacheManager shareInstance] getProjectInfoFromCacheFolderName:KInvestorStatusCacheFolder cacheKey:KInvestorStatusCache]];
    [self.categoryDefine addEntriesFromDictionary:[[PlistCacheManager shareInstance] getProjectInfoFromCacheFolderName:KCategoryDefineCacheFolder cacheKey:KCategoryDefineCache]];
    if ([self.categoryDefine objectForKey:@"categories"]) {
        NSArray *categoriesAry = [self.categoryDefine objectForKey:@"categories"];
        for (NSDictionary *subDict in categoriesAry) {
            NSArray *subCategoriesAry = [subDict objectForKey:@"subCategories"];
            for (NSDictionary *subDict in subCategoriesAry) {
                [self.subCategoryDefine setObject:[subDict objectForKey:@"name"]  forKey:[subDict objectForKey:@"id"]];
            }
        }
    }

    
}

-(void)getUserLoginInfo {
    self.user = [[PlistCacheManager shareInstance] getUserFromCache];
    self.accessToken = self.user.accessToken;
    self.userId = self.user.userId;
    self.userName = self.user.userName;
}

/*
 *通过项目ID获取项目状态
 */
- (NSString *)getProjectStatusDescritionForCode:(NSString *)code{

    NSDictionary *textDict = [NSDictionary dictionaryWithDictionary:[self.projectStatusDefine objectForKey:@"text"]];
    if ([textDict objectForKey:code]) {
        return [NSString stringWithFormat:@"%@", [textDict objectForKey:code]];
    }else {
        return @"";
    }    
}
/*
 *通过项目ID获取投资状态
 */
- (NSMutableArray *)getInvestorStatusDescritionForCode:(NSString *)code{
    NSMutableArray *investorStatusAry = [NSMutableArray array];
    
    NSDictionary *textDict = [NSDictionary dictionaryWithDictionary:[self.investorStatusDefine objectForKey:@"text"]];
    
    if ([textDict objectForKey:code]) {
        [investorStatusAry addObject:[NSString stringWithFormat:@"%@",[textDict objectForKey:code]]];
    }else{
        [investorStatusAry addObject:@""];
    }
    
    NSDictionary *transitionDict = [NSDictionary dictionaryWithDictionary:[self.investorStatusDefine objectForKey:@"transition"]];
    if ([[transitionDict objectForKey:code] count] > 0) {
        [investorStatusAry addObject:[transitionDict objectForKey:code]];
    }else{
        [investorStatusAry addObject:[NSArray array]];
    }
    
    return investorStatusAry;
}

/*
 *通过品类ID获取品类的名
 */
- (NSString *)getCategoryDefineNameForCode:(NSString *)code{
    if (![code isEqualToString:@"(null)"] && code.length > 0) {
        return [self.subCategoryDefine objectForKey:code];
    } else {
        return @"";
    }
}

/*
 *获取一级品类
 */
- (NSMutableArray *)getFirstGradeCategory{
    NSMutableArray *firstArray = [NSMutableArray array];
    if ([self.categoryDefine objectForKey:@"categories"] && [[self.categoryDefine objectForKey:@"categories"] count] > 0) {
        NSArray *categories = [self.categoryDefine objectForKey:@"categories"];
        for (NSDictionary * dict in categories) {
            [firstArray addObject:[dict objectForKey:@"name"]];
        }
    }
    return firstArray;
}

/*
 *通过一级品类名获取二级品类名
 */
- (NSMutableArray *)getSecondGradeCategory:(NSString *)name{
    NSMutableArray *secondArray = [NSMutableArray array];
    if ([self.categoryDefine objectForKey:@"categories"] && [[self.categoryDefine objectForKey:@"categories"] count] > 0) {
        NSArray *categories = [self.categoryDefine objectForKey:@"categories"];
        for (NSDictionary * dict in categories) {
            if ([[dict objectForKey:@"name"] isEqualToString:name]) {
                NSArray *subCategories = [dict objectForKey:@"subCategories"];
                for (NSDictionary *subDict in subCategories) {
                    [secondArray addObject:[subDict objectForKey:@"name"]];
                }
            }
        }
    }
    return secondArray;
}

/*
 *通过一级品类名和二级品类名获取二级品类id
 */
- (NSString *)getSecondGradeCategoryId:(NSArray *)array{
    NSString *categoryId = @"";
    if ([self.categoryDefine objectForKey:@"categories"] && [[self.categoryDefine objectForKey:@"categories"] count] > 0) {
        NSArray *categories = [self.categoryDefine objectForKey:@"categories"];
        for (NSDictionary * dict in categories) {
            if ([[dict objectForKey:@"name"] isEqualToString:array.firstObject]) {
                NSArray *subCategories = [dict objectForKey:@"subCategories"];
                for (NSDictionary *subDict in subCategories) {
                    if ([[subDict objectForKey:@"name"] isEqualToString:array.lastObject]) {
                        categoryId = [subDict objectForKey:@"id"];
                    }
                }
            }
        }
    }
    return categoryId;
}


-(BOOL)hasLogin {
    if(self.accessToken != nil && self.accessToken.length > 40) {
        return YES;
    }
    return NO;
}

-(void)removeUser {
    self.accessToken = @"";
    self.userId = @"";
    self.user = nil;
    [[PlistCacheManager shareInstance] removeUser];
}

//-------------------------------存储一些简单的参数---------------------------------------
-(void)saveSyncScheduleTime:(NSString *)time {
    self.lastSyncSchedulesTime = time;
    [self setValue:time forKey:@"lastSyncSchedulesTime"];
}
-(void)saveSyncCustomerTime:(NSString *)time {
    self.lastSyncCustomerTime = time;
    [self setValue:time forKey:@"lastSyncCustomerTime"];
}

-(void)refreshScheduleInfo:(NSString *)userId
{
    NSMutableArray *scheduleArray = [NSMutableArray arrayWithArray:[[ScheduleManager sharedInstance] syncGetScheduleFor:userId]];
    
    if (!scheduleArray) {
        scheduleArray = [[NSMutableArray alloc] init];
    }
    //更新日程的用户信息
    for (id tmp in scheduleArray) {
        NSMutableDictionary *dic = (NSMutableDictionary *)tmp;
        NSMutableArray *infoArray = [[NSMutableArray alloc] init];
        
        if ([[dic objectForKey:@"meetingId"] intValue] != 0) {
            int userId1 = -1;
            int userId2 = -1;
            
            userId1 = [[dic objectForKey:@"investorId"] intValue];
            userId2 = [[dic objectForKey:@"founderId"] intValue];
            
            
            if (userId1 != -1) {
                Customer *user = [[CustomerManager sharedInstance] searchUserFromId:userId1];
                if (user) {
                    [dic setObject:user forKey:@"investorInfo"];
                    [infoArray addObject:user];
                }
            }
            if (userId2 != -1) {
                Customer *user = [[CustomerManager sharedInstance] searchUserFromId:userId2];
                if (user) {
                    [dic setObject:user forKey:@"founderInfo"];
                    [infoArray addObject:user];
                }
            }
        }
        
        if ([[dic objectForKey:@"userId"] intValue] != 0) {
            NSArray *userArray = [[dic objectForKey:@"userId"] componentsSeparatedByString:@","];
            if (userArray && userArray.count > 0) {
                for (NSString *userId in userArray) {
                    if (userId && userId.length > 0) {
                        Customer *user = [[CustomerManager sharedInstance] searchUserFromId:[userId intValue]];
                        if (user) {
                            [infoArray addObject:user];
                        }
                    }
                }
            }
        }
        
        if (infoArray.count > 0) {
            [dic setObject:infoArray forKey:@"memberInfo"];
        }
    }
    
    //更新日程显示的数据源
    if (!self.localScheduleData) {
        self.localScheduleData = [[NSMutableDictionary alloc] init];
    }
    
    if(scheduleArray != nil && userId.length > 0) {
        if ([self isSyncToCalender]) {
            [[EventStoreManager sharedInstance] checkEventStoreAccessForCalendar];
        }
        [self.localScheduleData removeAllObjects];
        NSDictionary *dic = [self dealWithScheduleData:scheduleArray];
        [self.localScheduleData addEntriesFromDictionary:dic];
    }
}


-(NSDictionary *)dealWithScheduleData:(NSArray *)array
{
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    for (int i = 0; i < array.count; i ++) {
        NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:[array objectAtIndex:i]];
        if ([tmp objectForKey:@"startTime"] == nil) {
            continue;
        }
        
        NSDate *startTime = [tmp objectForKey:@"startTime"];
        long seconds = [startTime timeIntervalSince1970];
        
        NSString *key = [startTime stringWithFormat:@"yyyy-MM-dd"];
        if (self.scheduleStartDate == nil || [startTime isEarlierThanDate:self.scheduleStartDate]) {
            self.scheduleStartDate = startTime;
        }
        if (self.scheduleEndDate == nil || [self.scheduleEndDate isEarlierThanDate:startTime]) {
            self.scheduleEndDate = startTime;
        }
        //这里需要把起始日期按0时，结束日期按23时算，以免算相差天数的时候少一天
        self.scheduleStartDate = [self.scheduleStartDate dateAtStartOfDay];
        self.scheduleEndDate = [self.scheduleEndDate dateAtEndOfDay];
        
        
        NSString *hour = [startTime stringWithFormat:@"HH"];
        [tmp setObject:hour forKey:@"hour"];
        if ([data objectForKey:key]) {
            NSMutableArray * dayMissions = [data objectForKey:key];
            NSInteger index = dayMissions.count;
            for (int i = 0; i < index; i ++) {
                NSDictionary *dic = (NSDictionary *)[dayMissions objectAtIndex:i];
                long seconds2 = [[dic objectForKey:@"startTime"] timeIntervalSince1970];
                if (seconds <= seconds2) {
                    index = i;
                    break;
                }
            }
            
            [dayMissions insertObject:tmp atIndex:index];
        }
        else
        {
            NSMutableArray *dayMissions = [[NSMutableArray alloc] initWithObjects:tmp, nil];
            [data setObject:dayMissions forKey:key];
        }
    }
    
    
    for (NSString *key in [data allKeys]) {
        NSMutableArray *sourceSchedule = [[NSMutableArray alloc] init];
        
        NSMutableArray *tmpSchedules = [data objectForKey:key];
        NSDate *zero = [NSDate dateFromString:key withFormat:@"yyyy-MM-dd"];
        NSDate *twentyfour = [zero dateByAddingDays:1];
        for (int i = 0; i < tmpSchedules.count; i++) {
            NSDictionary *schedule = [tmpSchedules objectAtIndex:i];
            
            NSDate *startTime = [schedule objectForKey:@"startTime"];
            NSDate *endTime = [schedule objectForKey:@"endTime"];
            
            
            
            if (i == 0 && startTime) {
                if ([startTime isLaterThanDate:zero]) {
                    NSMutableDictionary *free = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"1",@"noneSchedule", nil];
                    [free setObject:[NSString stringWithFormat:@"%@ 前无日程", [startTime stringWithFormat:@"HH:mm"]] forKey:@"noneScheduleDes"];
                    [sourceSchedule addObject:free];
                }
            }
            else if (startTime) {
                NSDictionary *previousSchedule = [tmpSchedules objectAtIndex:(i - 1)];
                if (previousSchedule) {
                    NSDate *end = [previousSchedule objectForKey:@"endTime"];
                    if (end) {
                        if ([end isEarlierThanDate:startTime]) {
                            NSMutableDictionary *free = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"1",@"noneSchedule", nil];
                            [free setObject:[NSString stringWithFormat:@"%@-%@ 无日程", [end stringWithFormat:@"HH:mm"], [startTime stringWithFormat:@"HH:mm"]] forKey:@"noneScheduleDes"];
                            [sourceSchedule addObject:free];
                        }
                    }
                }
            }
            [sourceSchedule addObject:schedule];
            
            if (i == tmpSchedules.count - 1 && endTime) {
                if ([endTime isEarlierThanOrEqualDate:twentyfour]) {
                    NSMutableDictionary *free = [[NSMutableDictionary alloc] initWithObjectsAndKeys:@"1",@"noneSchedule", nil];
                    [free setObject:[NSString stringWithFormat:@"%@ 后无日程", [endTime stringWithFormat:@"HH:mm"]] forKey:@"noneScheduleDes"];
                    [sourceSchedule addObject:free];
                }
            }
        }
        [data setObject:sourceSchedule forKey:key];
    }
    
    
    return data;
}


-(NSString *)getSyncToCalender {
    NSString *key = [NSString stringWithFormat:@"syncToCalender_%@", self.userId];
    if ([self getStringForkey:key]) {
        return [self getStringForkey:key];
    }
    else {
        return @"-1";
    }
    
}

-(void)setSyncToCalender:(BOOL) value {
    NSString *key = [NSString stringWithFormat:@"syncToCalender_%@", self.userId];
    if (value) {
        [self setValue:@"1" forKey:key];
    }
    else {
        [self setValue:@"0" forKey:key];
    }
}

-(BOOL)isNeedAlertSyncToCalender {
    return [[self getSyncToCalender] isEqualToString:@"-1"];
}

-(BOOL)isSyncToCalender {
    return [[self getSyncToCalender] isEqualToString:@"1"];
}

@end
