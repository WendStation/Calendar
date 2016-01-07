//
//  SearchProjectViewController.m
//  Calendar
//
//  Created by 刘花椒 on 15/11/11.
//
//

#import "SearchProjectViewController.h"
#import "ProjectListDatasource.h"
#import "SearchProjectTableViewCell.h"
#import "ProjectDetailViewController.h"
#import "ProjectListItem.h"

@interface SearchProjectViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
@property(nonatomic, assign)int lastPosition;
@property(nonatomic, strong)UITextField *searchTextField;
@property(nonatomic, strong)ProjectListDatasource *Ds;
@property(nonatomic, strong)UITableView *searchTableView;
@property(nonatomic, assign)BOOL isKeyBoardHiden;
@property(nonatomic, assign)BOOL isRefreshing;

@end

@implementation SearchProjectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"项目搜索";
    self.view.backgroundColor = BACKGROUND_COLOR;
    self.Ds = [[ProjectListDatasource alloc] init];
    [self createSearchTextField];
    self.isKeyBoardHiden = YES;
    // Do any additional setup after loading the view.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.searchTextField resignFirstResponder];
}

- (void)createSearchTextField{
    if (!self.searchTextField) {
        self.searchTextField = [UITextField addUITextFieldLeftImage:[UIImage imageNamed:@"project_icon_search"] leftViewFrame:CGRectMake(0, 0, 40, 54) placeholder:@"可搜索项目名称/城市/CEO/品类" placeholderColor:LIGHTGRAY_COLOR placeholderFont:[UIFont systemFontOfSize:14] textColor:LIGHTGRAY_COLOR textFont:[UIFont systemFontOfSize:14]];
        self.searchTextField.frame = CGRectMake(0, 0, SCREEN_WIDTH, 54);
        self.searchTextField.returnKeyType = UIReturnKeySearch;
        self.searchTextField.delegate = self;
        
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
        [self isloadMoreAction:NO];
    }
    return YES;
}


- (void)isloadMoreAction:(BOOL)isLoadMore{
    __weak typeof(self)  weakSelf = self;
    if (![[NetworkManager sharedInstance] checkNetAndToken]) {
        [self.Ds getSearchProjectDatasFromeDatabase:self.searchTextField.text complete:^(id object) {
            [weakSelf.searchTableView reloadData];
            [weakSelf.searchTableView.footer endRefreshing];
            if (self.Ds.searchProjectAry.count == 0) {
                [AlertManager showAlertText:@"亲，暂无匹配项目！" withCloseSecond:1];
            }
        }];
        return;
    }
    
    [self showLoading:YES];
    [self.Ds postRequestSearchProjectIsLoadMore:isLoadMore searchTitle:self.searchTextField.text succeed:^(id object) {
        weakSelf.isRefreshing = NO;
        [weakSelf showLoading:NO];
        [weakSelf.searchTableView.footer endRefreshing];
        [weakSelf.searchTableView reloadData];
        if (self.Ds.searchProjectAry.count == 0) {
            [AlertManager showAlertText:@"亲，暂无匹配项目！" withCloseSecond:1];
        }
    } failed:^(id object) {
        weakSelf.isRefreshing = NO;
        [weakSelf showLoading:NO];
        [weakSelf.searchTableView.footer endRefreshing];
        [weakSelf.searchTableView reloadData];
        if (self.Ds.searchProjectAry.count == 0) {
            [AlertManager showAlertText:@"亲，暂无匹配项目！" withCloseSecond:1];
        }
    }];
}

- (void)loadMoreDatasAction{
    self.isRefreshing = YES;
    [self isloadMoreAction:YES];
}

#pragma mark tableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.Ds.searchProjectAry.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    static SearchProjectTableViewCell *cell;
    if (cell == nil) {
        cell = [[SearchProjectTableViewCell alloc] init];
    }
    if (indexPath.row < self.Ds.searchProjectAry.count) {
        return [cell tableView:tableView rowHeightForObject:[self.Ds.searchProjectAry objectAtIndex:indexPath.row]];
    }else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identy = @"projectTableViewCell";
    SearchProjectTableViewCell *searchProjectTableViewCell = [tableView dequeueReusableCellWithIdentifier:identy];
    if (searchProjectTableViewCell == nil) {
        searchProjectTableViewCell = [[SearchProjectTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identy];
        searchProjectTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (self.Ds.searchProjectAry.count > 0 && indexPath.row < self.Ds.searchProjectAry.count) {
        [searchProjectTableViewCell setData:[self.Ds.searchProjectAry objectAtIndex:indexPath.row]];
    }
    return searchProjectTableViewCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ProjectDetailViewController *vc = [[ProjectDetailViewController alloc] init];
    if (indexPath.row < self.Ds.searchProjectAry.count) {
        ProjectListItem *item = [self.Ds.searchProjectAry objectAtIndex:indexPath.row];
        vc.project_Id = item.projectId;
    }
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
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
        _searchTableView.delegate = self;
        _searchTableView.dataSource = self;
        _searchTableView.backgroundColor = RGBCOLOR(240, 239, 245);
        _searchTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _searchTableView.userInteractionEnabled = YES;
        _searchTableView.footer=[MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreDatasAction)];
        
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
