//
//  ProjectDetailViewController.m
//  Calendar
//
//  Created by 刘花椒 on 15/11/4.
//
//

#import "ProjectDetailViewController.h"
#import "TopTabBar.h"
#import "ProjectDetailDatasource.h"
#import "ProjectDetailItem.h"
#import "ProjectDetailTableViewCell.h"
#import "UpdateRecordTabelViewCell.h"
#import "MeetingRecordTableViewCell.h"
#import "ProjectWebViewController.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface ProjectDetailViewController ()<ProjectTopBarDelegate,
                            RelatedHttpURLTableViewCellDelegate,
                                 RelationProjectFounderDelegate,
                            MFMailComposeViewControllerDelegate,
                                            UIAlertViewDelegate>

@property(nonatomic, strong)NSMutableArray *topTabBars;
@property(nonatomic, strong)NSMutableArray *toStatusList;
@property(nonatomic, strong)NSMutableArray *operationUrl;
@property(nonatomic, strong)UIBarButtonItem *rightBarButtonItem;
@property(nonatomic, strong)NSURLConnection *urlConnection;
@property(nonatomic, assign)int lastPosition;
@property(nonatomic, strong)UIButton *slipTopBtn;
@property(nonatomic, strong)UIButton *lookBPBtn;
@property(nonatomic, strong)NSMutableArray *whitelist;
@property(nonatomic, strong)NSMutableArray *blackList;
@property(nonatomic, strong)NSMutableArray *competitorStatus;
@property(nonatomic, strong)NSMutableArray *projectBasicInfo;
@property(nonatomic, strong)NSMutableArray *projectHeaderTitles;
@property(nonatomic, strong)ProjectDetailItem *projectDetailItem;
@property(nonatomic, strong)ProjectDetailDatasource *Ds;
@property(nonatomic, strong)TopTabBar * projectDetailTopBar;
@property(nonatomic, strong)UITableView *projectDetailTableView;
@property(nonatomic, strong)UITableView *meetingRecordTableView;
@property(nonatomic, strong)UITableView *updateRecordTableView;

@end

