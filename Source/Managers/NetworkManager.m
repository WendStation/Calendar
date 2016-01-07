//
//  NetworkManager.m
//  Calendar
//
//  Created by 小华 on 15/10/20.
//
//

#import "NetworkManager.h"
#import "MBProgressHUD.h"
#import "MacroDefinition.h"

#import "CacheManager.h"
#import "ScheduleManager.h"
#import "CustomerManager.h"

#import "AFHTTPRequestOperationManager.h"

@implementation NetworkManager


+ (NetworkManager *)sharedInstance
{
    static NetworkManager *str;
    @synchronized(self){
        if (str==nil) {
            str=[[NetworkManager alloc]init];
            [str checkNetworkStatus];
        }
        return str;
    }
}

-(void)checkNetworkStatus
{
    /**
     AFNetworkReachabilityStatusUnknown          = -1,  // 未知
     AFNetworkReachabilityStatusNotReachable     = 0,   // 无连接
     AFNetworkReachabilityStatusReachableViaWWAN = 1,   // wwan
     AFNetworkReachabilityStatusReachableViaWiFi = 2,   // wifi
     */
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    self.netStatus = AFNetworkReachabilityStatusReachableViaWWAN;
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status)
    {
        if (status < AFNetworkReachabilityStatusReachableViaWWAN && self.netStatus >= AFNetworkReachabilityStatusReachableViaWWAN) {
            [AlertManager showAlertText:@"网络不佳，将使用缓存数据" withCloseSecond:1];
            
        }
        else if (status >= AFNetworkReachabilityStatusReachableViaWWAN && self.netStatus < AFNetworkReachabilityStatusReachableViaWWAN) {
            [AlertManager showAlertText:@"网络恢复" withCloseSecond:1];
        }
        self.netStatus = status;
        
    }];
}

-(BOOL)checkNetAndToken {
    if (self.netStatus > AFNetworkReachabilityStatusNotReachable && [[CacheManager sharedInstance] hasLogin]) {
        return YES;
    }
    return NO;
}

-(BOOL)NetSuccessManage:(NSDictionary *)result
{
    if (result == nil) {
        [AlertManager showAlertText:@"网络数据无法解析" withCloseSecond:1];
        return NO;
    }
    if ([[result objectForKey:@"code"] intValue] == NETWORK_CODE_NEED_LOGIN) {
        [[ViewManager sharedInstance] showLoginView];
        [AlertManager showAlertText:[NSString stringWithFormat:@"%@", [result objectForKey:@"message"]] withCloseSecond:1];
        return NO;
    }
    else if([[result objectForKey:@"code"] intValue] != NETWORK_CODE_SUCCESS) {
    }
    return YES;
}


- (void)setupNetRequestFilters:(NSString *)baseUrl {
    self.baseUrl = baseUrl;
}

