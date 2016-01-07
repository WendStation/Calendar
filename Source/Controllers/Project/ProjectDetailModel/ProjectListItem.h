//
//  OnlineProjectItem.h
//  Calendar
//
//  Created by 刘花椒 on 15/10/30.
//
//

#import <Foundation/Foundation.h>

@interface ProjectListItem : NSObject

@property (nonatomic, strong) NSString *projectId;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *agentName;
@property (nonatomic, strong) NSString *ownerName;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *statusText1;
@property (nonatomic, strong) NSString *statusText2;
@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *category;
@property (nonatomic, strong) NSString *abstract;

- (instancetype)initWithProjectListItem:(NSDictionary *)dict;

@end
