//
//  MessageListDatasource.h
//  Calendar
//
//  Created by 刘花椒 on 15/12/9.
//
//

#import <Foundation/Foundation.h>

@interface MessageListDatasource : NSObject

@property (nonatomic, strong) NSMutableArray *messageListAry;

#pragma mark getMessageListFromNetWork
- (void)postMessageListIsLoadMore:(BOOL)isLoadMore succeed:(PostSucceed)succeed failed:(PostFailed)failed;

#pragma mark getMessageListFromDatabase
- (void)getMessageListFromDatabase:(BOOL)isLoadMore complete:(Complete)complete;

@end
