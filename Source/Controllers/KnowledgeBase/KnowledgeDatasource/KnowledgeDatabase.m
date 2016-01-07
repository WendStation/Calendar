//
//  KnowledgeDatabase.m
//  Calendar
//
//  Created by 刘花椒 on 15/12/7.
//
//

#import "KnowledgeDatabase.h"
#import "SearchFounderListItem.h"

@implementation KnowledgeDatabase

+ (KnowledgeDatabase *)shareInstance{
    static KnowledgeDatabase *kdb = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        kdb = [[KnowledgeDatabase alloc] init];
     });
    return kdb;
}

#pragma mark saveFounderListToDatabase
- (void)saveFounderListArray:(NSArray *)array tableName:(NSString *)tableName {
    [[HJDatabase shareInstance] executeDB:^(FMDatabase *db) {
        if (![[HJDatabase shareInstance] isTableExist:tableName]) {
            NSString *createTableSQL = [[HJDatabase shareInstance] createTableSQL:tableName class:[array.firstObject class]];
            BOOL isSucess = [db executeUpdate:createTableSQL];
            if (!isSucess) {
                NSLog(@"table create fail %@",[db lastErrorMessage]);
            }
        }
        [[HJDatabase shareInstance] modifyTable:db.sqliteHandle tableName:tableName model:[array.firstObject class]];
        [db beginDeferredTransaction];
        for (SearchFounderListItem *item in array) {
            NSString *selectQuery = [NSString stringWithFormat:@"SELECT userId FROM %@ WHERE userId = '%@'",tableName, item.userId];
            NSString *userId = [db stringForQuery:selectQuery];
        
            if (userId.length > 0) {
                NSString *updateQuery = [[HJDatabase shareInstance] createUpdateSQL:item tableName:tableName primarykeyName:@"userId"];
                BOOL isSucess = [db executeUpdate:updateQuery];
                if (!isSucess) {
                    NSLog(@"update fail: %@",[db lastErrorMessage]);
                }
            } else {
                NSString *insertQuery = [[HJDatabase shareInstance] createInsertSQL:item tableName:tableName];
                BOOL isSucess = [db executeUpdate:insertQuery];
                if (!isSucess) {
                    NSLog(@"INSERT fail: %@",[db lastErrorMessage]);
                }
            }
        }
        [db commit];
    }];
}

#pragma mark saveFundListToDatabase
- (void)saveFundListArray:(NSArray *)array tableName:(NSString *)tableName {
    [[HJDatabase shareInstance] executeDB:^(FMDatabase *db) {
        if (![[HJDatabase shareInstance] isTableExist:tableName]) {
            NSString *createTableSQL = [[HJDatabase shareInstance] createTableSQL:tableName class:[array.firstObject class]];
            BOOL isSucess = [db executeUpdate:createTableSQL];
            if (!isSucess) {
                NSLog(@"table create fail %@",[db lastErrorMessage]);
            }
        }
        [[HJDatabase shareInstance] modifyTable:db.sqliteHandle tableName:tableName model:[array.firstObject class]];
        [db beginDeferredTransaction];
        for (SearchFounListItem *item in array) {
            NSString *selectQuery = [NSString stringWithFormat:@"SELECT fundId FROM %@ WHERE fundId = '%@'",tableName, item.fundId];
            NSString *fundId = [db stringForQuery:selectQuery];
            
            if (fundId.length > 0) {
                NSString *updateQuery = [[HJDatabase shareInstance] createUpdateSQL:item tableName:tableName primarykeyName:@"fundId"];
                BOOL isSucess = [db executeUpdate:updateQuery];
                if (!isSucess) {
                    NSLog(@"update fail: %@",[db lastErrorMessage]);
                }
            } else {
                NSString *insertQuery = [[HJDatabase shareInstance] createInsertSQL:item tableName:tableName];
                BOOL isSucess = [db executeUpdate:insertQuery];
                if (!isSucess) {
                    NSLog(@"INSERT fail: %@",[db lastErrorMessage]);
                }
            }
        }
        [db commit];
    }];
}

#pragma mark saveFounderDetailToDatabase
- (void)saveFounderDetail:(FounderDetailItem *)item tableName:(NSString *)tableName {
    [[HJDatabase shareInstance] executeDB:^(FMDatabase *db) {
        if (![[HJDatabase shareInstance] isTableExist:tableName]) {
            NSString *createTableSQL = [[HJDatabase shareInstance] createTableSQL:tableName class:[item class]];
            BOOL isSucess = [db executeUpdate:createTableSQL];
            if (!isSucess) {
                NSLog(@"table create fail %@",[db lastErrorMessage]);
            }
        }
        [[HJDatabase shareInstance] modifyTable:db.sqliteHandle tableName:tableName model:[item class]];
        [db beginDeferredTransaction];
        NSString *selectQuery = [NSString stringWithFormat:@"SELECT userId FROM %@ WHERE userId = '%@'",tableName, item.userId];
        NSString *userId = [db stringForQuery:selectQuery];
            
        if (userId.length > 0) {
            NSString *updateQuery = [[HJDatabase shareInstance] createUpdateSQL:item tableName:tableName primarykeyName:@"userId"];
            BOOL isSucess = [db executeUpdate:updateQuery];
            if (!isSucess) {
                NSLog(@"update fail: %@",[db lastErrorMessage]);
            }
        } else {
            NSString *insertQuery = [[HJDatabase shareInstance] createInsertSQL:item tableName:tableName];
            BOOL isSucess = [db executeUpdate:insertQuery];
            if (!isSucess) {
                NSLog(@"INSERT fail: %@",[db lastErrorMessage]);
            }
        }
    [db commit];
    }];
}

#pragma mark saveFundDetailToDatabase
- (void)saveFundDetail:(FundDetailItem *)item tableName:(NSString *)tableName {
    [[HJDatabase shareInstance] executeDB:^(FMDatabase *db) {
        if (![[HJDatabase shareInstance] isTableExist:tableName]) {
            NSString *createTableSQL = [[HJDatabase shareInstance] createTableSQL:tableName class:[item class]];
            BOOL isSucess = [db executeUpdate:createTableSQL];
            if (!isSucess) {
                NSLog(@"table create fail %@",[db lastErrorMessage]);
            }
        }
        [[HJDatabase shareInstance] modifyTable:db.sqliteHandle tableName:tableName model:[item class]];
        
        [db beginDeferredTransaction];
        NSString *selectQuery = [NSString stringWithFormat:@"SELECT fundId FROM %@ WHERE fundId = '%@'",tableName,item.fundId];
        NSString *fundId = [db stringForQuery:selectQuery];
        if (fundId.length > 0) {
            NSString *updateSql = [[HJDatabase shareInstance] createUpdateSQL:item tableName:tableName primarykeyName:@"fundId"];
            BOOL isSucess = [db executeUpdate:updateSql];
            if (!isSucess) {
                NSLog(@"update failed: %@",[db lastErrorMessage]);
            }
        } else {
            NSString *insertSql = [[HJDatabase shareInstance] createInsertSQL:item tableName:tableName];
            BOOL isSucess = [db executeUpdate:insertSql];
            if(!isSucess){
                NSLog(@"insert failed: %@",[db lastErrorMessage]);
            }
        }
        [db commit];
    }];
}
@end
