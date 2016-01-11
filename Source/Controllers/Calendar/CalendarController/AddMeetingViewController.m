//
//  ScheduleDetailTableViewController.m
//  Calendar
//
//  Created by 小华 on 15/10/27.
//
//

#import "AddMeetingViewController.h"
#import "Customer.h"
#import "ActionSheetDatePicker.h"
#import "CacheManager.h"
#import "ChooseSomeoneViewController.h"
#import "PlaceholderTextView.h"
#import "NSDate+Escort.h"
#import "NetworkManager.h"
#import "SyncSchedule.h"
#import "ProjectListItem.h"
#import "ProjectListDatasource.h"
#import "SubmitMeetingDatasource.h"

@interface AddMeetingViewController ()<UITextViewDelegate>

@property(nonatomic, strong)SyncSchedule *sync;
@property(nonatomic, strong)ProjectListDatasource *pDs;
@property(nonatomic, strong) SubmitMeetingDatasource *sDs;

@end

@implementation AddMeetingViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    self.tableView.estimatedRowHeight = 40;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    tap.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tap];
    
    self.addMember = [[NSMutableArray alloc] init];
    
    if (self.isEditFlag == NO) {
        self.navigationItem.rightBarButtonItems = nil;
        self.navigationItem.title = @"会议详情";
    }
    
    if (self.scheduleData == nil) {
        self.scheduleData = [[NSMutableDictionary alloc] init];
        [self.scheduleData setObject:[[NSMutableArray alloc] init] forKey:@"memberInfo"];
    }
    
    self.sync = [[SyncSchedule alloc] init];
    self.pDs = [[ProjectListDatasource alloc] init];
    self.sDs = [[SubmitMeetingDatasource alloc] init];
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_chooseInvestor != nil) {
        [self.scheduleData setObject:_chooseInvestor forKey:@"investorInfo"];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
        _chooseInvestor = nil;
    }
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
                [indexArray addObject: [NSIndexPath indexPathForRow:array.count + 6 inSection:0]];
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


- (IBAction)completeBtnClick:(id)sender {
    [self submitMeeting:@"online"];
}

- (IBAction)saveBtnClick:(id)sender {
    [self submitMeeting:@"reviewing"];
}

