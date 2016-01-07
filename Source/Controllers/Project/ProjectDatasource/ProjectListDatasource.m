//
//  ProjectDatasource.m
//  Calendar
//
//  Created by 刘花椒 on 15/11/1.
//
//

#import "ProjectListDatasource.h"
#import "ProjectListItem.h"
#import "ProjectDatabase.h"

@interface ProjectListDatasource ()

@property(nonatomic, assign)NSInteger onlineProjectRequestPage;
@property(nonatomic, assign)NSInteger privateOceanProjectPage;
@property(nonatomic, assign)NSInteger CCProjectPage;
@property(nonatomic, assign)NSInteger searchProjectPage;

@end

@implementation ProjectListDatasource

- (instancetype)init{
    if (self = [super init]) {
        self.projectRequestType = OnlineProject;
        self.onlineProjectAry = [[NSMutableArray alloc] initWithCapacity:0];
        self.privateOceanProjectAry = [[NSMutableArray alloc] initWithCapacity:0];
        self.ccNeedsProjectAry = [[NSMutableArray alloc] initWithCapacity:0];
        self.searchProjectAry = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

#pragma mark getOnlineProjectFromNetWork
- (void)postRequestOnlineProjectIsLoadMore:(BOOL)isLoadMore isAll:(BOOL)isAll succeed:(PostSucceed)succeed failed:(PostFailed)failed{
    if (!isAll) {
        if (!isLoadMore) {
            self.onlineProjectRequestPage = 0;
            [self.onlineProjectAry removeAllObjects];
        } else {
            self.onlineProjectRequestPage ++;
        }
    }else{
        self.onlineProjectRequestPage = -1;
        [self.onlineProjectAry removeAllObjects];
    }
    
    NSDictionary *para = @{
                           @"access_token":[CacheManager sharedInstance].accessToken
                           };
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@/%ld",GET_PROJECT_LIST_URL,@"ONLINE",(long)self.onlineProjectRequestPage];
    [[NetworkManager sharedInstance] postRequest:requestUrl params:para successBlock:^(NSDictionary *dict) {
        if (dict) {
            if ([dict objectForKey:@"data"] && [[dict objectForKey:@"data"] objectForKey:@"list"]) {
                NSMutableArray *projectsAry = [NSMutableArray arrayWithArray:[[dict objectForKey:@"data"] objectForKey:@"list"]];
                if (projectsAry.count > 0) {
                    for (NSInteger i = 0; i < [projectsAry count]; i++) {
                        NSDictionary *subDict = [projectsAry objectAtIndex:i];
                        ProjectListItem *item = [[ProjectListItem alloc] initWithProjectListItem:subDict];
                        item.type = [[dict objectForKey:@"data"] objectForKey:@"type"];
                        [self.onlineProjectAry addObject:item];
                    }
                    [[ProjectDatabase shareInstance] saveProjectListArray:self.onlineProjectAry tableName:ProjectListTableName];
                }
            }
        }
        succeed(self.onlineProjectAry);
        
    } failedBlock:^(id object){
        [self getOnlineProjectDatasFromeDatabaseIsLoadMore:isLoadMore complete:^(id object) {
            failed(object);
        }];
    }];
    
}

#pragma mark getPrivateOceanProjectFromNetWork
- (void)postRequestPrivateOceanProjectIsLoadMore:(BOOL)isLoadMore succeed:(PostSucceed)succeed failed:(PostFailed)failed{
    if (!isLoadMore) {
        self.privateOceanProjectPage = 0;
        [self.privateOceanProjectAry removeAllObjects];
    } else {
        self.privateOceanProjectPage ++;
    }
    NSDictionary *para = @{
                           @"access_token":[CacheManager sharedInstance].accessToken
                           };
    
     NSString *requestUrl = [NSString stringWithFormat:@"%@%@/%ld",GET_PROJECT_LIST_URL,@"PRIVATE",(long)self.privateOceanProjectPage];
    [[NetworkManager sharedInstance] postRequest:requestUrl params:para successBlock:^(NSDictionary *dict) {
        if (dict) {
            if ([dict objectForKey:@"data"] && [[dict objectForKey:@"data"] objectForKey:@"list"]) {
                NSMutableArray *projectsAry = [NSMutableArray arrayWithArray:[[dict objectForKey:@"data"] objectForKey:@"list"]];
                if (projectsAry.count > 0) {
                    for (NSInteger i = 0; i < [projectsAry count]; i++) {
                        NSDictionary *subDict = [projectsAry objectAtIndex:i];
                        ProjectListItem *item = [[ProjectListItem alloc] initWithProjectListItem:subDict];
                        item.type = [[dict objectForKey:@"data"] objectForKey:@"type"];
                        [self.privateOceanProjectAry addObject:item];
                    }
                }
            }
            [[ProjectDatabase shareInstance] saveProjectListArray:self.privateOceanProjectAry tableName:ProjectListTableName];
        }
        succeed(self.privateOceanProjectAry);
        
    } failedBlock:^(id object){
        [self getPrivateOceanProjectDatasFromeDatabaseIsLoadMore:isLoadMore complete:^(id object) {
            failed(object);
        }];
    }];
}

#pragma mark getCCFromNetWork
- (void)postRequestCCProjectIsLoadMore:(BOOL)isLoadMore succeed:(PostSucceed)succeed failed:(PostFailed)failed{
    if (!isLoadMore) {
        self.CCProjectPage = 0;
        [self.ccNeedsProjectAry removeAllObjects];
    } else {
        self.CCProjectPage ++;
    }
    NSDictionary *para = @{
                           @"access_token":[CacheManager sharedInstance].accessToken
                           };
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@/%ld",GET_PROJECT_LIST_URL,@"CC",(long)self.CCProjectPage];
    [[NetworkManager sharedInstance] postRequest:requestUrl params:para successBlock:^(NSDictionary *dict) {
        if (dict) {
            if ([dict objectForKey:@"data"] && [[dict objectForKey:@"data"] objectForKey:@"list"]) {
                NSMutableArray *projectsAry = [NSMutableArray arrayWithArray:[[dict objectForKey:@"data"] objectForKey:@"list"]];
                if (projectsAry.count > 0) {
                    for (NSInteger i = 0; i < [projectsAry count]; i++) {
                        NSDictionary *subDict = [projectsAry objectAtIndex:i];
                        ProjectListItem *item = [[ProjectListItem alloc] initWithProjectListItem:subDict];
                        item.type = [[dict objectForKey:@"data"] objectForKey:@"type"];
                        [self.ccNeedsProjectAry addObject:item];
                    }
                }
            }
            [[ProjectDatabase shareInstance] saveProjectListArray:self.ccNeedsProjectAry tableName:CCNeedsTableName];
        }
        succeed(self.ccNeedsProjectAry);
        
    } failedBlock:^(id object){
        [self getCCProjectDatasFromeDatabaseIsLoadMore:isLoadMore complete:^(id object) {
            failed(object);
        }];
    }];
}

#pragma mark getSearchProjectFromNetWork
- (void)postRequestSearchProjectIsLoadMore:(BOOL)isLoadMore
                               searchTitle:(NSString *)searchTitle
                                   succeed:(PostSucceed)succeed
                                    failed:(PostFailed)failed{
    if (!isLoadMore) {
        self.searchProjectPage = 0;
        [self.searchProjectAry removeAllObjects];
    } else {
        self.searchProjectPage ++;
    }
    NSDictionary *para = @{
                           @"access_token":[CacheManager sharedInstance].accessToken,
                           @"keyword"     :searchTitle
                           };
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@/%ld",GET_PROJECT_LIST_URL,@"SEARCH",(long)self.searchProjectPage];
    [[NetworkManager sharedInstance] postRequest:requestUrl params:para successBlock:^(NSDictionary *dict) {
        if (dict) {
            if ([dict objectForKey:@"data"] && [[dict objectForKey:@"data"] objectForKey:@"list"]) {
                NSMutableArray *projectsAry = [NSMutableArray arrayWithArray:[[dict objectForKey:@"data"] objectForKey:@"list"]];
                if (projectsAry.count > 0) {
                    for (NSDictionary *subDict in projectsAry) {
                        ProjectListItem *item = [[ProjectListItem alloc] initWithProjectListItem:subDict];
                        [self.searchProjectAry addObject:item];
                    }
                }
            }
        }
        succeed(self.searchProjectAry);
        
    } failedBlock:^(id object){
        [self getSearchProjectDatasFromeDatabase:searchTitle complete:^(id object) {
            failed(object);
        }];
    }];
    
}

#pragma mark AddProjectToNetWork
- (void)postAddProjectInfo:(NSDictionary *)info succeed:(PostAddProjectSuccessBlock)succeed failed:(PostAddProjectFailedBlock)failed{
    NSDictionary *para = @{
                           @"access_token":[CacheManager sharedInstance].accessToken,
                           @"title":[info objectForKey:@"项目名称"],
                           @"category":[info objectForKey:@"品类"],
                           @"founder_name":[info objectForKey:@"CEO姓名"],
                           @"founder_mobile":[info objectForKey:@"CEO手机"],
                           @"referer":[info objectForKey:@"推荐人"],
                           @"info":[info objectForKey:@"项目简介"]
                           };
    NSString *requestUrl = [NSString stringWithFormat:@"%@",ADD_PROJECT_URL];
    [[NetworkManager sharedInstance] postRequest:requestUrl params:para successBlock:^(NSDictionary *dict) {
        if ([[dict objectForKey:@"code"] integerValue] == NETWORK_CODE_SUCCESS) {
            [AlertManager showAlertText:@"添加成功!" withCloseSecond:1];
        }
        succeed(dict);
        
    } failedBlock:^(id object){
        failed();
    }];
    
}

#pragma mark addCCToNetWork
- (void)postAddCCInfo:(NSDictionary *)info succeed:(PostAddProjectSuccessBlock)succeed failed:(PostAddProjectFailedBlock)failed{
    NSDictionary *para = @{
                           @"access_token":[CacheManager sharedInstance].accessToken,
                           @"title":[info objectForKey:@"项目名称"],
                           @"categoryId":[info objectForKey:@"品类"],
                           @"name":[info objectForKey:@"CEO姓名"],
                           @"website":[info objectForKey:@"相关网址"],
                           @"phone":[info objectForKey:@"公司电话"],
                           @"abstract":[info objectForKey:@"备注信息"]
                           };
    NSString *requestUrl = [NSString stringWithFormat:@"%@",ADD_CC_URL];
    [[NetworkManager sharedInstance] postRequest:requestUrl params:para successBlock:^(NSDictionary *dict) {
        if ([[dict objectForKey:@"code"] integerValue] != NETWORK_CODE_SUCCESS) {
            [AlertManager showAlertText:@"添加成功!" withCloseSecond:1];
        }
        succeed(dict);
        
    } failedBlock:^(id object){
        failed();
    }];
}

#pragma mark getOnlineProjectDatasFromeDatabase
- (void)getOnlineProjectDatasFromeDatabaseIsLoadMore:(BOOL)isLoadMore complete:(Complete)complete {
    if (!isLoadMore) {
        self.onlineProjectRequestPage = 1;
        [self.onlineProjectAry removeAllObjects];
    } else {
        if (self.onlineProjectRequestPage == 0) {
            self.onlineProjectRequestPage = 1;
        }
        if (self.onlineProjectAry.count % 30 != 0) {
            [AlertManager showAlertText:@"亲！没有更多数据了哦～～～" withCloseSecond:1];
            complete (self.onlineProjectAry);
            return;
        }
        self.onlineProjectRequestPage ++;
    }
    NSDictionary *whereDict = [NSDictionary dictionaryWithObject:@"type = 'ONLINE'" forKey:@"type"];
    [self.onlineProjectAry addObjectsFromArray:[[HJDatabaseManager shareInstance] readArrayClass:[ProjectListItem class] Page:self.onlineProjectRequestPage pageSize:30 where:whereDict tableName:ProjectListTableName]];
    complete (self.onlineProjectAry);
}

#pragma mark getPrivateOceanProjectDatasFromeDatabase
- (void)getPrivateOceanProjectDatasFromeDatabaseIsLoadMore:(BOOL)isLoadMore complete:(Complete)complete {
    if (!isLoadMore) {
        self.privateOceanProjectPage = 1;
        [self.privateOceanProjectAry removeAllObjects];
    } else {
        if (self.privateOceanProjectPage == 0) {
            self.privateOceanProjectPage = 1;
        }
        if (self.privateOceanProjectAry.count % 30 != 0) {
            [AlertManager showAlertText:@"亲！没有更多数据了哦～～～" withCloseSecond:1];
            complete (self.privateOceanProjectAry);
            return;
        }
        self.privateOceanProjectPage ++;
    }
    NSDictionary *whereDict = [NSDictionary dictionaryWithObject:@"type = 'PRIVATE'" forKey:@"type"];
    [self.privateOceanProjectAry addObjectsFromArray:[[HJDatabaseManager shareInstance] readArrayClass:[ProjectListItem class] Page:self.privateOceanProjectPage pageSize:30 where:whereDict tableName:ProjectListTableName]];
    complete (self.privateOceanProjectAry);
}

#pragma mark getCCProjectDatasFromeDatabase
- (void)getCCProjectDatasFromeDatabaseIsLoadMore:(BOOL)isLoadMore complete:(Complete)complete {
    if (!isLoadMore) {
        self.CCProjectPage = 1;
        [self.ccNeedsProjectAry removeAllObjects];
    } else {
        self.CCProjectPage ++;
    }
    NSDictionary *whereDict = [NSDictionary dictionaryWithObject:@"type = 'CC'" forKey:@"type"];
    [self.ccNeedsProjectAry addObjectsFromArray:[[HJDatabaseManager shareInstance] readArrayClass:[ProjectListItem class] Page:self.CCProjectPage pageSize:30 where:whereDict tableName:CCNeedsTableName]];
    complete (self.ccNeedsProjectAry);
}

#pragma mark getSearchProjectDatasFromeDatabase
- (void)getSearchProjectDatasFromeDatabase:(NSString *)text complete:(Complete)complete {
    [self.searchProjectAry removeAllObjects];
    NSDictionary *whereDict = @{@"title":text,@"city":text,@"ownerName":text,@"category":text};
    NSArray *resultArray = [[HJDatabaseManager shareInstance] queryByOrWhereDict:whereDict tableName:ProjectListTableName];
    for (NSDictionary *dict in resultArray) {
        ProjectListItem *item = [[ProjectListItem alloc] initWithProjectListItem:dict];
        [self.searchProjectAry addObject:item];
    }
    complete (self.searchProjectAry);
}
@end
