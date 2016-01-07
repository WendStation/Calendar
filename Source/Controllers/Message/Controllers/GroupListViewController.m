//
//  MessageViewController.m
//  Calendar
//
//  Created by 小华 on 15/10/19.
//  Copyright © 2015年 Robert Dimitrov. All rights reserved.
//

#import "GroupListViewController.h"
#import "GroupListCell.h"
#import "MessageListCell.h"
#import "TaskListCell.h"
#import "GroupListDatasource.h"
#import "MessageListDatasource.h"
#import "TaskListDatasource.h"
#import "TopTabBar.h"
#import "ImViewController.h"
#import "GroupListItem.h"
#import "ImManager.h"

@interface GroupListViewController ()<ProjectTopBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *imTableView;
@property (weak, nonatomic) IBOutlet UITableView *messageTableView;
@property (weak, nonatomic) IBOutlet UITableView *taskTableView;

@property (nonatomic, strong) MessageListDatasource *messageDs;
@property (nonatomic, strong) GroupListDatasource *groupDs;
@property (nonatomic, strong) TaskListDatasource *taskDs;
@property (nonatomic, strong) TopTabBar *topTabBar;
@property (nonatomic, assign) NSInteger buttonTag;

@end

@implementation GroupListViewController

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.rdv_tabBarController.tabBarHidden) {
        [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.buttonTag == 100) {
       [self getImGroupList];
    }
    [ImManager shareInstance].groupListRequestCircleSeconds = 10;
    [[ImManager shareInstance] onStop];
    [[ImManager shareInstance] onStart];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [ImManager shareInstance].groupListRequestCircleSeconds = 60;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.buttonTag = 100;
    self.groupDs = [[GroupListDatasource alloc] init];
    self.messageDs = [[MessageListDatasource alloc] init];
    self.taskDs = [[TaskListDatasource alloc] init];
    [self createTopBar];
    [self getImGroupList];
    
    self.imTableView.hidden = NO;
    self.messageTableView.estimatedRowHeight = 69;
    self.messageTableView.rowHeight = UITableViewAutomaticDimension;
    self.messageTableView.header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(reFeshingMessageNewestDatasAction)];
    self.messageTableView.footer=[MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreMessagDatasAction)];
    
    self.taskTableView.estimatedRowHeight = 69;
    self.taskTableView.rowHeight = UITableViewAutomaticDimension;
    self.taskTableView.header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(reFeshingTaskNewestDatasAction)];
    self.taskTableView.footer=[MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreTaskDatasAction)];
}

#pragma mark getGroupDatas
- (void)getImGroupList {
    __weak typeof(self) weakSelf = self;
    [self.groupDs getGroupListFromDatabase:^(id object) {
        if ([object isKindOfClass:[NSMutableArray class]]) {
            NSArray *array = (NSArray *)object;
            if (array.count == 0) {
                [AlertManager showAlertText:@"亲！本地暂无数据" withCloseSecond:1];
            } else {
                [weakSelf.imTableView reloadData];
            }
        }
    }];
}

#pragma mark getMessageDatas
- (void)reFeshingMessageNewestDatasAction {
    if (![[NetworkManager sharedInstance] checkNetAndToken]) {
        [AlertManager showAlertText:@"亲！网络不给力，暂时无法更新哦" withCloseSecond:1];
        [self endRefresh:NO];
        return;
    }
    [self getMessageList:NO];
}

- (void)loadMoreMessagDatasAction {
    [self getMessageList:YES];
}

- (void)getMessageList:(BOOL)isLoadMore {
    __weak typeof(self) weakSelf = self;
    if (![[NetworkManager sharedInstance] checkNetAndToken]) {
        [self.messageDs getMessageListFromDatabase:isLoadMore complete:^(id object) {
            if ([object isKindOfClass:[NSMutableArray class]]) {
                NSArray *array = (NSArray *)object;
                if (array.count == 0) {
                    [AlertManager showAlertText:@"亲！本地暂无数据" withCloseSecond:1];
                } else {
                    [weakSelf.messageTableView reloadData];
                    [weakSelf endRefresh:isLoadMore];
                }
            }
        }];
        return;
    }
    
    [self showLoading:YES];
    [self.messageDs postMessageListIsLoadMore:isLoadMore succeed:^(id object) {
        [weakSelf endRefresh:isLoadMore];
        [weakSelf.messageTableView reloadData];
        [weakSelf showLoading:NO];
    } failed:^(id object) {
        [weakSelf endRefresh:isLoadMore];
        [weakSelf.messageTableView reloadData];
        [weakSelf showLoading:NO];
    }];
}

#pragma mark getTaskDatas
- (void)reFeshingTaskNewestDatasAction {
    if (![[NetworkManager sharedInstance] checkNetAndToken]) {
        [AlertManager showAlertText:@"亲！网络不给力，暂时无法更新哦" withCloseSecond:1];
        [self endRefresh:NO];
        return;
    }
    [self getTaskList:NO];
}

