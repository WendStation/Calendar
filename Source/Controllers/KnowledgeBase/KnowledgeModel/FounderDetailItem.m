//
//  FounderDetailItem.m
//  Calendar
//
//  Created by 刘花椒 on 15/11/25.
//
//

#import "FounderDetailItem.h"

@implementation FounderEvaluateListItem

- (instancetype)initWithFounderEvaluateListItem:(NSDictionary *)dict{
    if (self = [super init]) {
        self.name = [dict objectForKey:@"name"];
        self.company = [dict objectForKey:@"company"];
        self.evaluateTime = [dict objectForKey:@"evaluateTime"];
        self.manner = [[dict objectForKey:@"manner"] integerValue];
        self.direction = [[dict objectForKey:@"direction"] integerValue];
        self.comment = [dict objectForKey:@"comment"];
    }
    return self;
}

@end

@implementation FounderDetailItem

- (instancetype)initWithFounderDetailItem:(NSDictionary *)dict{
    if (self = [super init]) {
        self.userId = [dict objectForKey:@"userId"];
        self.name = [dict objectForKey:@"name"];
        self.company = [dict objectForKey:@"company"];
        self.position = [dict objectForKey:@"position"];
        self.info = [dict objectForKey:@"info"];
        self.rank = [dict objectForKey:@"rank"];
        self.pushAbility = [dict objectForKey:@"pushAbility"];
        self.favourable = [dict objectForKey:@"favourable"];
        self.investmentProbability = [dict objectForKey:@"investmentProbability"];
        self.reputation = [dict objectForKey:@"reputation"];
        if ([dict objectForKey:@"evaluateInfo"]) {
            NSArray *evaluateList = [[dict objectForKey:@"evaluateInfo"] objectForKey:@"evaluateList"];
            self.evaluateList = [NSMutableArray array];
            for (NSDictionary *subDict in evaluateList) {
                FounderEvaluateListItem *item = [[FounderEvaluateListItem alloc] initWithFounderEvaluateListItem:subDict];
                [self.evaluateList addObject:item];
            }
        } else {
            NSArray *evaluateList = (NSArray *)[self objectWithJsonString:[dict objectForKey:@"evaluateList"]];
            self.evaluateList = [NSMutableArray array];
            for (NSDictionary *subDict in evaluateList) {
                FounderEvaluateListItem *item = [[FounderEvaluateListItem alloc] initWithFounderEvaluateListItem:subDict];
                [self.evaluateList addObject:item];
            }
        }
    }
    return self;
}

@end
