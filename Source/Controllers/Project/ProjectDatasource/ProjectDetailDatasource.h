//
//  ProjectDetailDatasource.h
//  Calendar
//
//  Created by 刘花椒 on 15/11/5.
//
//

#import <Foundation/Foundation.h>
#import "ProjectDetailItem.h"

@interface ProjectDetailDatasource : NSObject

@property(nonatomic, strong)NSMutableArray *projectStatusAry;
@property(nonatomic, strong)NSMutableArray *meetingRecordAry;
@property(nonatomic, strong)NSMutableArray *updateRecordAry;

#pragma mark getProjectDetailFromNetwork
- (void)postRequestProjectDetailID:(NSString *)project_ID
                           succeed:(PostSucceed)succeed
                            failed:(PostFailed)failed;
#pragma mark getProjectStatusFromNetwork
- (void)postRequestProjectStatusID:(NSString *)project_ID
                           succeed:(PostSucceed)succeed
                            failed:(PostFailed)failed;
#pragma mark alterProjectStatus
- (void)alterRequestProjectStatus:(NSString *)operationUrl
                         complete:(Complete)complete;

#pragma mark getMeetingRecordFromNetwork
- (void)postRequestMeetingRecordID:(NSString *)project_ID succeed:(PostSucceed)succeed failed:(PostFailed)failed;

#pragma mark getUpdateRecordFromNetwork
- (void)postRequestUpdateRecordID:(NSString *)project_ID succeed:(PostSucceed)succeed failed:(PostFailed)failed;



#pragma mark getProjectDetailFromDatabase
- (void)getProjectDetailFromDatabase:(NSString *)project_ID complete:(Complete)complete;
#pragma mark getMeetingRecordFromDatabase
- (void)getMeetingRecordFromDatabase:(NSString *)project_ID complete:(Complete)complete;
#pragma mark getUpdateRecordFromDatabase
- (void)getUpdateRecordFromDatabase:(NSString *)project_ID complete:(Complete)complete;

@end
