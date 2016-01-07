//
//  KnowledgeDatabase.h
//  Calendar
//
//  Created by 刘花椒 on 15/12/7.
//
//

#import <Foundation/Foundation.h>
#import "FounderDetailItem.h"
#import "FundDetailItem.h"

@interface KnowledgeDatabase : NSObject

+ (KnowledgeDatabase *)shareInstance;

#pragma mark saveFounderListToDatabase
- (void)saveFounderListArray:(NSArray *)array tableName:(NSString *)tableName;
#pragma mark saveFundListToDatabase
- (void)saveFundListArray:(NSArray *)array tableName:(NSString *)tableName;
#pragma mark saveFounderDetailToDatabase
- (void)saveFounderDetail:(FounderDetailItem *)item tableName:(NSString *)tableName;
#pragma mark saveFundDetailToDatabase
- (void)saveFundDetail:(FundDetailItem *)item tableName:(NSString *)tableName;

@end
