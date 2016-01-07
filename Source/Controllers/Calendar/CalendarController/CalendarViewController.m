//
//  CalendarViewController.m
//  Calendar
//
//  Created by 小华 on 15/10/19.
//  Copyright © 2015年 Robert Dimitrov. All rights reserved.
//

#import "CalendarViewController.h"
#import "CLWeeklyCalendarView.h"
#import "RDVTabBarController.h"
#import "ViewManager.h"
#import "CacheManager.h"
#import "NetworkManager.h"
#import "ScheduleDetailTableViewController.h"
#import "Customer.h"
#import "SyncSchedule.h"
#import "AddMeetingViewController.h"

@interface CalendarViewController ()<CLWeeklyCalendarViewDelegate>
@property (nonatomic, strong) CLWeeklyCalendarView* calendarView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableTopConstraint;

@property (nonatomic, assign) BOOL scrollEnd;
@property(nonatomic, assign)BOOL isKxMenuHiden;

@property(nonatomic, strong)SyncSchedule *sync;
@end

@implementation CalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(schedulesChanged:) name:@"schedulesChanged" object:nil];
    
    self.isKxMenuHiden = YES;
    _calendarView = [[CLWeeklyCalendarView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width / 7)];
    _calendarView.delegate = self;
    [self.view addSubview:_calendarView];
    
    _tableTopConstraint.constant = _calendarView.frame.size.height;
    _tableView.estimatedRowHeight = 120;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.backgroundColor = BACKGROUND_COLOR;
    _tableView.backgroundView = nil;
    
    self.sync = [[SyncSchedule alloc] init];
    [self.sync syncScheduleApi: nil withBlock: nil];
    
    _scrollEnd = YES;
    
    if (self.scheduleOwner) {
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.title = [NSString stringWithFormat:@"%@的日程", self.scheduleOwner.name];
        //获取缓存的日程信息
        [[CacheManager sharedInstance] refreshScheduleInfo:[NSString stringWithFormat:@"%@", self.scheduleOwner.userId]];
        [self.sync checkOthersScheduleApi:[NSString stringWithFormat:@"%@", self.scheduleOwner.userId]  withBlock: ^(NSDictionary *response) {
            [AlertManager showAlertText:@"获取他人成功" withCloseSecond:1];
        }];
    }
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.rdv_tabBarController.tabBarHidden) {
        [[self rdv_tabBarController] setTabBarHidden:NO animated:NO];
    }
    
}

- (IBAction)newScheduleBtnClick:(id)sender {
    NSArray *menuItems =
    @[
      [KxMenuItem menuItem:@"新增日程"
                     image:[UIImage imageNamed:@"add_schedule"]
                    target:self
                    action:@selector(addSchedule:)],
      
      [KxMenuItem menuItem:@"新增会议"
                     image:[UIImage imageNamed:@"add_meeting"]
                    target:self
                    action:@selector(addMeeting:)]
      ];
    if (self.isKxMenuHiden) {
        [KxMenu showMenuInView:self.view
                      fromRect:CGRectMake(_calendarView.frame.size.width - 50, _calendarView.frame.origin.y , 50, 0)
                     menuItems:menuItems];
        self.isKxMenuHiden = NO;
    }else {
        [KxMenu dismissMenu];
        self.isKxMenuHiden = YES;
    }
    
    [KxMenu setTintColor:BLUE_COLOR];
    [KxMenu setTitleFont:[UIFont systemFontOfSize:17]];
}

- (void) addSchedule:(id)sender
{
    self.isKxMenuHiden = YES;
    [self performSegueWithIdentifier:@"addScheduleSegue" sender:self];
}

