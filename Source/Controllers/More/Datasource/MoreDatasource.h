//
//  MoreDatasource.h
//  Calendar
//
//  Created by 刘花椒 on 15/12/21.
//
//

#import <Foundation/Foundation.h>

@interface MoreDatasource : NSObject

- (void)postLogin:(NSString *)userName password:(NSString *)password succeed:(PostSucceed)succeed failed:(PostFailed)failed;

@end
