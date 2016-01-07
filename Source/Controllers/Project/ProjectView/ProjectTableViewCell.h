//
//  projectTableViewCell.h
//  Calendar
//
//  Created by 刘花椒 on 15/10/29.
//
//

#import <UIKit/UIKit.h>
#import "ProjectListItem.h"
#import "ProjectListDatasource.h"

@interface ProjectTableViewCell : UITableViewCell

@property(nonatomic, assign)ProjectRequestType projectType;
@property(nonatomic, strong)ProjectListItem *item;

@property(nonatomic, strong)UILabel *projectName;
@property(nonatomic, strong)UILabel *agentUserName;
@property(nonatomic, strong)UILabel *founderName;
@property(nonatomic, strong)UIImageView *segmentLine;
@property(nonatomic, strong)UIButton *phoneBtn;
@property(nonatomic, strong)UILabel *progressStatus;
@property(nonatomic, strong)UILabel *projectDatail;
@property(nonatomic, strong)UILabel *cellSegmentLine;

- (void)setData:(ProjectListItem *)item projectType:(ProjectRequestType )projectType;

@end
