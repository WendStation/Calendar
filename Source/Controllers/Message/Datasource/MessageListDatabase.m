//
//  MessageListDatabase.m
//  Calendar
//
//  Created by 刘花椒 on 15/12/9.
//
//

#import "MessageListDatabase.h"
#import "MessageListItem.h"

@implementation MessageListDatabase

+ (MessageListDatabase *)shareInstance {
    static MessageListDatabase *mdb = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        mdb = [[MessageListDatabase alloc] init];
    });
    return mdb;
}

- (void)saveMessageListToDatabase:(id)object tableName:(NSString *)tableName {
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
            for (MessageListItem *item in array) {
                NSString *selectQuery = [NSString stringWithFormat:@"SELECT messageId FROM %@ WHERE messageId = '%@'",tableName, item.messageId];
                NSString *messageId = [db stringForQuery:selectQuery];
                
                if (messageId.length > 0) {
                    NSString *updateQuery = [[HJDatabase shareInstance] createUpdateSQL:item tableName:tableName primarykeyName:@"messageId"];
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
