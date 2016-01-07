//
//  ProjectDetailDatasource.m
//  Calendar
//
//  Created by 刘花椒 on 15/11/5.
//
//

#import "ProjectDetailDatasource.h"
#import "HJDatabaseManager.h"
#import "ProjectDatabase.h"

@implementation ProjectDetailDatasource

- (instancetype)init{
    if (self = [super init]) {
        self.projectStatusAry = [[NSMutableArray alloc] initWithCapacity:0];
        self.meetingRecordAry = [[NSMutableArray alloc] initWithCapacity:0];
        self.updateRecordAry = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

#pragma mark getProjectDetailFromNetwork
- (void)postRequestProjectDetailID:(NSString *)project_ID succeed:(PostSucceed)succeed failed:(PostFailed)failed{

    NSDictionary *params = @{
                           @"access_token":[CacheManager sharedInstance].accessToken
                           };
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",GET_PROJECT_DETAIL_NEW_URL,project_ID];
    [[NetworkManager sharedInstance] postRequest:requestUrl params:params successBlock:^(NSDictionary *dict) {
        if (dict) {
            if ([dict objectForKey:@"data"] && [[dict objectForKey:@"data"] objectForKey:@"project"]) {
                NSDictionary * projectDict = [NSDictionary dictionaryWithDictionary:[[dict objectForKey:@"data"] objectForKey:@"project"]];
                ProjectDetailItem *item = [[ProjectDetailItem alloc] initWithProjectDetailDict:projectDict];
                item.projectId = project_ID;
                succeed(item);
                [[ProjectDatabase shareInstance] saveProjectDetail:item tableName:ProjectDetailTableName];
            }
        }
        
    } failedBlock:^(id object){
        [self getProjectDetailFromDatabase:project_ID complete:^(ProjectDetailItem *item) {
            failed(item);
        }];
    }];
}

#pragma mark getProjectStatusFromNetwork
- (void)postRequestProjectStatusID:(NSString *)project_ID succeed:(PostSucceed)succeed failed:(PostFailed)failed{
    [self.projectStatusAry removeAllObjects];
    
    NSDictionary *params = @{
                             @"access_token":[CacheManager sharedInstance].accessToken
                             };
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",GET_PROJECT_DETAIL_STATUS_URL,project_ID];
    [[NetworkManager sharedInstance] postRequest:requestUrl params:params successBlock:^(NSDictionary *dict) {
        if (dict) {
            if ([dict objectForKey:@"data"]) {
                NSArray *ary = [dict objectForKey:@"data"];
                for (NSDictionary *dict in ary) {
                    ProjectStatusItem *item = [[ProjectStatusItem alloc] initProjectStatusItem:dict];
                    if (item.toStatusList.count > 0) {
                        [self.projectStatusAry addObject:item];
                    }
                }
            }
            succeed(self.projectStatusAry);
        }
        
    } failedBlock:^(id object){
        failed(object);        
    }];
}

#pragma mark alterProjectStatus
- (void)alterRequestProjectStatus:(NSString *)operationUrl complete:(Complete)complete {
    if (![[NetworkManager sharedInstance] checkNetAndToken]) {
        return;
    }
    NSDictionary *params = @{
                             @"access_token":[CacheManager sharedInstance].accessToken
                             };
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@",operationUrl];
    [[NetworkManager sharedInstance] postRequest:requestUrl params:params successBlock:^(NSDictionary *dict) {
        if ([[dict objectForKey:@"message"] isEqualToString:@"成功"]) {
            [AlertManager showAlertText:@"项目状态修改成功！" withCloseSecond:1];
        }
        complete ([dict objectForKey:@"message"]);
    } failedBlock:^(id object) {
        complete (object);
    }];
}

#pragma mark getMeetingRecordFromNetwork
- (void)postRequestMeetingRecordID:(NSString *)project_ID succeed:(PostSucceed)succeed failed:(PostFailed)failed{
    [self.meetingRecordAry removeAllObjects];
    
    NSDictionary *params = @{
                             @"access_token":[CacheManager sharedInstance].accessToken
                             };
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",GET_MEETING_RECORD_URL,project_ID];
    [[NetworkManager sharedInstance] postRequest:requestUrl params:params successBlock:^(NSDictionary *dict) {
        if (dict) {
            if ([dict objectForKey:@"data"] && [[[dict objectForKey:@"data"] objectForKey:@"meetings"] count] > 0) {
                NSArray * meetingsAry = [NSArray arrayWithArray:[[dict objectForKey:@"data"] objectForKey:@"meetings"]];
                for (NSDictionary *subDict in meetingsAry) {
                    ProjectMeetingRecordItem *item = [[ProjectMeetingRecordItem alloc] initMeetingRecordItem:subDict];
                    item.projectId = project_ID;
                    [self.meetingRecordAry addObject:item];
                }
                succeed(self.meetingRecordAry);
                [[ProjectDatabase shareInstance] saveMeetingRecordArray:self.meetingRecordAry tableName:MeetingRecordTableName];
            }
        }
    } failedBlock:^(id object){
        [self getMeetingRecordFromDatabase:project_ID complete:^(id object) {
            failed(object);
        }];
    }];
}

#pragma mark getUpdateRecordFromNetwork
- (void)postRequestUpdateRecordID:(NSString *)project_ID succeed:(PostSucceed)succeed failed:(PostFailed)failed{
    
    [self.updateRecordAry removeAllObjects];
    
    NSDictionary *params = @{
                             @"access_token":[CacheManager sharedInstance].accessToken
                             };
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",GET_PROJECT_GRADE_CHANGE_URL,project_ID];
    [[NetworkManager sharedInstance] postRequest:requestUrl params:params successBlock:^(NSDictionary *dict) {
        if (dict) {
            if ([dict objectForKey:@"data"] && [[[dict objectForKey:@"data"] objectForKey:@"events"] count] > 0) {
                NSArray * eventsAry = [NSArray arrayWithArray:[[dict objectForKey:@"data"] objectForKey:@"events"]];
                for (NSDictionary *subDict in eventsAry) {
                    ProjectUpdateRecordItem *item = [[ProjectUpdateRecordItem alloc] initUpdateRecordItemItem:subDict];
                    item.projectId = project_ID;
                    [self.updateRecordAry addObject:item];
                }
                succeed(self.updateRecordAry);
                [[ProjectDatabase shareInstance] saveUpdateRecordArray:self.updateRecordAry tableName:UpdateRecordTableName];
            }
        }
        
    } failedBlock:^(id object){
        [self getUpdateRecordFromDatabase:project_ID complete:^(id object) {
            failed(object);
        }];
    }];
}

#pragma mark getProjectDetailFromDatabase
- (void)getProjectDetailFromDatabase:(NSString *)project_ID complete:(Complete)complete{
    NSString *object = [NSString stringWithFormat:@"projectId = '%@'",project_ID];
    NSDictionary *whereDict = [NSDictionary dictionaryWithObject:object forKey:@"projectId"];
    NSArray *resultArray = [[HJDatabaseManager shareInstance] queryByAndWhereDict:whereDict tableName:ProjectDetailTableName];
    if (resultArray.count != 0) {
        ProjectDetailItem *item = [[ProjectDetailItem alloc] initWithProjectDetailDict:resultArray.firstObject];
        complete(item);
        return;
    }
     complete(nil);
}

#pragma mark getMeetingRecordFromDatabase
- (void)getMeetingRecordFromDatabase:(NSString *)project_ID complete:(Complete)complete{
    [self.meetingRecordAry removeAllObjects];
    NSString *object = [NSString stringWithFormat:@"projectId = '%@'",project_ID];
    NSDictionary *whereDict = [NSDictionary dictionaryWithObject:object forKey:@"projectId"];
    NSArray *resultArray = [[HJDatabaseManager shareInstance] queryByAndWhereDict:whereDict tableName:MeetingRecordTableName];
    for (NSDictionary *dict in resultArray) {
        ProjectMeetingRecordItem *item = [[ProjectMeetingRecordItem alloc] initMeetingRecordItem:dict];
        [self.meetingRecordAry addObject:item];
    }
    complete(self.meetingRecordAry);
}

#pragma mark getUpdateRecordFromDatabase
- (void)getUpdateRecordFromDatabase:(NSString *)project_ID complete:(Complete)complete{
    [self.updateRecordAry removeAllObjects];
    NSString *object = [NSString stringWithFormat:@"projectId = '%@'",project_ID];
    NSDictionary *whereDict = [NSDictionary dictionaryWithObject:object forKey:@"projectId"];
    NSArray *resultArray = [[HJDatabaseManager shareInstance] queryByAndWhereDict:whereDict tableName:UpdateRecordTableName];
    for (NSDictionary *dict in resultArray) {
        ProjectUpdateRecordItem *item = [[ProjectUpdateRecordItem alloc] initUpdateRecordItemItem:dict];
        [self.updateRecordAry addObject:item];
    }
    complete(self.updateRecordAry);
}

@end
