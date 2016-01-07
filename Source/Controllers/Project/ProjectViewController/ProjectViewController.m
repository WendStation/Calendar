//
//  ProjectViewController.m
//  Calendar
//
//  Created by 小华 on 15/10/19.
//  Copyright © 2015年 Robert Dimitrov. All rights reserved.
//

#import "ProjectViewController.h"
#import "TopTabBar.h"
#import "projectTableViewCell.h"
#import "ProjectListDatasource.h"
#import "ProjectDetailViewController.h"
#import "RDVTabBarController.h"
#import "ProjectListItem.h"
#import "SearchProjectViewController.h"
#import "AddProjectViewController.h"
#import "AddCCViewController.h"

@interface ProjectViewController ()<ProjectTopBarDelegate>

@property(nonatomic, assign)BOOL isKxMenuHiden;
@property(nonatomic, strong)UIBarButtonItem *leftBarButtonItem;
@property(nonatomic, strong)UIBarButtonItem *rightBarButtonItem;
@property(nonatomic, strong)TopTabBar *projectTopBar;
@property(nonatomic, strong)ProjectListDatasource *pDs;
@property(nonatomic, strong)UITableView *currentTableView;

@end

@implementation ProjectViewController

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.rdv_tabBarController.tabBarHidden) {
        [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
        [self.currentTableView reloadData];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BACKGROUND_COLOR;
    self.isKxMenuHiden = YES;
    self.projectTableViewsAry = [[NSMutableArray alloc] initWithCapacity:0];
    self.pDs = [[ProjectListDatasource alloc] init];
    
    [self createNavigationBarItems];
    [self createProjectTopBar];
    [self createProjectTableViews];
    [self isloadMoreAction:NO];
}

- (void)isloadMoreAction:(BOOL)isLoadMore{
    __weak typeof(self)  weakSelf = self;
    if (![[NetworkManager sharedInstance] checkNetAndToken]) {
        if (self.pDs.projectRequestType == OnlineProject) {
            [self.pDs getOnlineProjectDatasFromeDatabaseIsLoadMore:isLoadMore complete:^(id object) {
                [weakSelf endRefreshing:isLoadMore];
                [weakSelf.currentTableView reloadData];
            }];
        } else if (self.pDs.projectRequestType == PrivateOceanProject) {
            [self.pDs getPrivateOceanProjectDatasFromeDatabaseIsLoadMore:isLoadMore complete:^(id object) {
                [weakSelf endRefreshing:isLoadMore];
                [weakSelf.currentTableView reloadData];
            }];
        } else {
            [self.pDs getCCProjectDatasFromeDatabaseIsLoadMore:isLoadMore complete:^(id object) {
                [weakSelf endRefreshing:isLoadMore];
                [weakSelf.currentTableView reloadData];
            }];
        }
        return;
    }
    
    [self showLoading:YES];
    if (self.pDs.projectRequestType == OnlineProject) {
        [self.pDs postRequestOnlineProjectIsLoadMore:isLoadMore isAll:NO succeed:^(id object) {
            [weakSelf showLoading:NO];
            [weakSelf endRefreshing:isLoadMore];
            [weakSelf.currentTableView reloadData];
        } failed:^(id object) {
            [weakSelf showLoading:NO];
            [weakSelf endRefreshing:isLoadMore];
            [weakSelf.currentTableView reloadData];
        }];
    }else if (self.pDs.projectRequestType == PrivateOceanProject){
        [self.pDs postRequestPrivateOceanProjectIsLoadMore:isLoadMore succeed:^(id object) {
            [weakSelf showLoading:NO];
            [weakSelf endRefreshing:isLoadMore];
            [weakSelf.currentTableView reloadData];
        } failed:^(id object) {
            [weakSelf showLoading:NO];
            [weakSelf endRefreshing:isLoadMore];
            [weakSelf.currentTableView reloadData];
        }];
    }else{
        [self.pDs postRequestCCProjectIsLoadMore:isLoadMore succeed:^(id object) {
            [weakSelf showLoading:NO];
            [weakSelf endRefreshing:isLoadMore];
            [weakSelf.currentTableView reloadData];
        } failed:^(id object) {
            [weakSelf showLoading:NO];
            [weakSelf endRefreshing:isLoadMore];
            [weakSelf.currentTableView reloadData];
        }];
    }
}

- (void)endRefreshing:(BOOL)isLoadMore{
    if (!isLoadMore) {
        [self.currentTableView.header endRefreshing];
    }else {
        [self.currentTableView.footer endRefreshing];
    }
}


- (void)tabButtonDidClicked:(UIButton *)button{
    self.currentTableView.hidden = YES;
    self.currentTableView = [self.projectTableViewsAry objectAtIndex:button.tag - 100];
    switch (button.tag) {
        case 100:
            self.pDs.projectRequestType = OnlineProject;
            [self.currentTableView reloadData];
            break;
        case 101:
            self.pDs.projectRequestType = PrivateOceanProject;
            if (self.pDs.privateOceanProjectAry.count > 0) {
                [self.currentTableView reloadData];
            }else{
                [self isloadMoreAction:NO];
            }
            break;
        default:
            self.pDs.projectRequestType = CCNeedsProject;
            if (self.pDs.ccNeedsProjectAry.count > 0) {
                [self.currentTableView reloadData];
            }else{
                [self isloadMoreAction:NO];
            }
            break;
    }
    self.currentTableView.hidden = NO;
}

#pragma mark tableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 118.0f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.pDs.projectRequestType == OnlineProject) {
        return self.pDs.onlineProjectAry.count;
    }else if (self.pDs.projectRequestType == PrivateOceanProject){
        return self.pDs.privateOceanProjectAry.count;
    }else{
        return self.pDs.ccNeedsProjectAry.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identy = @"projectTableViewCell";
    ProjectTableViewCell *projectTableViewCell = [tableView dequeueReusableCellWithIdentifier:identy];
    if (projectTableViewCell == nil) {
        projectTableViewCell = [[ProjectTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identy];
        projectTableViewCell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if (self.pDs.projectRequestType == OnlineProject) {
        if (self.pDs.onlineProjectAry.count > 0 && indexPath.row < self.pDs.onlineProjectAry.count) {
            [projectTableViewCell setData:[self.pDs.onlineProjectAry objectAtIndex:indexPath.row] projectType:self.pDs.projectRequestType];
        }
    } else if (self.pDs.projectRequestType == PrivateOceanProject){
        if (self.pDs.privateOceanProjectAry.count > 0 && indexPath.row < self.pDs.privateOceanProjectAry.count) {
            [projectTableViewCell setData:[self.pDs.privateOceanProjectAry objectAtIndex:indexPath.row] projectType:self.pDs.projectRequestType];
        }
    } else{
        if (self.pDs.ccNeedsProjectAry.count > 0 && indexPath.row < self.pDs.ccNeedsProjectAry.count) {
            [projectTableViewCell setData:[self.pDs.ccNeedsProjectAry objectAtIndex:indexPath.row] projectType:self.pDs.projectRequestType];
        }
    }
    
    [self.currentTableView registerClass:[ProjectTableViewCell class] forCellReuseIdentifier:identy];
    return projectTableViewCell;
}


/*
 *下个版本上
 */

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    if (self.pDs.projectRequestType == OnlineProject) {
//        return 30.0f;
//    }
//    return 0;
//}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    
//    if (self.pDs.projectRequestType == OnlineProject) {
//        UIView * headerView = [[UIView alloc] init];
//        headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 30);
//        headerView.backgroundColor = RGBCOLOR(240, 239, 245);
//        
//        UILabel *headerLabel = [[UILabel alloc] init];
//        headerLabel.text = @"当前显示为全部状态、顾问的项目，";
//        headerLabel.textColor = BLACK_COLOR;
//        headerLabel.font = [UIFont systemFontOfSize:14];
//        headerLabel.textAlignment = NSTextAlignmentNatural;
//        headerLabel.frame = CGRectMake((SCREEN_WIDTH - 230 - 70) / 2.0, 0, 230, 30);
//        headerLabel.backgroundColor = [UIColor clearColor];
//        [headerView addSubview:headerLabel];
//        
//        //设置button下划线
//        NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"可点此筛选"];
//        NSRange strRange = {0,[str length]};
//        [str addAttribute:NSForegroundColorAttributeName value:BLUE_COLOR range:strRange];  //设置颜色
//        [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
//        
//        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [btn setFrame:CGRectMake(headerLabel.right , 0, 70, 30)];
//        [[btn titleLabel] setFont:[UIFont systemFontOfSize:14]];
//        [btn setTitleColor:BLUE_COLOR forState:UIControlStateNormal];
//        [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];      //btn左对齐
//        [btn setAttributedTitle:str forState:UIControlStateNormal];
//        [btn addTarget:self action:@selector(selectedProject) forControlEvents:UIControlEventTouchUpInside];
//        [headerView addSubview:btn];
//        return headerView;
//    }else {
//        return nil;
//    }
//    
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
    ProjectDetailViewController *pdvc = [[ProjectDetailViewController alloc] init];
    if (self.pDs.projectRequestType == OnlineProject) {
        ProjectListItem *item = [self.pDs.onlineProjectAry objectAtIndex:indexPath.row];
        pdvc.project_Id = item.projectId;
    }else if (self.pDs.projectRequestType == PrivateOceanProject){
        ProjectListItem *item = [self.pDs.privateOceanProjectAry objectAtIndex:indexPath.row];
        pdvc.project_Id = item.projectId;
    }else{
        ProjectListItem *item = [self.pDs.ccNeedsProjectAry objectAtIndex:indexPath.row];
        pdvc.project_Id = item.projectId;
    }
    [self.navigationController pushViewController:pdvc animated:YES];
}

- (void)selectedProject{
    NSLog(@"筛选项目");
}

- (void)createProjectTableViews{
    for (NSInteger i = 0; i < 3; i++) {
        UITableView *projectTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.projectTopBar.bottom, SCREEN_WIDTH, self.view.height - self.projectTopBar.height - 113) style:UITableViewStylePlain];
        projectTableView.delegate = self;
        projectTableView.dataSource = self;
        projectTableView.rowHeight = 118;
        projectTableView.tag = 100 + i;
        projectTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [projectTableView registerClass:[ProjectTableViewCell class] forCellReuseIdentifier:@"projectTableViewCell"];
        projectTableView.backgroundColor = RGBCOLOR(240, 239, 245);
        if (i == 0) {
            projectTableView.hidden = NO;
            self.currentTableView = projectTableView;
        }else{
            projectTableView.hidden = YES;
        }
        
        projectTableView.header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(reFeshingNewestDatasAction)];
        projectTableView.footer=[MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreDatasAction)];        
        [self.view addSubview:projectTableView];
        [self.projectTableViewsAry addObject:projectTableView];
    }
}

