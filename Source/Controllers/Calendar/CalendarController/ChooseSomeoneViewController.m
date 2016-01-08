//
//  ChooseSomeoneViewController.m
//  Calendar
//
//  Created by 小华 on 15/10/28.
//
//

#import "ChooseSomeoneViewController.h"
#import "Customer.h"
#import "CustomerManager.h"
#import "AlertManager.h"
#import "CacheManager.h"
#import "AddProjectViewController.h"
#import "AddScheduleViewController.h"
#import "ScheduleDetailTableViewController.h"
#import "AddMeetingViewController.h"
#import "JZBorderedView.h"

static const CGFloat tagScrollViewHeight = 54;
static const CGFloat textFieldToLeft = 140;


@interface ChooseSomeoneViewController ()<UITextFieldDelegate,
                                          UITableViewDelegate,
                                        UITableViewDataSource,
                                        UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchIconLeft;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet JZBorderedView *searchView;
@property (nonatomic, strong) UIScrollView *tagScrollView;

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic ,strong) NSMutableArray *indexArray;
@property (nonatomic, strong) NSMutableArray *lastAllCustomerAry;

@end


@implementation ChooseSomeoneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _tableView.estimatedRowHeight = 44;
    _tableView.rowHeight = UITableViewAutomaticDimension;
    _tableView.backgroundColor = BACKGROUND_COLOR;
    _tableView.backgroundView = nil;
    _tableView.sectionIndexColor = BLUE_COLOR;
    _tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    _tableView.contentInset = UIEdgeInsetsMake(8, 0, 0, 0);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    tap.cancelsTouchesInView = NO;
    if (_isMultiSelect) {
        _tableView.allowsMultipleSelection = YES;
    }
    [_tableView addGestureRecognizer:tap];
    
    
    _dataSource = [[NSMutableArray alloc] init];
    _indexArray = [[NSMutableArray alloc] init];
    _lastAllCustomerAry = [[NSMutableArray alloc] init];
    
    if (_isSelectEthercap) {
        MBProgressHUD *hud = [AlertManager getAlertTextWithAss:@""];
        [hud show:YES];
        [self dealWithSearchResult:[[CustomerManager sharedInstance] getAllEthercapMember]];
        [_tableView reloadData];
        [hud hide:NO];
    }
    else if (_isSelectInvestor) {
        MBProgressHUD *hud = [AlertManager getAlertTextWithAss:@""];
        [hud show:YES];
        [self dealWithSearchResult:[[CustomerManager sharedInstance] getAllInvestor]];
        [_tableView reloadData];
        [hud hide:NO];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)hideKeyboard:(id)sender
{
    [self.view endEditing:YES];
}