- (void) addMeeting:(id)sender
{
    self.isKxMenuHiden = YES;
    [self performSegueWithIdentifier:@"addMeetingSegue" sender:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if([segue.identifier isEqualToString:@"addMeetingSegue"]) {
        AddMeetingViewController *controller = (AddMeetingViewController *)segue.destinationViewController;
        controller.isEditFlag = YES;
    }
    else {
        NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
        if (indexPath) {
            NSDate *date = [[CacheManager sharedInstance].scheduleStartDate dateByAddingDays:indexPath.section];
            NSString *key = [date stringWithFormat:@"yyyy-MM-dd"];
            NSArray *array = [[CacheManager sharedInstance].localScheduleData objectForKey:key];
            if (array && array.count > 0 && indexPath.row < array.count) {
                if ([segue.identifier isEqualToString:@"scheduleDetailSegue"] && indexPath) {
                    ScheduleDetailTableViewController *controller = (ScheduleDetailTableViewController *)segue.destinationViewController;
                    controller.scheduleData = [array objectAtIndex:indexPath.row];
                }
                else if([segue.identifier isEqualToString:@"meetingDetailSegue"]) {
                    AddMeetingViewController *controller = (AddMeetingViewController *)segue.destinationViewController;
                    controller.isEditFlag = NO;
                    controller.scheduleData = [array objectAtIndex:indexPath.row];
                }
            }
            
        }
    }
    
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
}



#pragma mark - CLWeeklyCalendarViewDelegate
-(NSDictionary *)CLCalendarBehaviorAttributes
{
    return @{
             CLCalendarWeekStartDay : @1,                 //Start Day of the week, from 1-7 Mon-Sun -- default 1
             CLCalendarBackgroundImageColor: [UIColor whiteColor],
             CLCalendarDayTitleTextColor: BLACK_COLOR,
             };
}



-(void)dailyCalendarViewDidSelect:(NSDate *)date
{
//    NSLog(@"dailyCalendarViewDidSelect:%@  %@", date,  [CacheManager sharedInstance].scheduleStartDate);
    //You can do any logic after the view select the date
    if ([self numberOfSectionsInTableView:self.tableView] == 1 || [CacheManager sharedInstance].scheduleStartDate == nil || [CacheManager sharedInstance].scheduleEndDate == nil) {
        return;
    }
    
    NSInteger section = 0;
    if ([date isEarlierThanDate:[CacheManager sharedInstance].scheduleStartDate]) {
        if (self.rdv_tabBarController.selectedIndex == SCHEDULE_TAB_INDEX && self.navigationController.viewControllers.count == 1) {
            [AlertManager showAlertText:[NSString stringWithFormat:@"%@ 前无日程", [[CacheManager sharedInstance].scheduleStartDate stringWithFormat:@"M月d日"]] withCloseSecond:1];
        }
        section = 0;
    }
    else if ([[date dateAtStartOfDay] isLaterThanDate:[CacheManager sharedInstance].scheduleEndDate]) {
        if (self.rdv_tabBarController.selectedIndex == SCHEDULE_TAB_INDEX && self.navigationController.viewControllers.count == 1) {
            [AlertManager showAlertText:[NSString stringWithFormat:@"%@ 后无日程", [[CacheManager sharedInstance].scheduleEndDate stringWithFormat:@"M月d日"]] withCloseSecond:1];
        }
        //section = [self numberOfSectionsInTableView:self.tableView] - 1;
        section = [date daysAfterDate:[CacheManager sharedInstance].scheduleStartDate];
    }
    else if ([self getScheduleCountForDate:[date stringWithFormat:@"yyyy-MM-dd"]] > 0) {
        section = [date daysAfterDate:[CacheManager sharedInstance].scheduleStartDate];
    }
    if (section >= 0) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:section];
        [self.tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:NO];
    }
    
}

-(void)schedulesChanged:(NSNotification *)notification
{
//    NSLog(@"schedulesChangedDelegate:%@--%@", [CacheManager sharedInstance].scheduleStartDate, [CacheManager sharedInstance].scheduleEndDate);
    [self.tableView reloadData];
    [self.calendarView setNeedsDisplay];
    [self dailyCalendarViewDidSelect:self.calendarView.selectedDate];
}

