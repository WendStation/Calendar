//
//  KnowledgeListItem.m
//  Calendar
//
//  Created by 刘花椒 on 15/11/24.
//
//

#import "SearchFounderListItem.h"

@implementation SearchFounListItem

- (instancetype)initWithSearchFounListItem:(NSDictionary *)dict{
    if (self = [super init]) {
        self.fundId = [dict objectForKey:@"fundId"];
        self.name = [dict objectForKey:@"name"];
        self.currency = [dict objectForKey:@"currency"];
        self.financingRound = [dict objectForKey:@"financingRound"];
    }
    return self;
}

@end

@implementation SearchFounderListItem

- (instancetype)initWithKnowledgeListItem:(NSDictionary *)dict{
    if (self = [super init]) {
        self.userId = [dict objectForKey:@"userId"];
        self.name = [dict objectForKey:@"name"];
        self.phone = [dict objectForKey:@"phone"];
        self.company = [dict objectForKey:@"company"];
        self.financingRound = [dict objectForKey:@"financingRound"];
        if ([[dict objectForKey:@"fields"] isKindOfClass:[NSArray class]]) {
            self.fields = [NSArray arrayWithArray:[dict objectForKey:@"fields"]];
        }
    }
    return self;
}

@end
