//
//  KnowledgeListItem.h
//  Calendar
//
//  Created by 刘花椒 on 15/11/24.
//
//

#import <Foundation/Foundation.h>

@interface SearchFounListItem : NSObject

@property(nonatomic, strong)NSString *fundId;
@property(nonatomic, strong)NSString *name;
@property(nonatomic, strong)NSString *currency;
@property(nonatomic, strong)NSString *financingRound;
@property(nonatomic, strong)NSString *city;

- (instancetype)initWithSearchFounListItem:(NSDictionary *)dict;

@end

@interface SearchFounderListItem : NSObject

@property(nonatomic, strong)NSString *userId;
@property(nonatomic, strong)NSString *name;
@property(nonatomic, strong)NSString *phone;
@property(nonatomic, strong)NSString *company;
@property(nonatomic, strong)NSString *city;
@property(nonatomic, strong)NSString *financingRound;
@property(nonatomic, strong)NSString *currency;
@property(nonatomic, strong)NSArray *fields;

- (instancetype)initWithKnowledgeListItem:(NSDictionary *)dict;

@end
