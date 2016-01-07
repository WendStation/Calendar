//
//  TaskListItem.h
//  Calendar
//
//  Created by 刘花椒 on 15/12/15.
//
//

#import "BaseItem.h"

@interface TaskListItem : BaseItem

@property (nonatomic, assign) NSInteger taskId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *text;

- (instancetype)initTaskListItem:(NSDictionary *)dict;

@end
