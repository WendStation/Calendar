//
//  WriteFilePersistentManager.m
//  Calendar
//
//  Created by 刘花椒 on 15/11/2.
//
//

#import "WriteFilePersistentManager.h"

NSString *const kCacheManagerFile = @"kCacheManagerFile";
NSString *const kCacheManagerFolder = @"kCacheManagerFolder";
NSString *const kCacheManagerKey = @"kCacheManagerKey";
NSString *const kCacheManagerAutoClear = @"kCacheManagerAutoClear";

@implementation FilePersistentDescription

+ (FilePersistentDescription *)persistentDescriptionWithFolderName:(NSString *)folderName
                                                             cacheKey:(NSString *)cacheKey
                                                            cacheData:(id)cacheData
{
    FilePersistentDescription *persistentDescription = [[FilePersistentDescription alloc] init];
    
    persistentDescription.folderName = folderName;
    persistentDescription.cacheKey = cacheKey;
    persistentDescription.cacheData = cacheData;
    return persistentDescription;
}

- (id)init
{
    if (self = [super init]) {
        self.autoClear = YES;
    }
    
    return self;
}

@end

@interface WriteFilePersistentManager ()

@property (nonatomic, strong) NSMutableDictionary *cacheManagerDict;

@end

@implementation WriteFilePersistentManager

+ (WriteFilePersistentManager *)instance {
    static WriteFilePersistentManager *_instance = nil;
    static dispatch_once_t               onceToken;
    
    dispatch_once(&onceToken, ^{
        _instance = [[WriteFilePersistentManager alloc] init];
    });
    return _instance;
}

- (id)init {
    if (self = [super init]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearCacheNotification:)
                                                     name:KClearCacheNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)recordCache:(FilePersistentDescription *)persistentDescription {
    BOOL     isSucceed = NO;
    NSString *folderName = persistentDescription.folderName;
    NSString *cacheKey = persistentDescription.cacheKey;
    BOOL     autoClear = persistentDescription.autoClear;
    
    if ((0 >= folderName.length) || (0 >= cacheKey.length)) {
        return isSucceed;
    }
    
    NSDictionary *record = @{kCacheManagerFolder: folderName,
                             kCacheManagerKey: cacheKey,
                             kCacheManagerAutoClear: @(autoClear)};
    NSString *managedKey = [NSString stringWithFormat:@"%@:%@", folderName, cacheKey];
    [self.cacheManagerDict setObject:record forKey:managedKey];
    [self saveCacheManagerDict];
    
    return isSucceed;
}

- (BOOL)clearCache {
    BOOL isSucceed = YES;
    
    NSFileManager  *fileMgr = [NSFileManager defaultManager];
    NSMutableArray *clearedKeys = [NSMutableArray array];
    
    for (NSDictionary *cacheRecordKey in [self.cacheManagerDict allKeys]) {
        BOOL     autoClear = [[[self.cacheManagerDict objectForKey:cacheRecordKey] objectForKey:kCacheManagerAutoClear] boolValue];
        NSString *folderName = [[self.cacheManagerDict objectForKey:cacheRecordKey] objectForKey:kCacheManagerFolder];
        NSString *cacheKey = [[self.cacheManagerDict objectForKey:cacheRecordKey] objectForKey:kCacheManagerKey];
        
        NSString *path = [NSString stringWithFormat:@"%@/%@", [self userCachePathWithFolderName:folderName], cacheKey];
        
        if (autoClear && [fileMgr fileExistsAtPath:path]) {
            NSError *error = nil;
            
            if ([fileMgr removeItemAtPath:path error:&error]) {
                [clearedKeys addObject:cacheRecordKey];
            } else {
                isSucceed = NO;
            }
        }
    }
    
    [self.cacheManagerDict removeObjectsForKeys:clearedKeys];
    
    return isSucceed;
}

