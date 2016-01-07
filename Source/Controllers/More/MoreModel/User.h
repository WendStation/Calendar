//
//  User.h
//  Calendar
//
//  Created by 小华 on 15/10/20.
//
//

#import <Foundation/Foundation.h>
#import "BaseItem.h"

@interface User : BaseItem

@property (copy, nonatomic) NSString *userId;
@property (copy, nonatomic) NSString *accessToken;
@property (copy, nonatomic) NSString *userName;

@end
