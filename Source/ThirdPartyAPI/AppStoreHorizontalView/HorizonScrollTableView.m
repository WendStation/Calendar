//
//  CenterTableView.m
//  BanTang
//
//  Created by liaoyp on 15/4/13.
//  Copyright (c) 2015年 JiuZhouYunDong. All rights reserved.
//

#import "HorizonScrollTableView.h"
#import "HorzonItemCell.h"
#import "CategoryModel.h"
#import "CollectModel.h"
//#import "CenterEmptyView.h"



 NSString *const cellIdentifier = @"HorzonItemCell";

@interface HorizonScrollTableView()
{
//    CenterEmptyView *_emptyView;
}
@end

@implementation HorizonScrollTableView


- (void)setUpTableView
{
    CGRect rect  =self.bounds;
    _tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.backgroundView = nil;
    [_tableView registerClass:[HorizontalScrollCell class] forCellReuseIdentifier:cellIdentifier];
    if (_type == ScrollHorizontalOnly) {
        _tableView.scrollEnabled = NO;
    }
    [self addSubview:_tableView];
}

- (void)setDataSource:(NSMutableArray *)dataSource
{
     _dataSource = dataSource;
    [_tableView removeFromSuperview];
    [self setUpTableView];
    
    if ([_dataSource count] == 0) {
    }else
    {
        _tableView.tableFooterView = nil;
    }
}

#pragma mark -
#pragma mark TableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataSource count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return _tableView.frame.size.height / [_dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HorizontalScrollCell *_centerCell;
    _centerCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    _centerCell.delegate =self;
    _centerCell.tableViewIndexPath = indexPath;
    return _centerCell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[HorizontalScrollCell class]]) {
        
        [(HorizontalScrollCell *)cell reloadData];
    }
}

#pragma mark - ASOXScrollTableViewCellDelegate

- (NSInteger)horizontalCellContentsView:(UICollectionView *)horizontalCellContentsView numberOfItemsInTableViewIndexPath:(NSIndexPath *)tableViewIndexPath{
    
    CategoryModel *category = [_dataSource objectAtIndex:tableViewIndexPath.row];
    NSInteger count = category.datalist.count;
    return count;
}

- (UICollectionViewCell *)horizontalCellContentsView:(UICollectionView *)horizontalCellContentsView cellForItemAtContentIndexPath:(NSIndexPath *)contentIndexPath inTableViewIndexPath:(NSIndexPath *)tableViewIndexPath{
    
    HorzonItemCell *cell;
    {
        cell = (HorzonItemCell *)[horizontalCellContentsView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:contentIndexPath];
    }
    CategoryModel *category = [_dataSource objectAtIndex:tableViewIndexPath.row];
    CollectModel *item = [category.datalist objectAtIndex:contentIndexPath.row];
    [cell isNormalCell:item];
    
    return cell;

}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view  =[UIView new];
    view.backgroundColor = [UIColor whiteColor];
    return view;
}

- (CGFloat)tableViewHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _tableView.frame.size.height / [_dataSource count];
}

- (CGSize)horizontalCellContentsView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    float width = (_tableView.frame.size.width - 40) / 3.5;
    float height = _tableView.frame.size.height / [_dataSource count];
    CGSize itemSize = CGSizeMake(width, height);
    return itemSize;
}

- (void)horizontalCellContentsView:(UICollectionView *)horizontalCellContentsView didSelectItemAtContentIndexPath:(NSIndexPath *)contentIndexPath inTableViewIndexPath:(NSIndexPath *)tableViewIndexPath
{
    [horizontalCellContentsView deselectItemAtIndexPath:contentIndexPath animated:YES]; // A custom behaviour in this example for removing highlight from the cell immediately after it had been selected
    
    NSLog(@"Section %ld Row %ld Item %ld is selected", (unsigned long)tableViewIndexPath.section, (unsigned long)tableViewIndexPath.row, (unsigned long)contentIndexPath.item);

    // 跳转界面
    if ([_delegate respondsToSelector:@selector(horizontalTableView:didSelectItemAtContentIndexPath:inTableViewIndexPath:)]) {
        
        [_delegate horizontalTableView:_type didSelectItemAtContentIndexPath:contentIndexPath inTableViewIndexPath:tableViewIndexPath];
    }
}

@end
