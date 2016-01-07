//
//  ScheduleDetailTableViewController.m
//  Calendar
//
//  Created by 小华 on 15/10/27.
//
//

#import "AddScheduleViewController.h"
#import "Customer.h"
#import "ActionSheetDatePicker.h"
#import "CacheManager.h"
#import "ChooseSomeoneViewController.h"
#import "PlaceholderTextView.h"
#import "NSDate+Escort.h"
#import "NetworkManager.h"
#import "SyncSchedule.h"

@interface AddScheduleViewController ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightItem;

@property (nonatomic, strong) NSMutableDictionary *scheduleData;
@property (nonatomic, strong) SyncSchedule *sync;

@end

@implementation AddScheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sync = [[SyncSchedule alloc] init];
    
    self.tableView.estimatedRowHeight = 44;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    tap.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tap];
    
    self.addMember = [[NSMutableArray alloc] init];
    Customer *user = [[CustomerManager sharedInstance] searchUserFromId:[[[CacheManager sharedInstance] userId] integerValue]];
    [self.addMember addObject:user];
    
    self.scheduleData = [[NSMutableDictionary alloc] init];
    [self.scheduleData setObject:@"" forKey:@"comment"];
    [self.scheduleData setObject:@"" forKey:@"location"];
    [self.scheduleData setObject:@"" forKey:@"startTime"];
    [self.scheduleData setObject:@"" forKey:@"endTime"];
    [self.scheduleData setObject:[NSMutableArray array] forKey:@"memberInfo"];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.addMember.count > 0) {
        NSArray *array = (NSArray *)[self.scheduleData objectForKey:@"memberInfo"];
        NSMutableArray *indexArray = [[NSMutableArray alloc] init];
        for (Customer *addUser in self.addMember) {
            BOOL hasExit = NO;
            for (Customer *user in array) {
                if (user.userId == addUser.userId) {
                    hasExit = YES;
                    break;
                }
            }
            if (!hasExit) {
                [indexArray addObject: [NSIndexPath indexPathForRow:array.count + 5 inSection:0]];
                [[self.scheduleData objectForKey:@"memberInfo"] addObject:addUser];
            }
        }
        
        if (indexArray.count > 0) {
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationRight];
            [self.tableView endUpdates];
        }
        [self.addMember removeAllObjects];
    }
    
    
}

-(void)hideKeyboard:(id)sender
{
    [self.view endEditing:YES];
}


