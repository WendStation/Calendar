//
//  ProjectDatasource.h
//  Calendar
//
//  Created by 刘花椒 on 15/11/1.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    OnlineProject = 0,
    PrivateOceanProject = 1,
    CCNeedsProject = 2
} ProjectRequestType;

//typedef void (^ PostRequestProjectSuccessBlock) (NSMutableArray *dataAry ,NSString *message);
//typedef void (^ PostRequestProjectFailedBlock) ();

typedef void (^ PostAddProjectSuccessBlock) (NSDictionary *dict);
typedef void (^ PostAddProjectFailedBlock) ();

@interface ProjectListDatasource : NSObject

@property(nonatomic, assign)ProjectRequestType projectRequestType;
@property(nonatomic, strong)NSMutableArray *onlineProjectAry;
@property(nonatomic, strong)NSMutableArray *privateOceanProjectAry;
@property(nonatomic, strong)NSMutableArray *ccNeedsProjectAry;
@property(nonatomic, strong)NSMutableArray *searchProjectAry;


#pragma mark getOnlineProjectFromNetWork
- (void)postRequestOnlineProjectIsLoadMore:(BOOL)isLoadMore
                                     isAll:(BOOL)isAll
                                   succeed:(PostSucceed)succeed
                                    failed:(PostFailed)failed;
#pragma mark getPrivateOceanProjectFromNetWork
- (void)postRequestPrivateOceanProjectIsLoadMore:(BOOL)isLoadMore
                                         succeed:(PostSucceed)succeed
                                          failed:(PostFailed)failed;

#pragma mark getCCFromNetWork
- (void)postRequestCCProjectIsLoadMore:(BOOL)isLoadMore
                                succeed:(PostSucceed)succeed
                                 failed:(PostFailed)failed;
#pragma mark getSearchProjectFromNetWork
- (void)postRequestSearchProjectIsLoadMore:(BOOL)isLoadMore
                               searchTitle:(NSString *)searchTitle
                                   succeed:(PostSucceed)succeed
                                    failed:(PostFailed)failed;

#pragma mark AddProjectToNetWork
- (void)postAddProjectInfo:(NSDictionary *)info
                   succeed:(PostAddProjectSuccessBlock)succeed
                    failed:(PostAddProjectFailedBlock)failed;

#pragma mark addCCToNetWork
- (void)postAddCCInfo:(NSDictionary *)info
                   succeed:(PostAddProjectSuccessBlock)succeed
                    failed:(PostAddProjectFailedBlock)failed;

#pragma mark getOnlineProjectDatasFromeDatabase
- (void)getOnlineProjectDatasFromeDatabaseIsLoadMore:(BOOL)isLoadMore complete:(Complete)complete;
#pragma mark getPrivateOceanProjectDatasFromeDatabase
- (void)getPrivateOceanProjectDatasFromeDatabaseIsLoadMore:(BOOL)isLoadMore complete:(Complete)complete;
#pragma mark getCCProjectDatasFromeDatabase
- (void)getCCProjectDatasFromeDatabaseIsLoadMore:(BOOL)isLoadMore complete:(Complete)complete;
#pragma mark getSearchProjectDatasFromeDatabase
- (void)getSearchProjectDatasFromeDatabase:(NSString *)text complete:(Complete)complete;

@end
