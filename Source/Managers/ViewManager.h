//
//  ViewManager.h
//  Calendar
//
//  Created by 小华 on 15/10/20.
//
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "CalendarViewController.h"
#import "LoginViewController.h"

@interface ViewManager : NSObject


+ (ViewManager *)sharedInstance;
-(void)showMainView;


-(void)showLoginView;

-(void)showMainTabView;


-(CalendarViewController *)getScheduleViewController;
-(LoginViewController *)getLoginViewController;

-(AppDelegate *)getAppDelegate;

@end
