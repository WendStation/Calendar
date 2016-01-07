//
//  SearchfundViewController.m
//  Calendar
//
//  Created by 刘花椒 on 15/11/24.
//
//

#import "SearchfundViewController.h"
#import "KnowledgeListDatasource.h"
#import "SearchFundCell.h"
#import "FundDetailViewController.h"
#import "SearchFounderListItem.h"
#import "RDVTabBarController.h"

@interface SearchfundViewController ()<UITableViewDataSource,
                                         UITableViewDelegate,
                                         UITextFieldDelegate>


@property(nonatomic, assign)int lastPosition;
@property(nonatomic, strong)UITextField *searchTextField;
@property(nonatomic, strong)KnowledgeListDatasource *Ds;
@property(nonatomic, strong)UITableView *searchTableView;

@end

@implementation SearchfundViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"基金";
    self.view.backgroundColor = BACKGROUND_COLOR;
    self.Ds = [[KnowledgeListDatasource alloc] init];
    [self createSearchTextField];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.searchTextField resignFirstResponder];
}

- (void)createSearchTextField{
    if (!self.searchTextField) {
        self.searchTextField = [UITextField addUITextFieldLeftImage:[UIImage imageNamed:@"project_icon_search"] leftViewFrame:CGRectMake(0, 0, 40, 54) placeholder:@"可搜索名称、币种、轮次、城市" placeholderColor:LIGHTGRAY_COLOR placeholderFont:[UIFont systemFontOfSize:14] textColor:LIGHTGRAY_COLOR textFont:[UIFont systemFontOfSize:14]];
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
        [self isloadMoreAction:NO];
    }
    return YES;
}

- (void)isloadMoreAction:(BOOL)isLoadMore{
    if (![[NetworkManager sharedInstance] checkNetAndToken]) {
        [self.Ds getFundListDatasFromeDatabase:self.searchTextField.text complete:^(id object) {
            if (self.Ds.searchFundAry.count > 0) {
                [self.searchTableView reloadData];
                [self.searchTableView.footer endRefreshing];
            } else {
                [AlertManager showAlertText:@"亲！本地暂无匹配基金" withCloseSecond:1];
            }
            return;
        }];
    }
    [self showLoading:YES];
    __weak typeof(self)  weakSelf = self;
    
    [self.Ds postRequestSearchFundIsLoadMore:isLoadMore searchTitle:self.searchTextField.text succeed:^(id object) {
        [weakSelf showLoading:NO];
        [weakSelf.searchTableView.footer endRefreshing];
        [weakSelf.searchTableView reloadData];

    } failed:^(id object){
        [weakSelf showLoading:NO];
        if (self.Ds.searchFundAry.count > 0) {
            [self.searchTableView reloadData];
            [self.searchTableView.footer endRefreshing];
        } else {
            [AlertManager showAlertText:@"亲！本地暂无匹配基金" withCloseSecond:1];
        }
    }];
}

- (void)loadMoreDatasAction{
    [self isloadMoreAction:YES];
}

#pragma mark tableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.Ds.searchFundAry.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    static SearchFundCell *cell;
    if (cell == nil) {
        cell = [[SearchFundCell alloc] init];
    }
    if (indexPath.row < self.Ds.searchFundAry.count) {
        return [cell tableView:tableView rowHeightForObject:[self.Ds.searchFundAry objectAtIndex:indexPath.row]];
    }else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identy = @"searchFundCell";
    SearchFundCell *searchFundCell = [tableView dequeueReusableCellWithIdentifier:identy];
    if (searchFundCell == nil) {
        searchFundCell = [[SearchFundCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identy];
        searchFundCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (self.Ds.searchFundAry.count > 0 && indexPath.row < self.Ds.searchFundAry.count) {
        [searchFundCell setData:[self.Ds.searchFundAry objectAtIndex:indexPath.row]];
    }
    return searchFundCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    FundDetailViewController *vc = [[FundDetailViewController alloc] init];
    SearchFounListItem *item = [self.Ds.searchFundAry objectAtIndex:indexPath.row];
    vc.fund_id = item.fundId;
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
        _searchTableView.contentInset = UIEdgeInsetsMake(8, 0, 0, 0);
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
