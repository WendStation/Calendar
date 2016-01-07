//
//  ChatMessageListItem.h
//  Calendar
//
//  Created by 刘花椒 on 15/12/17.
//
//

#import <Foundation/Foundation.h>
#import "BaseItem.h"

@interface ChatMessageListItem : BaseItem

@property (nonatomic, assign) NSInteger messageId;
@property (nonatomic, strong) NSString *fromUser;
@property (nonatomic, assign) NSInteger groupId;
@property (nonatomic, strong) NSString *toUser;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSNumber *time;
@property (nonatomic, assign) long long sendTime;
@property (nonatomic, strong) NSString *creationTime;
@property (nonatomic, strong) NSString *received;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *avatar;
@property (nonatomic, assign) NSInteger projectId;
@property (nonatomic, assign) BOOL isError;

- (instancetype)initWithMessageItem:(NSDictionary *)dict;

@end
