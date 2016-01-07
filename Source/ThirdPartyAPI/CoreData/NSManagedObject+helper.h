//
//  NSManagedObject+helper.h
//  agent
//
//  Created by LiMing on 14-6-24.
//  Copyright (c) 2014年 bangban. All rights reserved.
//



#import <CoreData/CoreData.h>
#import "mmDAO.h"

typedef void(^ListResult)(NSArray* result, NSError *error);
typedef void(^ObjectResult)(id result, NSError *error);
typedef id(^AsyncProcess)(NSManagedObjectContext *ctx, NSString *className);

@interface NSManagedObject (helper)

+(id)createNew;

+(NSError*)save:(OperationResult)handler;

+(NSArray*)filterWith:(NSPredicate *)predicate orderby:(NSArray *)orders offset:(int)offset limit:(int)limit;

+(NSArray*)filter:(NSString *)predicate orderby:(NSArray *)orders offset:(int)offset limit:(int)limit;

+(void)filter:(NSString *)predicate orderby:(NSArray *)orders offset:(int)offset limit:(int)limit on:(ListResult)handler;

+(id)one:(NSString*)predicate;

+(void)one:(NSString*)predicate on:(ObjectResult)handler;

+(void)async:(AsyncProcess)processBlock result:(ListResult)resultBlock;

+(void)delobject:(id)object;

+(void)delAllObject;

@end
