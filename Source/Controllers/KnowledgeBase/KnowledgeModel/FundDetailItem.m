//
//  FundDetailItem.m
//  Calendar
//
//  Created by 刘花椒 on 15/11/25.
//
//

#import "FundDetailItem.h"

@implementation FundDetailItem

- (instancetype)initWithFundDetailItem:(NSDictionary *)dict{
    if (self = [super init]) {
        self.fundId = [dict objectForKey:@"fundId"];
        self.name = [dict objectForKey:@"name"];
        self.englishName = [dict objectForKey:@"englishName"];
        self.nameShort = [dict objectForKey:@"nameShort"];
        self.englishNameShort = [dict objectForKey:@"englishNameShort"];
        
        self.address = [NSMutableArray array];
        if ([[dict objectForKey:@"address"] isKindOfClass:[NSArray class]]) {
            self.address = [dict objectForKey:@"address"];
        } else {
            self.address = (NSMutableArray *)[self objectWithJsonString:[dict objectForKey:@"address"]];
        }
        
        self.info = [dict objectForKey:@"info"];
        self.comment = [dict objectForKey:@"comment"];
        self.reputation = [dict objectForKey:@"reputation"];
        self.currency = [dict objectForKey:@"currency"];
        self.financingRound = [dict objectForKey:@"financingRound"];
        self.investProb = [dict objectForKey:@"investProb"];
        self.isStrategy = [dict objectForKey:@"isStrategy"];
        self.focus = [dict objectForKey:@"focus"];
        self.thirdBoard = [dict objectForKey:@"thirdBoard"];
        self.startupCEO = [dict objectForKey:@"startupCEO"];

    }
    return self;
}

@end