- (NSInteger)getScheduleCountForDate:(NSString *)date {
    NSArray *array = [[CacheManager sharedInstance].localScheduleData objectForKey:date];
    if (array) {
        return array.count;
    }
    else {
        return 1;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[CacheManager sharedInstance].scheduleStartDate daysBeforeDate:[CacheManager sharedInstance].scheduleEndDate] + 31;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDate *date = [[CacheManager sharedInstance].scheduleStartDate dateByAddingDays:section];
    
    return [self getScheduleCountForDate:[date stringWithFormat:@"yyyy-MM-dd"]];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 34;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 34)];
    
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(4, 0, self.tableView.frame.size.width, 35)];
    headerLabel.backgroundColor = [UIColor whiteColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:15.0];
    if ([CacheManager sharedInstance].scheduleStartDate == nil || [CacheManager sharedInstance].scheduleEndDate == nil) {
        headerLabel.text = @"暂时无日程";
        headerLabel.textColor = LIGHTGRAY_COLOR;
        headerView.backgroundColor = [UIColor whiteColor];
    }
    else {
        NSDate *date = [[CacheManager sharedInstance].scheduleStartDate dateByAddingDays:section];
        NSArray *array = [[CacheManager sharedInstance].localScheduleData objectForKey:[date stringWithFormat:@"yyyy-MM-dd"]];
        if (array && array.count > 0) {
            headerLabel.text = [NSString stringWithFormat:@"%@  %@", [date stringWithFormat:@"M月d日"], [date weekDes]];
            headerLabel.textColor = BLACK_COLOR;
            headerView.backgroundColor = BLUE_COLOR;
        }
        else {
            headerLabel.text = [NSString stringWithFormat:@"%@  %@  当日无日程", [date stringWithFormat:@"M月d日"], [date weekDes]];
            headerLabel.textColor = LIGHTGRAY_COLOR;
            headerView.backgroundColor = [UIColor whiteColor];
        }
    }
    
    [headerView addSubview:headerLabel];
    
