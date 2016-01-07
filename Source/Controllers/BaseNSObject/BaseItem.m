//
//  BaseItem.m
//  Calendar
//
//  Created by 刘花椒 on 15/12/3.
//
//

#import "BaseItem.h"

@implementation BaseItem

-(id)initWithCoder:(NSCoder *)aDecoder{
    if(self = [self init]){
        NSDictionary * propertList = [self propertyList:NO];
        for(NSString * key in propertList.allKeys){
            id codeValue = [aDecoder decodeObjectForKey:key];
            [self setValue:codeValue forKey:key];
        }
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    NSDictionary * propertList = [self propertyList:YES];
    for(NSString * key in propertList.allKeys){
        NSString * value = [propertList objectForKey:key];
        [aCoder encodeObject:value forKey:key];
    }
}

#pragma mark object --> jsonString
- (NSString *)toJsonString:(id)object {
    NSError *err = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&err];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    if (err) {
        NSLog(@"转json失败:%@",err);
        return nil;
    }
    return jsonStr;
}

#pragma mark jsonString --> object
- (id)objectWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    id object = [NSJSONSerialization JSONObjectWithData:jsonData
                 
                                                options:NSJSONReadingMutableContainers
                 
                                                  error:&err];
    
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return object;
}

- (NSDictionary *)propertyList:(BOOL)isIncludeValue
{
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    unsigned int outCount, i;
    //获得某个类的所有属性的拷贝
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    for (i = 0; i<outCount; i++) {
        //获得某一个属性
        objc_property_t property = properties[i];
        
        //获得属性名的字符串
        NSString *propertyName = [[NSString alloc] initWithCString:property_getName(property) encoding:NSUTF8StringEncoding] ;
        
        //获得指定的属性的值
        id propertyValue = [self valueForKey:(NSString *)propertyName];
        if (isIncludeValue) {
            if (propertyValue)
            {
                if([propertyValue isKindOfClass:[BaseItem class]]){
                    NSDictionary * valueDict = [propertyValue propertyList:YES];
                    //保存属性名和属值值到字典中
                    [props setObject:valueDict forKey:propertyName];
                }else if([propertyValue isKindOfClass:[NSArray class]]){
                    NSMutableArray * vArray = [[NSMutableArray alloc] init];
                    for(id value in (NSArray*)propertyValue){
                        NSDictionary * valueDict = [value propertyList:YES];
                        [vArray addObject:valueDict];
                    }
                    [props setObject:vArray forKey:propertyName];
                }else{
                    //保存属性名和属值值到字典中
                    [props setObject:propertyValue forKey:propertyName];
                }
            }
        }
        else{
            //保存空对象到字典中,为了获得所有属性名的列表
            [props setObject:[NSNull null] forKey:propertyName];
        }
    }
    //释放拷贝的属性列表
    free(properties);
    //返回所需要的当前实例的属性字典（如果对象被赋值了，同时返回对象的值）
    return props;
}

@end