@implementation ProjectDetailViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (instancetype)init{
    if (self = [super init]) {
        self.Ds = [[ProjectDetailDatasource alloc] init];
        self.topTabBars = [NSMutableArray arrayWithCapacity:0];
        self.toStatusList = [NSMutableArray arrayWithCapacity:0];
        self.operationUrl = [NSMutableArray arrayWithCapacity:0];
        self.whitelist = [NSMutableArray arrayWithObjects:@"黑名单模式/白名单模式",@"基金投资人白名单",@"可见投资人级别",@"战投基金是否可见",@"阶段",nil];
        self.blackList = [NSMutableArray arrayWithObjects:@"黑名单模式/白名单模式",@"基金投资人黑名单",@"可见投资人级别",@"战投基金是否可见",@"币种",@"阶段",nil];
        self.competitorStatus = [NSMutableArray arrayWithObjects:@"竞争对手",@"见过投资者",@"现有投资者",nil];
        self.projectBasicInfo = [NSMutableArray arrayWithObjects:@"项目名称",@"顾问",@"运营",@"推荐人",@"品类",@"地域",@"项目亮点",@"融资规模",@"出让比例",nil];
        self.projectHeaderTitles = [NSMutableArray arrayWithObjects:@"投资亮点",@"项目详述",@"相关网址",@"运营数据",@"团队情况",@"竞争情况与现有投资人",@"项目可见性", nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BACKGROUND_COLOR;
    self.title = @"项目详情";
    [self createProjectDetailTopBar];
    if ([[NetworkManager sharedInstance] checkNetAndToken]) {
        [self getProjectDetailStatusDatas];
    }
    [self getProjectDetailDatas];
}

- (void)getProjectDetailStatusDatas{
    __weak typeof(self) weakSelf = self;
    [self.Ds postRequestProjectStatusID:self.project_Id succeed:^(id object) {
        if ([object isKindOfClass:[NSArray class]]) {
            NSArray *array = (NSArray *)object;
            if (array.count > 0) {
                [weakSelf.toStatusList removeAllObjects];
                [weakSelf.operationUrl removeAllObjects];
                for (NSInteger i = 0; i < [array count]; i++) {
                    ProjectStatusItem *item = [array objectAtIndex:i];
                    if (![item.statusText isEqualToString:@"(null)"] && item.statusText.length > 0) {
                        for (ProjectToStatusListItem *itemList in item.toStatusList) {
                            if (![itemList.operationText isEqualToString:@"(null)"] && itemList.operationText.length > 0) {
                                NSString *statusStr = [NSString stringWithFormat:@"%@ - %@",item.statusText,itemList.operationText];
                                [weakSelf.toStatusList addObject:statusStr];
                                [weakSelf.operationUrl addObject:itemList.operationUrl];
                            }
                        }
                    }
                }
                [weakSelf createRightNavigationBarItem];
            }
        }
    } failed:^(id object) {
        
    }];
}

- (void)getProjectDetailDatas{
    __weak typeof(self) weakSelf = self;
    if (![[NetworkManager sharedInstance] checkNetAndToken]) {
        [self.Ds getProjectDetailFromDatabase:self.project_Id complete:^(ProjectDetailItem *item) {
            if (item != nil) {
                weakSelf.projectDetailItem = item;
                [weakSelf deleteBlankDatas];
                [weakSelf.projectDetailTableView reloadData];
                if (![weakSelf.projectDetailItem.attach isEqualToString:@"(null)"] && weakSelf.projectDetailItem.attach.length > 0) {
                    weakSelf.lookBPBtn.hidden = NO;
                }
                weakSelf.slipTopBtn.hidden = NO;
            } else {
                [AlertManager showAlertText:@"亲！本地暂无数据" withCloseSecond:1];
            }
        }];
        return;
    }
    [self showLoading:YES];
    [self.Ds postRequestProjectDetailID:self.project_Id succeed:^(id object) {
        if ([object isKindOfClass:[ProjectDetailItem class]]) {
            weakSelf.projectDetailItem = (ProjectDetailItem *)object;
        }
        [weakSelf deleteBlankDatas];
        [weakSelf showLoading:NO];
        [weakSelf.projectDetailTableView reloadData];
        if (![weakSelf.projectDetailItem.attach isEqualToString:@"(null)"] && weakSelf.projectDetailItem.attach.length > 0) {
            weakSelf.lookBPBtn.hidden = NO;
        }
        weakSelf.slipTopBtn.hidden = NO;
    } failed:^(id object) {
        if ([object isKindOfClass:[ProjectDetailItem class]]) {
            weakSelf.projectDetailItem = (ProjectDetailItem *)object;
        }
        [weakSelf deleteBlankDatas];
        [weakSelf showLoading:NO];
        [weakSelf.projectDetailTableView reloadData];
        if (![weakSelf.projectDetailItem.attach isEqualToString:@"(null)"] && weakSelf.projectDetailItem.attach.length > 0) {
            weakSelf.lookBPBtn.hidden = NO;
        }
        weakSelf.slipTopBtn.hidden = NO;
    }];
}

- (void)deleteBlankDatas {
    if ([self.projectDetailItem.investHighlights isKindOfClass:[NSNull class]] || self.projectDetailItem.investHighlights.length == 0) {
        [self.projectHeaderTitles removeObject:@"投资亮点"];
    }
    if ([self.projectDetailItem.companyDetail isKindOfClass:[NSNull class]] || self.projectDetailItem.companyDetail.count == 0) {
        [self.projectHeaderTitles removeObject:@"项目详述"];
    }
    if ([self.projectDetailItem.links isKindOfClass:[NSNull class]] || self.projectDetailItem.links.count == 0) {
        [self.projectHeaderTitles removeObject:@"相关网址"];
    }
    if ([self.projectDetailItem.operationData isKindOfClass:[NSNull class]] || self.projectDetailItem.operationData.length == 0) {
        [self.projectHeaderTitles removeObject:@"运营数据"];
    }
    if ([self.projectDetailItem.teamInfo isKindOfClass:[NSNull class]] || self.projectDetailItem.teamInfo.count == 0) {
        [self.projectHeaderTitles removeObject:@"团队情况"];
    }
}

- (void)getMeetingRecordDatas{
    __weak typeof(self) weakSelf = self;
    if (![[NetworkManager sharedInstance] checkNetAndToken]) {
        [self.Ds getMeetingRecordFromDatabase:self.project_Id complete:^(NSMutableArray *array) {
            if (array.count > 0) {
                [weakSelf.meetingRecordTableView reloadData];
            } else {
                [AlertManager showAlertText:@"亲！本地暂无数据" withCloseSecond:1];
            }
        }];
        return;
    }
    [self showLoading:YES];
    [self.Ds postRequestMeetingRecordID:self.project_Id succeed:^(id object) {
        [weakSelf showLoading:NO];
        [weakSelf.meetingRecordTableView reloadData];
    } failed:^(id object) {
        [weakSelf showLoading:NO];
        [weakSelf.meetingRecordTableView reloadData];
    }];
}

- (void)getUpdateRecordDatas{
    __weak typeof(self) weakSelf = self;
    if (![[NetworkManager sharedInstance] checkNetAndToken]) {
        [self.Ds getUpdateRecordFromDatabase:self.project_Id complete:^(NSMutableArray *array) {
            if (array.count > 0) {
                [weakSelf.updateRecordTableView reloadData];
            } else {
                [AlertManager showAlertText:@"亲！本地暂无数据" withCloseSecond:1];
            }
        }];
        return;
    }
    [self showLoading:YES];
    [self.Ds postRequestUpdateRecordID:self.project_Id succeed:^(id object) {
        [weakSelf showLoading:NO];
        [weakSelf.updateRecordTableView reloadData];
    } failed:^(id object) {
        [weakSelf showLoading:NO];
        [weakSelf.updateRecordTableView reloadData];
    }];
}

- (void)rightBarItemClicked:(id)sender{
    ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        [self.Ds alterRequestProjectStatus:[self.operationUrl objectAtIndex:selectedIndex] complete:^(id object) {
            if ([object isKindOfClass:[NSString class]]) {
                NSString *message = (NSString *)object;
                if ([message isEqualToString:@"成功"]) {
                    [self getProjectDetailStatusDatas];
                }
            }
        }];
    };
    ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
        NSLog(@"Block Picker Canceled");
    };
    ActionSheetStringPicker* picker = [[ActionSheetStringPicker alloc] initWithTitle:@"修改项目状态" rows:self.toStatusList initialSelection:0 doneBlock:done cancelBlock:cancel origin:sender];
    picker.tapDismissAction = TapActionCancel;
    [picker showActionSheetPicker];

}

