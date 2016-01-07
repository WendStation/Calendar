//
//  PlistCacheManager.h
//  Calendar
//
//  Created by 刘花椒 on 15/11/2.
//
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    ProjectStatus,
    InvestorStatus,
    CategoryDefine,
} ProjectType;

@interface PlistCacheManager : NSObject

+ (PlistCacheManager *)shareInstance;

#pragma mark saveProjectStatus/InvestorStatus/ProjectDefine
- (void)saveProjectStatusDefineCache:(id)info folderName:(NSString *)folderName cacheKey:(NSString *)cacheKey;
- (id)getProjectInfoFromCacheFolderName:(NSString *)folderName cacheKey:(NSString *)cacheKey;

#pragma mark save_BP_file
- (NSArray *)BPFileKeys;
- (void)saveBPFileToCache:(NSMutableDictionary *)info;
- (NSMutableDictionary *)getBPFileFromCache;

#pragma mark saveUser
- (void)saveUserToCache:(User *)user;
- (User *)getUserFromCache;
- (void)removeUser;

#pragma mark saveChangedSchedule
-(void)saveChangedScheduleData:(NSMutableArray *)info;
-(NSMutableArray *)getChangedScheduleData;

#pragma mark saveScheduleIdCache
-(void)saveScheduleIdToCache:(NSMutableDictionary *)info;
-(NSMutableDictionary *)getScheduleIdFromCache;

@end
