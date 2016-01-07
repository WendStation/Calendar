//
//  KnowledgeListDatasource.m
//  Calendar
//
//  Created by 刘花椒 on 15/11/24.
//
//

#import "KnowledgeListDatasource.h"
#import "SearchFounderListItem.h"
#import "KnowledgeDatabase.h"

@interface KnowledgeListDatasource ()

@property (nonatomic, assign) NSInteger searchFounderPage;
@property (nonatomic, assign) NSInteger searchFundPage;
@property (nonatomic, assign) NSInteger founderDetailPage;

@end

@implementation KnowledgeListDatasource

- (instancetype)init{
    if (self = [super init]) {
        self.searchFounderAry = [NSMutableArray arrayWithCapacity:0];
        self.searchFundAry = [NSMutableArray arrayWithCapacity:0];
    }
    return self;
}

- (void)postRequestSearchFounderIsLoadMore:(BOOL)isLoadMore searchTitle:(NSString *)searchTitle succeed:(PostSucceed)succeed failed:(PostFailed)failed{
    if (!isLoadMore) {
        self.searchFounderPage = 0;
        [self.searchFounderAry removeAllObjects];
    } else {
        self.searchFounderPage ++;
    }
    NSDictionary *para = @{
                           @"access_token":[CacheManager sharedInstance].accessToken,
                           @"keyword"     :searchTitle
                           };
    NSString *requestUrl = [NSString stringWithFormat:@"%@%ld",SEARCH_INVESTORS_URL,(long)self.searchFounderPage];
    [[NetworkManager sharedInstance] postRequest:requestUrl params:para successBlock:^(NSDictionary *dict) {
        if (dict) {
            if ([dict objectForKey:@"data"]) {
                NSArray *investors = [[dict objectForKey:@"data"] objectForKey:@"investors"];
                if (investors && investors.count > 0) {
                    for (NSDictionary *subDict in investors) {
                        SearchFounderListItem *item = [[SearchFounderListItem alloc] initWithKnowledgeListItem:subDict];
                        [self.searchFounderAry addObject:item];
                    }
                    [[KnowledgeDatabase shareInstance] saveFounderListArray:self.searchFounderAry tableName:FounderListTableName];
                }
            }
        }
        succeed(self.searchFounderAry);
        
    } failedBlock:^(id object){
        [self getFounderListDatasFromeDatabase:searchTitle complete:^(id object) {
            failed(object);
        }];
    }];
}

- (void)postRequestSearchFundIsLoadMore:(BOOL)isLoadMore searchTitle:(NSString *)searchTitle succeed:(PostSucceed)succeed failed:(PostFailed)failed{
    if (!isLoadMore) {
        self.searchFundPage = 0;
        [self.searchFundAry removeAllObjects];
    } else {
        self.searchFundPage ++;
    }
    NSDictionary *para = @{
                           @"access_token":[CacheManager sharedInstance].accessToken,
                           @"keyword"     :searchTitle
                           };
    NSString *requestUrl = [NSString stringWithFormat:@"%@%ld",GET_FUND_LIST,(long)self.searchFundPage];
    [[NetworkManager sharedInstance] postRequest:requestUrl params:para successBlock:^(NSDictionary *dict) {
        if (dict) {
            if ([dict objectForKey:@"data"]) {
                NSArray *funds = [[dict objectForKey:@"data"] objectForKey:@"funds"];
                if (funds && funds.count > 0) {
                    for (NSDictionary *subDict in funds) {
                        SearchFounListItem *item = [[SearchFounListItem alloc] initWithSearchFounListItem:subDict];
                        [self.searchFundAry addObject:item];
                    }
                    [[KnowledgeDatabase shareInstance] saveFundListArray:self.searchFundAry tableName:FundListTableName];
                }
            }
        }
        succeed(self.searchFundAry);
        
    } failedBlock:^(id object){
        [self getFundListDatasFromeDatabase:searchTitle complete:^(id object) {
            failed(object);
        }];
    }];
}

