//
//  FounderDetailViewController.m
//  Calendar
//
//  Created by 刘花椒 on 15/11/24.
//
//

#import "FounderDetailViewController.h"
#import "KnowledgeListDatasource.h"
#import "FounderDetailItem.h"
#import "FounderDetailCell.h"
#import "SyncSchedule.h"

@interface FounderDetailViewController ()<UITableViewDataSource,
                                            UITableViewDelegate,
                                    FounderDetailCellDelegate>

@property(nonatomic, strong)NSMutableArray *titleAry;
@property(nonatomic, strong)NSMutableArray *contentAry;
@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, strong)KnowledgeListDatasource *Ds;
@property(nonatomic, strong)FounderDetailItem *item;
@property(nonatomic, strong)SyncSchedule *sync;

@end

@implementation FounderDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BACKGROUND_COLOR;
    self.title = @"投资人详情";
    self.sync = [[SyncSchedule alloc] init];
    self.Ds = [[KnowledgeListDatasource alloc] init];
    self.item = [[FounderDetailItem alloc]init];
    self.titleAry = [NSMutableArray array];
    self.contentAry = [NSMutableArray array];
    [self isloadMoreAction:NO];
}

- (void)isloadMoreAction:(BOOL)isLoadMore{
    __weak typeof(self)  weakSelf = self;
    if (![[NetworkManager sharedInstance] checkNetAndToken]) {
        [self.Ds getFounderDetailFromeDatabase:self.user_id complete:^(FounderDetailItem *item) {
            if (item != nil) {
                weakSelf.item = item;
                [weakSelf arrangeDatas];
                [weakSelf.tableView reloadData];
                [weakSelf.tableView.footer endRefreshing];
            } else {
                [AlertManager showAlertText:@"亲！本地暂无数据" withCloseSecond:1];
            }
        }];
    }
    [self.Ds postRequestFounderDetailIsLoadMore:isLoadMore founderId:self.user_id succeed:^(id object) {
        if ([object isKindOfClass:[FounderDetailItem class]]) {
            FounderDetailItem *item = (FounderDetailItem *)object;
            if (item != nil) {
                weakSelf.item = item;
                if (!isLoadMore) {
                    [weakSelf arrangeDatas];
                }
                if (!isLoadMore) {
                    [weakSelf.tableView reloadData];
                }else{
                    if (weakSelf.item.evaluateList.count > 0) {
                        NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:1];
                        [weakSelf.tableView reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
                    }
                }
            }
            [weakSelf.tableView.footer endRefreshing];
        }
    } failed:^(id object) {
        if ([object isKindOfClass:[FounderDetailItem class]]) {
            FounderDetailItem *item = (FounderDetailItem *)object;
            if (item != nil) {
                weakSelf.item = item;
                [weakSelf arrangeDatas];
                [weakSelf.tableView reloadData];
            } else {
                [AlertManager showAlertText:@"亲！本地暂无数据" withCloseSecond:1];
            }
        }
        [weakSelf.tableView.footer endRefreshing];
    }];
}

