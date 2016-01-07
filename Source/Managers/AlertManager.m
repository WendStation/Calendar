//
//  AlertManager.m
//  Calendar
//
//  Created by 小华 on 15/10/21.
//
//

#import "AlertManager.h"
#import "UIAlertView+Blocks.h"

@implementation AlertManager


+ (void)showAlertText:(NSString *)text withCloseSecond:(int)second {
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:[[ViewManager sharedInstance] getAppDelegate].window];
    [[[ViewManager sharedInstance] getAppDelegate].window addSubview:hud];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = text;
    [hud showAnimated:YES whileExecutingBlock:^(void){
        if (second > 0) {
            sleep(second);
        }
    }completionBlock:^(void) {
        if (second > 0) {
            [hud removeFromSuperview];
        }
    }];
}

+ (void)showAlertTextWithAss:(NSString *)text withExecutingBlock:(dispatch_block_t)executingBlock withCompletion:(dispatch_block_t)completionBlock {
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:[[ViewManager sharedInstance] getAppDelegate].window];
    [[[ViewManager sharedInstance] getAppDelegate].window addSubview:hud];
    if (text.length > 0) {
        hud.labelText = text;
    }
    
    [hud showAnimated:YES whileExecutingBlock:^(void){
        if (executingBlock != nil) {
            executingBlock();
        }
    }completionBlock:^(void) {
        if (completionBlock != nil) {
            completionBlock();
        }
    }];
}


+ (MBProgressHUD *)getAlertTextWithAss:(NSString *)text {
    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithWindow:[[ViewManager sharedInstance] getAppDelegate].window];
    [[[ViewManager sharedInstance] getAppDelegate].window addSubview:hud];
    if (text.length > 0) {
        hud.labelText = text;
    }
    return hud;
}

+ (void)showAlertText:(NSString *)text withTitle:(NSString *)title sureAction:(alert_action_block)sure cancelAction:(alert_action_block)cancel {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:title
                                                 message:text
                                                delegate:self
                                       cancelButtonTitle:@"取消"
                                       otherButtonTitles:@"确定", nil];
    
    av.alertViewStyle = UIAlertViewStyleDefault;
    
    av.tapBlock = ^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == alertView.firstOtherButtonIndex && sure) {
            sure();
        } else if (buttonIndex == alertView.cancelButtonIndex && cancel) {
            cancel();
        }
    };
    
    //    av.shouldEnableFirstOtherButtonBlock = ^BOOL(UIAlertView *alertView){
    //        return ([[[alertView textFieldAtIndex:1] text] length] > 0);
    //    };
    
    [av show];
    
    
}


+ (void)showAlertText:(NSString *)text withTitle:(NSString *)title sureAction:(alert_action_block)sure {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:title
                                                 message:text
                                                delegate:self
                                       cancelButtonTitle:@"确定"
                                       otherButtonTitles:nil];
    
    av.alertViewStyle = UIAlertViewStyleDefault;
    
    av.tapBlock = ^(UIAlertView *alertView, NSInteger buttonIndex) {
        if (buttonIndex == alertView.firstOtherButtonIndex && sure) {
            sure();
        }
    };
    [av show];
}

@end
