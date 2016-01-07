//
//  NetworkManager.h
//  Calendar
//
//  Created by 小华 on 15/10/20.
//
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

typedef void (^PostRequestSuccessBlock)(NSDictionary *dict);
typedef void (^PostRequestFailedBlock)(id object);

typedef void (^GetRequestSuccessBlock)(NSDictionary *dict);
typedef void (^GetRequestFailedBlock)();


@interface NetworkManager : NSObject
@property(nonatomic, strong) NSString *baseUrl;


//网络状态
@property (nonatomic) AFNetworkReachabilityStatus netStatus;
+ (NetworkManager *)sharedInstance;
//判断请求是否成功，是否token过期，过期则跳转到登陆页面
-(BOOL)NetSuccessManage:(NSDictionary *)result;
//检查网络和token值
-(BOOL)checkNetAndToken;

//加上一些网络请求的公共参数
- (void)setupNetRequestFilters:(NSString *)baseUrl;

- (void)syncAllStatusDefinitionDatas;

/*
 action :请求路径
 params :请求参数
 */
-(void)postRequest:(NSString *)requestUrl
           params:(NSDictionary *)params
     successBlock:(PostRequestSuccessBlock)succesblock
      failedBlock:(PostRequestFailedBlock)failedBlock;


- (void)getRequest:(NSString *)requestUrl
             Params:(NSDictionary*)Params
       successBlock:(GetRequestSuccessBlock)succesblock
        failedBlock:(GetRequestFailedBlock)failedBlock;

@end
