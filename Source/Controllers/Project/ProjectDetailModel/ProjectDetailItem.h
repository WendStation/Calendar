//
//  ProjectDetailItem.h
//  Calendar
//
//  Created by 刘花椒 on 15/11/5.
//
//

#import <Foundation/Foundation.h>
#import "BaseItem.h"

#pragma mark projectOperation
@interface ProjectToStatusListItem : NSObject

@property(nonatomic, strong)NSString *dataValue;
@property(nonatomic, strong)NSString *dataText;
@property(nonatomic, strong)NSString *operationText;
@property(nonatomic, strong)NSString *operationUrl;

@end

@interface ProjectStatusItem : NSObject

@property(nonatomic, strong)NSString *statusText;
@property(nonatomic, strong)NSMutableArray *toStatusList;

- (instancetype)initProjectStatusItem:(NSDictionary *)dict;

@end


#pragma mark projectMeetingRecord
@interface ProjectAttendeesItem : BaseItem

@property(nonatomic, strong)NSString *name;
@property(nonatomic, strong)NSString *phone;
@property(nonatomic, strong)NSString *company;

@end


@interface ProjectMeetingRecordItem : BaseItem

@property(nonatomic, strong)NSString *projectId;
@property(nonatomic, strong)NSString *meetingId;
@property(nonatomic, strong)NSString *startTime;
@property(nonatomic, strong)NSString *stateText;
@property(nonatomic, strong)NSString *location;
@property(nonatomic, strong)NSMutableArray *attendees;
@property(nonatomic, assign)BOOL needfeedback;

- (instancetype)initMeetingRecordItem:(NSDictionary *)dict;

@end

#pragma mark projectUpdateRecord
@interface ProjectUpdateRecordItem: BaseItem

@property(nonatomic, strong)NSString *projectId;
@property(nonatomic, strong)NSString *operationId;
@property(nonatomic, strong)NSString *type;
@property(nonatomic, strong)NSString *creationTime;
@property(nonatomic, strong)NSString *name;
//type: "operation"
@property(nonatomic, strong)NSString *fromStatus;
@property(nonatomic, strong)NSString *toStatus;
//type: "grade"
@property(nonatomic, strong)NSString *comment;
//type: "other"

- (instancetype)initUpdateRecordItemItem:(NSDictionary *)dict;

@end



#pragma mark projectDeatils
@interface RelatedHttpUrlItem: NSObject

//相关网址
@property(nonatomic, strong)NSString *name;
@property(nonatomic, strong)NSString *url;
@property(nonatomic, strong)NSString *type;
@property(nonatomic, strong)NSString *text;

@end

@interface CompanyDetailItem : NSObject

//项目详述
@property(nonatomic, strong)NSString *title;
@property(nonatomic, strong)NSString *content;

@end

@interface ProjectTeamsInfoItem : NSObject

//teamsInfo
@property(nonatomic, strong)NSString *name;
@property(nonatomic, strong)NSString *position;
@property(nonatomic, strong)NSString *info;
@property(nonatomic, strong)NSString *phone;
@property(nonatomic, strong)NSString *weixin;
@property(nonatomic, strong)NSString *email;

@end

@interface ProjectDetailItem : BaseItem

//基本信息
@property(nonatomic, strong)NSString *projectId;
@property(nonatomic, strong)NSString *title;//项目名称
@property(nonatomic, strong)NSString *agentUserName; //顾问
@property(nonatomic, strong)NSString *operatorUserName; //运营
@property(nonatomic, strong)NSString *referralUserName; //推荐人
@property(nonatomic, strong)NSString *categoryName;//品类
@property(nonatomic, strong)NSString *location;//地域
@property(nonatomic, strong)NSArray *highlights;//项目亮点
@property(nonatomic, strong)NSString *financingScale;//融资规模
@property(nonatomic, strong)NSString *shareProportion;//出让比例

//投资亮点
@property(nonatomic, strong)NSString *investHighlights;

//项目详述
@property(nonatomic, strong)NSMutableArray *companyDetail;

//相关网址
@property(nonatomic, strong)NSMutableArray *links;

//运营数据
@property(nonatomic, strong)NSString *operationData;

//团队情况
@property(nonatomic, strong)NSMutableArray *teamInfo;

//竞争情况与现有投资人
@property(nonatomic, strong)NSMutableArray *competitors;//竞争对手
@property(nonatomic, strong)NSMutableArray *seen;//见过投资者
@property(nonatomic, strong)NSMutableArray *existing;//已有投资者

//项目可见性
@property(nonatomic, strong)NSString *visibleMode;//名单模式
@property(nonatomic, strong)NSMutableArray *rejected;//基金投资人黑名单
@property(nonatomic, strong)NSMutableArray *whiteList;//基金投资人白名单
@property(nonatomic, strong)NSMutableArray *investorLevel;//可见投资人级别
@property(nonatomic, strong)NSNumber *fundType;//站投基金是否可见（0不可见，1可见）
@property(nonatomic, strong)NSMutableArray *currentType;//币种
@property(nonatomic, strong)NSMutableArray *stage;//阶段

@property(nonatomic, strong)NSString *attach;//查看BP
@property(nonatomic, assign)BOOL isGreen;//是否绿色通道
@property(nonatomic, strong)NSString *attachUpdateTime;

- (instancetype)initWithProjectDetailDict:(NSDictionary *)dict;

@end
