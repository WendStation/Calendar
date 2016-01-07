//
//  MessageDatabase.m
//  Calendar
//
//  Created by 刘花椒 on 15/12/8.
//
//

#import "GroupListDatabase.h"
#import "GroupListItem.h"
#import "ChatMessageListItem.h"

@interface GroupListDatabase ()

@property (nonatomic, strong) NSMutableDictionary *whereDict;
@property (nonatomic, strong) NSMutableDictionary *fieldDict;

@end

@implementation GroupListDatabase

+ (GroupListDatabase *)shareInstance {
    static GroupListDatabase *mdb = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        mdb = [[GroupListDatabase alloc] init];
        mdb.whereDict = [NSMutableDictionary dictionaryWithCapacity:0];
        mdb.fieldDict = [NSMutableDictionary dictionaryWithCapacity:0];
    });
    return mdb;
}

- (void)saveGroupListToDatabase:(id)object tableName:(NSString *)tableName {
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
            for (GroupListItem *item in array) {
                NSString *selectQuery = [NSString stringWithFormat:@"SELECT groupId FROM %@ WHERE groupId = %ld",tableName, (long)item.groupId];
                NSString *groupId = [db stringForQuery:selectQuery];
                
                if (groupId.length > 0) {
                    NSString *updateQuery = [[HJDatabase shareInstance] createUpdateSQL:item tableName:tableName primarykeyName:@"groupId"];
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

- (void)saveMessageListToDatabase:(id)object tableName:(NSString *)tableName {
    if ([object isKindOfClass:[NSMutableArray class]] || [object isKindOfClass:[NSArray class]]) {
        NSArray *messages = (NSArray *)object;
        [[HJDatabase shareInstance] executeDB:^(FMDatabase *db) {
            if (![[HJDatabase shareInstance] isTableExist:tableName]) {
                NSString *createTableSQL = [[HJDatabase shareInstance] createTableSQL:tableName class:[messages.firstObject class]];
                BOOL isSucess = [db executeUpdate:createTableSQL];
                if (!isSucess) {
                    NSLog(@"table create fail %@",[db lastErrorMessage]);
                    return ;
                }
            }
            [[HJDatabase shareInstance] modifyTable:db.sqliteHandle tableName:tableName model:messages.firstObject];
            [db beginDeferredTransaction];
            for (ChatMessageListItem *item in messages) {
                [self.whereDict removeAllObjects];
                NSString *messageId = [NSString stringWithFormat:@"messageId = %ld",(long)item.messageId];
                [self.whereDict setObject:messageId forKey:@"messageId"];
                NSString *result1 = [[HJDatabaseManager shareInstance] stringQueryByAndWhereDict:self.whereDict field:@"messageId" tableName:tableName];
                if (!result1.length || item.isError) {
                    NSString *insertQuery = [[HJDatabase shareInstance] createInsertSQL:item tableName:tableName];
                    BOOL isSucess = [db executeUpdate:insertQuery];
                    if (!isSucess) {
                        NSLog(@"INSERT fail: %@",[db lastErrorMessage]);
                    }
                } else {
                    NSString *avatar = [NSString stringWithFormat:@"avatar = '%@'",item.avatar];
                    [self.fieldDict setObject:avatar forKey:@"avatar"];
                    NSString *name = [NSString stringWithFormat:@"name = '%@'",item.name];
                    [self.fieldDict setObject:name forKey:@"name"];
                    [[HJDatabaseManager shareInstance] updateColumnsOfTable:self.fieldDict tableName:tableName];
                }
            }
            [db commit];
        }];
    }
}

@end