- (IBAction)sureBtnClick:(id)sender {
    NSArray *selected = [self.tableView indexPathsForSelectedRows];
    if (selected && selected.count > 0) {
        if (self.navigationController.viewControllers.count > 1) {
            unsigned long viewIndex = self.navigationController.viewControllers.count - 2;
            UIViewController *controller = [self.navigationController.viewControllers objectAtIndex:viewIndex];
            if ([controller isKindOfClass:[AddProjectViewController class]]) {
                AddProjectViewController *view = (AddProjectViewController *)controller;
                if (selected.count == 1) {
                    
                    view.customer = [_lastAllCustomerAry lastObject];
                }
            }
            else if ([controller isKindOfClass:[AddScheduleViewController class]]) {
                __block AddScheduleViewController *view = (AddScheduleViewController *)controller;
                if (_lastAllCustomerAry != nil) {
                    [self.lastAllCustomerAry enumerateObjectsUsingBlock:^(Customer *user, NSUInteger idx, BOOL *stop) {
                        [view.addMember addObject:user];
                    }];
                }
            }
            else if ([controller isKindOfClass:[ScheduleDetailTableViewController class]]) {
                __block ScheduleDetailTableViewController *view = (ScheduleDetailTableViewController *)controller;
                if (_lastAllCustomerAry != nil) {
                    [self.lastAllCustomerAry enumerateObjectsUsingBlock:^(Customer *user, NSUInteger idx, BOOL *stop) {
                        [view.addMember addObject:user];
                    }];
                }
            }
            else if ([controller isKindOfClass:[AddMeetingViewController class]]) {
                __block AddMeetingViewController *view = (AddMeetingViewController *)controller;
                if (_isSelectInvestor) {
                    NSIndexPath *dataIndex = [selected objectAtIndex:0];
                    view.chooseInvestor = [[_dataSource objectAtIndex:dataIndex.section] objectAtIndex:dataIndex.row];
                }
                else {
                    if (_lastAllCustomerAry != nil) {
                        [self.lastAllCustomerAry enumerateObjectsUsingBlock:^(Customer *user, NSUInteger idx, BOOL *stop) {
                            [view.addMember addObject:user];
                        }];
                    }
                    //是这里的问题，刷新后不能原先的选中的cell不在这个selected里
//                    for (NSIndexPath *index in selected) {
//                        [view.addMember addObject:[[_dataSource objectAtIndex:index.section] objectAtIndex:index.row]];
//                    }
                }
                
            }
            [self.navigationController popToViewController:controller animated:YES];
        }
        
        
    }
    
}

-(void)dealWithSearchResult:(NSArray *)array {
    [_indexArray removeAllObjects];
    [_dataSource removeAllObjects];
    for (Customer *user in array) {
        NSString *first = [CommonAPI getFirstCharFrom:user.name];
        if (![_indexArray containsObject:first]) {
            [_indexArray addObject:first];
            [_dataSource addObject:[NSMutableArray arrayWithObject:user]];
        }
        else {
            [[_dataSource lastObject] addObject:user];
        }
    }
}

#pragma mark textField Delegate Methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    MBProgressHUD *hud = [AlertManager getAlertTextWithAss:@""];
    [hud show:YES];
    [self dealWithSearchResult:[[CustomerManager sharedInstance] searchUsers:textField.text]];
    [_tableView reloadData];
    [hud hide:NO];
    return YES;
}

#pragma mark -设置右方表格的索引数组
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return _indexArray;
}

