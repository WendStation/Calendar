//
//  ProjectDatabase.h
//  Calendar
//
//  Created by 刘花椒 on 15/12/18.
//
//

#import <Foundation/Foundation.h>
#import "ProjectDetailItem.h"

@interface ProjectDatabase : NSObject

+ (ProjectDatabase *)shareInstance;

#pragma mark saveProjectListToDatabase
- (void)saveProjectListArray:(NSArray *)projectAry tableName:(NSString *)tableName;
#pragma mark saveProjectDetailToDatase
- (void)saveProjectDetail:(ProjectDetailItem *)item tableName:(NSString *)tableName;
#pragma mark saveMeetingRecordToDatabase
- (void)saveMeetingRecordArray:(NSArray *)projectAry tableName:(NSString *)tableName;
#pragma mark saveUpdateRecordToDatabase
- (void)saveUpdateRecordArray:(NSArray *)projectAry tableName:(NSString *)tableName;

@end
