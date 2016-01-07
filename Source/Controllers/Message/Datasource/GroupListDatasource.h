//
//  MessageDatasource.h
//  Calendar
//
//  Created by 刘花椒 on 15/12/7.
//
//

#import <Foundation/Foundation.h>

@interface GroupListDatasource : NSObject

@property (nonatomic, strong) NSMutableArray *groupListAry;
@property (nonatomic, strong) NSMutableArray *messageListAry;
@property (nonatomic, strong) NSMutableArray *globalListAry;

#pragma mark getGroupListFromNetWork
- (void)postGroupListSucceed:(PostSucceed)succeed failed:(PostFailed)failed;
#pragma mark getGlobalNewMessageFromNetWork
- (void)postGlobalNewMessage:(BOOL)isLoadMore groupId:(NSString *)groupId succeed:(PostSucceed)succeed failed:(PostFailed)failed;
#pragma mark sendMessageToNetWork
- (void)sendMessageGroupId:(NSString *)groupId content:(NSString *)content model:(id)model tableName:(NSString *)tableName succeed:(PostSucceed)succeed failed:(PostFailed)failed;
#pragma mark historyMessages
- (void)postGroupHistoryMessages:(NSString *)groupId succeed:(PostSucceed)succeed failed:(PostFailed)failed;


#pragma mark getGroupListFromDatabase
- (void)getGroupListFromDatabase:(Complete)complete;
#pragma mark getGlobalMessageFromDatabase
- (void)getGlobalMessageByGroupIdFromDatabase:(NSString *)groupId isLoadMore:(BOOL)isLoadMore complete:(Complete)complete;
#pragma mark getNewestGlobalMessageFromDatabase
- (void)getNewestMessageByGroupIdFromDatabase:(NSString *)groupId complete:(Complete)complete;
- (void)updateNewestMessageReceived:(NSInteger)groupId;

@end
