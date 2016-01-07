//
//  ProjectViewController.h
//  Calendar
//
//  Created by 小华 on 15/10/19.
//  Copyright © 2015年 Robert Dimitrov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProjectViewController : BaseViewController<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UINavigationItem *projectNavigationItem;

@property(nonatomic, strong)NSMutableArray *projectTableViewsAry;

@end
