//
//  UserManager.h
//  Ethercap
//
//  Created by 小华 on 15/5/14.
//  Copyright (c) 2015年 Robert Dimitrov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Customer.h"

@interface CustomerManager : NSObject

@property (nonatomic, strong) NSMutableArray *ethercapType;
@property (nonatomic, strong) NSMutableArray *investorType;
@property (nonatomic, strong) NSMutableArray *founderType;
@property (nonatomic, strong) NSMutableArray *platformType;
@property (nonatomic, strong) NSMutableArray *xuetangType;

+ (CustomerManager *)sharedInstance;

//获取所有以太资本的员工
-(NSArray *)getAllEthercapMember;
//获取投资人
-(NSArray *)getAllInvestor;
//获取创业者
-(NSArray *)getAllFounder;



//将文件系统中的用户信息迁移到数据库中
-(void)moveUsersToDB:(NSArray *)array;

//同步删除所有用户
-(void)syncRemoveAllUser;

//同步获取用户个数
-(NSInteger)syncGetUserCount;

//更新用户信息
-(void)asyncAddOrUpdateUser:(NSArray *)array withBlock:(dispatch_block_c)block;

//查询用户信息
-(Customer *)searchUserFromId:(NSInteger)userId;
-(NSArray *)searchUsers:(NSString *)info;
-(NSArray *)searchUsersFromCompany:(NSString *)company;
-(NSArray *)searchUsersFromName:(NSString *)name;
-(NSArray *)searchUsersFromCompany:(NSString *)company andContainName:(NSString *)name;
-(NSArray *)searchEthercapColleagueFromNameOrPhone:(NSString *)info;

@end
