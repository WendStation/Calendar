//
//  KnowledgeListDatasource.h
//  Calendar
//
//  Created by 刘花椒 on 15/11/24.
//
//

#import <Foundation/Foundation.h>
#import "FounderDetailItem.h"
#import "FundDetailItem.h"

@interface KnowledgeListDatasource : NSObject

@property(nonatomic, strong)NSMutableArray *searchFounderAry;
@property(nonatomic, strong)NSMutableArray *searchFundAry;
@property(nonatomic, strong)FounderDetailItem *founderDetailItem;
@property(nonatomic, strong)FundDetailItem *fundDetailItem;

#pragma mark FounderListFromNetwork
- (void)postRequestSearchFounderIsLoadMore:(BOOL)isLoadMore
                               searchTitle:(NSString *)searchTitle
                                   succeed:(PostSucceed)succeed
                                    failed:(PostFailed)failed;
#pragma mark FundListFromNetwork
- (void)postRequestSearchFundIsLoadMore:(BOOL)isLoadMore
                               searchTitle:(NSString *)searchTitle
                                   succeed:(PostSucceed)succeed
                                    failed:(PostFailed)failed;


#pragma mark FounderDetailFromNetwork
- (void)postRequestFounderDetailIsLoadMore:(BOOL)isLoadMore
                                 founderId:(NSString *)founderId
                                   succeed:(PostSucceed)succeed
                                    failed:(PostFailed)failed;
#pragma mark FundDetailFromNetwork
- (void)postRequestFundDetailfundId:(NSString *)fundId
                                   succeed:(PostSucceed)succeed
                                    failed:(PostFailed)failed;

#pragma mark FounderListFromDatabase
- (void)getFounderListDatasFromeDatabase:(NSString *)text complete:(Complete)complete;
#pragma mark FounderDetailFromDatabase
- (void)getFounderDetailFromeDatabase:(NSString *)userId complete:(Complete)complete;
#pragma mark FundListFromDatabase
- (void)getFundListDatasFromeDatabase:(NSString *)text complete:(Complete)complete;
#pragma mark FundDetailFromDatabase
- (void)getFundDetailFromeDatabase:(NSString *)fundId complete:(Complete)complete;

@end
