//
//  MacroDefinition.h
//  Ethercap
//
//  Created by 小华 on 15/2/11.
//  Copyright (c) 2015年 Robert Dimitrov. All rights reserved.
//
#import <Foundation/Foundation.h>


#define UMENG_APPKEY @"556d4f2367e58e26a6002b04"

#define PROJECT_ITEM_VIEW_TAG 1000

#define PROJECT_GONGHAI 1
#define PROJECT_SIHAI 2
#define PROJECT_YUNYING 3

#pragma mark databaseTableName
#define ProjectListTableName @"ProjectListTableName"
#define CCNeedsTableName @"CCNeedsTableName"
#define ProjectDetailTableName @"ProjectDetailTableName"
#define MeetingRecordTableName @"MeetingRecordTableName"
#define UpdateRecordTableName @"UpdateRecordTableName"

#define FounderListTableName @"FounderListTableName"
#define FundListTableName @"FundListTableName"
#define FounderDetailTableName @"FounderDetailTableName"
#define FundDetailTableName @"FundDetailTableName"

#define GroupListTableName        @"GroupListTableName"
#define GlobalMessageTableName    @"GlobalMessageTableName"
#define MessageListTableName      @"MessageListTableName"
#define TaskListTableName         @"TaskListTableName"

//url定义
#define BASE_NETWORK_URL_115  @"http://115.29.34.171"
#define BASE_NETWORK_URL_ADMIN  @"http://admin.ethercap.com"
#define BASE_NETWORK_URL_APLUS  @"http://aplus.ethercap.com"

#define LOGIN_URL @"/a/user/login/"

#define GET_OTHERS_SCHEDULE_INFO_URL @"/a/schedule/getSchedules/"
#define SUBMIT_SCHEDULES_URL @"/a/schedule/submitSchedules/"


#define GET_PROJECT_LIST_URL @"/a/project/getList/"
#define GET_PROJECT_DETAIL_NEW_URL @"/a/project/projectDetailNew/"
#define GET_PROJECT_DETAIL_STATUS_URL @"/a/project/getProjectStatus/"

#define GET_MEETING_RECORD_URL @"/a/meeting/getMeetingsByProjectId/"
#define GET_PEOJECT_INVESTORS_URL @"/a/project/projectInvestors/"
//#define ADD_UPDATE_PROJECT_URL @"/a/project/addUpdateProject/"
#define ADD_PROJECT_URL @"/a/project/addProject"
#define ADD_CC_URL @"/a/project/addCC"
#define GET_PROJECT_GRADE_CHANGE_URL @"/a/project/projectGradeAndChangeEvent/"
//#define GET_INVESTOR_GRADE_CHANGE_URL @"/a/project/projectInvestorEvent/"
//#define GET_INVESTOR_PROJECT_STATUS_URL @"/a/project/projectInvestorStatus/"
//#define GET_OWNER_PROJECT_URL @"/a/project/ownerProjects/"
#define GET_PROJECT_CATEGORY_DEFINE_URL @"/a/project/categoryDefine/"

//#define UPDATE_PROJECT_STATUS_URL @"/a/project_operation/updateProjectStatus/"
//#define ADD_INVESTOR_TO_PROJECT_URL @"/a/project_operation/addInvestorToProject/"
//#define ADD_TOUCH_RECODE_URL @"/a/project_operation/addFollowUp/"
#define GET_PROJECT_STATUS_RULE_URL @"/a/project_operation/getProjectStatusDefinition/"
#define GET_INVESTOR_STATUS_RULE_URL @"/a/project_operation/getInvestorStatusDefinition/"
//#define UPDATE_INVESTOR_STATUS_URL @"/a/project_operation/updateInvestorStatus/"


#define SEARCH_INVESTORS_URL @"/a/investor/searchInvestors/"
//#define GET_INVESTORS_DETAIL_URL @"/a/investor/info/"

//#define GET_MEETING_DETAIL_URL @"/a/meeting/getMeetingInfo/"
//#define GET_MEETING_LIST_URL @"/a/meeting/getMeetings/"
#define SUBMIT_MEETING_URL @"/a/meeting/submitMeeting/"
//#define GEN_MEETING_INVATATION_URL @"/a/meeting/genMeetingInvitation/"
//#define SUBMIT_FEEDBACK_URL @"/a/meeting/submitAgentFeedback/"
//#define GET_MEETING_STATUS_URL @"/a/meeting/getMeetingStatus/"


#define GET_MESSAGE_URL @"/a/message/getMessages/"
#define GET_MISSION_URL @"/a/task/tasks/"
#define GET_AGENTS_URL @"/a/staff/agents/"
#define GET_UESER_URL @"/a/user/sync/"
#define GET_UESER_PRIVACY_URL @"/a/user/getPrivacy/"
#define GET_MAINPAGE_DATA_URL @"/a/project/mydata/"
#define GET_OPERATE_PROJECT_URL @"/a/project/operateProjects/"
#define GET_FOLLOW_PROJECT_URL @"/a/project/followProjects/"

