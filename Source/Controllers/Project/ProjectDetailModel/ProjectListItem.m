//
//  OnlineProjectItem.m
//  Calendar
//
//  Created by 刘花椒 on 15/10/30.
//
//

#import "ProjectListItem.h"

@implementation ProjectListItem

- (instancetype)initWithProjectListItem:(NSDictionary *)dict{
    if (self = [super init]) {
        self.projectId = [dict objectForKey:@"id"];
        self.title = [dict objectForKey:@"title"];
        self.agentName = [dict objectForKey:@"agentName"];
        self.ownerName = [dict objectForKey:@"ownerName"];
        self.phone = [dict objectForKey:@"phone"];
        self.statusText1 = [dict objectForKey:@"statusText1"];
        self.statusText2 = [dict objectForKey:@"statusText2"];
        self.status = [dict objectForKey:@"status"];
        self.city = [dict objectForKey:@"city"];
        self.category = [dict objectForKey:@"category"];
        self.abstract = [dict objectForKey:@"abstract"];
    }
    return self;
}

@end
