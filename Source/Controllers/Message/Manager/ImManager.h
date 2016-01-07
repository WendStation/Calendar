//
//  ImManager.h
//  Calendar
//
//  Created by 刘花椒 on 15/12/11.
//
//

#import <Foundation/Foundation.h>

@interface ImManager : NSObject

@property (nonatomic, assign) NSInteger mesageRequestCircleSeconds;
@property (nonatomic, assign) NSInteger groupListRequestCircleSeconds;

+ (instancetype)shareInstance;
-(void)onStart;
-(void)onStop;

@end
