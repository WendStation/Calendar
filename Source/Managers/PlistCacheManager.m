//
//  PlistCacheManager.m
//  Calendar
//
//  Created by 刘花椒 on 15/11/2.
//
//

#import "PlistCacheManager.h"
#import "WriteFilePersistentManager.h"

@implementation PlistCacheManager

+ (PlistCacheManager *)shareInstance{
    static PlistCacheManager *cacheManager = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        cacheManager = [[PlistCacheManager alloc] init];
    });
    return cacheManager;
}

#pragma mark saveProjectStatus/InvestorStatus/ProjectDefine
- (void)saveProjectStatusDefineCache:(id)info folderName:(NSString *)folderName cacheKey:(NSString *)cacheKey{
    FilePersistentDescription *cacheDescription =
    [FilePersistentDescription persistentDescriptionWithFolderName:folderName
                                                             cacheKey:cacheKey
                                                            cacheData:info];
    
    [[WriteFilePersistentManager instance] saveDataWithDescription:cacheDescription];
}

- (id)getProjectInfoFromCacheFolderName:(NSString *)folderName cacheKey:(NSString *)cacheKey{
    FilePersistentDescription *cacheDescription =
    [FilePersistentDescription persistentDescriptionWithFolderName:folderName
                                                             cacheKey:cacheKey
                                                            cacheData:nil];
    
    return [[WriteFilePersistentManager instance] cacheDataWithDescription:cacheDescription];
}

#pragma mark save_BP_file
- (NSArray *)BPFileKeys{
    NSMutableDictionary * dict = [self getBPFileFromCache];
    return dict.allKeys;
}

- (void)saveBPFileToCache:(NSMutableDictionary *)info{
    FilePersistentDescription *cacheDescription =
    [FilePersistentDescription persistentDescriptionWithFolderName:KBPCacheFolder
                                                          cacheKey:KBPCache
                                                         cacheData:info];
    BOOL isSucceed = [[WriteFilePersistentManager instance] saveDataWithDescription:cacheDescription];
    if (!isSucceed) {
        NSLog(@"saveBPFailed");
    }
}

- (NSMutableDictionary *)getBPFileFromCache{
    FilePersistentDescription *cacheDescription =
    [FilePersistentDescription persistentDescriptionWithFolderName:KBPCacheFolder
                                                          cacheKey:KBPCache
                                                         cacheData:nil];
    return [[WriteFilePersistentManager instance] cacheDataWithDescription:cacheDescription];
}

#pragma mark saveUser
- (void)saveUserToCache:(User *)user{
    FilePersistentDescription *cacheDescription =
    [FilePersistentDescription persistentDescriptionWithFolderName:KUserCacheFolder
                                                          cacheKey:KUserCache
                                                         cacheData:user];
    BOOL isSucceed = [[WriteFilePersistentManager instance] saveDataWithDescription:cacheDescription];
    if (!isSucceed) {
        NSLog(@"saveUserFailed");
    }
}

- (User *)getUserFromCache{
    FilePersistentDescription *cacheDescription =
    [FilePersistentDescription persistentDescriptionWithFolderName:KUserCacheFolder
                                                          cacheKey:KUserCache
                                                         cacheData:nil];
    return [[WriteFilePersistentManager instance] cacheDataWithDescription:cacheDescription];
}

- (void)removeUser {
   BOOL isSucceed = [[WriteFilePersistentManager instance] removeCacheFolderName:KUserCacheFolder cacheKey:KUserCache];
    if (!isSucceed) {
        NSLog(@"removeUserFailed");
    }
}

#pragma mark saveChangedSchedule
-(void)saveChangedScheduleData:(NSMutableArray *)info {
    FilePersistentDescription *cacheDescription =
    [FilePersistentDescription persistentDescriptionWithFolderName:KChangedScheduleCacheFolder
                                                          cacheKey:KChangedScheduleCache
                                                         cacheData:info];
    BOOL isSucceed = [[WriteFilePersistentManager instance] saveDataWithDescription:cacheDescription];
    if (!isSucceed) {
        NSLog(@"saveBPFailed");
    }
}

-(NSMutableArray *)getChangedScheduleData {
    FilePersistentDescription *cacheDescription =
    [FilePersistentDescription persistentDescriptionWithFolderName:KChangedScheduleCacheFolder
                                                          cacheKey:KChangedScheduleCache
                                                         cacheData:nil];
    return [[WriteFilePersistentManager instance] cacheDataWithDescription:cacheDescription];
}

#pragma mark saveScheduleIdCache
-(void)saveScheduleIdToCache:(NSMutableDictionary *)info {
    FilePersistentDescription *cacheDescription =
    [FilePersistentDescription persistentDescriptionWithFolderName:KScheduleIdCacheFolder
                                                          cacheKey:KScheduleIdCache
                                                         cacheData:info];
    BOOL isSucceed = [[WriteFilePersistentManager instance] saveDataWithDescription:cacheDescription];
    if (!isSucceed) {
        NSLog(@"saveScheduleIdFailed");
    }
}

-(NSMutableDictionary *)getScheduleIdFromCache {
    FilePersistentDescription *cacheDescription =
    [FilePersistentDescription persistentDescriptionWithFolderName:KScheduleIdCacheFolder
                                                          cacheKey:KScheduleIdCache
                                                         cacheData:nil];
    return [[WriteFilePersistentManager instance] cacheDataWithDescription:cacheDescription];
}

@end
