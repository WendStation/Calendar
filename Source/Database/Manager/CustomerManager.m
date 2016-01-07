//
//  UserManager.m
//  Ethercap
//
//  Created by 小华 on 15/5/14.
//  Copyright (c) 2015年 Robert Dimitrov. All rights reserved.
//

#import "CustomerManager.h"
#import "pinyin.h"


@implementation CustomerManager


+ (CustomerManager *)sharedInstance
{
    static CustomerManager *str;
    @synchronized(self){
        if (str==nil) {
            str = [[CustomerManager alloc] init];
            str.ethercapType = [[NSMutableArray alloc] init];
            str.investorType = [[NSMutableArray alloc] init];
            str.founderType = [[NSMutableArray alloc] init];
            str.platformType = [[NSMutableArray alloc] init];
            str.xuetangType = [[NSMutableArray alloc] init];
            
            for (int type = 0; type < 100; type ++) {
                NSNumber *tmp = [NSNumber numberWithInt: type];
                if ( (type & 1) == 1) {
                    [str.ethercapType addObject:tmp];
                }
                if ( (type & 2) == 2) {
                    [str.investorType addObject:tmp];
                }
                if ( (type & 4) == 4) {
                    [str.founderType addObject:tmp];
                }
                if ( (type & 8) == 8) {
                    [str.platformType addObject:tmp];
                }
                if ( (type & 16) == 16) {
                    [str.xuetangType addObject:tmp];
                }
            }
        }
        return str;
    }
}

-(void)addUserfromDictionary:(NSDictionary *)dic {
    if ([dic objectForKey:@"userId"] && [dic objectForKey:@"name"]) {
        NSString *name = [dic objectForKey:@"name"];
        int userId = [[dic objectForKey:@"userId"] intValue];
        if (name.length > 0 && userId > 0) {
            Customer *info = [Customer createNew];
            [self updateUser:info fromDictionary:dic];
        }
    }
}


-(void)updateUser:(Customer *)user fromDictionary:(NSDictionary *)dic {
    if ([dic objectForKey:@"name"] && [dic objectForKey:@"userId"] && user) {
        user.name = [dic objectForKey:@"name"];
        user.userId = [NSNumber numberWithInt:[[dic objectForKey:@"userId"] intValue]];
        user.company = [dic objectForKey:@"company"];
        user.phone = [dic objectForKey:@"phone"];
        user.position = [dic objectForKey:@"position"];
        if ([dic objectForKey:@"type"]) {
            user.type = [NSNumber numberWithInt:[[dic objectForKey:@"type"] intValue]];
        }
    }
    else {
        NSLog(@"updateUser error:%@", dic);
    }
}