//    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(0, 33, self.tableView.frame.size.width, 1)];
//    line.image = [UIImage imageNamed:@"line"];
//    [headerView addSubview:line];
    return headerView;
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    NSDate *date = [[CacheManager sharedInstance].scheduleStartDate dateByAddingDays:indexPath.section];
    NSString *key = [date stringWithFormat:@"yyyy-MM-dd"];
    NSArray *array = [[CacheManager sharedInstance].localScheduleData objectForKey:key];
    if (array && array.count > 0) {
        NSDictionary *dic = [array objectAtIndex:indexPath.row];
        if (dic) {
            if ([dic objectForKey:@"noneSchedule"]) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"cell0"];
                UILabel *des = (UILabel *)[cell viewWithTag:1];
                des.text = [NSString stringWithFormat:@"%@", [dic objectForKey:@"noneScheduleDes"]];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            else {
                BOOL hideLine = NO;
                if (indexPath.row + 1 < array.count) {
                    NSDictionary *next = [array objectAtIndex:indexPath.row + 1];
                    if ([next objectForKey:@"noneSchedule"]) {
                        hideLine = YES;
                    }
                }
                
                cell = [tableView dequeueReusableCellWithIdentifier:@"cell1"];
                
                UILabel *time = (UILabel *)[cell viewWithTag:1];
                UILabel *title = (UILabel *)[cell viewWithTag:2];
                UILabel *location = (UILabel *)[cell viewWithTag:3];
                UILabel *founderCompany = (UILabel *)[cell viewWithTag:4];
                UILabel *founderName = (UILabel *)[cell viewWithTag:5];
                UIButton *founderPhone = (UIButton *)[cell viewWithTag:6];
                UILabel *customerCompany = (UILabel *)[cell viewWithTag:7];
                UILabel *customerName = (UILabel *)[cell viewWithTag:8];
                UIButton *customerPhone = (UIButton *)[cell viewWithTag:9];
                UILabel *line = (UILabel *)[cell viewWithTag:10];
                
                NSDate *startTime = [dic objectForKey:@"startTime"];
                NSDate *endTime = [dic objectForKey:@"endTime"];
                NSString *start = [startTime stringWithFormat:@"HH:mm"];
                NSString *end = [endTime stringWithFormat:@"HH:mm"];
                time.text = [NSString stringWithFormat:@"%@-%@",start,end];
                title.text = [NSString stringWithFormat:@"%@",[dic objectForKey:@"comment"]];
                location.text = [NSString stringWithFormat:@"%@",[dic objectForKey:@"location"]];
                
                NSString *company1 = @"";
                NSString *userName1 = @"";
                NSString *company2 = @"";
                NSString *userName2 = @"";
                
                if ([dic objectForKey:@"investorInfo"]) {
                    Customer *investor = (Customer *)[dic objectForKey:@"investorInfo"];
                    company1 = investor.company;
                    userName1 = investor.name;
                }
                if ([dic objectForKey:@"founderInfo"]) {
                    Customer *founder = (Customer *)[dic objectForKey:@"founderInfo"];
                    company2 = founder.company;
                    userName2 = founder.name;
                }
                
                int phoneHeight = hideLine ? 0 : 4;
                if (![company1 isEqualToString:@"(null)"] && company1.length > 0) {
                    founderCompany.text = company1;
                    phoneHeight = hideLine ? 32 : 36;
                }
                else {
                    founderCompany.text = @" ";
                }
                if (![userName1 isEqualToString:@"(null)"] && userName1.length > 0) {
                    founderName.text = userName1;
                    phoneHeight = hideLine ? 32 : 36;
                    founderPhone.hidden = NO;
                    [founderPhone addTarget:self action:@selector(callPhone:) forControlEvents:UIControlEventTouchUpInside];
                }
                else {
                    founderName.text = @"";
                    founderPhone.hidden = YES;
                }
               
                if (![company2 isEqualToString:@"(null)"] && company2.length > 0) {
                    customerCompany.text = company2;
                    phoneHeight = hideLine ? 64 : 68;
                }
                else {
                    customerCompany.text = @" ";
                }
                if (![userName2 isEqualToString:@"(null)"] && userName2.length > 0) {
                    customerName.text = userName2;
                    phoneHeight = hideLine ? 64 : 68;
                    customerPhone.hidden = NO;
                    [customerPhone addTarget:self action:@selector(callPhone:) forControlEvents:UIControlEventTouchUpInside];
                }
                else {
                    customerName.text = @"";
                    customerPhone.hidden = YES;
                }
                for (NSLayoutConstraint *constraint in cell.contentView.constraints) {
                    if ([constraint.identifier isEqualToString:@"phoneHeight"]) {
                        constraint.constant = phoneHeight;
                        break;
                    }
                }
                
                line.hidden = hideLine;
                cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            }
        }        
    }
    if (cell == nil) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell2"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.scheduleOwner) {
        return;
    }
    NSDate *date = [[CacheManager sharedInstance].scheduleStartDate dateByAddingDays:indexPath.section];
    NSString *key = [date stringWithFormat:@"yyyy-MM-dd"];
    NSArray *array = [[CacheManager sharedInstance].localScheduleData objectForKey:key];
    NSMutableDictionary *dic = [array objectAtIndex:indexPath.row];
    if (![dic objectForKey:@"noneSchedule"]) {
        int meetingId = [[dic objectForKey:@"meetingId"] intValue];
        if (meetingId && meetingId > 0) {
            [self performSegueWithIdentifier:@"meetingDetailSegue" sender:self];
        }
        else {
            [self performSegueWithIdentifier:@"scheduleDetailSegue" sender:self];
        }
    }    
}

//允许 Menu菜单
- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDate *date = [[CacheManager sharedInstance].scheduleStartDate dateByAddingDays:indexPath.section];
    NSString *key = [date stringWithFormat:@"yyyy-MM-dd"];
    NSArray *array = [[CacheManager sharedInstance].localScheduleData objectForKey:key];
    if (array && array.count > 0) {
        NSDictionary *dic = [array objectAtIndex:indexPath.row];
        if (dic && ![dic objectForKey:@"noneSchedule"]) {
            return YES;
        }
    }
    return NO;
}

