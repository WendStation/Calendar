//
//  ChatMessageListItem.m
//  Calendar
//
//  Created by 刘花椒 on 15/12/17.
//
//

#import "ChatMessageListItem.h"

@implementation ChatMessageListItem

- (instancetype)initWithMessageItem:(NSDictionary *)dict {
    if (self = [super init]) {
        self.messageId = [[dict objectForKey:@"messageId"] integerValue];
        if ([dict objectForKey:@"from"]) {
            self.fromUser = [dict objectForKey:@"from"];
        } else {
            self.fromUser = [dict objectForKey:@"fromUser"];
        }
        self.groupId = [[dict objectForKey:@"groupId"] integerValue];
        if ([dict objectForKey:@"to"]) {
            self.toUser = [dict objectForKey:@"to"];
        } else {
            self.toUser = [dict objectForKey:@"toUser"];
        }
        if ([dict objectForKey:@"message"]) {
            NSDictionary *message = [dict objectForKey:@"message"];
            self.type = [message objectForKey:@"type"];
            self.content = [message objectForKey:@"content"];
            self.time = [message objectForKey:@"time"];
        } else {
            self.type = [dict objectForKey:@"type"];
            self.content = [dict objectForKey:@"content"];
            self.time = [dict objectForKey:@"time"];
        }
        self.sendTime = [[dict objectForKey:@"sendTime"] longLongValue];
        self.creationTime = [dict objectForKey:@"creationTime"];
        self.received = [dict objectForKey:@"received"];
        self.name = [dict objectForKey:@"name"];
        self.avatar = [dict objectForKey:@"avatar"];
        self.projectId = [[dict objectForKey:@"projectId"] integerValue];
        if ([dict objectForKey:@"isError"]) {
            self.isError = [[dict objectForKey:@"isError"] boolValue];
        }
    }
    return self;
}

@end