- (IBAction)sureBtnClick:(id)sender {
    NSString *start = [self.scheduleData objectForKey:@"startTime"];
    NSString *end = [self.scheduleData objectForKey:@"endTime"];
    
    if (start.length < 10 || end.length < 10 || [[NSDate dateFromString:start] isLaterThanOrEqualDate: [NSDate dateFromString:end]] ) {
        [AlertManager showAlertText:@"时间不合法" withCloseSecond:1];
        return;
    }

    NSArray *member = (NSArray *)[self.scheduleData objectForKey:@"memberInfo"];
    if (!member || member.count == 0) {
        [AlertManager showAlertText:@"日程必须有参与人" withCloseSecond:1];
        return;
    }
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:@"0" forKey:@"scheduleId"];
    [dic setObject:@"0" forKey:@"projectId"];
    [dic setObject:start forKey:@"startTime"];
    [dic setObject:end forKey:@"endTime"];
    [dic setObject:[self.scheduleData objectForKey:@"location"] forKey:@"location"];
    [dic setObject:[self.scheduleData objectForKey:@"comment"] forKey:@"comment"];
    
    [dic setObject:[NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]] forKey:@"localId"];
    [dic setObject:[CacheManager sharedInstance].userId forKey:@"createBy"];
    NSMutableString *string = [[NSMutableString alloc] init];
    for (Customer *user in member) {
        [string appendString:[NSString stringWithFormat:@"%@", user.userId]];
        [string appendString:@","];
    }
    [dic setObject:string forKey:@"userId"];
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:dic, nil];    
    __weak AddScheduleViewController *weakSelf = self;
    [self.sync syncScheduleApi: array withBlock: ^(NSDictionary *response) {
        [AlertManager showAlertText:@"提交成功" withCloseSecond:1];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger memberNum = 0;
    if (self.scheduleData) {
        NSArray *array = (NSArray *)[self.scheduleData objectForKey:@"memberInfo"];
        if (array && array.count > 0) {
            memberNum = array.count;
        }
    }
    
    return 5 + memberNum;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.row < 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell0"];
        UILabel *title = (UILabel *)[cell viewWithTag:1];
        PlaceholderTextView *view = (PlaceholderTextView *)[cell viewWithTag:2];
        view.delegate = self;
        view.placeholder = @"请输入";
        if (indexPath.row == 0) {
            title.text = @"名称";
            view.text = [NSString stringWithFormat:@"%@", [self.scheduleData objectForKey:@"comment"]];
        }
        else {
            title.text = @"地点";
            view.text = [NSString stringWithFormat:@"%@", [self.scheduleData objectForKey:@"location"]];
        }
        
    }
    else if (indexPath.row >= 2 && indexPath.row < 4) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell1"];
        UILabel *title = (UILabel *)[cell viewWithTag:1];
        UILabel *time = (UILabel *)[cell viewWithTag:2];
        if (indexPath.row == 2) {
            title.text = @"开始";
            NSString *start = [NSString stringWithFormat:@"%@", [self.scheduleData objectForKey:@"startTime"]];
            if (start.length > 10) {
                BOOL isChina = [NSDate isInChina];
                if (!isChina) {
                    start = [start stringByAppendingString:@" (北京时间)"];
                }
                time.text = start;
            }
            else {
                time.text = @"点击选择";
            }
        }
        else {
            title.text = @"结束";
            NSString *end = [NSString stringWithFormat:@"%@", [self.scheduleData objectForKey:@"endTime"]];
            if (end.length > 10) {
                BOOL isChina = [NSDate isInChina];
                if (!isChina) {
                    end = [end stringByAppendingString:@" (北京时间)"];
                }
                time.text = end;
            }
            else {
                time.text = @"点击选择";
            }
        }
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectTime:)];
        [time addGestureRecognizer:tap];
    }
    else if (indexPath.row == 4) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell2"];
        UILabel *title = (UILabel *)[cell viewWithTag:1];
        title.text = @"参会人";
    }
    else {
        if ([self.scheduleData objectForKey:@"memberInfo"]) {
            NSArray *array = (NSArray *)[self.scheduleData objectForKey:@"memberInfo"];
            NSInteger index = indexPath.row - 5;
            cell = [tableView dequeueReusableCellWithIdentifier:@"cell3"];
            
            UILabel *name = (UILabel *)[cell viewWithTag:1];
            UILabel *company = (UILabel *)[cell viewWithTag:2];
            UIButton *phone = (UIButton *)[cell viewWithTag:3];
            UIButton *delBtn = (UIButton *)[cell viewWithTag:4];
            UILabel *tips = (UILabel *)[cell viewWithTag:5];
            name.text = @"";
            company.text = @"";
            [delBtn addTarget:self action:@selector(delBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            Customer *user;
            if (index < array.count) {
                user = (Customer *)[array objectAtIndex:index];
                name.text = user.name;
                company.text = user.company;
                [phone addTarget:self action:@selector(callPhone:) forControlEvents:UIControlEventTouchUpInside];
                [delBtn setTitle:[NSString stringWithFormat:@"%@", user.userId] forState:UIControlStateDisabled];
            }
            
            BOOL canEdit = YES;
            if (user) {
                if ([self.scheduleData objectForKey:@"investorInfo"]) {
                    Customer *investor = [self.scheduleData objectForKey:@"investorInfo"];
                    if (investor.userId == user.userId) {
                        canEdit = NO;
                        tips.text = @"投资人不可修改";
                    }
                }
                if ([self.scheduleData objectForKey:@"founderInfo"]) {
                    Customer *founder = [self.scheduleData objectForKey:@"founderInfo"];
                    if (founder.userId == user.userId) {
                        canEdit = NO;
                        tips.text = @"创业者不可修改";
                    }
                }
            }
//            if (array.count == 1) {
//                delBtn.hidden = YES;
//            }
//            else {
              delBtn.hidden = !canEdit;
            //}
            
            tips.hidden = canEdit;
            phone.hidden = !canEdit;
            for (NSLayoutConstraint *constraint in cell.contentView.constraints) {
                if ([constraint.identifier isEqualToString:@"hideDelBtnConstaint"]) {
                    if (canEdit) {
                        constraint.constant = 40;
                    }
                    else {
                        constraint.constant = 0;
                    }
                    break;
                }
            }
        }
    }
    return cell;
}
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 2 || indexPath.row == 3) {
        return indexPath;
    }
    return nil;
}



