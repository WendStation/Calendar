//
//  TaskListDatabase.m
//  Calendar
//
//  Created by 刘花椒 on 15/12/15.
//
//

#import "TaskListDatabase.h"
#import "TaskListItem.h"

@implementation TaskListDatabase

+ (TaskListDatabase *)shareInstance {
    static TaskListDatabase *db = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        db = [[TaskListDatabase alloc] init];
    });
    return db;
}

- (void)saveTaskListToDatabase:(id)object tableName:(NSString *)tableName {
    if ([object isKindOfClass:[NSArray class]] || [object isKindOfClass:[NSMutableArray class]]) {
        NSArray *array = (NSArray *)object;
        [[HJDatabase shareInstance] executeDB:^(FMDatabase *db) {
            if (![[HJDatabase shareInstance] isTableExist:tableName]) {
                NSString *createTableSQL = [[HJDatabase shareInstance] createTableSQL:tableName class:[array.firstObject class]];
                BOOL isSucess = [db executeUpdate:createTableSQL];
                if (!isSucess) {
                    NSLog(@"table create fail %@",[db lastErrorMessage]);
                    return ;
                }
            }
            [[HJDatabase shareInstance] modifyTable:db.sqliteHandle tableName:tableName model:[array.firstObject class]];
            [db beginDeferredTransaction];
            for (TaskListItem *item in array) {
                NSString *selectQuery = [NSString stringWithFormat:@"SELECT taskId FROM %@ WHERE taskId = '%ld'",tableName, (long)item.taskId];
                NSString *taskId = [db stringForQuery:selectQuery];
                if (taskId.length > 0) {
                    NSString *updateQuery = [[HJDatabase shareInstance] createUpdateSQL:item tableName:tableName primarykeyName:@"taskId"];
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
}

@end