- (void)postRequestFounderDetailIsLoadMore:(BOOL)isLoadMore founderId:(NSString *)founderId succeed:(PostSucceed)succeed failed:(PostFailed)failed{
    if (!isLoadMore) {
        self.founderDetailPage = 0;
    } else {
        self.founderDetailPage ++;
    }
    NSDictionary *para = @{
                           @"access_token":[CacheManager sharedInstance].accessToken
                           };
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@/%ld",GET_INVESTOR_DETAIL,founderId,(long)self.founderDetailPage];
    
    [[NetworkManager sharedInstance] postRequest:requestUrl params:para successBlock:^(NSDictionary *dict) {
        if (dict) {
            if ([dict objectForKey:@"data"]) {
                if (!isLoadMore) {
                    self.founderDetailItem = [[FounderDetailItem alloc] initWithFounderDetailItem:[dict objectForKey:@"data"]];
                    [[KnowledgeDatabase shareInstance]saveFounderDetail:self.founderDetailItem tableName:FounderDetailTableName];
                }else{
                    NSDictionary *evaluateInfo = [[dict objectForKey:@"data"] objectForKey:@"evaluateInfo"];
                    if ([evaluateInfo objectForKey:@"evaluateList"]) {
                        NSArray *evaluateList = [evaluateInfo objectForKey:@"evaluateList"];
                        for (NSDictionary *dict in evaluateList) {
                            FounderEvaluateListItem *item = [[FounderEvaluateListItem alloc] initWithFounderEvaluateListItem:dict];
                            [self.founderDetailItem.evaluateList addObject:item];
                        }
                    }
                }
            }
        }
        succeed(self.founderDetailItem);
        
    } failedBlock:^(id object){
        if (self.founderDetailItem != nil) {
            failed (object);
            return;
        }
        [self getFounderDetailFromeDatabase:founderId complete:^(id object) {
            failed (object);
        }];
    }];
}

- (void)postRequestFundDetailfundId:(NSString *)fundId succeed:(PostSucceed)succeed failed:(PostFailed)failed{
    NSDictionary *para = @{
                           @"access_token":[CacheManager sharedInstance].accessToken
                           };
    NSString *requestUrl = [NSString stringWithFormat:@"%@%@",GET_FUND_DETAIL,fundId];
    
    [[NetworkManager sharedInstance] postRequest:requestUrl params:para successBlock:^(NSDictionary *dict) {
        if (dict) {
            if ([dict objectForKey:@"data"]) {
                self.fundDetailItem = [[FundDetailItem alloc] initWithFundDetailItem:[dict objectForKey:@"data"]];
                [[KnowledgeDatabase shareInstance] saveFundDetail:self.fundDetailItem tableName:FundDetailTableName];
            }
        }
        succeed(self.fundDetailItem);
        
    } failedBlock:^(id object){
        [self getFundDetailFromeDatabase:fundId complete:^(id object) {
            failed(object);
        }];
    }];
}


#pragma mark FounderListFromDatabase
- (void)getFounderListDatasFromeDatabase:(NSString *)text complete:(Complete)complete {
    [self.searchFounderAry removeAllObjects];
    NSDictionary *whereDict = @{@"name":text,@"city":text,@"company":text,@"fields":text,@"financingRound":text};
    NSArray *resultArray =[[HJDatabaseManager shareInstance] queryByOrWhereDict:whereDict tableName:FounderListTableName];
    for (NSDictionary *dict in resultArray) {
        SearchFounderListItem *item = [[SearchFounderListItem alloc] initWithKnowledgeListItem:dict];
        [self.searchFounderAry addObject:item];
    }
    complete (self.searchFounderAry);
}

#pragma mark FounderDetailFromDatabase
- (void)getFounderDetailFromeDatabase:(NSString *)userId complete:(Complete)complete {
    NSString *object = [NSString stringWithFormat:@"userId = '%@'",userId];
    NSDictionary *whereDict = [NSDictionary dictionaryWithObject:object forKey:@"userId"];
    NSArray *resultArray = [[HJDatabaseManager shareInstance] queryByAndWhereDict:whereDict tableName:FounderDetailTableName];
    if (resultArray.count != 0) {
        FounderDetailItem *item = [[FounderDetailItem alloc] initWithFounderDetailItem:resultArray.firstObject];
        self.founderDetailItem = item;
        complete(item);
        return;
    }
    complete(nil);
}

#pragma mark FundListFromDatabase
- (void)getFundListDatasFromeDatabase:(NSString *)text complete:(Complete)complete {
    [self.searchFundAry removeAllObjects];
    NSDictionary *whereDict = @{@"name":text,@"currency":text,@"financingRound":text,@"city":text};
    NSArray *resultArray =[[HJDatabaseManager shareInstance] queryByOrWhereDict:whereDict tableName:FundListTableName];
    for (NSDictionary *dict in resultArray) {
        SearchFounListItem *item = [[SearchFounListItem alloc] initWithSearchFounListItem:dict];
        [self.searchFundAry addObject:item];
    }
    complete (self.searchFundAry);
}

#pragma mark FundDetailFromDatabase
- (void)getFundDetailFromeDatabase:(NSString *)fundId complete:(Complete)complete {
    NSString *object = [NSString stringWithFormat:@"fundId = '%@'",fundId];
    NSDictionary *whereDict = [NSDictionary dictionaryWithObject:object forKey:@"fundId"];
    NSArray *resultArray = [[HJDatabaseManager shareInstance] queryByAndWhereDict:whereDict tableName:FundDetailTableName];
    if (resultArray.count != 0) {
        FundDetailItem *item = [[FundDetailItem alloc] initWithFundDetailItem:resultArray.firstObject];
        complete(item);
        return;
    }
    complete(nil);
}

@end
