//
//  MessageDatasource.m
//  Calendar
//
//  Created by 刘花椒 on 15/12/7.
//
//

#import "GroupListDatasource.h"
#import "GroupListItem.h"
#import "GroupListDatabase.h"
#import "ChatMessageListItem.h"

static NSString *GROUP_ID = @"groupId";
static NSString *LAST_ID = @"lastId";
static NSString *LIMIT = @"limit";

@interface GroupListDatasource ()

@property (nonatomic, assign) NSInteger messagePage;

@end

@implementation GroupListDatasource

- (instancetype)init {
    if (self = [super init]) {
        self.groupListAry = [NSMutableArray arrayWithCapacity:0];
        self.messageListAry = [NSMutableArray arrayWithCapacity:0];
        self.globalListAry = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

- (void)postGroupListSucceed:(PostSucceed)succeed failed:(PostFailed)failed{
    [self.groupListAry removeAllObjects];
    NSDictionary *para = @{
                           @"access_token":[CacheManager sharedInstance].accessToken
                           };
    NSString *requestUrl = [NSString stringWithFormat:@"%@",MESSAGE_GROUP_LIST_URL];
    [[NetworkManager sharedInstance] postRequest:requestUrl params:para successBlock:^(NSDictionary *dict) {
        if ([dict objectForKey:@"data"]) {
            NSArray *groups = [[dict objectForKey:@"data"] objectForKey:@"groups"];
            if ([groups count] > 0) {
                for (NSDictionary *dict in groups) {
                    GroupListItem *item = [[GroupListItem alloc] initWithGroupListItem:dict];
                    [self.groupListAry addObject:item];
                }
                [[GroupListDatabase shareInstance] saveGroupListToDatabase:self.groupListAry tableName:GroupListTableName];
            }
        }
        succeed(self.groupListAry);
    } failedBlock:^(id object){
        failed(object);
    }];
}

- (void)postGlobalNewMessage:(BOOL)isLoadMore groupId:(NSString *)groupId succeed:(PostSucceed)succeed failed:(PostFailed)failed {
    [self.globalListAry removeAllObjects];
    NSMutableDictionary *whereDict = [NSMutableDictionary dictionaryWithCapacity:0];
    NSString *fromUser = [NSString stringWithFormat:@"fromUser != %@",[[CacheManager sharedInstance] userId]];
    [whereDict setObject:fromUser forKey:@"fromUser"];
    NSInteger maxMessageId = [[HJDatabaseManager shareInstance] getMaxFromTableName:GlobalMessageTableName field:@"messageId" whereDict:whereDict];
    NSString *lastId = [NSString stringWithFormat:@"%ld",(long)maxMessageId];
    
    NSMutableDictionary *para = [NSMutableDictionary dictionaryWithCapacity:0];
    [para setObject:[CacheManager sharedInstance].accessToken forKey:@"access_token"];
    [para setObject:lastId forKey:LAST_ID];
    if (![groupId isEqualToString:@"-1"]) {
        [para setValue:groupId forKey:GROUP_ID];
    }
    [para setObject:@"50" forKey:LIMIT];
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@",GET_NEW_MESSGAE_URL];
    [[NetworkManager sharedInstance] postRequest:requestUrl params:para successBlock:^(NSDictionary *dict) {
        if (dict) {
            if ([dict objectForKey:@"data"]) {
                NSArray *messages = [[dict objectForKey:@"data"] objectForKey:@"messages"];
                if (messages.count > 0) {
                    for (NSDictionary *dict in messages) {
                        ChatMessageListItem *item = [[ChatMessageListItem alloc] initWithMessageItem:dict];
                        [self.globalListAry addObject:item];
                    }
                    [[GroupListDatabase shareInstance] saveMessageListToDatabase:self.globalListAry tableName:GlobalMessageTableName];
                }
            }
        }
        succeed([dict objectForKey:@"message"]);
    } failedBlock:^(id object){
        failed(@"失败");
    }];
}

- (void)sendMessageGroupId:(NSString *)groupId content:(NSString *)content model:(id)model tableName:(NSString *)tableName succeed:(PostSucceed)succeed failed:(PostFailed)failed {
    __block ChatMessageListItem *item = (ChatMessageListItem *)model;
    
    NSMutableDictionary *para = [NSMutableDictionary dictionaryWithCapacity:0];
    [para setObject:[CacheManager sharedInstance].accessToken forKey:@"access_token"];
    UInt64 recordTime = [[NSDate date] timeIntervalSince1970]*1000;
    NSNumber *timeStamp = [NSNumber numberWithLongLong:recordTime];
    NSMutableDictionary *message = [NSMutableDictionary dictionaryWithCapacity:0];
    [message setObject:@"text" forKey:@"type"];
    [message setObject:content forKey:@"content"];
    [message setObject:timeStamp forKey:@"time"];
    [para setObject:[self toJsonString:message] forKey:@"message"];
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",MESSAGE_SEND_URL,groupId];
    [[NetworkManager sharedInstance] postRequest:requestUrl params:para successBlock:^(NSDictionary *dict) {
        if (dict && [dict objectForKey:@"data"]) {
            if ([[dict objectForKey:@"code"] integerValue] == NETWORK_CODE_SUCCESS) {
                item.messageId = [[[dict objectForKey:@"data"] objectForKey:@"messageId"] integerValue];
                [[GroupListDatabase shareInstance] saveMessageListToDatabase:@[item] tableName:tableName];
            }
            succeed ([dict objectForKey:@"data"]);
        }
    } failedBlock:^(id object){
        item.isError = YES;
        [[GroupListDatabase shareInstance] saveMessageListToDatabase:@[item] tableName:tableName];
        failed (object);
    }];
}

- (void)postGroupHistoryMessages:(NSString *)groupId succeed:(PostSucceed)succeed failed:(PostFailed)failed {
    NSMutableDictionary *whereDict = [NSMutableDictionary dictionaryWithCapacity:0];
    NSString *group_Id = [NSString stringWithFormat:@"groupId = %@",groupId];
    [whereDict setObject:group_Id forKey:@"groupId"];
    NSString *isError = [NSString stringWithFormat:@"isError = '0'"];
    [whereDict setObject:isError forKey:@"isError"];
    NSInteger minMessageId = [[HJDatabaseManager shareInstance] getMinFromTableName:GlobalMessageTableName field:@"messageId" whereDict:whereDict];
    
    NSMutableDictionary *para = [NSMutableDictionary dictionaryWithCapacity:0];
    [para setObject:[CacheManager sharedInstance].accessToken forKey:@"access_token"];
    [para setObject:@"10" forKey:LIMIT];
    NSString *first_id = [NSString stringWithFormat:@"%ld",(long)minMessageId];
    [para setObject:first_id forKey:LAST_ID];
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",HISTORY_MESSAGES_URL,groupId];
    [[NetworkManager sharedInstance] postRequest:requestUrl params:para successBlock:^(NSDictionary *dict) {
        NSMutableArray *array = [NSMutableArray array];
        if (dict) {
            if ([dict objectForKey:@"data"]) {
                if (![[dict objectForKey:@"data"] isKindOfClass:[NSNull class]]) {
                    NSArray *messages = [[dict objectForKey:@"data"] objectForKey:@"messages"];
                    if (messages != nil && messages.count > 0) {
                        for (NSDictionary *dict in messages) {
                            ChatMessageListItem *item = [[ChatMessageListItem alloc] initWithMessageItem:dict];
                            item.received = @"1";
                            [array addObject:item];
                        }
                        [[GroupListDatabase shareInstance] saveMessageListToDatabase:array tableName:GlobalMessageTableName];
                    }
                }
            }
        }
        succeed (array);
    } failedBlock:^(id object) {
        failed (@"获取历史消息失败");
    }];
}

- (void)getGroupListFromDatabase:(Complete)complete {
    [self.groupListAry removeAllObjects];
    NSArray *resultArray = [[HJDatabaseManager shareInstance] queryTableName:GroupListTableName];
    NSMutableDictionary *whereDict = [NSMutableDictionary dictionaryWithCapacity:0];
    NSString *received = [NSString stringWithFormat:@"received = '0'"];
    for (NSDictionary *dict in resultArray) {
        GroupListItem *item = [[GroupListItem alloc] initWithGroupListItem:dict];
        [whereDict removeAllObjects];
        [whereDict setObject:received forKey:@"received"];
        NSString *groupId = [NSString stringWithFormat:@"groupId = '%ld'",(long)item.groupId];
        [whereDict setObject:groupId forKey:@"groupId"];
        NSInteger count = [[HJDatabaseManager shareInstance] queryObjectCountByAnd:whereDict tableName:GlobalMessageTableName];
        item.unReadMessageNum = count;
        [self.groupListAry addObject:item];
    }
    complete(self.groupListAry);
}

- (void)getGlobalMessageByGroupIdFromDatabase:(NSString *)groupId  isLoadMore:(BOOL)isLoadMore complete:(Complete)complete {
    [self.messageListAry removeAllObjects];
    if (!isLoadMore) {
        self.messagePage = 1;
    } else {
        self.messagePage ++;
    }
    NSMutableDictionary *whereDict = [NSMutableDictionary dictionaryWithCapacity:0];
    NSString *group_Id = [NSString stringWithFormat:@"groupId = %ld",(long)[groupId integerValue]];
    [whereDict setObject:group_Id forKey:@"groupId"];
    NSArray *resultArray = [[HJDatabaseManager shareInstance] invertedReadArray:self.messagePage pageSize:10 where:whereDict field:@"time" tableName:GlobalMessageTableName];
    if (resultArray.count != 0) {
        for (NSDictionary *dict in resultArray) {
            ChatMessageListItem *item = [[ChatMessageListItem alloc] initWithMessageItem:dict];
            [self.messageListAry addObject:item];
        }
    }
    if (self.messageListAry.count == 0) {
        [self postGroupHistoryMessages:groupId succeed:^(id object) {
            NSArray *array = (NSArray *)object;
            if (array.count > 0) {
                [self.messageListAry addObjectsFromArray:array];
            }
            complete(self.messageListAry);
        } failed:^(id object) {
            complete(self.messageListAry);
        }];
    } else {
        complete(self.messageListAry);
    }
}

- (void)getNewestMessageByGroupIdFromDatabase:(NSString *)groupId complete:(Complete)complete {
    NSMutableArray *messageAry = [NSMutableArray arrayWithCapacity:0];
    NSMutableDictionary *whereDict = [NSMutableDictionary dictionaryWithCapacity:0];
    NSString *received = [NSString stringWithFormat:@"received = '0'"];
    [whereDict setObject:received forKey:@"received"];
    NSString *fromUser = [NSString stringWithFormat:@"fromUser != '%@'",[[CacheManager sharedInstance] userId]];
    [whereDict setObject:fromUser forKey:@"fromUser"];
    NSString *group_id = [NSString stringWithFormat:@"groupId = %@",groupId];
    [whereDict setObject:group_id forKey:@"groupId"];

    NSArray *resultArray = [[HJDatabaseManager shareInstance] queryByAndWhereDict:whereDict tableName:GlobalMessageTableName];
    for (NSDictionary *dict in resultArray) {
        ChatMessageListItem *item = [[ChatMessageListItem alloc] initWithMessageItem:dict];
        [messageAry addObject:item];
        [self updateNewestMessageReceived:item.groupId];
        
    }
    complete (messageAry);
}

- (void)updateNewestMessageReceived:(NSInteger)groupId {
    NSMutableDictionary *whereDict = [NSMutableDictionary dictionaryWithCapacity:0];
    NSString *group_Id = [NSString stringWithFormat:@"groupId = %ld",(long)groupId];
    [whereDict setObject:group_Id forKey:@"groupId"];
    NSString *received = [NSString stringWithFormat:@"received = '0'"];
    [whereDict setObject:received forKey:@"received"];
    
    NSMutableDictionary *fieldDict = [NSMutableDictionary dictionaryWithCapacity:0];
    NSString *received1 = [NSString stringWithFormat:@"received = '1'"];
    [fieldDict setObject:received1 forKey:@"received"];
    [[HJDatabaseManager shareInstance] updateColumnsOfTable:whereDict field:fieldDict tableName:GlobalMessageTableName];
}

- (NSString *)toJsonString:(id)object {
    NSError *err = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&err];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if (err) {
        NSLog(@"转json失败:%@",err);
        return nil;
    }
    return jsonStr;
}

@end
