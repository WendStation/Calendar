//
//  BaseItem.h
//  Calendar
//
//  Created by 刘花椒 on 15/12/3.
//
//

#import <Foundation/Foundation.h>

@interface BaseItem : NSObject

#pragma mark object --> jsonString
- (NSString *)toJsonString:(id)object;
#pragma mark jsonString --> object
- (id)objectWithJsonString:(NSString *)jsonString;

@end
