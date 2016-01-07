//
//  WriteFilePersistentManager.h
//  Calendar
//
//  Created by 刘花椒 on 15/11/2.
//
//

#import <Foundation/Foundation.h>

@interface FilePersistentDescription : NSObject

@property (nonatomic, copy) NSString *folderName;
@property (nonatomic, copy) NSString *cacheKey;
@property (nonatomic, retain) id     cacheData;
@property (nonatomic, assign) BOOL   autoClear;

+ (FilePersistentDescription *)persistentDescriptionWithFolderName:(NSString *)folderName
                                                             cacheKey:(NSString *)cacheKey
                                                            cacheData:(id)cacheData;

@end

@interface WriteFilePersistentManager : NSObject

+ (WriteFilePersistentManager *)instance;

- (BOOL)saveDataWithDescription:(FilePersistentDescription *)persistentDescription;

- (id)cacheDataWithDescription:(FilePersistentDescription *)persistentDescription;

- (NSString *)documentPath;

- (BOOL)removeCacheFolderName:(NSString *)folderName cacheKey:(NSString *)cacheKey;

@end
