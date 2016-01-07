//
//  FundDetailViewController.m
//  Calendar
//
//  Created by 刘花椒 on 15/11/25.
//
//

#import "FundDetailViewController.h"
#import "KnowledgeListDatasource.h"
#import "FundDetailItem.h"
#import "FundDetailCell.h"

@interface FundDetailViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, strong)KnowledgeListDatasource *Ds;
@property(nonatomic, strong)FundDetailItem *item;
@property(nonatomic, strong)NSArray *titleAry;
@property(nonatomic, strong)NSMutableArray *contentAry;

@end

@implementation FundDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BACKGROUND_COLOR;
    self.title = @"基金详情";
    self.Ds = [[KnowledgeListDatasource alloc] init];
    self.titleAry = @[@[@"中文名称",@"英文名称",@"介绍",@"备注",@"名气",@"币种",@"投资阶段",@"投资概率",@"是否战投",@"关注点",@"新三板",@"本身是小公司创业"],@[@"地址"]];
    self.contentAry = [NSMutableArray arrayWithCapacity:0];
    [self getFundDetailDatas];
    // Do any additional setup after loading the view.
}

- (void)getFundDetailDatas{
    __weak typeof(self) weakSelf = self;
    if (![[NetworkManager sharedInstance] checkNetAndToken]) {
        [self.Ds getFundDetailFromeDatabase:self.fund_id complete:^(FundDetailItem *item) {
            if (item != nil) {
                weakSelf.item = [[FundDetailItem alloc] init];
                weakSelf.item = item;
                [weakSelf arrangeDatas];
                [weakSelf.tableView reloadData];
            } else {
                [AlertManager showAlertText:@"亲！本地暂无数据" withCloseSecond:1];
            }
        }];
        return;
    }
    [self showLoading:YES];
    [self.Ds postRequestFundDetailfundId:self.fund_id succeed:^(id object) {
        if ([object isKindOfClass:[FundDetailItem class]]) {
            FundDetailItem *item = (FundDetailItem *)object;
            if (item != nil) {
                weakSelf.item = [[FundDetailItem alloc] init];
                weakSelf.item = item;
                [weakSelf arrangeDatas];
            }
            [weakSelf showLoading:NO];
            [weakSelf.tableView reloadData];
        }
    } failed:^(id object) {
        [weakSelf showLoading:NO];
        if ([object isKindOfClass:[FundDetailItem class]]) {
            FundDetailItem *item = (FundDetailItem *)object;
            if (item != nil) {
                weakSelf.item = [[FundDetailItem alloc] init];
                weakSelf.item = item;
                [weakSelf arrangeDatas];
                [weakSelf.tableView reloadData];
            } else {
                [AlertManager showAlertText:@"亲！本地暂无数据" withCloseSecond:1];
            }
        }
    }];
}

