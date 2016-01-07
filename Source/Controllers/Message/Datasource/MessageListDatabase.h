//
//  MessageListDatabase.h
//  Calendar
//
//  Created by 刘花椒 on 15/12/9.
//
//

#import <Foundation/Foundation.h>

@interface MessageListDatabase : NSObject

+ (MessageListDatabase *)shareInstance;

- (void)saveMessageListToDatabase:(id)object tableName:(NSString *)tableName;

@end
