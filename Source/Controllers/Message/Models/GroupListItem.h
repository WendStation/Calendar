//
//  MessageListItem.h
//  Calendar
//
//  Created by 刘花椒 on 15/12/7.
//
//

#import "BaseItem.h"

@interface GroupListItem : BaseItem

@property (nonatomic, assign) NSInteger groupId;
@property (nonatomic, assign) NSInteger projectId;
@property (nonatomic, assign) NSInteger investorId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *lastMessage;
@property (nonatomic, strong) NSString *lastSendName;
@property (nonatomic, assign) NSInteger lastSendTime;
@property (nonatomic, strong) NSString *logoUrl;
@property (nonatomic, assign) NSInteger unReadMessageNum;

- (instancetype)initWithGroupListItem:(NSDictionary *)dict;

@end