- (void)arrangeDatas {
    if (![self.item.name isEqualToString:@"(null)"] && self.item.name.length > 0) {
        [self.titleAry addObject:@"姓名"];
        [self.contentAry addObject:self.item.name];
    }
    if ((![self.item.company isEqualToString:@"(null)"] && self.item.company.length > 0) || (![self.item.position isEqualToString:@"(null)"] && self.item.position.length > 0)) {
        [self.titleAry addObject:@"机构"];
        if ((![self.item.company isEqualToString:@"(null)"] && self.item.company.length > 0) && (![self.item.position isEqualToString:@"(null)"] && self.item.position.length > 0)) {
            
            NSString *str = [NSString stringWithFormat:@"%@ - %@",self.item.company,self.item.position];
            [self.contentAry addObject:str];
            
        }else if (![self.item.company isEqualToString:@"(null)"] && self.item.company.length > 0){
            [self.contentAry addObject:self.item.company];
        }else{
            [self.contentAry addObject:self.item.position];
        }
    }
    [self.titleAry addObject:@"手机"];
    [self.contentAry addObject:@"点击查看"];
    [self.titleAry addObject:@"微信"];
    [self.contentAry addObject:@"点击查看"];
    [self.titleAry addObject:@"邮箱"];
    [self.contentAry addObject:@"点击查看"];
    if (![self.item.info isEqualToString:@"(null)"] && self.item.info.length > 0) {
        [self.titleAry addObject:@"信息"];
        [self.contentAry addObject:self.item.info];
    }
    [self.titleAry addObject:@"级别"];
    [self.contentAry addObject:self.item.rank];
    [self.titleAry addObject:@"推动力"];
    [self.contentAry addObject:self.item.pushAbility];
    [self.titleAry addObject:@"好评"];
    [self.contentAry addObject:self.item.favourable];
    [self.titleAry addObject:@"投资概率"];
    [self.contentAry addObject:self.item.investmentProbability];
    [self.titleAry addObject:@"名气"];
    [self.contentAry addObject:self.item.reputation];
}

- (void)loadMoreDatasAction{
    if (![[NetworkManager sharedInstance] checkNetAndToken]) {
        [AlertManager showAlertText:@"亲！网络不给力，暂时无法加载" withCloseSecond:1];
        [self.tableView.footer endRefreshing];
        return;
    }
    [self isloadMoreAction:YES];
}

#pragma mark tableViewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.titleAry.count > 0 && self.item.evaluateList.count > 0) {
        return 2;
    }else{
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return self.titleAry.count;
    }else{
        return self.item.evaluateList.count + 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return 44.0f;
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        return 52.0f;
    } else{
        static CommentFounderCell *cell;
        if (cell == nil) {
            cell = [[CommentFounderCell alloc] init];
        }
        return [cell tableView:tableView rowHeightForObject:[self.item.evaluateList objectAtIndex:indexPath.row - 1]];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0 || (indexPath.section == 1 && indexPath.row == 0)) {
        static NSString *identy = @"founderDetailCell";
        FounderDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:identy];
        if (cell == nil) {
            cell = [[FounderDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identy];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        if (self.item != nil) {
            NSMutableArray *array = [NSMutableArray array];
            if (indexPath.section == 0) {
                NSString *title = [self.titleAry objectAtIndex:indexPath.row];
                NSString *content = [self.contentAry objectAtIndex:indexPath.row];
                [array addObject:title];
                [array addObject:content];
            }else{
                [array addObject:@"评价"];
                [array addObject:@""];
            }
            cell.delegate = self;
            [cell setData:array];
        }
        return cell;
    }else {
        static NSString *identy = @"commentFounderCell";
        CommentFounderCell *cell = [tableView dequeueReusableCellWithIdentifier:identy];
        if (cell == nil) {
            cell = [[CommentFounderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identy];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        if (self.item.evaluateList.count > 0) {
            [cell setData:[self.item.evaluateList objectAtIndex:indexPath.row - 1]];
        }
        return cell;
    }
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.footer=[MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreDatasAction)];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (void)lookFounderRelationNumber:(NSString *)type {
    [self.sync getUserPhoneApi:@([self.user_id integerValue]) type:type block:^(id object) {
        NSString *number = (NSString *)object;
        if ([type isEqualToString:@"phone"]) {
            if (number.length == 0) {
                [AlertManager showAlertText:@"没有获取到电话号！" withCloseSecond:1];
                return ;
            }
            [CommonAPI callPhone:number];
        } else if ([type isEqualToString:@"weixin"]) {
            if (number.length == 0) {
                [AlertManager showAlertText:@"没有获取到微信号！" withCloseSecond:1];
                return ;
            }
            [CommonAPI weichat:number];
        } else {
            if (number.length == 0) {
                [AlertManager showAlertText:@"没有获取到邮箱号！" withCloseSecond:1];
                return ;
            }
            [CommonAPI emial:number];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
