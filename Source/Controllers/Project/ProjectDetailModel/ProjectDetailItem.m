//
//  ProjectDetailItem.m
//  Calendar
//
//  Created by 刘花椒 on 15/11/5.
//
//

#import "ProjectDetailItem.h"

@implementation ProjectToStatusListItem

#pragma mark projectOperation
- (instancetype)initProjectToStatusListItem:(NSDictionary *)dict{
    if (self = [super init]) {
        self.dataValue = [dict objectForKey:@"dataValue"];
        self.dataText = [dict objectForKey:@"dataText"];
        self.operationText = [dict objectForKey:@"operationText"];
        self.operationUrl = [dict objectForKey:@"operationUrl"];
    }
    return self;
}

@end

@implementation ProjectStatusItem

- (instancetype)initProjectStatusItem:(NSDictionary *)dict{
    if (self = [super init]) {
        self.statusText = [dict objectForKey:@"statusText"];
        self.toStatusList = [NSMutableArray array];
        if ([[dict objectForKey:@"toStatusList"] count] > 0) {
            NSArray *ary = [dict objectForKey:@"toStatusList"];
            for (NSDictionary * subDict in ary) {
                ProjectToStatusListItem *item = [[ProjectToStatusListItem alloc] initProjectToStatusListItem:subDict];
                [self.toStatusList addObject:item];
            }
        }
    }
    return self;
}

@end

#pragma mark projectMeetingRecord
@implementation ProjectAttendeesItem

- (instancetype)initAttendeesItem:(NSDictionary *)dict{
    if (self = [super init]) {
        self.name = [dict objectForKey:@"name"];
        self.phone = [dict objectForKey:@"phone"];
        self.company = [dict objectForKey:@"company"];
    }
    return self;
}

@end


@implementation ProjectMeetingRecordItem

- (instancetype)initMeetingRecordItem:(NSDictionary *)dict{
    if (self = [super init]) {
        self.meetingId = [dict objectForKey:@"meetingId"];
        self.startTime = [dict objectForKey:@"startTime"];
        self.stateText = [dict objectForKey:@"stateText"];
        self.location = [dict objectForKey:@"location"];
        
        self.attendees = [NSMutableArray array];
        NSArray *attendeesAry;
        if ([[dict objectForKey:@"attendees"] isKindOfClass:[NSArray class]]) {
            attendeesAry = [dict objectForKey:@"attendees"];
        } else {
            attendeesAry = (NSArray *)[self objectWithJsonString:[dict objectForKey:@"attendees"]];
        }
        for (NSDictionary *dict in attendeesAry) {
            ProjectAttendeesItem *item = [[ProjectAttendeesItem alloc] initAttendeesItem:dict];
            [self.attendees addObject:item];
        }
        
        self.needfeedback = [[dict objectForKey:@"needfeedback"] boolValue];
    }
    return self;
}

@end

#pragma mark projectUpdateRecord
@implementation ProjectUpdateRecordItem

- (instancetype)initUpdateRecordItemItem:(NSDictionary *)dict{
    if (self = [super init]) {
        self.type = [dict objectForKey:@"type"];
        self.creationTime = [dict objectForKey:@"creationTime"];
        if ([dict objectForKey:@"event"]) {
            NSDictionary *event = [dict objectForKey:@"event"];
            self.operationId = [event objectForKey:@"operationId"];
            self.name = [event objectForKey:@"name"];
            if ([self.type isEqualToString:@"operation"]) {
                self.fromStatus = [event objectForKey:@"fromStatus"];
                self.toStatus = [event objectForKey:@"toStatus"];
            } else if ([self.type isEqualToString:@"grade"]) {
                self.comment = [event objectForKey:@"comment"];
            } else {
                self.comment = [event objectForKey:@"comment"];
            }
        } else {
            self.operationId = [dict objectForKey:@"operationId"];
            self.name = [dict objectForKey:@"name"];
            if ([self.type isEqualToString:@"operation"]) {
                self.fromStatus = [dict objectForKey:@"fromStatus"];
                self.toStatus = [dict objectForKey:@"toStatus"];
            } else if ([self.type isEqualToString:@"grade"]) {
                self.comment = [dict objectForKey:@"comment"];
            } else {
                self.comment = [dict objectForKey:@"comment"];
            }
        }
    }
    return self;
}

@end


#pragma mark projectDeatils
@implementation RelatedHttpUrlItem

- (instancetype)initWithRelatedHttpUrlDict:(NSDictionary *)dict{
    if (self = [super init]) {
        self.name = [dict objectForKey:@"name"];
        self.url = [dict objectForKey:@"url"];
        self.type = [dict objectForKey:@"type"];
        if ([self.type isEqualToString:@"account"]) {
            self.text = [dict objectForKey:@"text"];
        }
    }
    return self;
}

@end

@implementation CompanyDetailItem 

- (instancetype)initWithCompanyDetailDict:(NSDictionary *)dict{
    if (self = [super init]) {
        self.title = [dict objectForKey:@"title"];
        self.content = [dict objectForKey:@"content"];
    }
    return self;
}

@end

@implementation ProjectTeamsInfoItem

- (instancetype)initWithProjectTeamsDict:(NSDictionary *)dict{
    if (self = [super init]) {
        self.name = [dict objectForKey:@"name"];
        self.position = [dict objectForKey:@"position"];
        self.info = [dict objectForKey:@"info"];
        self.phone = [dict objectForKey:@"phone"];
        self.weixin = [dict objectForKey:@"weixin"];
        self.email = [dict objectForKey:@"email"];
    }
    return self;
}

@end

@implementation ProjectDetailItem

