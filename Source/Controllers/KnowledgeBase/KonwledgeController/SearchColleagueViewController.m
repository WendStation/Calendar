//
//  SearchColleagueViewController.m
//  Calendar
//
//  Created by 刘花椒 on 15/11/24.
//
//

#import "SearchColleagueViewController.h"
#import "KnowledgeListDatasource.h"
#import "SearchColleagueCell.h"

@interface SearchColleagueViewController ()<UITableViewDataSource,
                                              UITableViewDelegate,
                                               UITextFieldDelegate,
                                        SearchColleagueCellDelegate>

@property(nonatomic, assign)int lastPosition;
@property(nonatomic, strong)UITextField *searchTextField;
@property(nonatomic, strong)UITableView *searchTableView;
@property(nonatomic, strong)NSArray *colleagueAry;

@end

@implementation SearchColleagueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"你的同事";
    self.view.backgroundColor = BACKGROUND_COLOR;
    self.colleagueAry = [NSArray array];
    [self createSearchTextField];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.searchTextField resignFirstResponder];
}

- (void)createSearchTextField{
    if (!self.searchTextField) {
        self.searchTextField = [UITextField addUITextFieldLeftImage:[UIImage imageNamed:@"project_icon_search"] leftViewFrame:CGRectMake(0, 0, 40, 54) placeholder:@"可搜索姓名、手机" placeholderColor:LIGHTGRAY_COLOR placeholderFont:[UIFont systemFontOfSize:14] textColor:LIGHTGRAY_COLOR textFont:[UIFont systemFontOfSize:14]];
        self.searchTextField.frame = CGRectMake(0, 0, SCREEN_WIDTH, 54);
        self.searchTextField.returnKeyType = UIReturnKeySearch;
        self.searchTextField.delegate = self;
        self.searchTextField.tintColor = BLUE_COLOR;
        
        UIImageView *line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line"]];
        line.frame = CGRectMake(0, self.searchTextField.height - 1, SCREEN_WIDTH, 1);
        line.backgroundColor = [UIColor clearColor];
        [self.searchTextField addSubview:line];
        [self.view addSubview:self.searchTextField];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.view endEditing:YES];
    if (self.searchTextField.text.length > 0) {
        [self loadMoreAction];
    }
    return YES;
}

- (void)loadMoreAction{
    self.colleagueAry = [[CustomerManager sharedInstance] searchEthercapColleagueFromNameOrPhone:self.searchTextField.text];
    if (self.colleagueAry.count > 0) {
        [self.searchTableView reloadData];
    } else {
        [AlertManager showAlertText:@"亲！没有搜到该同事" withCloseSecond:1];
    }
}

#pragma mark tableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.colleagueAry.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 59.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identy = @"searchColleagueCell";
    SearchColleagueCell *searchColleagueCell = [tableView dequeueReusableCellWithIdentifier:identy];
    if (searchColleagueCell == nil) {
        searchColleagueCell = [[SearchColleagueCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identy];
        searchColleagueCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (self.colleagueAry.count > 0 && indexPath.row < self.colleagueAry.count) {
        [searchColleagueCell setData:[self.colleagueAry objectAtIndex:indexPath.row]];
        searchColleagueCell.delegate = self;
    }
    return searchColleagueCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (void)relationColleague:(NSString *)phone {
    [CommonAPI callPhone:phone];
}

- (void)lookschedule:(Customer *)user  {
    CalendarViewController *view = [[ViewManager sharedInstance] getScheduleViewController];
    view.scheduleOwner = user;
    [self.navigationController pushViewController:view animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.searchTextField resignFirstResponder];
//    int currentPostion = scrollView.contentOffset.y;
//    if(currentPostion - _lastPosition > 0) {//上
//        if(scrollView.contentOffset.y > self.searchTextField.height) {
//            [UIView animateWithDuration:0.25 animations:^{
//                self.searchTextField.bottom = 0;
//                self.searchTableView.top = self.searchTextField.bottom;
//                self.searchTableView.height = self.view.height - self.searchTextField.bottom;
//                
//            }];
//        }
//    }else{
//        [UIView animateWithDuration:0.25 animations:^{
//            self.searchTextField.top = 0;
//            self.searchTableView.top = self.searchTextField.bottom;
//            self.searchTableView.height = self.view.height - self.searchTextField.bottom;
//        }];
//    }
//    _lastPosition = currentPostion;
}

- (UITableView *)searchTableView{
    if (!_searchTableView) {
        _searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.searchTextField.bottom, SCREEN_WIDTH, self.view.height - self.searchTextField.bottom) style:UITableViewStylePlain];
        _searchTableView.contentInset = UIEdgeInsetsMake(8, 0, 0, 0)
        ;        _searchTableView.delegate = self;
        _searchTableView.dataSource = self;
        _searchTableView.backgroundColor = RGBCOLOR(240, 239, 245);
        _searchTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _searchTableView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
        tap.cancelsTouchesInView = NO;
        [_searchTableView addGestureRecognizer:tap];
        
        [self.view addSubview:_searchTableView];
    }
    return _searchTableView;
}

-(void)hideKeyboard:(id)sender
{
    [self.searchTextField endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
