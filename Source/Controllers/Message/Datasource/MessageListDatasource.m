//
//  MessageListDatasource.m
//  Calendar
//
//  Created by 刘花椒 on 15/12/9.
//
//

#import "MessageListDatasource.h"
#import "MessageListDatabase.h"
#import "MessageListItem.h"

@interface MessageListDatasource ()

@property (nonatomic, assign) NSInteger messageListpage;

@end

@implementation MessageListDatasource

- (instancetype)init {
    if (self = [super init]) {
        self.messageListAry = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

- (void)postMessageListIsLoadMore:(BOOL)isLoadMore succeed:(PostSucceed)succeed failed:(PostFailed)failed {
    if (!isLoadMore) {
        self.messageListpage = 0;
        [self.messageListAry removeAllObjects];
    } else {
        self.messageListpage ++;
    }
    NSDictionary *para = @{
                           @"access_token":[CacheManager sharedInstance].accessToken
                           };
    NSString *requestUrl = [NSString stringWithFormat:@"%@%ld",GET_MESSGAE_LIST_URL,(long)self.messageListpage];
    [[NetworkManager sharedInstance] postRequest:requestUrl params:para successBlock:^(NSDictionary *dict) {
        if ([dict objectForKey:@"data"]) {
            NSArray *messages = [[dict objectForKey:@"data"] objectForKey:@"messages"];
            if ([messages count] > 0) {
                for (NSDictionary *dict in messages) {
                    MessageListItem *item = [[MessageListItem alloc] init];
                    [item setValuesForKeysWithDictionary:dict];
                    [self.messageListAry addObject:item];
                }
                [[MessageListDatabase shareInstance] saveMessageListToDatabase:self.messageListAry tableName:MessageListTableName];
            }
        }
        succeed (self.messageListAry);
    } failedBlock:^(id object){
        [self getMessageListFromDatabase:isLoadMore complete:^(id object) {
            failed (self.messageListAry);
        }];
    }];
}

- (void)getMessageListFromDatabase:(BOOL)isLoadMore complete:(Complete)complete {
    if (!isLoadMore) {
        self.messageListpage = 1;
        [self.messageListAry removeAllObjects];
    } else {
        if (self.messageListpage == 0) {
            self.messageListpage = 1;
        }
        if (self.messageListAry.count % 10 != 0) {
            [AlertManager showAlertText:@"亲！没有更多数据了哦～～～" withCloseSecond:1];
            complete(self.messageListAry);
        }
        self.messageListpage ++;
    }
    
    [self.messageListAry addObjectsFromArray:[[HJDatabaseManager shareInstance] readArrayClass:[MessageListItem class] Page:self.messageListpage pageSize:10 tableName:MessageListTableName]];
    complete(self.messageListAry);
}

@end