- (void)reFeshingNewestDatasAction{
    if ([[NetworkManager sharedInstance] checkNetAndToken]) {
        [self isloadMoreAction:NO];
    } else {
        [AlertManager showAlertText:@"亲！网络不给力，暂时无法刷新哦～～～" withCloseSecond:1];
        [self endRefreshing:NO];
    }
}

- (void)loadMoreDatasAction{
    [self isloadMoreAction:YES];
}

- (void)addProject:(id)sender{
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
    [self performSegueWithIdentifier:@"addProjectSegue" sender:self];
}

- (void)addCC:(id)sender{
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
    [self performSegueWithIdentifier:@"addCCSegue" sender:self];

}

- (void)rightBarItemClicked:(id)sender{
    NSArray *menuItems =
    @[
      [KxMenuItem menuItem:@"新增项目"
                     image:[UIImage imageNamed:@"add_project"]
                    target:self
                    action:@selector(addProject:)],

      [KxMenuItem menuItem:@"新增CC"
                     image:[UIImage imageNamed:@"add_project"]
                    target:self
                    action:@selector(addCC:)]
      ];
    if (self.isKxMenuHiden) {
        [KxMenu showMenuInView:self.view
                      fromRect:CGRectMake(self.projectTopBar.frame.size.width - 50, self.projectTopBar.frame.origin.y , 50, 0)
                     menuItems:menuItems];
        self.isKxMenuHiden = NO;
    }else{
        [KxMenu dismissMenu];
        self.isKxMenuHiden = YES;
    }
    
    [KxMenu setTintColor:BLUE_COLOR];
    [KxMenu setTitleFont:[UIFont systemFontOfSize:17]];
}

