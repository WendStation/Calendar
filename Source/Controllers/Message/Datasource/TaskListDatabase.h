//
//  TaskListDatabase.h
//  Calendar
//
//  Created by 刘花椒 on 15/12/15.
//
//

#import <Foundation/Foundation.h>

@interface TaskListDatabase : NSObject

+ (TaskListDatabase *)shareInstance;

- (void)saveTaskListToDatabase:(id)object tableName:(NSString *)tableName;

@end
