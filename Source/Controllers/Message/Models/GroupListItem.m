  //
//  MessageListItem.m
//  Calendar
//
//  Created by 刘花椒 on 15/12/7.
//
//

#import "GroupListItem.h"

@implementation GroupListItem

- (instancetype)initWithGroupListItem:(NSDictionary *)dict {
    if (self = [super init]) {
        self.groupId = [[dict objectForKey:@"groupId"] integerValue];
        self.projectId = [[dict objectForKey:@"projectId"] integerValue];
        self.investorId = [[dict objectForKey:@"investorId"] integerValue];
        self.name = [dict objectForKey:@"name"];
        self.lastMessage = [dict objectForKey:@"lastMessage"];
        self.lastSendName = [dict objectForKey:@"lastSendName"];
        if ([[dict objectForKey:@"lastSendTime"] isKindOfClass:[NSString class]]) {
            self.lastSendTime = [[NSDate  dateFromString:[dict objectForKey:@"lastSendTime"]] utcTimeStamp];
        } else {
            self.lastSendTime = [[dict objectForKey:@"lastSendTime"] integerValue];
        }
        self.logoUrl = [dict objectForKey:@"logoUrl"];
    }
    return self;
}

@end
