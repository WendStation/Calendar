//
//  FMDatabaseManager.m
//  Calendar
//
//  Created by 刘花椒 on 15/10/31.
//
//

#import "HJDatabaseManager.h"
#import "HJDatabase.h"

@implementation HJDatabaseManager

+ (HJDatabaseManager *)shareInstance{
    static HJDatabaseManager *fmdb = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        fmdb = [[HJDatabaseManager alloc] init];
    });
    return fmdb;
}

#pragma mark pagingReadTableDatas
-(NSArray *)readArrayClass:(Class)class Page:(NSInteger)page pageSize:(NSInteger)size tableName:(NSString *)tableName {
    __block NSMutableArray *resultArray = [NSMutableArray new];
    [[HJDatabase shareInstance] executeDB:^(FMDatabase *db) {
        NSString *sql=[NSString stringWithFormat:@"select * from %@ limit %ld,%ld",tableName,(long)(page-1)*size,(long)size];
        FMResultSet * rs = [db executeQuery:sql];
        while (rs.next) {
            id model = [class new];
            NSMutableDictionary *dict = (NSMutableDictionary *)[rs resultDictionary];
            [dict removeObjectForKey:@"serial"];
            [model setValuesForKeysWithDictionary:dict];
            [resultArray addObject:model];
        }
    }];
    
    return resultArray;
}

#pragma mark wherePagingReadTableDatas
- (NSArray *)readArrayClass:(Class)class Page:(NSInteger)page pageSize:(NSInteger)size where:(NSDictionary *)whereDict tableName:(NSString *)tableName {
    __block NSMutableArray *resultArray = [NSMutableArray new];
    [[HJDatabase shareInstance] executeDB:^(FMDatabase *db) {
        NSString *where = @"";
        NSArray *array = whereDict.allKeys;
        for(int i=0; i < whereDict.count; i++){
            NSString *key = array[i];
            NSString *value = [whereDict objectForKey:key];
            if(i == whereDict.count - 1) {
                where = [where stringByAppendingString:[NSString stringWithFormat:@" %@ ",value]];
            }else {
                where = [where stringByAppendingString:[NSString stringWithFormat:@" %@ and ",value]];
            }
        }
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@limit %ld,%ld",tableName,where,(long)(page - 1) * size,(long)page * size - 1];
        FMResultSet *rs = [db executeQuery:sql];
        while (rs.next) {
            id model = [class new];
            NSMutableDictionary *dict = (NSMutableDictionary *)[rs resultDictionary];
            [dict removeObjectForKey:@"serial"];
            [model setValuesForKeysWithDictionary:dict];
            [resultArray addObject:model];
        }
    }];
    return resultArray;
}

#pragma mark invertedWherePagingReadTableDatas
- (NSArray *)invertedReadArray:(NSInteger)page pageSize:(NSInteger)size where:(NSDictionary *)whereDict field:(NSString *)field tableName:(NSString *)tableName {
    __block NSMutableArray *resultArray = [NSMutableArray new];
    [[HJDatabase shareInstance] executeDB:^(FMDatabase *db) {
        NSString *where = @"";
        NSArray *array = whereDict.allKeys;
        for(int i=0; i < whereDict.count; i++){
            NSString *key = array[i];
            NSString *value = [whereDict objectForKey:key];
            if(i == whereDict.count - 1) {
                where = [where stringByAppendingString:[NSString stringWithFormat:@" %@ ",value]];
            }else {
                where = [where stringByAppendingString:[NSString stringWithFormat:@" %@ and ",value]];
            }
        }
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@  order by %@ desc limit %ld,%ld",tableName,where,field,(long)(page - 1) * size,(long)size];
        
        FMResultSet *rs = [db executeQuery:sql];
        while (rs.next) {
            NSMutableDictionary *dict = (NSMutableDictionary *)[rs resultDictionary];
            [dict removeObjectForKey:@"serial"];
            [resultArray addObject:dict];
        }
    }];
    return resultArray;
}

- (NSArray *)invertedReadArray:(NSInteger)page pageSize:(NSInteger)size tableName:(NSString *)tableName {
    __block NSMutableArray *resultArray = [NSMutableArray new];
    [[HJDatabase shareInstance] executeDB:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@ order by serial desc limit %ld,%ld",tableName,(long)(page - 1) * size,(long)size];
        FMResultSet *rs = [db executeQuery:sql];
        while (rs.next) {
            NSMutableDictionary *dict = (NSMutableDictionary *)[rs resultDictionary];
            [dict removeObjectForKey:@"serial"];
            [resultArray addObject:dict];
        }
    }];
    return resultArray;
}