- (void)leftBarItemClicked:(id)sender{
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
    SearchProjectViewController *svc = [[SearchProjectViewController alloc] init];
    [self.navigationController pushViewController:svc animated:YES];
}

- (void)createNavigationBarItems{
    self.rightBarButtonItem = [UIBarButtonItem rsBarButtonItemWithTitle:@"新增" image:nil heightLightImage:nil disableImage:nil target:self action:@selector(rightBarItemClicked:)];
    [self  addRightBarButtonItem:self.rightBarButtonItem];
    
    self.leftBarButtonItem = [UIBarButtonItem rsBarButtonItemWithTitle:nil image:[UIImage imageNamed:@"project_icon_search2"] heightLightImage:nil disableImage:nil target:self action:@selector(leftBarItemClicked:)];
    [self  addLeftBarButtonItem:self.leftBarButtonItem];
}

- (void)addRightBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    
   negativeSpacer.width = -20;
   self.projectNavigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, barButtonItem, nil];
}

- (void)addLeftBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    
    negativeSpacer.width = -5;
    self.projectNavigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, barButtonItem, nil];
}

- (void)createProjectTopBar{
    if (!_projectTopBar) {
        self.projectTopBar = [[TopTabBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
        [self.projectTopBar initWithSubviews:[NSMutableArray arrayWithObjects:@"我的在线",@"我的私海",@"CC需求", nil]];
        self.projectTopBar.delegate = self;
    }
    [self.view addSubview:self.projectTopBar];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