- (void)loadMoreTaskDatasAction {
    [self getTaskList:YES];
}

- (void)getTaskList:(BOOL)isLoadMore {
    __weak typeof(self) weakSelf = self;
    if (![[NetworkManager sharedInstance] checkNetAndToken]) {
        [self.taskDs getTaskListFromDatabase:isLoadMore complete:^(id object) {
            if ([object isKindOfClass:[NSMutableArray class]]) {
                NSArray *array = (NSArray *)object;
                if (array.count == 0) {
                    [AlertManager showAlertText:@"亲！本地暂无数据" withCloseSecond:1];
                } else {
                    [weakSelf.taskTableView reloadData];
                    [weakSelf endRefresh:isLoadMore];
                }
            }
        }];
        return;
    }
    [self showLoading:YES];
    [self.taskDs postTaskListIsLoadMore:isLoadMore succeed:^(id object) {
        [weakSelf.taskTableView reloadData];
        [weakSelf endRefresh:isLoadMore];
        [weakSelf showLoading:NO];
    } failed:^(id object) {
        [weakSelf.taskTableView reloadData];
        [weakSelf endRefresh:isLoadMore];
        [weakSelf showLoading:NO];
    }];
}

- (void)endRefresh:(BOOL)isLoadMore {
    if (isLoadMore) {
        [self.messageTableView.footer endRefreshing];
        [self.taskTableView.footer endRefreshing];
    } else {
        [self.messageTableView.header endRefreshing];
        [self.taskTableView.header endRefreshing];
    }
}

#pragma mark topBarDelegate
- (void)tabButtonDidClicked:(UIButton *)button {
    self.buttonTag = button.tag;
    switch (button.tag) {
        case 100:
            self.imTableView.hidden = NO;
            self.messageTableView.hidden = YES;
            self.taskTableView.hidden = YES;
            [self getImGroupList];
            break;
        case 101:
            self.imTableView.hidden = YES;
            self.messageTableView.hidden = NO;
            self.taskTableView.hidden = YES;
            if (self.messageDs.messageListAry.count == 0) {
                [self getMessageList:NO];
            } else {
                [self.messageTableView reloadData];
            }
            break;
        default:
            self.imTableView.hidden = YES;
            self.messageTableView.hidden = YES;
            self.taskTableView.hidden = NO;
            if (self.taskDs.taskListAry.count == 0) {
                [self getTaskList:NO];
            } else {
                [self.taskTableView reloadData];
            }
            break;
    }
}

#pragma mark tableViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.imTableView) {
        return self.groupDs.groupListAry.count;
    } else if (tableView == self.messageTableView) {
        return self.messageDs.messageListAry.count;
    } else {
        return self.taskDs.taskListAry.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.imTableView) {
        GroupListCell *cell;
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell0"];
        if (self.groupDs.groupListAry.count > 0 && indexPath.row < self.groupDs.groupListAry.count) {
            [cell setData:[self.groupDs.groupListAry objectAtIndex:indexPath.row]];
        }
        return cell;
    } else if (tableView == self.messageTableView) {
        MessageListCell *cell;
        cell = [tableView dequeueReusableCellWithIdentifier:@"messageCell0"];
        if (self.messageDs.messageListAry.count > 0 && indexPath.row < self.messageDs.messageListAry.count) {
            [cell setData:[self.messageDs.messageListAry objectAtIndex:indexPath.row]];
        }
        return cell;
    } else {
        TaskListCell *cell;
        cell = [tableView dequeueReusableCellWithIdentifier:@"taskCell0"];
        if (self.taskDs.taskListAry.count > 0 && indexPath.row < self.taskDs.taskListAry.count) {
            [cell setData:[self.taskDs.taskListAry objectAtIndex:indexPath.row]];
        }
        return cell;
    }
    UITableViewCell *cell;
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"blankCell"];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[self rdv_tabBarController] setTabBarHidden:YES animated:YES];
    if (indexPath.row < self.groupDs.groupListAry.count) {
        GroupListItem *item = [self.groupDs.groupListAry objectAtIndex:indexPath.row];
        ImViewController *vc = [[ImViewController alloc] init];
        vc.imTitle = item.name;
        vc.groupId = [NSString stringWithFormat:@"%ld",(long)item.groupId];
        vc.projectId = [NSString stringWithFormat:@"%ld",(long)item.projectId];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)createTopBar{
    if (!_topTabBar) {
        self.topTabBar = [[TopTabBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
        [self.topTabBar initWithSubviews:[NSMutableArray arrayWithObjects:@"IM",@"消息",@"任务", nil]];
        self.topTabBar.delegate = self;
    }
    [self.view addSubview:self.topTabBar];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