NSInteger nickNameSort(id user1, id user2, void *context)
{
    Customer * u1 = (Customer *)user1;
    Customer * u2 = (Customer *)user2;
    NSString *name1 = [u1.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *name2 = [u2.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (name1.length == 0 && name2.length != 0) {
        return NSOrderedAscending;
    }
    else if (name1.length != 0 && name2.length == 0) {
        return NSOrderedDescending;
    }
    else if (name1.length == 0 && name2.length == 0) {
        return NSOrderedSame;
    }
    
    NSString *u1First = [[NSString stringWithFormat:@"%c",pinyinFirstLetter([name1 characterAtIndex:0])] uppercaseString];
    NSString *u2First = [[NSString stringWithFormat:@"%c",pinyinFirstLetter([name2 characterAtIndex:0])] uppercaseString];
    unichar char1 = [name1 characterAtIndex:0];
    unichar char2 = [name2 characterAtIndex:0];
    if (char1 < 0x4E00 || char1 > 0x9FFF) {
        u1First = [[name1 substringToIndex:1] uppercaseString];
    }
    if (char2 < 0x4E00 || char2 > 0x9FFF) {
        u2First = [[name2 substringToIndex:1] uppercaseString];
    }
    return  [u1First compare:u2First];
}




-(NSArray *)getAllEthercapMember {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type IN %@", self.ethercapType];
    NSMutableArray *array = [NSMutableArray arrayWithArray:[Customer filterWith:predicate orderby:@[@"userId"] offset:0 limit:0]];
    if (array) {
        for (Customer *user in array) {
            if (!([[NetworkManager sharedInstance].baseUrl isEqualToString:BASE_NETWORK_URL_ADMIN] && ([user.name containsString:@"测试"] || [user.name containsString:@"test"]))) {
                [result addObject:user];
            }
        }
    }
    return [result sortedArrayUsingFunction:nickNameSort context:nil];
}



-(void)moveUsersToDB:(NSArray *)array {
    
    NSLog(@"##############moveUsersToDB:%lu################", (unsigned long)array.count);
    for (NSDictionary *new in array) {
        [self addUserfromDictionary:new];
    }
    [[mmDAO instance] save:^(NSError *error) {
        if (error) {
            NSLog(@"!!!!!!!!!!!!!!!!!!moveUsersToDB save error:%@", error.description);
        }
    }];
    
    NSLog(@"##############moveUsersToDB end################");
}

-(void)syncRemoveAllUser {
    
    NSArray *array = [Customer filter:nil orderby:@[@"userId"] offset:0 limit:0];
    NSLog(@"##############syncRemoveAllUser before:%lu################", (unsigned long)array.count);
    for (id obj in array) {
        [[mmDAO instance].mainObjectContext deleteObject:obj];
    }
    [[mmDAO instance] save:^(NSError *error) {
        if (error) {
            NSLog(@"!!!!!!!!!!!!!!!!!!moveUsersToDB save error:%@", error.description);
        }
    }];
    //NSLog(@"##############syncRemoveAllUser after:%lu################", (unsigned long)[Customer filter:nil orderby:@[@"userId"] offset:0 limit:0].count);
}

-(NSInteger)syncGetUserCount {
    return [Customer filter:nil orderby:@[@"userId"] offset:0 limit:0].count;
}


-(void)asyncAddOrUpdateUser:(NSArray *)array withBlock:(dispatch_block_c)block {
    //NSLog(@"##############addOrUpdateUser start:%ld################", array.count);
    
    [Customer async:^id(NSManagedObjectContext *ctx, NSString *className) {
        NSMutableArray *objArray = [[NSMutableArray alloc] init];
        
        NSMutableArray *userIdArray = [[NSMutableArray alloc] init];
        for (NSDictionary* info in array) {
            if ([info objectForKey:@"userId"] && [info objectForKey:@"name"]) {
                NSString *name = [info objectForKey:@"name"];
                int userId = [[info objectForKey:@"userId"] intValue];
                if (userId > 0 && name.length > 0) {
                    [userIdArray addObject:[NSNumber numberWithInt:userId]];
                }
            }
        }
        if (userIdArray.count > 0) {
            NSFetchRequest *request = [NSFetchRequest fetchRequestWithManagedObjectContext:ctx EntityName:className SortByAttributeName:@"userId" Predicate:[NSPredicate predicateWithFormat:@"userId IN %@",userIdArray]];
            NSError *error = nil;
            NSArray *dataArray = [ctx executeFetchRequest:request error:&error];
            if (error) {
                [objArray addObject:error];
            }else{
                [objArray addObjectsFromArray:dataArray];
            }

        }
        
        return objArray;
    } result:^(NSArray *results, NSError *error) {
        
        if (error || !results) {
            NSLog(@"!!!!!!!!!!!!!!!!!!!addOrUpdateUser error!!!!!!!!!!!!!!!!!!!");
            return;
        }
        
        NSMutableDictionary *objDic = [[NSMutableDictionary alloc] init];
        for (id result in results) {
            if ([result isKindOfClass:[NSError class]]) {
                NSError *tmpErr = (NSError *)result;
                NSLog(@"!!!!!!!!!!!!!!!!!!!addOrUpdateUser error:%@", tmpErr.description);
            }
            else if ([result isKindOfClass:[Customer class]]) {
                Customer *user = (Customer *)result;
                [objDic setObject:user forKey:user.userId];
            }
        }
        for (NSDictionary* info in array) {
            NSNumber *userId = [NSNumber numberWithInt:[[info objectForKey:@"userId"] intValue]];
            if ([objDic objectForKey:userId]) {
                [self updateUser:[objDic objectForKey:userId] fromDictionary:info];
            }
            else {
                [self addUserfromDictionary:info];
            }
        }
        
        [[mmDAO instance] save:^(NSError *error) {
            if (error) {
                NSLog(@"!!!!!!!!!!!!!!!!!!addOrUpdateUser save error:%@", error.description);
            }
            else {
                //NSLog(@"##############addOrUpdateUser end:%ld################", array.count);
                if (block) {
                    block();
                }
            }
        }];
        
        
    }];
    
    
}


-(Customer *)searchUserFromId:(NSInteger)userId {
    NSArray *results = [Customer filter:[NSString stringWithFormat:@"userId=%ld",(long)userId] orderby:@[@"userId"] offset:0 limit:1];
    if ([results count] > 0) {
        return [results objectAtIndex:0];
    }
    return nil;
}

-(NSArray *)searchUsers:(NSString *)info {
    NSMutableArray *result = [NSMutableArray arrayWithArray:[Customer filter:[NSString stringWithFormat:@"company like '*%@*' OR name like '*%@*' OR position like '*%@*' OR phone like '*%@*'",info,info,info,info] orderby:@[@"userId"] offset:0 limit:0]];
    return [result sortedArrayUsingFunction:nickNameSort context:nil];
}

-(NSArray *)searchUsersFromCompany:(NSString *)company {
    NSMutableArray *result = [NSMutableArray arrayWithArray:[Customer filter:[NSString stringWithFormat:@"company like '*%@*'",company] orderby:@[@"userId"] offset:0 limit:0]];
    return [result sortedArrayUsingFunction:nickNameSort context:nil];
}

-(NSArray *)searchUsersFromName:(NSString *)name {
    NSMutableArray *result = [NSMutableArray arrayWithArray:[Customer filter:[NSString stringWithFormat:@"name like '*%@*'",name] orderby:@[@"userId"] offset:0 limit:0]];
    return [result sortedArrayUsingFunction:nickNameSort context:nil];
}

-(NSArray *)searchUsersFromCompany:(NSString *)company andContainName:(NSString *)name {
    NSMutableArray *result = [NSMutableArray arrayWithArray:[Customer filter:[NSString stringWithFormat:@"company like '*%@*' AND name like '*%@*'",company,name] orderby:@[@"userId"] offset:0 limit:0]];
    return [result sortedArrayUsingFunction:nickNameSort context:nil];
}

-(NSArray *)searchEthercapColleagueFromNameOrPhone:(NSString *)info {
    NSArray *ethercaps = [self getAllEthercapMember];
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (Customer *user in ethercaps) {
        if ([user.name containsString:info] || [user.phone containsString:info]) {
            [result addObject:user];
        }
    }
    return result;
}

-(NSArray *)getAllInvestor {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type IN %@", self.investorType];
    NSMutableArray *result = [NSMutableArray arrayWithArray:[Customer filterWith:predicate orderby:@[@"userId"] offset:0 limit:0]];
    return [result sortedArrayUsingFunction:nickNameSort context:nil];
}

-(NSArray *)getAllFounder {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type IN %@", self.founderType];
    NSMutableArray *result = [NSMutableArray arrayWithArray:[Customer filterWith:predicate orderby:@[@"userId"] offset:0 limit:0]];
    return [result sortedArrayUsingFunction:nickNameSort context:nil];
}


@end