#pragma mark queryByOrWhere
- (NSArray *)queryByOrWhereDict:(NSDictionary *)whereDict tableName:(NSString *)tableName {
    __block NSMutableArray *resultArray = [NSMutableArray array];
    [[HJDatabase shareInstance] executeDB:^(FMDatabase *db) {
        NSString *where = @"";
        NSArray *array = whereDict.allKeys;
        for (NSInteger i = 0; i < [whereDict.allKeys count]; i++) {
            NSString *key = array[i];
            NSString *value = [whereDict objectForKey:key];
            if (i == whereDict.allKeys.count -  1) {
                where = [where stringByAppendingString:[NSString stringWithFormat:@"%@ like '%%%@%%'",key,value]];
            } else {
                where = [where stringByAppendingString:[NSString stringWithFormat:@"%@ like '%%%@%%' or ",key,value]];
            }
        }
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@",tableName,where];
        FMResultSet *rs = [db executeQuery:sql];
        while (rs.next) {
            NSMutableDictionary *dict = (NSMutableDictionary *)[rs resultDictionary];
            [dict removeObjectForKey:@"serial"];
            [resultArray addObject:dict];
        }
    }];
    return resultArray;
}

#pragma mark queryByAndWhere
- (NSArray *)queryByAndWhereDict:(NSDictionary *)whereDict tableName:(NSString *)tableName{
    __block NSMutableArray *resultArray = [NSMutableArray array];
    [[HJDatabase shareInstance] executeDB:^(FMDatabase *db) {
        NSString *where = @"";
        NSArray *array = whereDict.allKeys;
        for (NSInteger i = 0; i < [whereDict.allKeys count]; i++) {
            NSString *key = array[i];
            NSString *value = [whereDict objectForKey:key];
            if (i == whereDict.allKeys.count -  1) {
                where = [where stringByAppendingString:[NSString stringWithFormat:@" %@",value]];
            } else {
                where = [where stringByAppendingString:[NSString stringWithFormat:@" %@ and ",value]];
            }
        }
        NSString *sql = [NSString stringWithFormat:@"select * from %@ where %@",tableName,where];
        FMResultSet *rs = [db executeQuery:sql];
        while (rs.next) {
            NSMutableDictionary *dict = (NSMutableDictionary *)[rs resultDictionary];
            [dict removeObjectForKey:@"serial"];
            [resultArray addObject:dict];
        }
    }];
    return resultArray;
}

- (NSString *)stringQueryByAndWhereDict:(NSDictionary *)whereDict field:(NSString *)field tableName:(NSString *)tableName {
    __block NSString *resultStr = @"";
    [[HJDatabase shareInstance] executeDB:^(FMDatabase *db) {
        NSString *where = @"";
        NSArray *array = whereDict.allKeys;
        for (NSInteger i = 0; i < [whereDict.allKeys count]; i++) {
            NSString *key = array[i];
            NSString *value = [whereDict objectForKey:key];
            if (i == whereDict.allKeys.count -  1) {
                where = [where stringByAppendingString:[NSString stringWithFormat:@" %@",value]];
            } else {
                where = [where stringByAppendingString:[NSString stringWithFormat:@" %@ and ",value]];
            }
        }
        NSString *sql = [NSString stringWithFormat:@"select %@ from %@ where %@",field,tableName,where];
        NSString *result = [db stringForQuery:sql];
        resultStr = result;
    }];
    return resultStr;
}

- (NSInteger)getMaxFromTableName:(NSString *)tableName field:(NSString *)field whereDict:(NSDictionary *)whereDict {
    __block NSInteger resultInt;
    [[HJDatabase shareInstance] executeDB:^(FMDatabase *db) {
        NSString *where = @"";
        NSArray *array = whereDict.allKeys;
        for (NSInteger i = 0; i < [whereDict.allKeys count]; i++) {
            NSString *key = array[i];
            NSString *value = [whereDict objectForKey:key];
            if (i == whereDict.allKeys.count -  1) {
                where = [where stringByAppendingString:[NSString stringWithFormat:@" %@",value]];
            } else {
                where = [where stringByAppendingString:[NSString stringWithFormat:@" %@ and ",value]];
            }
        }
        NSString *sql = [NSString stringWithFormat:@"select max(%@) from %@ where %@",field,tableName,where];
        resultInt = [db intForQuery:sql];
    }];
    return resultInt;
}