//每个cell都会点击出现Menu菜单
- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(copy:)) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(copy:)) {
        NSDate *date = [[CacheManager sharedInstance].scheduleStartDate dateByAddingDays:indexPath.section];
        NSString *key = [date stringWithFormat:@"yyyy-MM-dd"];
        NSArray *array = [[CacheManager sharedInstance].localScheduleData objectForKey:key];
        NSDictionary *dic = [array objectAtIndex:indexPath.row];
        
        NSDate *startTime = [dic objectForKey:@"startTime"];
        NSDate *endTime = [dic objectForKey:@"endTime"];
        NSString *start = [startTime stringWithFormat:@"HH:mm"];
        NSString *end = [endTime stringWithFormat:@"HH:mm"];
        NSString *time = [NSString stringWithFormat:@"%@-%@",start,end];
        NSString *title = [NSString stringWithFormat:@"%@",[dic objectForKey:@"comment"]];
        NSString *location = [NSString stringWithFormat:@"%@",[dic objectForKey:@"location"]];
        NSString *company1 = @"";
        NSString *userName1 = @"";
        NSString *company2 = @"";
        NSString *userName2 = @"";
        if ([dic objectForKey:@"investorInfo"]) {
            Customer *investor = (Customer *)[dic objectForKey:@"investorInfo"];
            company1 = investor.company;
            userName1 = investor.name;
        }
        if ([dic objectForKey:@"founderInfo"]) {
            Customer *founder = (Customer *)[dic objectForKey:@"founderInfo"];
            company2 = founder.company;
            userName2 = founder.name;
        }
        [UIPasteboard generalPasteboard].string = [NSString stringWithFormat:@"%@/%@/%@/%@/%@/%@/%@",time,title,location,company1,userName1,company2,userName2];
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _scrollEnd = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    _scrollEnd = YES;
    [NSTimer scheduledTimerWithTimeInterval:0.7 target:self selector:@selector(selectedDateChanged) userInfo:nil repeats:NO];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        _scrollEnd = YES;
        [NSTimer scheduledTimerWithTimeInterval:0.7 target:self selector:@selector(selectedDateChanged) userInfo:nil repeats:NO];
    }
    
}


-(void)selectedDateChanged {
    if (!_scrollEnd || [CacheManager sharedInstance].scheduleStartDate == nil || [CacheManager sharedInstance].scheduleEndDate == nil) {
        return;
    }
    CGPoint point = [self.tableView convertPoint:CGPointMake(0, self.tableView.frame.origin.y + 20) fromView:self.view];
    NSIndexPath *index = [self.tableView indexPathForRowAtPoint:point];
    NSDate *date = [[CacheManager sharedInstance].scheduleStartDate dateByAddingDays:index.section];
    if (![date isEqualToDateIgnoringTime:[self.calendarView selectedDate]]) {
        [self.calendarView redrawToDate:date];
    }
}


- (void)callPhone:(id)sender {
    UIButton *btn = (UIButton *)sender;
    CGPoint pos = [btn convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *index = [self.tableView indexPathForRowAtPoint:pos];
    NSDate *date = [[CacheManager sharedInstance].scheduleStartDate dateByAddingDays:index.section];
    NSString *key = [date stringWithFormat:@"yyyy-MM-dd"];
    NSArray *array = [[CacheManager sharedInstance].localScheduleData objectForKey:key];
    NSDictionary *dic = [array objectAtIndex:index.row];
    switch (btn.tag) {
        case 6:
            if ([dic objectForKey:@"investorInfo"]) {
                Customer *investor = (Customer *)[dic objectForKey:@"investorInfo"];
                [self.sync getUserPhoneApi:investor.userId type:@"phone" block:^(id object) {
                    NSString *phone = (NSString *)object;
                    [CommonAPI callPhone:phone];
                }];
            }
            break;
        case 9:
            if ([dic objectForKey:@"founderInfo"]) {
                Customer *founder = (Customer *)[dic objectForKey:@"founderInfo"];
                [self.sync getUserPhoneApi:founder.userId type:@"phone" block:^(id object) {
                    NSString *phone = (NSString *)object;
                    [CommonAPI callPhone:phone];
                }];
            }
            break;
        default:
            break;
    }
}

@end
