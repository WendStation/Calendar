//
//  MessageDatabase.h
//  Calendar
//
//  Created by 刘花椒 on 15/12/8.
//
//

#import <Foundation/Foundation.h>

@interface GroupListDatabase : NSObject

+ (GroupListDatabase *)shareInstance;

- (void)saveGroupListToDatabase:(id)object tableName:(NSString *)tableName;
- (void)saveMessageListToDatabase:(id)object tableName:(NSString *)tableName;

@end