- (NSInteger)getMinFromTableName:(NSString *)tableName field:(NSString *)field whereDict:(NSDictionary *)whereDict {
    __block NSInteger resultInt;
    [[HJDatabase shareInstance] executeDB:^(FMDatabase *db) {
        NSString *where = @"";
        NSArray *array = whereDict.allKeys;
        for (NSInteger i = 0; i < [whereDict.allKeys count]; i++) {
            NSString *key = array[i];
            NSString *value = [whereDict objectForKey:key];
            if (i == whereDict.allKeys.count -  1) {
                where = [where stringByAppendingString:[NSString stringWithFormat:@" %@",value]];
            } else {
                where = [where stringByAppendingString:[NSString stringWithFormat:@" %@ and ",value]];
            }
        }
        NSString *sql = [NSString stringWithFormat:@"select min(%@) from %@ where %@",field,tableName,where];
        resultInt = [db intForQuery:sql];
    }];
    return resultInt;
}

#pragma mark queryAllDatas
- (NSArray *)queryTableName:(NSString *)tableName {
    __block NSMutableArray *resultArray = [NSMutableArray array];
    [[HJDatabase shareInstance] executeDB:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"select * from %@",tableName];
        FMResultSet *rs = [db executeQuery:sql];
        while (rs.next) {
            NSMutableDictionary *dict = (NSMutableDictionary *)[rs resultDictionary];
            [dict removeObjectForKey:@"serial"];
            [resultArray addObject:dict];
        }
    }];
    return resultArray;
}

#pragma mark queryObjectCountByAndWhereDict
- (NSInteger)queryObjectCountByAnd:(NSDictionary *)whereDict tableName:(NSString *)tableName {
    __block NSInteger count = 0;
    [[HJDatabase shareInstance] executeDB:^(FMDatabase *db) {
        NSString *where = @"";
        NSArray *array = whereDict.allKeys;
        for (NSInteger i = 0; i < [whereDict.allKeys count]; i++) {
            NSString *key = array[i];
            NSString *value = [whereDict objectForKey:key];
            if (i == whereDict.allKeys.count -  1) {
                where = [where stringByAppendingString:[NSString stringWithFormat:@" %@",value]];
            } else {
                where = [where stringByAppendingString:[NSString stringWithFormat:@" %@ and ",value]];
            }
        }
        NSString *sql = [NSString stringWithFormat:@"select count(*) from %@ where %@",tableName,where];
        FMResultSet *rs = [db executeQuery:sql];
        while (rs.next) {
            count = [rs intForColumnIndex:0];
            break;
        }
    }];
    return count;
}

#pragma mark updateColumnsOfTable
- (void)updateColumnsOfTable:(NSDictionary *)whereDict field:(NSDictionary *)fieldDict tableName:(NSString *)tableName {
    [[HJDatabase shareInstance] executeDB:^(FMDatabase *db) {
        NSString *where = @"";
        NSArray *whereAry = whereDict.allKeys;
        for (NSInteger i = 0; i < [whereAry count]; i++) {
            NSString *key = whereAry[i];
            NSString *value = [whereDict objectForKey:key];
            if (i == whereDict.allKeys.count -  1) {
                where = [where stringByAppendingString:[NSString stringWithFormat:@" %@",value]];
            } else {
                where = [where stringByAppendingString:[NSString stringWithFormat:@" %@ and ",value]];
            }
        }
        
        NSString *field = @"";
        NSArray *fieldAry = fieldDict.allKeys;
        for (NSInteger i = 0; i < [fieldAry count]; i++) {
            NSString *key = fieldAry[i];
            NSString *value = [fieldDict objectForKey:key];
            if (i == fieldDict.allKeys.count -  1) {
                field = [field stringByAppendingString:[NSString stringWithFormat:@" %@",value]];
            } else {
                field = [field stringByAppendingString:[NSString stringWithFormat:@" %@ and ",value]];
            }
        }
        
        NSString *sql = [NSString stringWithFormat:@"update %@ set %@ where %@",tableName,field,where];
        BOOL isSucess = [db executeUpdate:sql];
        if (!isSucess) {
            NSLog(@"update failed: %@",[db lastErrorMessage]);
        }        
    }];
}

- (void)updateColumnsOfTable:(NSDictionary *)fieldDict tableName:(NSString *)tableName {
    [[HJDatabase shareInstance] executeDB:^(FMDatabase *db) {
        NSString *field = @"";
        NSArray *fieldAry = fieldDict.allKeys;
        for (NSInteger i = 0; i < [fieldAry count]; i++) {
            NSString *key = fieldAry[i];
            NSString *value = [fieldDict objectForKey:key];
            if (i == fieldDict.allKeys.count -  1) {
                field = [field stringByAppendingString:[NSString stringWithFormat:@" %@",value]];
            } else {
                field = [field stringByAppendingString:[NSString stringWithFormat:@" %@ and ",value]];
            }
        }
        
        NSString *sql = [NSString stringWithFormat:@"update %@ set %@",tableName,field];
        BOOL isSucess = [db executeUpdate:sql];
        if (!isSucess) {
            NSLog(@"update failed: %@",[db lastErrorMessage]);
        }
    }];

}

@end