- (void)createRightNavigationBarItem{
    self.rightBarButtonItem = [UIBarButtonItem rsBarButtonItemWithTitle:@"操作" image:nil heightLightImage:nil disableImage:nil target:self action:@selector(rightBarItemClicked:)];
    
    [self  addRightBarButtonItem:self.rightBarButtonItem];
}

- (void)addRightBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    
    negativeSpacer.width = -20;
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer, barButtonItem, nil];
}

- (void)createProjectDetailTopBar{
    if (!_projectDetailTopBar) {
        self.projectDetailTopBar = [[TopTabBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
        [self.projectDetailTopBar initWithSubviews:[NSMutableArray arrayWithObjects:@"项目详情",@"会议记录",@"跟进纪录", nil]];
        self.projectDetailTopBar.delegate = self;
    }
    [self.view addSubview:self.projectDetailTopBar];

}

- (void)tabButtonDidClicked:(UIButton *)button{
    
    switch (button.tag) {
        case 100:
            self.lookBPBtn.hidden = NO;
            self.slipTopBtn.hidden = NO;
            self.projectDetailTableView.hidden = NO;
            self.meetingRecordTableView.hidden = YES;
            self.updateRecordTableView.hidden = YES;
            if (self.projectDetailItem == nil) {
                [self getProjectDetailDatas];
            } else {
                [self.projectDetailTableView reloadData];
            }
            break;
        case 101:
            self.lookBPBtn.hidden = YES;
            self.slipTopBtn.hidden = YES;
            self.projectDetailTableView.hidden = YES;
            self.meetingRecordTableView.hidden = NO;
            self.updateRecordTableView.hidden = YES;
            if (self.Ds.meetingRecordAry.count == 0) {
                [self getMeetingRecordDatas];
            } else {
                [self.meetingRecordTableView reloadData];
            }
            break;
        default:
            self.lookBPBtn.hidden = YES;
            self.slipTopBtn.hidden = YES;
            self.projectDetailTableView.hidden = YES;
            self.meetingRecordTableView.hidden = YES;
            self.updateRecordTableView.hidden = NO;
            if (self.Ds.updateRecordAry.count == 0) {
                [self getUpdateRecordDatas];
            } else {
                [self.updateRecordTableView reloadData];
            }
            break;
    }
    
}

#pragma mark tableViewDelegateAndDatasource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.projectDetailTableView) {
        NSString *title = @"";
        if (indexPath.section != 0) {
            title = [self.projectHeaderTitles objectAtIndex:indexPath.section - 1];
        }
        if (indexPath.section == 0 || [title isEqualToString:@"竞争情况与现有投资人"] || [title isEqualToString:@"项目可见性"]) {
            if (self.projectDetailItem != nil) {
                static ProjectDetailTableViewCell *cell = nil;
                if (!cell) {
                    cell = [[ProjectDetailTableViewCell alloc] init];
                }
                if (indexPath.section == 0) {
                    cell.projectInformation = ProjectBasicInfo;
                } else if ([title isEqualToString:@"竞争情况与现有投资人"]) {
                    cell.projectInformation = ProjectCompetition;
                } else {
                    cell.projectInformation = ProjectVisibility;
                }
                return [cell tableView:tableView rowHeightForObject:self.projectDetailItem index:indexPath];
            }
        } else if ([title isEqualToString:@"投资亮点"]) {
            static InvestHighlightsTableViewCell *cell = nil;
            if (!cell) {
                cell = [[InvestHighlightsTableViewCell alloc] init];
            }
            return [cell tableView:tableView rowHeightForObject:self.projectDetailItem];
        } else if ([title isEqualToString:@"项目详述"]) {
            static ProjectDescriptionTableViewCell *cell = nil;
            if (!cell) {
                cell = [[ProjectDescriptionTableViewCell alloc] init];
            }
            return [cell tableView:tableView rowHeightForObject:self.projectDetailItem.companyDetail];
        } else if ([title isEqualToString:@"相关网址"]) {
            return 100.0f;
        } else if ([title isEqualToString:@"运营数据"]) {
            static OperationDataTableViewCell *cell = nil;
            if (!cell) {
                cell = [[OperationDataTableViewCell alloc] init];
            }
            return [cell tableView:tableView rowHeightForObject:self.projectDetailItem.operationData];
        } else if ([title isEqualToString:@"团队情况"]) {
            static TeamInfoTableViewCell *cell = nil;
            if (!cell) {
                cell = [[TeamInfoTableViewCell alloc] init];
            }
            return [cell tableView:tableView rowHeightForObject:self.projectDetailItem.teamInfo];
        }

    } else if (tableView == self.updateRecordTableView) {
        static UpdateRecordTabelViewCell *cell = nil;
        if (!cell) {
            cell = [[UpdateRecordTabelViewCell alloc] init];
        }
        return [cell tableView:tableView rowHeightForObject:[self.Ds.updateRecordAry objectAtIndex:indexPath.row]];
    } else {
        static MeetingRecordTableViewCell *cell = nil;
        if (!cell) {
            cell = [[MeetingRecordTableViewCell alloc] init];
        }
        return [cell tableView:tableView rowHeightForObject:[self.Ds.meetingRecordAry objectAtIndex:indexPath.row]];
    }
    return 44.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView == self.projectDetailTableView) {
        if (self.projectDetailItem == nil) {
            return 0;
        }
        return self.projectHeaderTitles.count + 1;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.projectDetailTableView) {
        if (self.projectDetailItem == nil) {
            return 0;
        }
        if (section == 0) {
            return self.projectBasicInfo.count;
        }else{
            NSString *title = [self.projectHeaderTitles objectAtIndex:section - 1];
            if ([title isEqualToString:@"竞争情况与现有投资人"]) {
                return self.competitorStatus.count;
            } else if ([title isEqualToString:@"项目可见性"]) {
                if ([self.projectDetailItem.visibleMode isEqualToString:@"white"]) {
                    return self.whitelist.count;
                }else{
                    return self.blackList.count;
                }
            } else {
                return 1;
            }
        }
    } else if (tableView == self.updateRecordTableView) {
        return [self.Ds.updateRecordAry count];
    } else {
        return [self.Ds.meetingRecordAry count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.projectDetailTableView) {
        NSString *title = @"";
        if (indexPath.section != 0) {
            title = [self.projectHeaderTitles objectAtIndex:indexPath.section - 1];
        }
        if (indexPath.section == 0 || [title isEqualToString:@"竞争情况与现有投资人"] || [title isEqualToString:@"项目可见性"]) {
            static NSString *identy = @"projectDetailTableViewCell";
            ProjectDetailTableViewCell *projectDetailTableViewCell = [tableView dequeueReusableCellWithIdentifier:identy];
            if (projectDetailTableViewCell == nil) {
                projectDetailTableViewCell = [[ProjectDetailTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identy];
            }
            if (self.projectDetailItem != nil) {
                if (indexPath.section == 0) {
                    projectDetailTableViewCell.projectInformation = ProjectBasicInfo;
                    [projectDetailTableViewCell setData:self.projectDetailItem title:[self.projectBasicInfo objectAtIndex:indexPath.row] index:indexPath];
                } else if ([title isEqualToString:@"竞争情况与现有投资人"]) {
                    projectDetailTableViewCell.projectInformation = ProjectCompetition;
                    [projectDetailTableViewCell setData:self.projectDetailItem title:[self.competitorStatus objectAtIndex:indexPath.row] index:indexPath];
                } else {
                    projectDetailTableViewCell.projectInformation = ProjectVisibility;
                    if (![self.projectDetailItem.visibleMode isEqualToString:@"(null)"] && self.projectDetailItem.visibleMode.length > 0) {
                        if ([self.projectDetailItem.visibleMode isEqualToString:@"white"]) {
                            [projectDetailTableViewCell setData:self.projectDetailItem title:[self.whitelist objectAtIndex:indexPath.row] index:indexPath];
                        } else {
                            [projectDetailTableViewCell setData:self.projectDetailItem title:[self.blackList objectAtIndex:indexPath.row] index:indexPath];
                        }
                    }
                }
                
            }
            return projectDetailTableViewCell;
        } else if ([title isEqualToString:@"投资亮点"]) {
            static NSString *identy = @"investHighlightsTableViewCell";
            InvestHighlightsTableViewCell *investHighlightsTableViewCell = [tableView dequeueReusableCellWithIdentifier:identy];
            if (investHighlightsTableViewCell == nil) {
                investHighlightsTableViewCell = [[InvestHighlightsTableViewCell alloc
                                                  ]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identy];
            }
            if (self.projectDetailItem != nil) {
                [investHighlightsTableViewCell setData:self.projectDetailItem];
            }
            return investHighlightsTableViewCell;
        } else if ([title isEqualToString:@"项目详述"]) {
            static NSString *identy = @"projectDescriptionTableViewCell";
            ProjectDescriptionTableViewCell *projectDescriptionTableViewCell = [tableView dequeueReusableCellWithIdentifier:identy];
            if (projectDescriptionTableViewCell == nil) {
                projectDescriptionTableViewCell = [[ProjectDescriptionTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identy];
            }
            if (self.projectDetailItem != nil) {
                [projectDescriptionTableViewCell setData:self.projectDetailItem.companyDetail];
            }
            return projectDescriptionTableViewCell;
        } else if ([title isEqualToString:@"相关网址"]) {
            static NSString *identy = @"relatedHttpURLTableViewCell";
            RelatedHttpURLTableViewCell *relatedHttpURLTableViewCell = [tableView dequeueReusableCellWithIdentifier:identy];
            if (relatedHttpURLTableViewCell == nil) {
                relatedHttpURLTableViewCell = [[RelatedHttpURLTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identy];
            }
            if (self.projectDetailItem != nil) {
                relatedHttpURLTableViewCell.delegate = self;
                [relatedHttpURLTableViewCell setData:self.projectDetailItem.links];
            }
            return relatedHttpURLTableViewCell;
        } else if ([title isEqualToString:@"运营数据"]) {
            static NSString *identy = @"operationDataTableViewCell";
            OperationDataTableViewCell *operationDataTableViewCell = [tableView dequeueReusableCellWithIdentifier:identy];
            if (operationDataTableViewCell == nil) {
                operationDataTableViewCell = [[OperationDataTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identy];
            }
            if (self.projectDetailItem != nil) {
                [operationDataTableViewCell setData:self.projectDetailItem.operationData];
            }
            return operationDataTableViewCell;
        } else if ([title isEqualToString:@"团队情况"]) {
            static NSString *identy = @"teamInfoTableViewCell";
            TeamInfoTableViewCell *teamInfoTableViewCell = [tableView dequeueReusableCellWithIdentifier:identy];
            if (teamInfoTableViewCell == nil) {
                teamInfoTableViewCell = [[TeamInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identy];
            }
            if (self.projectDetailItem != nil) {
                teamInfoTableViewCell.delegate = self;
                [teamInfoTableViewCell setData:self.projectDetailItem.teamInfo];
            }
            return teamInfoTableViewCell;
        }

    } else if (tableView == self.updateRecordTableView) {
        static NSString *identy = @"updateRecordTabelViewCell";
        UpdateRecordTabelViewCell *updateRecordTabelViewCell = [tableView dequeueReusableCellWithIdentifier:identy];
        if (updateRecordTabelViewCell == nil) {
            updateRecordTabelViewCell = [[UpdateRecordTabelViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identy];
        }
        if (self.Ds.updateRecordAry.count > 0) {
            [updateRecordTabelViewCell setData:[self.Ds.updateRecordAry objectAtIndex:indexPath.row]];
        }
        return updateRecordTabelViewCell;
    } else {
        static NSString *identy = @"meetingRecordTableViewCell";
        MeetingRecordTableViewCell *meetingRecordTableViewCell = [tableView dequeueReusableCellWithIdentifier:identy];
        if (meetingRecordTableViewCell == nil) {
            meetingRecordTableViewCell = [[MeetingRecordTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identy];
        }
        if (self.Ds.meetingRecordAry.count > 0) {
            [meetingRecordTableViewCell setData:[self.Ds.meetingRecordAry objectAtIndex:indexPath.row]];
        }
        return meetingRecordTableViewCell;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (tableView == self.projectDetailTableView) {
        if (section == 0) {
            return 0;
        }
        return 39.0f;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (tableView == self.projectDetailTableView) {
        if (section == 0) {
            return nil;
        }else{
            UIView * headerView = [[UIView alloc] init];
            headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 39);
            headerView.backgroundColor = RGBCOLOR(240, 239, 245);
            
            UILabel *headerTitle = [[UILabel alloc] initWithFrame:CGRectMake(evaluate(10), 0, SCREEN_WIDTH - evaluate(10), 39)];
            headerTitle.backgroundColor = [UIColor clearColor];
            headerTitle.text = [self.projectHeaderTitles objectAtIndex:section - 1];
            headerTitle.textColor = BLACK_COLOR;
            headerTitle.font = [UIFont systemFontOfSize:16];
            [headerView addSubview:headerTitle];
            
            return headerView;
        }
    }else{
        return nil;
    }
}

- (void)lookBP:(id)sender{
    if (![self.projectDetailItem.attach isEqualToString:@"(null)"] && self.projectDetailItem.attach.length > 0 ) {
        __block BOOL isExist;
        __weak typeof(self) weakSelf = self;
        NSArray *array = [[PlistCacheManager shareInstance] BPFileKeys];
        [array enumerateObjectsUsingBlock:^(NSString *str, NSUInteger idx, BOOL *stop) {
            if ([str isEqualToString:weakSelf.project_Id]) {
                *stop = YES;
                isExist = YES;
            }
        }];
        if (isExist) {
            NSMutableDictionary *dict = [[PlistCacheManager shareInstance] getBPFileFromCache];
            NSString *fileName = [[dict valueForKey:self.project_Id] lastPathComponent];
            NSString *attachTime = [[fileName componentsSeparatedByString:@"_"] firstObject];
            if (![attachTime isEqualToString:self.projectDetailItem.attachUpdateTime]) {
                [self beginDownLoad:self.projectDetailItem];
            }else {
                [self webLoadBP:[dict valueForKey:self.project_Id]];
            }
        } else {
            [self beginDownLoad:self.projectDetailItem];
        }
    }
}

- (void)beginDownLoad:(ProjectDetailItem *)item{
    NSOperationQueue * queue = [[NSOperationQueue alloc] init];
    NSURL * url = [NSURL URLWithString:[item.attach stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest * request = [[NSURLRequest alloc] initWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSData *datas = [NSData dataWithData:data];
        [self saveBPFileToLocalWithData:datas];
    }];
}

//保存到本地
- (void)saveBPFileToLocalWithData:(NSData*)data{
    
    NSString * filePath = [self pathWithFileName:[self.projectDetailItem.attach pathExtension]];
    [data writeToFile:filePath atomically:YES];
    NSMutableDictionary *dict = [[PlistCacheManager shareInstance] getBPFileFromCache];
    if (!dict) {
        dict = [NSMutableDictionary dictionary];
    }
    if ([dict.allKeys containsObject:self.project_Id]) {
        [dict removeObjectForKey:self.project_Id];
    }
    [dict setObject:filePath forKey:self.project_Id];
    [[PlistCacheManager shareInstance] saveBPFileToCache:dict];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self webLoadBP:filePath];
    });
}
//根据url后缀名生成文件路径
- (NSString*)pathWithFileName:(NSString*)suffix{
    
    NSArray  *searchPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentpath = [searchPath objectAtIndex:0];
    NSString *folderPath = [documentpath stringByAppendingPathComponent:@"BPDownloadPath"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:folderPath isDirectory:nil]) {
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:folderPath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    
    NSString *fileName = [NSString stringWithFormat:@"%@_%@.%@",self.projectDetailItem.attachUpdateTime,self.project_Id,suffix];
    NSString *path = [folderPath stringByAppendingPathComponent:fileName];
    return path;
}

- (void)webLoadBP:(NSString *)bpPath{
    ProjectWebViewController *vc = [[ProjectWebViewController alloc] init];
    vc.bpFilePath = [self pathWithFileName:[self.projectDetailItem.attach pathExtension]];
    [self.navigationController pushViewController:vc animated:YES];
    NSLog(@"%@",bpPath);    
}

- (void)slipTop:(id)sender{
    [self.projectDetailTableView setContentOffset:CGPointMake(0, -8) animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView == self.projectDetailTableView) {
        if (self.projectDetailTableView.contentOffset.y > 0) {
            self.projectDetailTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        } else {
            self.projectDetailTableView.contentInset = UIEdgeInsetsMake(8, 0, 0, 0);
        }
        int currentPostion = scrollView.contentOffset.y;
        if (currentPostion - _lastPosition > 0 && currentPostion > 0) {
            [UIView animateWithDuration:0.5 animations:^{
                self.lookBPBtn.top = SCREEN_HEIGHT;
                self.slipTopBtn.top = self.lookBPBtn.bottom + 20;
            }];
        }else if ((_lastPosition - currentPostion > 0) && (currentPostion  <= scrollView.contentSize.height-scrollView.bounds.size.height - 20)){
            [UIView animateWithDuration:0.5 animations:^{
                self.lookBPBtn.top = SCREEN_HEIGHT - evaluate(250);
                self.slipTopBtn.top = self.lookBPBtn.bottom + 20;
            }];
        }
        _lastPosition = currentPostion;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
   
}

#pragma mark RelationProjectFounderDelegate
- (void)relationProjectFounder:(ProjectTeamsInfoItem *)item relationWay:(NSString *)way{
    if ([way isEqualToString:@"weixin"]) {
        [CommonAPI weichat:item.weixin];
    }else if ([way isEqualToString:@"phone"]) {
        [CommonAPI callPhone:item.phone];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"邮箱" message:item.email delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"发送"  , @"复制",nil];
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == 100) {
        return;
    }
    if (buttonIndex == 1) {
        [self sendMailInApp:alertView.message];
    }else if (buttonIndex == 2){
        UIPasteboard *pasterboard = [UIPasteboard generalPasteboard];
        pasterboard.string = alertView.message;
    }
}

- (void)sendMailInApp:(NSString *)mail {
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (!mailClass) {
        [AlertManager showAlertText:@"当前系统版本不支持应用内发送邮件功能，您可以使用mailto方法代替" withCloseSecond:1];
        return;
    }
    if (![mailClass canSendMail]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"邮箱" message:@"请先在“设置->邮件”中添加邮件账户" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定"  ,nil];
        alert.tag = 100;
        [alert show];
        return;
    }
    [self displayMailPicker:mail];
}
- (void)displayMailPicker:(NSString *)mail{
    MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
    mailPicker.mailComposeDelegate = self;
    NSArray *toRecipients = [NSArray arrayWithObject:mail];
    [mailPicker setToRecipients: toRecipients];
    [self presentViewController:mailPicker animated:YES completion:nil];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    [self dismissViewControllerAnimated:YES completion:nil];
    NSString *msg;
    switch (result) {
        case MFMailComposeResultCancelled:
            msg = @"用户取消编辑邮件";
            break;
        case MFMailComposeResultSaved:
            msg = @"用户成功保存邮件";
            break;
        case MFMailComposeResultSent:
            msg = @"成功加入发送列表，有可能发送失败！";
            break;
        case MFMailComposeResultFailed:
            msg = @"用户试图保存或者发送邮件失败";
            break;
        default:
            msg = @"";
            break;
    }
    
    [AlertManager showAlertText:msg withCloseSecond:1];
}

#pragma mark RelatedHttpURLTableViewCellDelegate
- (void)cellButtonClick:(UIButton *)btn urlLink:(NSString *)urlLink
{
    NSString *newUrl = urlLink;
    if (!([newUrl containsString:@"http://"] || [newUrl containsString:@"https://"])) {
        newUrl = [NSString stringWithFormat:@"http://%@",newUrl];
    }
    NSURL *urlWV = [NSURL URLWithString:[newUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[UIApplication sharedApplication] openURL:urlWV];
}

#pragma mark tableViewProperty
- (UITableView *)projectDetailTableView{
    if (!_projectDetailTableView) {
        _projectDetailTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.projectDetailTopBar.bottom, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - self.projectDetailTopBar.bottom) style:UITableViewStylePlain];
        _projectDetailTableView.contentInset = UIEdgeInsetsMake(8, 0, 0, 0);
        _projectDetailTableView.delegate = self;
        _projectDetailTableView.dataSource = self;
        _projectDetailTableView.backgroundColor = RGBCOLOR(240, 239, 245);
        _projectDetailTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _projectDetailTableView.scrollsToTop = YES;
        [self.view addSubview:_projectDetailTableView];

    }
    return _projectDetailTableView;
}

- (UITableView *)updateRecordTableView{
    if (!_updateRecordTableView) {
        _updateRecordTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.projectDetailTopBar.bottom, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - self.projectDetailTopBar.bottom) style:UITableViewStylePlain];
        _updateRecordTableView.contentInset = UIEdgeInsetsMake(8, 0, 0, 0);
        _updateRecordTableView.delegate = self;
        _updateRecordTableView.dataSource = self;
        _updateRecordTableView.backgroundColor = RGBCOLOR(240, 239, 245);
        _updateRecordTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_updateRecordTableView];
    }
    return _updateRecordTableView;
}

- (UITableView *)meetingRecordTableView{
    if (!_meetingRecordTableView) {
        _meetingRecordTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.projectDetailTopBar.bottom, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - self.projectDetailTopBar.bottom) style:UITableViewStylePlain];
        _meetingRecordTableView.delegate = self;
        _meetingRecordTableView.dataSource = self;
        _meetingRecordTableView.backgroundColor = RGBCOLOR(240, 239, 245);
        _meetingRecordTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_meetingRecordTableView];
    }
    return _meetingRecordTableView;
}

