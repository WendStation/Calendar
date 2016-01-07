//
//  AlertManager.h
//  Calendar
//
//  Created by 小华 on 15/10/21.
//
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"
#import "ViewManager.h"

typedef void (^alert_action_block)();
@interface AlertManager : NSObject


+ (void)showAlertText:(NSString *)text withCloseSecond:(int)second;
+ (void)showAlertTextWithAss:(NSString *)text withExecutingBlock:(dispatch_block_t)executingBlock withCompletion:(dispatch_block_t)completionBlock;
+ (MBProgressHUD *)getAlertTextWithAss:(NSString *)text;

+ (void)showAlertText:(NSString *)text withTitle:(NSString *)title sureAction:(alert_action_block)sure cancelAction:(alert_action_block)cancel;

+ (void)showAlertText:(NSString *)text withTitle:(NSString *)title sureAction:(alert_action_block)sure;

@end
