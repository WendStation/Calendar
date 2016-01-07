//
//  ProjectDatabase.m
//  Calendar
//
//  Created by 刘花椒 on 15/12/18.
//
//

#import "ProjectDatabase.h"
#import "ProjectListItem.h"

@implementation ProjectDatabase

+ (ProjectDatabase *)shareInstance {
    static ProjectDatabase *db = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        db = [[ProjectDatabase alloc] init];
    });
    return db;
}

#pragma mark saveProjectListToDatabase
- (void)saveProjectListArray:(NSArray *)projectAry tableName:(NSString *)tableName{
    [[HJDatabase shareInstance] executeDB:^(FMDatabase *db) {
        if (![[HJDatabase shareInstance] isTableExist:tableName]) {
            NSString *createTableSQL = [[HJDatabase shareInstance] createTableSQL:tableName class:[projectAry.firstObject class]];
            BOOL isSucess = [db executeUpdate:createTableSQL];
            if (!isSucess) {
                NSLog(@"table create fail %@",[db lastErrorMessage]);
            }
        }
        [[HJDatabase shareInstance] modifyTable:db.sqliteHandle tableName:tableName model:[projectAry.firstObject class]];
        [db beginDeferredTransaction];
        for (ProjectListItem *item in projectAry) {
            NSString *selectQuery = [NSString stringWithFormat:@"SELECT projectId FROM %@ WHERE projectId = '%@'",tableName, item.projectId];
            NSString *project_id = [db stringForQuery:selectQuery];
            if (project_id.length > 0) {
                NSString *updateQuery = [[HJDatabase shareInstance] createUpdateSQL:item tableName:tableName primarykeyName:@"projectId"];
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

#pragma mark saveProjectDetailToDatase
- (void)saveProjectDetail:(ProjectDetailItem *)item tableName:(NSString *)tableName{
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
        NSString *selectQuery = [NSString stringWithFormat:@"SELECT projectId FROM %@ WHERE projectId = '%@'",tableName,item.projectId];
        NSString *project_id = [db stringForQuery:selectQuery];
        if (project_id.length > 0) {
            NSString *updateSql = [[HJDatabase shareInstance] createUpdateSQL:item tableName:tableName primarykeyName:@"projectId"];
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

#pragma mark saveMeetingRecordToDatabase
- (void)saveMeetingRecordArray:(NSArray *)projectAry tableName:(NSString *)tableName {
    [[HJDatabase shareInstance] executeDB:^(FMDatabase *db) {
        if (![[HJDatabase shareInstance] isTableExist:tableName]) {
            NSString *createTableSQL = [[HJDatabase shareInstance] createTableSQL:tableName class:[projectAry.firstObject class]];
            BOOL isSucess = [db executeUpdate:createTableSQL];
            if (!isSucess) {
                NSLog(@"table create fail %@",[db lastErrorMessage]);
            }
        }
        [[HJDatabase shareInstance] modifyTable:db.sqliteHandle tableName:tableName model:[projectAry.firstObject class]];
        
        [db beginDeferredTransaction];
        for (ProjectMeetingRecordItem *item in projectAry) {
            NSString *selectQuery = [NSString stringWithFormat:@"SELECT meetingId FROM %@ WHERE meetingId = '%@'",tableName, item.meetingId];
            NSString *meetingId = [db stringForQuery:selectQuery];
            if (meetingId.length > 0) {
                NSString *updateSql = [[HJDatabase shareInstance] createUpdateSQL:item tableName:tableName primarykeyName:@"meetingId"];
                BOOL isSucess = [db executeUpdate:updateSql];
                if (!isSucess) {
                    NSLog(@"update failed: %@",[db lastErrorMessage]);
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

#pragma mark saveUpdateRecordToDatabase
- (void)saveUpdateRecordArray:(NSArray *)projectAry tableName:(NSString *)tableName {
    [[HJDatabase shareInstance] executeDB:^(FMDatabase *db) {
        if (![[HJDatabase shareInstance] isTableExist:tableName]) {
            NSString *createTableSQL = [[HJDatabase shareInstance] createTableSQL:tableName class:[projectAry.firstObject class]];
            BOOL isSucess = [db executeUpdate:createTableSQL];
            if (!isSucess) {
                NSLog(@"table create fail %@",[db lastErrorMessage]);
            }
        }
        [[HJDatabase shareInstance] modifyTable:db.sqliteHandle tableName:tableName model:[projectAry.firstObject class]];
        
        [db beginDeferredTransaction];
        for (ProjectUpdateRecordItem *item in projectAry) {
            
            NSString *selectQuery = [NSString stringWithFormat:@"SELECT operationId FROM %@ WHERE operationId = '%@'",tableName, item.operationId];
            NSString *operationId = [db stringForQuery:selectQuery];
            if (operationId.length > 0) {
                NSString *updateSql = [[HJDatabase shareInstance] createUpdateSQL:item tableName:tableName primarykeyName:@"operationId"];
                BOOL isSucess = [db executeUpdate:updateSql];
                if (!isSucess) {
                    NSLog(@"update failed: %@",[db lastErrorMessage]);
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


@end
