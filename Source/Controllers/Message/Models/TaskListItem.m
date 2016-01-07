//
//  TaskListItem.m
//  Calendar
//
//  Created by 刘花椒 on 15/12/15.
//
//

#import "TaskListItem.h"

@implementation TaskListItem

- (instancetype)initTaskListItem:(NSDictionary *)dict {
    if (self = [super init]) {
        self.taskId = [[dict objectForKey:@"taskId"] integerValue];
        self.title = [dict objectForKey:@"title"];
        self.text = [dict objectForKey:@"description"];
    }
    return self;
}

@end