-(void)delBtnClick:(UIButton *)sender {
    if ([sender titleForState:UIControlStateDisabled]) {
        NSString *userId = [sender titleForState:UIControlStateDisabled];
        if ([userId intValue] > 0) {
            NSArray *array = (NSArray *)[self.scheduleData objectForKey:@"memberInfo"];
            for (Customer *user in array) {
                if ([user.userId intValue] == [userId intValue]) {
                    NSInteger index = [array indexOfObject:user];
                    [[self.scheduleData objectForKey:@"memberInfo"] removeObjectAtIndex:index];
                    [self.tableView beginUpdates];
                    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index + 5 inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
                    [self.tableView endUpdates];
                    break;
                }
            }
        }
    }
}

- (void)callPhone:(id)sender {
    NSArray *array = (NSArray *)[self.scheduleData objectForKey:@"memberInfo"];
    UIButton *btn = (UIButton *)sender;
    CGPoint pos = [btn convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *index = [self.tableView indexPathForRowAtPoint:pos];
    Customer *user = (Customer *)[array objectAtIndex:index.row - 5];
    [self.sync getUserPhoneApi:user.userId type:@"phone" block:^(id object) {
        NSString *phone = (NSString *)object;
        [CommonAPI callPhone:phone];
    }];
}

-(void)selectTime:(UITapGestureRecognizer *)gesture {
    [self hideKeyboard:nil];
    
    
    CGPoint pos = [gesture.view convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *index = [self.tableView indexPathForRowAtPoint:pos];
    NSDate *date = [[NSDate date] dateNextHour];
    NSString *start = [NSString stringWithFormat:@"%@", [self.scheduleData objectForKey:@"startTime"]];
    NSString *end = [NSString stringWithFormat:@"%@", [self.scheduleData objectForKey:@"endTime"]];
    if (index.row == 2)  {
        if (start.length > 10) {
            date = [NSDate dateFromString:start];
        }
    }else if (index.row == 3) {
        if (end.length > 10) {
            date = [NSDate dateFromString:end];
        }
        else if (start.length > 10) {
            date = [[NSDate dateFromString:start] dateByAddingHours:2];
        }
    }
    ActionSheetDatePicker *datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"选择时间" datePickerMode:UIDatePickerModeDateAndTime selectedDate:date target:self action:@selector(timeWasSelected:element:) origin:gesture.view];
    datePicker.minuteInterval = 15;
    [datePicker showActionSheetPicker];
    
}

-(void)timeWasSelected:(NSDate *)selectedTime element:(id)element {
    CGPoint pos = [element convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *index = [self.tableView indexPathForRowAtPoint:pos];
    if (index.row == 2) {
        [self.scheduleData setObject:[selectedTime string] forKey:@"startTime"];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:index] withRowAnimation:UITableViewRowAnimationAutomatic];
    }else if (index.row == 3) {
        [self.scheduleData setObject:[selectedTime string] forKey:@"endTime"];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:index] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}



 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     if ([segue.identifier isEqualToString:@"chooseMemberSegue"]) {
         ChooseSomeoneViewController *controller = (ChooseSomeoneViewController *)segue.destinationViewController;
         controller.isSelectEthercap = YES;
         controller.isMultiSelect = YES;
     }
 }
 


- (void)textViewDidChange:(UITextView *)textView
{
    CGRect bounds = textView.bounds;
    CGSize maxSize = CGSizeMake(bounds.size.width, CGFLOAT_MAX);
    CGSize newSize = [textView sizeThatFits:maxSize];
    if (newSize.height < 20) {
        newSize = CGSizeMake(newSize.width, 20);
    }
    bounds.size = newSize;
    textView.bounds = bounds;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    
    
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    CGPoint pos = [textView convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *index = [self.tableView indexPathForRowAtPoint:pos];
    if (index.row == 0) {
        [self.scheduleData setObject:textView.text forKey:@"comment"];
    }
    else if (index.row == 1) {
        [self.scheduleData setObject:textView.text forKey:@"location"];
    }
}

@end
