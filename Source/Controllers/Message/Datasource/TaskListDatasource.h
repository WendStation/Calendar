//
//  TaskListDatasource.h
//  Calendar
//
//  Created by 刘花椒 on 15/12/15.
//
//

#import <Foundation/Foundation.h>

@interface TaskListDatasource : NSObject

@property (nonatomic, strong) NSMutableArray *taskListAry;

#pragma mark getTaskListFromNetWork
- (void)postTaskListIsLoadMore:(BOOL)isLoadMore succeed:(PostSucceed)succeed failed:(PostFailed)failed;

#pragma mark getTaskListFromDatabase
- (void)getTaskListFromDatabase:(BOOL)isLoadMore complete:(Complete)complete;


@end
