//
//  FounderDetailItem.h
//  Calendar
//
//  Created by 刘花椒 on 15/11/25.
//
//

#import <Foundation/Foundation.h>

@interface FounderEvaluateListItem : NSObject

@property(nonatomic, strong)NSString *name;
@property(nonatomic, strong)NSString *company;
@property(nonatomic, strong)NSString *evaluateTime;
@property(nonatomic, assign)NSInteger manner;//(int整型,  数值 代表 实心五角星数)
@property(nonatomic, assign)NSInteger direction;//(int整型,  数值 代表 实心五角星数)
@property(nonatomic, strong)NSString *comment;

- (instancetype)initWithFounderEvaluateListItem:(NSDictionary *)dict;

@end

@interface FounderDetailItem : BaseItem

@property(nonatomic, strong)NSString *userId;
@property(nonatomic, strong)NSString *name;
@property(nonatomic, strong)NSString *company;
@property(nonatomic, strong)NSString *position;
@property(nonatomic, strong)NSString *info;
@property(nonatomic, strong)NSString *rank;//（高100，中50，低0 、 为空表示未知）
@property(nonatomic, strong)NSString *pushAbility;//（值为100表示强、0表示弱、为空表示未知）
@property(nonatomic, strong)NSString *favourable;//（100’好评'、50’一般'、0’差评'、空’未知'）
@property(nonatomic, strong)NSString *investmentProbability;//100高、0低、空值未知）
@property(nonatomic, strong)NSString *reputation;
@property(nonatomic, strong)NSMutableArray *evaluateList;

- (instancetype)initWithFounderDetailItem:(NSDictionary *)dict;

@end
