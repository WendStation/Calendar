//
//  FMDatabaseManager.h
//  Calendar
//
//  Created by 刘花椒 on 15/10/31.
//
//

#import <Foundation/Foundation.h>
#import "FMDatabaseQueue.h"

@interface HJDatabaseManager : NSObject

+ (HJDatabaseManager *)shareInstance;

#pragma mark pagingReadTableDatas
- (NSArray *)readArrayClass:(Class)class Page:(NSInteger)page pageSize:(NSInteger)size tableName:(NSString *)tableName;
#pragma mark wherePagingReadTableDatas
- (NSArray *)readArrayClass:(Class)class Page:(NSInteger)page pageSize:(NSInteger)size where:(NSDictionary *)whereDict tableName:(NSString *)tableName;
#pragma mark invertedWherePagingReadTableDatas
- (NSArray *)invertedReadArray:(NSInteger)page pageSize:(NSInteger)size where:(NSDictionary *)whereDict field:(NSString *)field tableName:(NSString *)tableName;
- (NSArray *)invertedReadArray:(NSInteger)page pageSize:(NSInteger)size tableName:(NSString *)tableName;
#pragma mark queryByAndWhere
- (NSArray *)queryByAndWhereDict:(NSDictionary *)whereDict tableName:(NSString *)tableName;
#pragma mark queryByOrWhere
- (NSArray *)queryByOrWhereDict:(NSDictionary *)whereDict tableName:(NSString *)tableName;
#pragma mark queryAllDatas
- (NSArray *)queryTableName:(NSString *)tableName;
#pragma mark queryObjectCountByAndWhereDict
- (NSInteger)queryObjectCountByAnd:(NSDictionary *)whereDict tableName:(NSString *)tableName;
#pragma mark updateColumnsOfTable
- (void)updateColumnsOfTable:(NSDictionary *)whereDict field:(NSDictionary *)fieldDict tableName:(NSString *)tableName;
- (void)updateColumnsOfTable:(NSDictionary *)fieldDict tableName:(NSString *)tableName;

- (NSString *)stringQueryByAndWhereDict:(NSDictionary *)whereDict field:(NSString *)field tableName:(NSString *)tableName;
- (NSInteger)getMaxFromTableName:(NSString *)tableName field:(NSString *)field whereDict:(NSDictionary *)whereDict;
- (NSInteger)getMinFromTableName:(NSString *)tableName field:(NSString *)field whereDict:(NSDictionary *)whereDict;

@end