-(void)submitMeeting:(NSString *)type {
    [self.view endEditing:YES];
    if (![self.scheduleData objectForKey:@"projectInfo"]) {
        [AlertManager showAlertText:@"请选择项目" withCloseSecond:1];
        return;
    }
    
    if (![self.scheduleData objectForKey:@"investorInfo"]) {
        [AlertManager showAlertText:@"请选择投资人" withCloseSecond:1];
        return;
    }
    
    if (![self.scheduleData objectForKey:@"city"]) {
        [AlertManager showAlertText:@"请选择城市" withCloseSecond:1];
        return;
    }
    
    if (![self.scheduleData objectForKey:@"startTime"]) {
        [AlertManager showAlertText:@"请选择开始时间" withCloseSecond:1];
        return;
    }
    
    NSDate *start = [self.scheduleData objectForKey:@"startTime"];
    if ([[NSDate date] isLaterThanOrEqualDate: start] ) {
        [AlertManager showAlertText:@"开始时间不合法" withCloseSecond:1];
        return;
    }
    
    if (![self.scheduleData objectForKey:@"location"]||[[self.scheduleData objectForKey:@"location"] isEqualToString:@""]) {
        [AlertManager showAlertText:@"请输入地点" withCloseSecond:1];
        return;
    }
    
    
    ProjectListItem *project = (ProjectListItem *)[self.scheduleData objectForKey:@"projectInfo"];
    Customer *investor = (Customer *)[self.scheduleData objectForKey:@"investorInfo"];
    NSArray *member = (NSArray *)[self.scheduleData objectForKey:@"memberInfo"];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setObject:type forKey:@"type"];
    [dic setObject:project.projectId forKey:@"projectId"];
    [dic setObject:investor.userId forKey:@"investorId"];
    [dic setObject:[start string] forKey:@"start"];
    [dic setObject:[self.scheduleData objectForKey:@"city"] forKey:@"city"];
    [dic setObject:[self.scheduleData objectForKey:@"location"] forKey:@"location"];
    NSMutableString *string = [[NSMutableString alloc] init];
    for (Customer *user in member) {
        [string appendString:[NSString stringWithFormat:@"%@", user.userId]];
        [string appendString:@","];
    }
    [dic setObject:string forKey:@"attenderId"];
    
    __weak AddMeetingViewController *weakSelf = self;
    [self.sDs submitMeeting:dic succeed:^() {
        [AlertManager showAlertText:@"提交成功" withCloseSecond:1];
        [weakSelf.navigationController popViewControllerAnimated:YES];
    }failed:^() {
        
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
    
    return 6 + memberNum;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.row < 4) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell1"];
        UILabel *title = (UILabel *)[cell viewWithTag:1];
        UILabel *content = (UILabel *)[cell viewWithTag:2];
        if (indexPath.row == 0) {
            title.text = @"项目";
            if (self.isEditFlag == YES) {
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectProject:)];
                [content addGestureRecognizer:tap];
                content.text = @"点击选择";
                if ([self.scheduleData objectForKey:@"projectInfo"]) {
                    ProjectListItem *item = (ProjectListItem *)[self.scheduleData objectForKey:@"projectInfo"];
                    content.text = [NSString stringWithFormat:@"%@  %@", item.title, item.agentName];
                }
            }
            else {
                content.text = @"";
                if ([self.scheduleData objectForKey:@"comment"]) {
                    content.text = [NSString stringWithFormat:@"%@", [self.scheduleData objectForKey:@"comment"]];
                }
            }
        }
        else if (indexPath.row == 1) {
            title.text = @"投资人";
            if (self.isEditFlag == YES) {
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectInvestor:)];
                [content addGestureRecognizer:tap];
                content.text = @"点击选择";
            }
            else {
                content.text = @"";
            }
            if ([self.scheduleData objectForKey:@"investorInfo"]) {
                Customer *investor = (Customer *)[self.scheduleData objectForKey:@"investorInfo"];
                content.text = investor.name;
            }
        }
        else if (indexPath.row == 2) {
            title.text = @"城市";
            if (self.isEditFlag == YES) {
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectCity:)];
                [content addGestureRecognizer:tap];
                content.text = @"点击选择";
            }
            else {
                content.text = @"";
            }
            if ([self.scheduleData objectForKey:@"city"]) {
                content.text = [NSString stringWithFormat:@"%@", [self.scheduleData objectForKey:@"city"]];
            }
        }
        else if (indexPath.row == 3) {
            title.text = @"开始时间";
            if (self.isEditFlag == YES) {
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectTime:)];
                [content addGestureRecognizer:tap];
                content.text = @"点击选择";
            }
            else {
                content.text = @"";
            }
            if ([self.scheduleData objectForKey:@"startTime"]) {
                NSDate *tmp = [self.scheduleData objectForKey:@"startTime"];
                content.text = tmp.string;
                BOOL isChina = [NSDate isInChina];
                if (!isChina) {
                    content.text = [content.text stringByAppendingString:@" (北京时间)"];
                }
            }
        }
        
    }
    else if (indexPath.row == 4) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell0"];
        UILabel *title = (UILabel *)[cell viewWithTag:1];
        PlaceholderTextView *view = (PlaceholderTextView *)[cell viewWithTag:2];
        view.delegate = self;
        title.text = @"地点";
        
        if (self.isEditFlag == YES) {
            view.placeholder = @"请输入";
            view.editable = YES;
        }
        else {
            view.placeholder = @"";
            view.editable = NO;
        }
        if ([self.scheduleData objectForKey:@"location"]) {
            view.text = [NSString stringWithFormat:@"%@", [self.scheduleData objectForKey:@"location"]];
        }
    }
    else if (indexPath.row == 5) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell2"];
        UILabel *title = (UILabel *)[cell viewWithTag:1];
        UIButton *addBtn = (UIButton *)[cell viewWithTag:2];
        title.text = @"其他参会人";
        if (self.isEditFlag == YES) {
            addBtn.hidden = NO;
        }
        else {
            addBtn.hidden = YES;
        }
    }
    else {
        if ([self.scheduleData objectForKey:@"memberInfo"]) {
            NSArray *array = (NSArray *)[self.scheduleData objectForKey:@"memberInfo"];
            NSInteger index = indexPath.row - 6;
            cell = [tableView dequeueReusableCellWithIdentifier:@"cell3"];
            
            UILabel *name = (UILabel *)[cell viewWithTag:1];
            UILabel *company = (UILabel *)[cell viewWithTag:2];
            UIButton *phone = (UIButton *)[cell viewWithTag:3];
            UIButton *delBtn = (UIButton *)[cell viewWithTag:4];
            name.text = @"";
            company.text = @"";
            
            for (NSLayoutConstraint *constraint in cell.contentView.constraints) {
                if ([constraint.identifier isEqualToString:@"hideDelBtnConstaint"]) {
                    if (self.isEditFlag) {
                        constraint.constant = 40;
                    }
                    else {
                        constraint.constant = 0;
                    }
                    break;
                }
            }

            if (self.isEditFlag == YES) {
                //delBtn.enabled = YES;
                [delBtn addTarget:self action:@selector(delBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            }
            else {
                delBtn.hidden = YES;
                //delBtn.enabled = NO;
                
            }
            
            Customer *user;
            if (index < array.count) {
                user = (Customer *)[array objectAtIndex:index];
                name.text = user.name;
                company.text = user.company;
                phone.hidden = NO;
                [phone addTarget:self action:@selector(callPhone:) forControlEvents:UIControlEventTouchUpInside];
                [delBtn setTitle:[NSString stringWithFormat:@"%@", user.userId] forState:UIControlStateDisabled];
            }
        }
    }
    return cell;
}
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < 4 && self.isEditFlag == YES) {
        return indexPath;
    }
    return nil;
}

