//
//  CenterTableView.h
//  BanTang
//
//  Created by liaoyp on 15/4/13.
//  Copyright (c) 2015年 JiuZhouYunDong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HorizontalScrollCell.h"
#import "HorizontalScrollCellDeleagte.h"

typedef NS_ENUM(NSUInteger, TableViewScrollType) {
    ScrollHorizontalOnly,
    ScrollAll,
};

@protocol HorizontalTableViewDelegate <NSObject>

- (void)horizontalTableView:(TableViewScrollType)type didSelectItemAtContentIndexPath:(NSIndexPath *)contentIndexPath inTableViewIndexPath:(NSIndexPath *)tableViewIndexPath;

@end

@interface HorizonScrollTableView : UIView<UITableViewDataSource,UITableViewDelegate,HorizontalScrollCellDeleagte>
{

}

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, assign) TableViewScrollType type;

@property (nonatomic, weak) id<HorizontalTableViewDelegate> delegate;

@end