- (BOOL)removeCacheFolderName:(NSString *)folderName cacheKey:(NSString *)cacheKey {
    BOOL isSucceed = NO;
    NSFileManager  *fileMgr = [NSFileManager defaultManager];
    NSString *path = [NSString stringWithFormat:@"%@/%@", [self userCachePathWithFolderName:folderName], cacheKey];
    if ([fileMgr fileExistsAtPath:path]) {
        NSError *error = nil;
        isSucceed = [fileMgr removeItemAtPath:path error:&error];
    }
    return isSucceed;
}

- (NSString *)documentPath {
    NSArray  *searchPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [searchPath objectAtIndex:0];
    [self createFilePath:path];
    
    return path;
}

- (BOOL)createFilePath:(NSString *)path {
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    if (![fileMgr fileExistsAtPath:path]) {
        NSError *error = nil;
        [fileMgr  createDirectoryAtPath:path
            withIntermediateDirectories:YES
                             attributes:nil
                                  error:&error];
        
        if (error) {
            NSLog(@"创建 %@ 失败 %@", path,error);
            return NO;
        }
    }
    return YES;
}

- (NSString *)userCachePathWithFolderName:(NSString *)folderName {
    if (0 >= folderName.length) {
        return nil;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/%@",
                      [self documentPath], folderName];
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    if (![fileMgr fileExistsAtPath:path]) {
        NSError *error = nil;
        [fileMgr createDirectoryAtPath:path
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:&error];
        
        if (error) {
            NSLog(@"创建 userDocumentPath 失败 %@", error);
            return nil;
        }
    }
    
    return path;
}

#pragma mark - 缓存管理的字典

- (NSMutableDictionary *)cacheManagerDict {
    if (!_cacheManagerDict) {
        _cacheManagerDict = [NSMutableDictionary dictionary];
        NSString *path = [NSString stringWithFormat:@"%@/%@", [self documentPath], kCacheManagerFile];
        NSData   *data = [NSData dataWithContentsOfFile:path];
        id       cache = [NSKeyedUnarchiver unarchiveObjectWithData:data exception_p:NULL];
        
        if ([cache isKindOfClass:[NSDictionary class]]) {
            [_cacheManagerDict setValuesForKeysWithDictionary:cache];
        }
    }
    
    return _cacheManagerDict;
}

- (BOOL)saveCacheManagerDict {
    BOOL isSucceed = NO;
    
    if (!self.cacheManagerDict) {
        return isSucceed;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/%@", [self documentPath], kCacheManagerFile];
    NSData   *data = [NSKeyedArchiver archivedDataWithRootObject:self.cacheManagerDict];
    isSucceed = [data writeToFile:path atomically:NO];
    
    return isSucceed;
}

#pragma mark - 清除缓存的通知

- (void)clearCacheNotification:(NSNotification *)notification {
    [self clearCache];
}

#pragma mark - public method

- (BOOL)saveDataWithDescription:(FilePersistentDescription *)persistentDescription {
    BOOL isSucceed = NO;
    
    if (!persistentDescription.cacheKey) {
        return isSucceed;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/%@", [self userCachePathWithFolderName:persistentDescription.folderName], persistentDescription.cacheKey];
    NSData   *data = [NSKeyedArchiver archivedDataWithRootObject:persistentDescription.cacheData];
    isSucceed = [data writeToFile:path atomically:NO];
    
    if (isSucceed) {
        [self recordCache:persistentDescription];
    }
    
    return isSucceed;
}

- (id)cacheDataWithDescription:(FilePersistentDescription *)persistentDescription {
    NSString *path = [NSString stringWithFormat:@"%@/%@", [self userCachePathWithFolderName:persistentDescription.folderName], persistentDescription.cacheKey];
    NSData   *data = [NSData dataWithContentsOfFile:path];
    id       cache = [NSKeyedUnarchiver unarchiveObjectWithData:data exception_p:NULL];
    
    return cache;
}


@end
