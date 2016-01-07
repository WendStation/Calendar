//
//  ProjectDetailTableViewCell.h
//  Calendar
//
//  Created by 刘花椒 on 15/11/5.
//
//

#import <UIKit/UIKit.h>
#import "ProjectDetailItem.h"


#pragma mark 团队情况

@protocol RelationProjectFounderDelegate <NSObject>

- (void)relationProjectFounder:(ProjectTeamsInfoItem *)item relationWay:(NSString *)way;

@end

@interface TeamInfoTableViewCell : BaseTableViewCell

@property(nonatomic, weak) id <RelationProjectFounderDelegate>delegate;

- (void)setData:(NSMutableArray *)teamInfoAry;

@end


#pragma mark 运营数据
@interface OperationDataTableViewCell : BaseTableViewCell

@property(nonatomic, strong)UILabel *operationDataLabel;

- (void)setData:(NSString *)operationDatas;

@end

#pragma mark 相关网址

@protocol RelatedHttpURLTableViewCellDelegate <NSObject>

- (void)cellButtonClick:(UIButton*)btn urlLink:(NSString*)urlLink;

@end

@interface RelatedHttpURLTableViewCell : BaseTableViewCell

@property (nonatomic, weak)id <RelatedHttpURLTableViewCellDelegate>delegate;
- (void)setData:(NSMutableArray *)httpUrlAry;

@end

#pragma mark 项目详述
@interface ProjectDescriptionTableViewCell : BaseTableViewCell

- (void)setData:(NSMutableArray *)companyDetailAry;

@end

#pragma mark 投资亮点
@interface InvestHighlightsTableViewCell : BaseTableViewCell

@property(nonatomic, strong)UILabel *investHighlightsLabel;

- (void)setData:(ProjectDetailItem *)item;

@end

typedef enum : NSUInteger {
    ProjectBasicInfo,
    ProjectCompetition,
    ProjectVisibility,
} ProjectInformation;

#pragma mark 项目基本信息/竞争情况与现有投资人／项目可见性
@interface ProjectDetailTableViewCell : BaseTableViewCell

@property(nonatomic, assign)ProjectInformation projectInformation;
@property(nonatomic, strong)UILabel *titleLabel;
@property(nonatomic, strong)UILabel *descriptionLabel;
@property(nonatomic, strong)UIImageView *cellSegmentLine;

- (void)setData:(ProjectDetailItem *)item title:(NSString *)title index:(NSIndexPath *)index;

@end