- (void)syncAllStatusDefinitionDatas{
    NSDictionary *params = @{
                             @"access_token":[CacheManager sharedInstance].accessToken
                             };
    NSString *requestUrl = @"";
    NSString *folderNameStr = @"";
    NSString *cacheKeyStr = @"";
    for (NSInteger i = 0; i < 3; i++) {
        
        if (i == 0) {
            requestUrl = GET_PROJECT_STATUS_RULE_URL;
            folderNameStr = KProjectStatusCacheFolder;
            cacheKeyStr = KProjectStatusCache;
        } else if (i == 1) {
            requestUrl = GET_INVESTOR_STATUS_RULE_URL;
            folderNameStr = KInvestorStatusCacheFolder;
            cacheKeyStr = KInvestorStatusCache;
        } else {
            requestUrl = GET_PROJECT_CATEGORY_DEFINE_URL;
            folderNameStr = KCategoryDefineCacheFolder;
            cacheKeyStr = KCategoryDefineCache;
        }
        
        [[NetworkManager sharedInstance] postRequest:requestUrl params:params successBlock:^(NSDictionary *dict) {
            if (dict) {
                if ([dict objectForKey:@"data"]) {
                    NSDictionary *info = [NSDictionary dictionaryWithDictionary:[dict objectForKey:@"data"]];
                    if ([requestUrl isEqualToString:GET_PROJECT_STATUS_RULE_URL]) {
                        [[CacheManager sharedInstance].projectStatusDefine removeAllObjects];
                        [[CacheManager sharedInstance].projectStatusDefine addEntriesFromDictionary:info];
                    } else if ([requestUrl isEqualToString:GET_INVESTOR_STATUS_RULE_URL]){
                        [[CacheManager sharedInstance].investorStatusDefine removeAllObjects];
                        [[CacheManager sharedInstance].investorStatusDefine addEntriesFromDictionary:info];
                    } else{
                        [[CacheManager sharedInstance].categoryDefine removeAllObjects];
                        [[CacheManager sharedInstance].categoryDefine addEntriesFromDictionary:info];
                        
                        [[CacheManager sharedInstance].subCategoryDefine removeAllObjects];
                        NSDictionary *categoryDefine = [CacheManager sharedInstance].categoryDefine;
                        if ([categoryDefine objectForKey:@"categories"]) {
                            NSArray *categoriesAry = [categoryDefine objectForKey:@"categories"];
                            for (NSDictionary *subDict in categoriesAry) {
                                NSArray *subCategoriesAry = [subDict objectForKey:@"subCategories"];
                                for (NSDictionary *subDict in subCategoriesAry) {
                                    [[CacheManager sharedInstance].subCategoryDefine setObject:[subDict objectForKey:@"name"]  forKey:[subDict objectForKey:@"id"]];
                                }
                            }
                        }                        
                    }
                    [[PlistCacheManager shareInstance] saveProjectStatusDefineCache:info folderName:folderNameStr cacheKey:cacheKeyStr];
                }
            }
        } failedBlock:^(id object){
            NSLog(@"请求失败");
        }];
    }
}

/**
 * post请求
 */
- (void)postRequest:(NSString *)requestUrl params:(NSDictionary *)params successBlock:(PostRequestSuccessBlock)succesblock failedBlock:(PostRequestFailedBlock)failedBlock{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
    manager.requestSerializer.timeoutInterval = 10;
    
    NSString *str_url = [self.baseUrl stringByAppendingString:requestUrl];
    [manager POST:str_url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        NSDictionary *dict_data = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&error];
        if ([self NetSuccessManage:dict_data]){
            if ([[dict_data objectForKey:@"code"] integerValue] != NETWORK_CODE_SUCCESS) {
                [AlertManager showAlertText:[dict_data objectForKey:@"message"] withCloseSecond:1];
            }
            if (!error) {
                succesblock(dict_data);
            } else {
                failedBlock(error);
            }
        } else {
            NSLog(@"网络出错  %@",responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSDictionary *errorInfo = (NSDictionary *)error.userInfo;
        if ([[errorInfo objectForKey:@"NSLocalizedDescription"] isEqualToString:@"The request timed out."]) {
            [AlertManager showAlertText:@"亲，网络超时！" withCloseSecond:1];
        }
        failedBlock(error);
    }];
}

/**
 * get请求
 */
- (void)getRequest:(NSString *)requestUrl Params:(NSDictionary *)Params successBlock:(GetRequestSuccessBlock)succesblock failedBlock:(GetRequestFailedBlock)failedBlock{
    
    NSMutableDictionary *paramsList = [[NSMutableDictionary alloc] init];
    for (NSInteger i=0; i<Params.count; i++)    {
        NSArray *allKey=Params.allKeys;
        [paramsList setObject:[Params objectForKey:[allKey objectAtIndex:i]] forKey:[allKey objectAtIndex:i]];
    }
    
    if (![self checkNetAndToken]) {
        return;
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSString *str_url = [self.baseUrl stringByAppendingString:requestUrl];
    
    [manager GET:str_url parameters:Params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSError *error;
        NSDictionary *dict_data = [NSJSONSerialization JSONObjectWithData:responseObject
                                                                  options:NSJSONReadingAllowFragments
                                                                    error:&error];
        if ([self NetSuccessManage:dict_data]){
            if (!error) {
                succesblock(dict_data);
            } else {
                failedBlock();
            }
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failedBlock();
    }];
}

@end
