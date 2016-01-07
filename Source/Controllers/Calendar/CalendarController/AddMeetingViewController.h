//
//  AddScheduleViewController.h
//  Calendar
//
//  Created by 小华 on 15/10/29.
//
//

#import <UIKit/UIKit.h>

@interface AddMeetingViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *addMember;
@property (nonatomic, strong) Customer *chooseInvestor;

@property (nonatomic, strong) NSMutableDictionary *scheduleData;
@property (nonatomic, assign) BOOL isEditFlag;
@end
