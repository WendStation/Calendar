//
//  ProjectDetailViewController.h
//  Calendar
//
//  Created by 刘花椒 on 15/11/4.
//
//

#import <UIKit/UIKit.h>

@interface ProjectDetailViewController : BaseViewController<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic, strong)NSString *project_Id;

@end