- (UIButton *)slipTopBtn{
    if (!_slipTopBtn) {
        UIImage *image = [UIImage imageNamed:@"bp_bt_top"];
        _slipTopBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _slipTopBtn.hidden = YES;
        _slipTopBtn.backgroundColor = [UIColor clearColor];
        _slipTopBtn.frame = CGRectMake(SCREEN_WIDTH - evaluate(14) - image.size.width, _lookBPBtn.bottom + 20, image.size.width, image.size.height);
        [_slipTopBtn addTarget:self action:@selector(slipTop:) forControlEvents:UIControlEventTouchUpInside];
        [_slipTopBtn setImage:image forState:UIControlStateNormal];
        [self.view addSubview:_slipTopBtn];
    }
    return _slipTopBtn;
}

- (UIButton *)lookBPBtn{
    if (!_lookBPBtn) {
        UIImage *image = [UIImage imageNamed:@"bp_chakanbp"];
        _lookBPBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _lookBPBtn.backgroundColor = [UIColor clearColor];
        _lookBPBtn.hidden = YES;
        _lookBPBtn.frame = CGRectMake(SCREEN_WIDTH - evaluate(14) - image.size.width, SCREEN_HEIGHT - evaluate(250), image.size.width, image.size.height);
        [_lookBPBtn addTarget:self action:@selector(lookBP:) forControlEvents:UIControlEventTouchUpInside];
        [_lookBPBtn setImage:image forState:UIControlStateNormal];
        [self.view addSubview:_lookBPBtn];
    }
    return _lookBPBtn;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
