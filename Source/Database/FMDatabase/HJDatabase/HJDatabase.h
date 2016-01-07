//
//  HJDatabase.h
//  Calendar
//
//  Created by 刘花椒 on 15/12/2.
//
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"

@interface HJDatabase : NSObject

@property (nonatomic, strong) FMDatabase *DB;
@property (nonatomic, strong) NSRecursiveLock *threadLock;
@property (nonatomic, strong) FMDatabaseQueue *dbQueue;//FMDatabaseQueue 这个类在多个线程来执行查询和更新时会使用这个类。避免同时访问同一个数据。


#pragma mark databaseShareInstance
+ (HJDatabase *)shareInstance;
#pragma mark operateDatabase
- (void)executeDB:(void (^)(FMDatabase *db))block;
#pragma mark tableIsExist
- (BOOL)isTableExist:(NSString *)tableName;
#pragma mark createTableSQL
- (NSString *)createTableSQL:(NSString *)tableName class:(Class)class;
#pragma mark createInsertSQL
-(NSString*)createInsertSQL:(id)model tableName:(NSString*)tableName;
#pragma mark createUpdateSQL
-(NSString*)createUpdateSQL:(id)model tableName:(NSString*)tableName primarykeyName:(NSString *)primarykeyName;
#pragma mark modify table
- (void)modifyTable:(sqlite3*)sqlite tableName:(NSString*)tableName model:(id)model;
#pragma mark queryTableLineNumber
- (NSInteger)count:(NSString *)tableName;
#pragma mark deleteDataBase
- (void)deleteDB;
- (void)deleteTableDatasource:(NSString *)tableName;

@end
