//
//  CommonAPI.h
//  Ethercap
//
//  Created by 小华 on 15/2/11.
//  Copyright (c) 2015年 Robert Dimitrov. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NSDate+Helper.h"
#import "NSDate+Escort.h"
#import "MacroDefinition.h"
#import "CALayer+Additions.h"


@interface CommonAPI : NSObject<UIAlertViewDelegate>

//根据id和storyboard获取viewcontroller
+(UIViewController *)getUIViewControllerForID:(NSString *)controllerID formStoryboard:(NSString *)storyboard;

//从底部弹出选择框
+ (void)popView:(UIView *)view FormView:(UIView *)rootView;
+ (void)inView:(UIView *)view ToView:(UIView *)rootView;



//plist文件读写
+(NSMutableArray *)readArrayFromDocumentPlist:(NSString *)plistName;
+(NSMutableDictionary *)readDictionaryFromDocumentPlist:(NSString *)plistName;

+(NSMutableArray *)readArrayFromLocalPlist:(NSString *)plistName;
+(NSMutableDictionary *)readDictionaryFromLocalPlist:(NSString *)plistName;

+(void)writeArray:(NSArray *)array ToPlist:(NSString *)plistName;
+(void)writeDictionary:(NSDictionary *)dic ToPlist:(NSString *)plistName;



//解析json
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

//sha1加密
+ (NSString *) sha1:(NSString *)input;



//有效性校验
+ (BOOL)isPureInt:(NSString *)string;
+(BOOL) isValidateCarNo:(NSString*) carNo;
+(BOOL) isValidateMobile:(NSString *)mobile;
+(BOOL)isValidateEmail:(NSString *)email;

+(NSString *)intervalSinceNow: (NSString *) theDate;


//转json
+ (NSString *) jsonStringWithDictionary:(NSDictionary *)dictionary;
+ (NSString *) jsonStringWithArray:(NSArray *)array;
+ (NSString *) jsonStringWithString:(NSString *) string;
+ (NSString *) jsonStringWithObject:(id) object;
+ (NSString *)toJsonString:(id)object;

//向右移位取值 将值为1的位数返回
+(NSArray *)shiftRightOperate:(int)value;

#pragma mark callPhone
+ (void)callPhone:(NSString *)number;
#pragma mark weichat
+ (void)weichat:(NSString *)number;
#pragma mark emial
+ (void)emial:(NSString *)number;

//获取中文或英文字符串的第一个字符 大写
+(NSString *)getFirstCharFrom:(NSString *)string;

+(void)setOrientation:(int) orientation;


@end
