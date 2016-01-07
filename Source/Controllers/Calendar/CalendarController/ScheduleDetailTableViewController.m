//
//  ScheduleDetailTableViewController.m
//  Calendar
//
//  Created by 小华 on 15/10/27.
//
//

#import "ScheduleDetailTableViewController.h"
#import "Customer.h"
#import "ActionSheetDatePicker.h"
#import "CacheManager.h"
#import "ChooseSomeoneViewController.h"
#import "NetworkManager.h"
#import "SyncSchedule.h"

@interface ScheduleDetailTableViewController ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UINavigationItem *titleItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightItem;

@property (assign, nonatomic) BOOL editFlag;

@property (nonatomic, strong) SyncSchedule *sync;
@end

@implementation ScheduleDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _editFlag = NO;
    
    self.tableView.backgroundColor = BACKGROUND_COLOR;
    self.tableView.backgroundView = nil;
    
    self.tableView.estimatedRowHeight = 50;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    tap.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tap];
    
    self.addMember = [[NSMutableArray alloc] init];
    self.sync = [[SyncSchedule alloc] init];
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


- (IBAction)rightBarItemClick:(id)sender {
    [self.view endEditing:YES];
    if (!_editFlag) {
        _editFlag = !_editFlag;
        _titleItem.title = @"编辑日程";
        _rightItem.title = @"确定";
        [self.tableView reloadData];
    }
    else {
        NSDate *start = [self.scheduleData objectForKey:@"startTime"];
        NSDate *end = [self.scheduleData objectForKey:@"endTime"];
        
        if (start== nil || end == nil || [start isLaterThanOrEqualDate: end] ) {
            [AlertManager showAlertText:@"时间不合法" withCloseSecond:1];
            return;
        }
        
        NSArray *member = (NSArray *)[self.scheduleData objectForKey:@"memberInfo"];
        if (!member || member.count == 0) {
            [AlertManager showAlertText:@"日程必须有参与人" withCloseSecond:1];
            return;
        }
        
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setObject:[self.scheduleData objectForKey:@"localId"] forKey:@"localId"];
        [dic setObject:[self.scheduleData objectForKey:@"createBy"] forKey:@"createBy"];
        [dic setObject:[self.scheduleData objectForKey:@"scheduleId"] forKey:@"scheduleId"];
        [dic setObject:@"0" forKey:@"projectId"];
        [dic setObject:start.string forKey:@"startTime"];
        [dic setObject:end.string forKey:@"endTime"];
        [dic setObject:[self.scheduleData objectForKey:@"location"] forKey:@"location"];
        [dic setObject:[self.scheduleData objectForKey:@"comment"] forKey:@"comment"];
        
        
        NSMutableString *string = [[NSMutableString alloc] init];
        for (Customer *user in member) {
            [string appendString:[NSString stringWithFormat:@"%@", user.userId]];
            [string appendString:@","];
        }
        [dic setObject:string forKey:@"userId"];
        
        NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:dic, nil];
        __weak ScheduleDetailTableViewController *weakSelf = self;
        [self.sync syncScheduleApi: array withBlock:^(NSDictionary *response) {
            [AlertManager showAlertText:@"修改成功" withCloseSecond:1];
            [weakSelf.navigationController popViewControllerAnimated:YES];
            
        }];
        
    }
    
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
//    if (self.editFlag) {
//        memberNum = memberNum + 1;
//    }
    return 5 + memberNum;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.row < 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell0"];
        UILabel *title = (UILabel *)[cell viewWithTag:1];
        UITextView *view = (UITextView *)[cell viewWithTag:2];
        view.delegate = self;
//        view.layer.borderWidth = self.editFlag? 1 : 0;
        view.editable = self.editFlag;
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
            NSDate *date = [self.scheduleData objectForKey:@"startTime"];
            time.text = date.string;
        }
        else {
            title.text = @"结束";
            NSDate *date = [self.scheduleData objectForKey:@"endTime"];
            time.text = date.string;
        }
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectTime:)];
        [time addGestureRecognizer:tap];
    }
    else if (indexPath.row == 4) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell2"];
        UILabel *title = (UILabel *)[cell viewWithTag:1];
        UIButton *add = (UIButton *)[cell viewWithTag:2];
        title.text = @"参会人";
        add.hidden = !self.editFlag;
    }
    else {
        if ([self.scheduleData objectForKey:@"memberInfo"]) {
            NSArray *array = (NSArray *)[self.scheduleData objectForKey:@"memberInfo"];
            NSInteger index = indexPath.row - 5;
            if (self.editFlag && index == array.count) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"cell4"];
                UIButton *cancelBtn = (UIButton *)[cell viewWithTag:1];
                [cancelBtn addTarget:self action:@selector(cancelBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                
            }
            else {
                cell = [tableView dequeueReusableCellWithIdentifier:@"cell3"];
                
                UILabel *name = (UILabel *)[cell viewWithTag:1];
                UILabel *company = (UILabel *)[cell viewWithTag:2];
                UIButton *phoneBtn = (UIButton *)[cell viewWithTag:3];
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
                    phoneBtn.hidden = NO;
                    [phoneBtn addTarget:self action:@selector(callPhone:) forControlEvents:UIControlEventTouchUpInside];
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
                if (array.count == 1) {
                    delBtn.hidden = YES;
                }
                else {
                    delBtn.hidden = (!self.editFlag) || (!canEdit);
                }
                
                tips.hidden = !(self.editFlag && !canEdit);
                phoneBtn.hidden = self.editFlag && !canEdit;
                for (NSLayoutConstraint *constraint in cell.contentView.constraints) {
                    if ([constraint.identifier isEqualToString:@"hideDelBtnConstaint"]) {
                        if (self.editFlag && canEdit) {
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


-(void)cancelBtnClick:(UIButton *)sender {
    NSLog(@"cancelBtnClick");
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
    if (!self.editFlag) {
        return;
    }
    [self hideKeyboard:nil];
    
    
    CGPoint pos = [gesture.view convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *index = [self.tableView indexPathForRowAtPoint:pos];
    NSDate *date = [[NSDate date] dateNextHour];
    NSDate *start = [self.scheduleData objectForKey:@"startTime"];
    NSDate *end = [self.scheduleData objectForKey:@"endTime"];
    if (index.row == 2)  {
        date = start;
    }else if (index.row == 3) {
        date = end;
    }
    ActionSheetDatePicker *datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"选择时间" datePickerMode:UIDatePickerModeDateAndTime selectedDate:date target:self action:@selector(timeWasSelected:element:) origin:gesture.view];
    datePicker.minuteInterval = 15;
    [datePicker showActionSheetPicker];
    
}

-(void)timeWasSelected:(NSDate *)selectedTime element:(id)element {
    CGPoint pos = [element convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *index = [self.tableView indexPathForRowAtPoint:pos];
    if (index.row == 2) {
        [self.scheduleData setObject:selectedTime forKey:@"startTime"];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:index] withRowAnimation:UITableViewRowAnimationAutomatic];
    }else if (index.row == 3) {
        [self.scheduleData setObject:selectedTime forKey:@"endTime"];
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
