//
//  TaskListDatasource.m
//  Calendar
//
//  Created by 刘花椒 on 15/12/15.
//
//

#import "TaskListDatasource.h"
#import "TaskListItem.h"
#import "TaskListDatabase.h"

@interface TaskListDatasource ()

@property (nonatomic, assign) NSInteger taskListpage;

@end

@implementation TaskListDatasource

- (instancetype)init {
    if (self = [super init]) {
        self.taskListAry = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

- (void)postTaskListIsLoadMore:(BOOL)isLoadMore succeed:(PostSucceed)succeed failed:(PostFailed)failed {
    if (!isLoadMore) {
        self.taskListpage = 0;
        [self.taskListAry removeAllObjects];
    } else {
        self.taskListpage ++;
    }
    NSDictionary *para = @{
                           @"access_token":[CacheManager sharedInstance].accessToken,
                           @"completed"   :@"0"
                           };
    NSString *requestUrl = [NSString stringWithFormat:@"%@%ld",GET_TASK_LIST_URL,(long)self.taskListpage];
    [[NetworkManager sharedInstance] postRequest:requestUrl params:para successBlock:^(NSDictionary *dict) {
        if ([dict objectForKey:@"data"]) {
            NSArray *tasks = [[dict objectForKey:@"data"] objectForKey:@"tasks"];
            if ([tasks count] > 0) {
                for (NSDictionary *dict in tasks) {
                    TaskListItem *item = [[TaskListItem alloc] initTaskListItem:dict];
                    [self.taskListAry addObject:item];
                }
                [[TaskListDatabase shareInstance] saveTaskListToDatabase:self.taskListAry  tableName:TaskListTableName];
            }
        }
        succeed (self.taskListAry);
    } failedBlock:^(id object){
        [self getTaskListFromDatabase:isLoadMore complete:^(id object) {
            failed (object);
        }];
    }];
}

- (void)getTaskListFromDatabase:(BOOL)isLoadMore complete:(Complete)complete {
    if (!isLoadMore) {
        self.taskListpage = 1;
        [self.taskListAry removeAllObjects];
    } else {
        if (self.taskListpage == 0) {
            self.taskListpage = 1;
        }
        if (self.taskListAry.count % 30 != 0) {
            [AlertManager showAlertText:@"亲！没有更多数据了哦～～～" withCloseSecond:1];
            complete(self.taskListAry);
        }
        self.taskListpage ++;
    }
    
    [self.taskListAry addObjectsFromArray:[[HJDatabaseManager shareInstance] readArrayClass:[TaskListItem class] Page:self.taskListpage pageSize:30 tableName:TaskListTableName]];
    complete(self.taskListAry);
}

@end
