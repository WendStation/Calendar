//
//  BaseTableViewCell.h
//  AppStore(Horizontal)Demo
//
//  Created by liaoyp on 15/4/24.
//  Copyright (c) 2015年 liaoyp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseTableViewCell : UITableViewCell

- (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object;
- (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object index:(NSIndexPath *)index;

- (CGSize)calculateCellHeight:(NSString *)textStr
                     textFont:(UIFont *)textFont
                  contentSize:(CGSize)contentSize;


- (void)setData:(id)sender;
- (void)setData:(id)sender indexPath:(NSIndexPath *)indexPath;

@end