- (instancetype)initWithProjectDetailDict:(NSDictionary *)dict{
    if (self = [super init]) {
        self.title = [dict objectForKey:@"title"];
        self.agentUserName = [dict objectForKey:@"agentUserName"];
        self.operatorUserName = [dict objectForKey:@"operatorUserName"];
        self.referralUserName = [dict objectForKey:@"referralUserName"];
        self.categoryName = [dict objectForKey:@"categoryName"];
        self.location = [dict objectForKey:@"location"];
        
        self.highlights = [NSArray array];
        if ([[dict objectForKey:@"highlights"] isKindOfClass:[NSArray class]]) {
            self.highlights = [dict objectForKey:@"highlights"];
        } else {
            self.highlights = (NSArray *)[self objectWithJsonString:[dict objectForKey:@"highlights"]];
        }
        
        self.financingScale = [dict objectForKey:@"financingScale"];
        self.shareProportion = [dict objectForKey:@"shareProportion"];
        self.investHighlights = [dict objectForKey:@"investHighlights"];
        
        NSArray *companyDetailAry = (NSArray *)[self objectWithJsonString:[dict objectForKey:@"companyDetail"]];
        self.companyDetail = [NSMutableArray array];
        for (NSDictionary *dict in companyDetailAry) {
            CompanyDetailItem *item = [[CompanyDetailItem alloc] initWithCompanyDetailDict:dict];
            [self.companyDetail addObject:item];
        }
        
        self.links = [NSMutableArray array];
        NSArray *linksAry;
        if ([[dict objectForKey:@"links"] isKindOfClass:[NSArray class]]) {
            linksAry = [dict objectForKey:@"links"];
        } else {
            linksAry = (NSArray *)[self objectWithJsonString:[dict objectForKey:@"links"]];
        }
        for (NSDictionary *dict in linksAry) {
            RelatedHttpUrlItem *item = [[RelatedHttpUrlItem alloc] initWithRelatedHttpUrlDict:dict];
            [self.links addObject:item];
        }
        
        self.operationData = [dict objectForKey:@"operationData"];
        
        self.teamInfo = [NSMutableArray array];
        NSArray *teamAry;
        if ([[dict objectForKey:@"teamInfo"] isKindOfClass:[NSArray class]]) {
            teamAry = [dict objectForKey:@"teamInfo"];
        } else {
            teamAry = (NSArray *)[self objectWithJsonString:[dict objectForKey:@"teamInfo"]];
        }
        for (NSDictionary *subDict in teamAry) {
            ProjectTeamsInfoItem *teamItem = [[ProjectTeamsInfoItem alloc] initWithProjectTeamsDict:subDict];
            [self.teamInfo addObject:teamItem];
        }
        
        self.competitors = [NSMutableArray array];
        if ([[dict objectForKey:@"competitors"] isKindOfClass:[NSArray class]]) {
            self.competitors = [dict objectForKey:@"competitors"];
        } else {
            self.competitors = (NSMutableArray *)[self objectWithJsonString:[dict objectForKey:@"competitors"]];
        }
        
        self.seen = [NSMutableArray array];
        if ([[dict objectForKey:@"seen"] isKindOfClass:[NSArray class]]) {
            self.seen = [dict objectForKey:@"seen"];
        } else {
            self.seen = (NSMutableArray *)[self objectWithJsonString:[dict objectForKey:@"seen"]];
        }
        
        self.existing = [NSMutableArray array];
        if ([[dict objectForKey:@"existing"] isKindOfClass:[NSArray class]]) {
            self.existing = [dict objectForKey:@"existing"];
        } else {
            self.existing = (NSMutableArray *)[self objectWithJsonString:[dict objectForKey:@"existing"]];
        }
        
        self.rejected = [NSMutableArray array];
        if ([[dict objectForKey:@"rejected"] isKindOfClass:[NSArray class]]) {
            self.rejected = [dict objectForKey:@"rejected"];
        } else {
            self.rejected = (NSMutableArray *)[self objectWithJsonString:[dict objectForKey:@"rejected"]];
        }
        
        self.whiteList = [NSMutableArray array];
        if ([[dict objectForKey:@"whiteList"] isKindOfClass:[NSArray class]]) {
            self.whiteList = [dict objectForKey:@"whiteList"];
        } else {
            self.whiteList = (NSMutableArray *)[self objectWithJsonString:[dict objectForKey:@"whiteList"]];
        }
        
        self.visibleMode = [dict objectForKey:@"visibleMode"];
        
        self.investorLevel = [NSMutableArray array];
        if ([[dict objectForKey:@"investorLevel"] isKindOfClass:[NSArray class]]) {
            self.investorLevel = [dict objectForKey:@"investorLevel"];
        } else {
            self.investorLevel = (NSMutableArray *)[self objectWithJsonString:[dict objectForKey:@"investorLevel"]];
        }
        
        self.fundType = [dict objectForKey:@"fundType"];
        
        self.currentType = [NSMutableArray array];
        if ([[dict objectForKey:@"currentType"] isKindOfClass:[NSArray class]]) {
            self.currentType = [dict objectForKey:@"currentType"];
        } else {
            self.currentType = (NSMutableArray *)[self objectWithJsonString:[dict objectForKey:@"currentType"]];
        }
        
        self.stage = [NSMutableArray array];
        if ([[dict objectForKey:@"stage"] isKindOfClass:[NSArray class]]) {
            self.stage = [dict objectForKey:@"stage"];
        } else {
            self.stage = (NSMutableArray *)[self objectWithJsonString:[dict objectForKey:@"stage"]];
        }
        
        self.attach = [dict objectForKey:@"attach"];
        self.attachUpdateTime = [dict objectForKey:@"attachUpdateTime"];
    }
    return self;
}

@end