#define GET_FUND_LIST @"/a/fund/getFundsList/"
#define GET_FUND_BY_INVESTOR @"/a/fund/fundByInvestorId/"
#define GET_FUND_DETAIL @"/a/fund/getFundInfo/"
#define GET_FUND_CASE @"/a/fund/getFundEvents/"

#define GET_INVESTOR_LIST @"/a/investor/getInvestorsList/"
#define GET_INVESTOR_CASE @"/a/investor/getInvestorEvents/"
#define GET_INVESTOR_DETAIL @"/a/investor/getInvestorInfo/"
#define GET_INVESTOR_COMMENT @"/a/investor/getInvestorComment/"
#define SUBMIT_INVESTOR_COMMENT_URL @"/a/investor/submitComment/"

#pragma mark messageUrl
#define MESSAGE_GROUP_LIST_URL  @"/a/im_message/getGroupList/"
#define GET_NEW_MESSGAE_URL     @"/a/im_message/getNewMessages/"
#define MESSAGE_SEND_URL        @"/a/im_message/send/"
#define HISTORY_MESSAGES_URL    @"/a/im_message/getGroupHistoryMessages/"
#define GET_MESSGAE_LIST_URL    @"/a/message/getMessages/"
#define GET_TASK_LIST_URL       @"/a/task/tasks/"

#pragma mark cacheFolder
#define KUserCacheFolder @"User"
#define KUserCache       @"UserCache"

#define KChangedScheduleCacheFolder @"ChangedSchedule"
#define KChangedScheduleCache       @"ChangedScheduleCache"

#define KUserScheduleCacheFolder @"UserSchedule"
#define KUserScheduleCache       @"UserScheduleCache"

#define KScheduleIdCacheFolder @"ScheduleId"
#define KScheduleIdCache       @"ScheduleIdCache"

#define KProjectStatusCacheFolder   @"ProjectStatus"
#define KProjectStatusCache         @"ProjectStatusCache"
#define KInvestorStatusCacheFolder    @"InvestorStatus"
#define KInvestorStatusCache          @"InvestorStatusCache"
#define KCategoryDefineCacheFolder       @"CategoryDefine"
#define KCategoryDefineCache             @"CategoryDefineCache"

#define KBPCacheFolder       @"BP"
#define KBPCache             @"BPCache"

//清除本地缓存
#define KClearCacheNotification  @"ClearCacheNotification"


//网络码
#define NETWORK_CODE_SUCCESS   0
#define NETWORK_CODE_NEED_LOGIN   10
#define NETWORK_CODE_NO_MoreDatas 201 


//常用的宏
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]


#define BLUE_COLOR [UIColor colorWithRed:50/255.0f green:188/255.0f blue:198/255.0f alpha:1]
#define LIGHTGRAY_COLOR [UIColor colorWithRed:138/255.0f green:138/255.0f blue:138/255.0f alpha:1]
#define DARKGRAY_COLOR [UIColor colorWithRed:106/255.0f green:106/255.0f blue:106/255.0f alpha:1]
#define BLACK_COLOR [UIColor colorWithRed:17/255.0f green:17/255.0f blue:17/255.0f alpha:1]
#define BACKGROUND_COLOR [UIColor colorWithRed:240/255.0f green:240/255.0f blue:245/255.0f alpha:1]

/*
 *各个tab的index
 */
#define SCHEDULE_TAB_INDEX 0
#define PROJECT_TAB_INDEX 1
#define KNOWLEDGE_TAB_INDEX 2
#define MESSAGE_TAB_INDEX 3
#define MORE_TAB_INDEX 4


/*
 *屏幕宽度/高度
 */
#define SCREEN_WIDTH ([[UIScreen mainScreen]bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen]bounds].size.height)

/*
 *单独view的宽高
 */

#define WIDTH self.frame.size.width
#define HEIGHT self.frame.size.height

/*
 * iPhone 屏幕尺寸
 */
#define PHONE_SCREEN_SIZE (CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT - PHONE_STATUSBAR_HEIGHT))

/*
 * iPhone statusbar 高度
 */
#define PHONE_STATUSBAR_HEIGHT 20

/*
 *用户适配横向布局的密度参数
 */
#define DENSITY SCREEN_WIDTH/320.0
#define evaluate(x) ceil((x)*DENSITY)

/*
 *默认多语言表
 */
#define RS_CURRENT_LANGUAGE_TABLE  [[NSUserDefaults standardUserDefaults] objectForKey:@"LanguageSwtich"]?[[NSUserDefaults standardUserDefaults] objectForKey:@"LanguageSwtich"]:@"zh-Hans"

typedef void (^dispatch_block_c)(void);