- (void)callPhone:(id)sender {
    NSArray *array = (NSArray *)[self.scheduleData objectForKey:@"memberInfo"];
    UIButton *btn = (UIButton *)sender;
    CGPoint pos = [btn convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *index = [self.tableView indexPathForRowAtPoint:pos];
    Customer *user = (Customer *)[array objectAtIndex:index.row - 6];
    [self.sync getUserPhoneApi:user.userId type:@"phone" block:^(id object) {
        NSString *phone = (NSString *)object;
        [CommonAPI callPhone:phone];
    }];
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
                    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index + 6 inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
                    [self.tableView endUpdates];
                    break;
                }
            }
        }
    }
}

-(void)selectProject:(UITapGestureRecognizer *)gesture {
    [self hideKeyboard:nil];
    
    MBProgressHUD *hud = [AlertManager getAlertTextWithAss:@""];
    [hud show:YES];
    __weak typeof(self)  weakSelf = self;
    [self.pDs postRequestOnlineProjectIsLoadMore:NO isAll:YES succeed:^(id object) {
        [hud hide:NO];
        if ([object isKindOfClass:[NSMutableArray class]]) {
            NSMutableArray *info = (NSMutableArray *)object;
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (ProjectListItem *item in info) {
                [array addObject:[NSString stringWithFormat:@"%@  %@", item.title, item.agentName]];
            }
            if (array.count == 0) {
                [AlertManager showAlertText:@"目前没有项目！" withCloseSecond:1];
                return ;
            }
            ActionSheetStringPicker *picker = [[ActionSheetStringPicker alloc] initWithTitle:@"选择项目" rows:array initialSelection:0 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectIndex, id selectValue) {
                ProjectListItem *item = [info objectAtIndex:selectIndex];
                [weakSelf.scheduleData setObject:item forKey:@"projectInfo"];
                [weakSelf.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            } cancelBlock:^(ActionSheetStringPicker *picker) {
                
            }origin:gesture.view];
            [picker showActionSheetPicker];
        }
    } failed:^(id object) {
        [hud hide:NO];
        if ([object isKindOfClass:[NSMutableArray class]]) {
            NSMutableArray *info = (NSMutableArray *)object;
            NSMutableArray *array = [[NSMutableArray alloc] init];
            for (ProjectListItem *item in info) {
                [array addObject:[NSString stringWithFormat:@"%@  %@", item.title, item.agentName]];
            }
            if (array.count == 0) {
                [AlertManager showAlertText:@"目前没有项目！" withCloseSecond:1];
                return ;
            }
            ActionSheetStringPicker *picker = [[ActionSheetStringPicker alloc] initWithTitle:@"选择项目" rows:array initialSelection:0 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectIndex, id selectValue) {
                ProjectListItem *item = [info objectAtIndex:selectIndex];
                [weakSelf.scheduleData setObject:item forKey:@"projectInfo"];
                [weakSelf.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            } cancelBlock:^(ActionSheetStringPicker *picker) {
                
            }origin:gesture.view];
            [picker showActionSheetPicker];
        }
    }];
}

-(void)selectInvestor:(UITapGestureRecognizer *)gesture {
    [self hideKeyboard:nil];
    [self performSegueWithIdentifier:@"chooseInvestorSegue" sender:self];
    
}


-(void)selectCity:(UITapGestureRecognizer *)gesture {
    [self hideKeyboard:nil];
    
   
    __weak typeof(self)  weakSelf = self;
    ActionSheetStringPicker *picker = [[ActionSheetStringPicker alloc] initWithTitle:@"选择城市" rows:[CacheManager sharedInstance].cityListData initialSelection:0 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectIndex, id selectValue) {
        [weakSelf.scheduleData setObject:selectValue forKey:@"city"];
        [weakSelf.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    } cancelBlock:^(ActionSheetStringPicker *picker) {
        
    }origin:gesture.view];
    [picker showActionSheetPicker];
    
    
}

-(void)selectTime:(UITapGestureRecognizer *)gesture {
    [self hideKeyboard:nil];

    NSDate *date = [[NSDate date] dateNextHour];
    if ([self.scheduleData objectForKey:@"startTime"]) {
        date = [self.scheduleData objectForKey:@"startTime"];
    }
    
    ActionSheetDatePicker *datePicker = [[ActionSheetDatePicker alloc] initWithTitle:@"选择时间" datePickerMode:UIDatePickerModeDateAndTime selectedDate:date target:self action:@selector(timeWasSelected:element:) origin:gesture.view];
    datePicker.minuteInterval = 15;
    [datePicker showActionSheetPicker];
    
}

-(void)timeWasSelected:(NSDate *)selectedTime element:(id)element {
    [self.scheduleData setObject:selectedTime forKey:@"startTime"];
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
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
     else if ([segue.identifier isEqualToString:@"chooseInvestorSegue"]) {
         ChooseSomeoneViewController *controller = (ChooseSomeoneViewController *)segue.destinationViewController;
         controller.isSelectInvestor = YES;
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
    if (bounds.size.height != newSize.height) {
        bounds.size = newSize;
        textView.bounds = bounds;
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
    CGPoint pos = [textView convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *index = [self.tableView indexPathForRowAtPoint:pos];
    [self.tableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
    
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    [self.scheduleData setObject:textView.text forKey:@"location"];
}

@end
