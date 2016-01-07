//
//  FundDetailItem.h
//  Calendar
//
//  Created by 刘花椒 on 15/11/25.
//
//

#import <Foundation/Foundation.h>

@interface FundDetailItem : BaseItem

@property(nonatomic, strong)NSString *fundId;
@property(nonatomic, strong)NSString *name;
@property(nonatomic, strong)NSString *englishName;
@property(nonatomic, strong)NSString *nameShort;
@property(nonatomic, strong)NSString *englishNameShort;
@property(nonatomic, strong)NSMutableArray *address;
@property(nonatomic, strong)NSString *info;//介绍
@property(nonatomic, strong)NSString *comment;//备注
@property(nonatomic, strong)NSString *reputation;//名气大100，小0
@property(nonatomic, strong)NSString *currency;//币种人民币1，2美元，3人民币和美元
@property(nonatomic, strong)NSString *financingRound;//投资阶段
@property(nonatomic, strong)NSString *investProb;//投资概率大100，小0
@property(nonatomic, strong)NSString *isStrategy;//是否战投(1是，0否)
@property(nonatomic, strong)NSString *focus;//关注点
@property(nonatomic, strong)NSString *thirdBoard;//是否新三板(1是，0否)
@property(nonatomic, strong)NSString *startupCEO;//是否小创业公司CEO(1是，0否)

- (instancetype)initWithFundDetailItem:(NSDictionary *)dict;

@end
