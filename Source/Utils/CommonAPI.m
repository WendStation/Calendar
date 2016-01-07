//
//  CommonAPI.m
//  Ethercap
//
//  Created by 小华 on 15/2/11.
//  Copyright (c) 2015年 Robert Dimitrov. All rights reserved.
//

#import "CommonAPI.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import <Security/Security.h>
#import "AppDelegate.h"
#import "AlertManager.h"
#import "pinyin.h"
#import "UIAlertView+Blocks.h"

@implementation CommonAPI


+ (void)popView:(UIView *)view FormView:(UIView *)rootView{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5];//动画时间长度，单位秒，浮点数
    view.frame = CGRectMake(0, rootView.frame.size.height, view.frame.size.width, view.frame.size.height);
    [UIView commitAnimations];
}

+ (void)inView:(UIView *)view ToView:(UIView *)rootView{
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    [UIView setAnimationDuration:0.5];//动画时间长度，单位秒，浮点数
    view.frame = CGRectMake(0, rootView.frame.size.height - view.frame.size.height, view.frame.size.width, view.frame.size.height);
    [UIView commitAnimations];
}

+(NSMutableArray *)readArrayFromDocumentPlist:(NSString *)plistName
{
    NSArray *patharray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path =  [patharray objectAtIndex:0];
    NSString *filepath=[path stringByAppendingPathComponent:plistName];
    //获取此路径下的我们需要的数据（NSArray,NSDictionary,NSString...）
//    return [NSMutableArray arrayWithContentsOfFile:filepath];
    NSData * data = [NSData dataWithContentsOfFile:filepath];
    if (data) {
        return  (NSMutableArray *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    else
    {
        return  nil;
    }
}

+(NSMutableDictionary *)readDictionaryFromDocumentPlist:(NSString *)plistName
{
    NSArray *patharray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path =  [patharray objectAtIndex:0];
    NSString *filepath=[path stringByAppendingPathComponent:plistName];
//    return [NSMutableDictionary dictionaryWithContentsOfFile:filepath];
    
    NSData * data = [NSData dataWithContentsOfFile:filepath];
    if (data) {
        return  (NSMutableDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    else
    {
        return  nil;
    }
}

+(NSMutableArray *)readArrayFromLocalPlist:(NSString *)plistName
{
    NSString *path = [[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"];
    return [NSMutableArray arrayWithContentsOfFile:path];
}

+(NSMutableDictionary *)readDictionaryFromLocalPlist:(NSString *)plistName
{
    NSString *path = [[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"];
    return [NSMutableDictionary dictionaryWithContentsOfFile:path];
}



+(void)writeArray:(NSArray *)array ToPlist:(NSString *)plistName
{
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:array];
    NSArray *patharray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path =  [patharray objectAtIndex:0];
    NSString *filepath=[path stringByAppendingPathComponent:plistName];
    if (![data writeToFile:filepath atomically:YES]) {
        NSLog(@"writeArray ToPlist :%@ error!!!!!!!!!!!!!!!!!!!!!",plistName);
    }
}

+(void)writeDictionary:(NSDictionary *)dic ToPlist:(NSString *)plistName
{
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:dic];
    NSArray *patharray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path =  [patharray objectAtIndex:0];
    NSString *filepath=[path stringByAppendingPathComponent:plistName];
    if (![data writeToFile:filepath atomically:YES]) {
        NSLog(@"writeDictionary ToPlist :%@ error!!!!!!!!!!!!!!!!!!!!!",plistName);
    }
}


+(UIViewController *)getUIViewControllerForID:(NSString *)controllerID formStoryboard:(NSString *)storyboard
{
    UIStoryboard *calendarStoryboard = [UIStoryboard storyboardWithName:storyboard bundle:nil];
    return [calendarStoryboard instantiateViewControllerWithIdentifier:controllerID];
}




+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        [AlertManager showAlertText:@"服务端传输数据解析失败..." withCloseSecond:1];
        return nil;
    }
    return dic;
}

+ (NSString *) sha1:(NSString *)input
{
    const char *cstr = [input cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:input.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, (uint)data.length, digest);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i=0; i<CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}





/*邮箱验证 MODIFIED BY HELENSONG*/
+(BOOL)isValidateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

/*手机号码验证 MODIFIED BY HELENSONG*/
+(BOOL) isValidateMobile:(NSString *)mobile
{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189
     22         */
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
     NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    NSPredicate *regextestphs = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", PHS];
    
    if (([regextestmobile evaluateWithObject:mobile] == YES)
        || ([regextestcm evaluateWithObject:mobile] == YES)
        || ([regextestct evaluateWithObject:mobile] == YES)
        || ([regextestcu evaluateWithObject:mobile] == YES)
        || ([regextestphs evaluateWithObject:mobile] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

/*车牌号验证 MODIFIED BY HELENSONG*/
+(BOOL) isValidateCarNo:(NSString*) carNo
{
    NSString *carRegex = @"^[A-Za-z]{1}[A-Za-z_0-9]{5}$";
    NSPredicate *carTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",carRegex];
    NSLog(@"carTest is %@",carTest);
    return [carTest evaluateWithObject:carNo];
}

+ (BOOL)isPureInt:(NSString *)string
{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}


+(NSString *)intervalSinceNow: (NSString *) theDate
{
    NSDateFormatter *date=[[NSDateFormatter alloc] init];
    [date setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *d=[date dateFromString:theDate];
    
    NSTimeInterval late=[d timeIntervalSince1970]*1;

    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now=[dat timeIntervalSince1970]*1;
    NSString *timeString=@"";
    
    NSTimeInterval cha=late - now;
    BOOL flag = true;
    if (cha < 0) {
        flag = false;
        cha = now - late;
    }
    
    int minite = (int)(cha/60);
    
    if (minite > 60) {
        if (minite%60 != 0) {
            timeString=[NSString stringWithFormat:@"%d小时%d分钟", minite/60, minite%60];
        }
        else
        {
            timeString=[NSString stringWithFormat:@"%d小时", minite/60];
        }
    }
    else
    {
        timeString=[NSString stringWithFormat:@"%d分钟", minite%60];
    }
    
       
    return flag ? [NSString stringWithFormat:@"剩余:%@", timeString] : [NSString stringWithFormat:@"逾期:%@", timeString] ;
}



+(NSString *) jsonStringWithString:(NSString *) string{
    return [NSString stringWithFormat:@"\"%@\"",
            [[string stringByReplacingOccurrencesOfString:@"\n" withString:@"\\n"] stringByReplacingOccurrencesOfString:@"\""withString:@"\\\""]
            ];
}

+(NSString *) jsonStringWithNumber:(NSNumber *) number{
    return [NSString stringWithFormat:@"\"%@\"", number];
}


+(NSString *) jsonStringWithArray:(NSArray *)array{
    NSMutableString *reString = [NSMutableString string];
    [reString appendString:@"["];
    NSMutableArray *values = [NSMutableArray array];
    for (id valueObj in array) {
        NSString *value = [self jsonStringWithObject:valueObj];
        if (value) {
            [values addObject:[NSString stringWithFormat:@"%@",value]];
        }
    }
    [reString appendFormat:@"%@",[values componentsJoinedByString:@","]];
    [reString appendString:@"]"];
    return reString;
}

+(NSString *) jsonStringWithDictionary:(NSDictionary *)dictionary{
    NSArray *keys = [dictionary allKeys];
    NSMutableString *reString = [NSMutableString string];
    [reString appendString:@"{"];
    NSMutableArray *keyValues = [NSMutableArray array];
    for (int i=0; i<[keys count]; i++) {
        NSString *name = [keys objectAtIndex:i];
        id valueObj = [dictionary objectForKey:name];
        NSString *value = [self jsonStringWithObject:valueObj];
        if (value) {
            [keyValues addObject:[NSString stringWithFormat:@"\"%@\":%@",name,value]];
        }
    }
    [reString appendFormat:@"%@",[keyValues componentsJoinedByString:@","]];
    [reString appendString:@"}"];
    return reString;
}



+(NSString *) jsonStringWithObject:(id) object{
    NSString *value = nil;
    if (!object) {
        return value;
    }
    if ([object isKindOfClass:[NSString class]]) {
        value = [self jsonStringWithString:object];
    }else if([object isKindOfClass:[NSDictionary class]]){
        value = [self jsonStringWithDictionary:object];
    }else if([object isKindOfClass:[NSArray class]]){
        value = [self jsonStringWithArray:object];
    }else if([object isKindOfClass:[NSNumber class]])
    {
        value = [self jsonStringWithNumber:object];
    }
    
    return value;
}

+ (NSString *)toJsonString:(id)object {
    NSError *err = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&err];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if (err) {
        NSLog(@"转json失败:%@",err);
        return nil;
    }
    return jsonStr;
}

+(NSArray *)shiftRightOperate:(int)value {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i = 0; i < 20; i ++) {
        int tmp = value >> i & 1;
        if (tmp == 1) {
            [array addObject:[NSNumber numberWithInt:i]];
        }
    }
    return  array;
    
}


+ (void)callPhone:(NSString *)number {
    if (number.length == 0) {
        return;
    }
    [UIAlertView showWithTitle:@"手机号" message:number cancelButtonTitle:@"取消" otherButtonTitles:@[@"拨打", @"复制"] tapBlock:^(UIAlertView * _Nonnull alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            if (![self isValidateMobile:number]) {
                [AlertManager showAlertText:@"号码无效！" withCloseSecond:1];
                return;
            }
            NSString *telUrl = [NSString stringWithFormat:@"telprompt:%@",alertView.message];
            NSURL *url = [[NSURL alloc] initWithString:telUrl];
            [[UIApplication sharedApplication] openURL:url];
        }else if (buttonIndex == 2){
            UIPasteboard *pasterboard = [UIPasteboard generalPasteboard];
            pasterboard.string = alertView.message;
        }
    }];
}

+ (void)weichat:(NSString *)number {
    [UIAlertView showWithTitle:@"微信" message:number cancelButtonTitle:@"取消" otherButtonTitles:@[@"复制"] tapBlock:^(UIAlertView * _Nonnull alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            UIPasteboard *pasterboard = [UIPasteboard generalPasteboard];
            pasterboard.string = alertView.message;
        }
    }];
}

+ (void)emial:(NSString *)number {
    [UIAlertView showWithTitle:@"邮箱" message:number cancelButtonTitle:@"取消" otherButtonTitles:@[@"复制"] tapBlock:^(UIAlertView * _Nonnull alertView, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            UIPasteboard *pasterboard = [UIPasteboard generalPasteboard];
            pasterboard.string = alertView.message;
        }
    }];
}

+(NSString *)getFirstCharFrom:(NSString *)string {
    NSString *source = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (source.length == 0) {
        return @"";
    }
    NSString *first = [[NSString stringWithFormat:@"%c",pinyinFirstLetter([source characterAtIndex:0])] uppercaseString];
    unichar char1 = [source characterAtIndex:0];
    if (char1 < 0x4E00 || char1 > 0x9FFF) {
        first = [source substringToIndex:1];
    }
    return [first uppercaseString];
}

+(void)setOrientation:(int) orientation {
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        [invocation setArgument:&orientation atIndex:2];
        [invocation invoke];
    }
}



@end