- (void)arrangeDatas {
    if ((![self.item.name isEqualToString:@"(null)"] && self.item.name.length > 0) && (![self.item.nameShort isEqualToString:@"(null)"] && self.item.nameShort.length > 0)) {
        NSString *str = [NSString stringWithFormat:@"%@/%@",self.item.name,self.item.nameShort];
        [self.contentAry addObject:str];
    } else if (![self.item.name isEqualToString:@"(null)"] && self.item.name.length > 0){
        [self.contentAry addObject:self.item.name];
    } else if (![self.item.nameShort isEqualToString:@"(null)"] && self.item.nameShort.length > 0){
        [self.contentAry addObject:self.item.nameShort];
    } else {
        [self.contentAry addObject:@"未知"];
    }
    if ((![self.item.englishName isEqualToString:@"(null)"] && self.item.englishName.length > 0) && (![self.item.englishNameShort isEqualToString:@"(null)"] && self.item.englishNameShort.length > 0)) {
        NSString *str = [NSString stringWithFormat:@"%@/%@",self.item.englishName,self.item.englishNameShort];
        [self.contentAry addObject:str];
    } else if (![self.item.englishName isEqualToString:@"(null)"] && self.item.englishName.length > 0){
        [self.contentAry addObject:self.item.englishName];
    } else if (![self.item.englishNameShort isEqualToString:@"(null)"] && self.item.englishNameShort.length > 0){
        [self.contentAry addObject:self.item.englishNameShort];
    } else {
        [self.contentAry addObject:@"未知"];
    }
    if (![self.item.info isEqualToString:@"(null)"] && self.item.info.length > 0) {
        [self.contentAry addObject:self.item.info];
    } else {
        [self.contentAry addObject:@"目前没有介绍哦！"];
    }
    if (![self.item.comment isEqualToString:@"(null)"] && self.item.comment.length > 0) {
        [self.contentAry addObject:self.item.comment];
    } else {
        [self.contentAry addObject:@"目前没有备注哦！"];
    }
    if (![self.item.reputation isEqualToString:@"(null)"] && self.item.reputation.length > 0) {
        [self.contentAry addObject:self.item.reputation];
    } else {
        [self.contentAry addObject:@"未知"];
    }
    if (![self.item.currency isEqualToString:@"(null)"] && self.item.currency.length > 0) {
        [self.contentAry addObject:self.item.currency];
    } else {
        [self.contentAry addObject:@"未知"];
    }
    if (![self.item.financingRound isEqualToString:@"(null)"] && self.item.financingRound.length > 0) {
        [self.contentAry addObject:self.item.financingRound];
    } else {
        [self.contentAry addObject:@"未知"];
    }
    if (![self.item.investProb isEqualToString:@"(null)"] && self.item.investProb.length > 0) {
        [self.contentAry addObject:self.item.investProb];
    } else {
        [self.contentAry addObject:@"未知"];
    }
    if (![self.item.isStrategy isEqualToString:@"(null)"] && self.item.isStrategy.length > 0) {
        [self.contentAry addObject:self.item.isStrategy];
    } else {
        [self.contentAry addObject:@"未知"];
    }
    if (![self.item.focus isKindOfClass:[NSNull class]] && self.item.focus.length > 0) {
        [self.contentAry addObject:self.item.focus];
    } else {
        [self.contentAry addObject:@"未知"];
    }
    if (![self.item.thirdBoard isEqualToString:@"(null)"] && self.item.thirdBoard.length > 0) {
        [self.contentAry addObject:self.item.thirdBoard];
    } else {
        [self.contentAry addObject:@"未知"];
    }
    if (![self.item.startupCEO isEqualToString:@"(null)"] && self.item.startupCEO.length > 0) {
        [self.contentAry addObject:self.item.startupCEO];
    } else {
        [self.contentAry addObject:@"未知"];
    }
}

#pragma mark tableDatas
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.titleAry.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return [self.titleAry.firstObject count];
    }else{
        return [self.titleAry.lastObject count];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 1) {
        return 8.0f;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static FundDetailCell *cell;
    if (cell == nil) {
        cell = [[FundDetailCell alloc] init];
    }
    if (indexPath.section == 0) {
        if (indexPath.row == 2 || indexPath.row == 3) {
            return [cell tableView:tableView rowHeightForObject:[self.contentAry objectAtIndex:indexPath.row] index:indexPath];
        }else{
            return 44.0f;
        }
    }else{
        return [cell tableView:tableView rowHeightForObject:self.item.address index:indexPath];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identy = @"fundDetailCell";
    FundDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:identy];
    if (cell == nil) {
        cell = [[FundDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identy];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (self.item != nil) {
        NSMutableArray *array = [NSMutableArray array];
        if (indexPath.section == 0) {
            NSString *title = [self.titleAry.firstObject objectAtIndex:indexPath.row];
            NSString *content = [self.contentAry objectAtIndex:indexPath.row];
            [array addObject:title];
            [array addObject:content];
        } else if (indexPath.section == 1) {
            [array addObject:[self.titleAry.lastObject firstObject]];
            [array addObject:self.item.address];
        }
        [cell setData:array];
    }
    return cell;
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