#pragma mark -
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return index;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _indexArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[_dataSource objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    UILabel *name = (UILabel *)[cell viewWithTag:1];
    UILabel *info = (UILabel *)[cell viewWithTag:2];
    Customer *user = [[_dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    if (user) {
        name.text = user.name;
        info.text = [NSString stringWithFormat:@"%@  %@", user.company, user.position];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = RGBCOLOR(245, 245, 245);
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Customer *newUser = [[_dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    __block BOOL isExist = NO;
    [self.lastAllCustomerAry enumerateObjectsUsingBlock:^(Customer *user, NSUInteger idx, BOOL *stop) {
        if (user == newUser) {
            *stop = YES;
            isExist = YES;
        }
    }];
    if (!isExist) {
        if (!_isMultiSelect) {
            [self.lastAllCustomerAry removeAllObjects];
        }
        [self.lastAllCustomerAry addObject:newUser];
    }
    [self.tagScrollView removeAllSubviews];
    CGFloat tagViewWidth = 0;
    NSString *name = @"";
    if (self.lastAllCustomerAry.count > 0) {
        for (NSInteger i = 0; i < [self.lastAllCustomerAry count]; i++) {
            Customer *user = [self.lastAllCustomerAry objectAtIndex:i];
            if (i == 0) {
                name = user.name;
            } else {
                name = [NSString stringWithFormat:@"/%@",user.name];
            }
            CGSize tagSize = [NSString calculate:name textFont:[UIFont systemFontOfSize:14] contentSize:CGSizeMake(SCREEN_WIDTH, CGFLOAT_MAX)];
            UILabel *tag = [[UILabel alloc] initWithFrame:CGRectMake(tagViewWidth, 0, tagSize.width, tagScrollViewHeight)];
            tag.backgroundColor = [UIColor clearColor];
            tag.text = name;
            tag.font = [UIFont systemFontOfSize:14];
            tag.textColor = BLACK_COLOR;
            tagViewWidth += tagSize.width;
            self.tagScrollView.contentSize = CGSizeMake(tagViewWidth, tagScrollViewHeight);
            if (tagViewWidth + 10 < SCREEN_WIDTH - textFieldToLeft) {
                self.searchIconLeft.constant = tagViewWidth + 35;
                self.tagScrollView.size = CGSizeMake(tagViewWidth + 10, tagScrollViewHeight);
            } else {
                self.tagScrollView.size = CGSizeMake(SCREEN_WIDTH - textFieldToLeft - 30, tagScrollViewHeight);
            }
            [self.tagScrollView addSubview:tag];
        }
       [self.tagScrollView scrollRectToVisible:CGRectMake(self.tagScrollView.left, self.tagScrollView.top, self.tagScrollView.contentSize.width, tagScrollViewHeight) animated:NO];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    Customer *newUser = [[_dataSource objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [self.lastAllCustomerAry enumerateObjectsUsingBlock:^(Customer *user, NSUInteger idx, BOOL *stop) {
        if (user == newUser) {
            *stop = YES;
            [self.lastAllCustomerAry removeObject:user];
        }
    }];
    [self.tagScrollView removeAllSubviews];
    CGFloat tagViewWidth = 0;
    NSString *name = @"";
    if (self.lastAllCustomerAry.count > 0) {
        for (NSInteger i = 0; i < [self.lastAllCustomerAry count]; i++) {
            Customer *user = [self.lastAllCustomerAry objectAtIndex:i];
            if (i == 0) {
                name = user.name;
            } else {
                name = [NSString stringWithFormat:@"/%@",user.name];
            }
            CGSize tagSize = [NSString calculate:name textFont:[UIFont systemFontOfSize:14] contentSize:CGSizeMake(SCREEN_WIDTH, CGFLOAT_MAX)];
            UILabel *tag = [[UILabel alloc] initWithFrame:CGRectMake(tagViewWidth, 0, tagSize.width, tagScrollViewHeight)];
            tag.backgroundColor = [UIColor clearColor];
            tag.text = name;
            tag.font = [UIFont systemFontOfSize:14];
            tag.textColor = BLACK_COLOR;
            tagViewWidth += tagSize.width;
            [self.tagScrollView addSubview:tag];
            self.tagScrollView.contentSize = CGSizeMake(tagViewWidth, tagScrollViewHeight);
            if (tagViewWidth + 10 < SCREEN_WIDTH - textFieldToLeft) {
                self.searchIconLeft.constant = tagViewWidth + 35;
                self.tagScrollView.size = CGSizeMake(tagViewWidth + 10, tagScrollViewHeight);
            } else {
                self.tagScrollView.size = CGSizeMake(SCREEN_WIDTH - textFieldToLeft - 30, tagScrollViewHeight);
            }
        }
        [self.tagScrollView scrollRectToVisible:CGRectMake(self.tagScrollView.left, self.tagScrollView.top, self.tagScrollView.contentSize.width, tagScrollViewHeight) animated:NO];
    }
    if (self.lastAllCustomerAry.count == 0) {
        self.searchIconLeft.constant = 15;
        self.tagScrollView.size = CGSizeMake(10, tagScrollViewHeight);
    }
}

#pragma mark property
- (UIScrollView *)tagScrollView {
    if (!_tagScrollView) {
        _tagScrollView = [[UIScrollView alloc] init];
        _tagScrollView.frame = CGRectMake(10, 0, 10, tagScrollViewHeight);
        _tagScrollView.backgroundColor = [UIColor clearColor];
        _tagScrollView.showsHorizontalScrollIndicator = YES;
        [self.view addSubview:self.tagScrollView];
    }
    return _tagScrollView;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
