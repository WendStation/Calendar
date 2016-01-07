//
//  FounderDetailCell.h
//  Calendar
//
//  Created by 刘花椒 on 15/11/25.
//
//

#import "BaseTableViewCell.h"

@interface CommentFounderCell : BaseTableViewCell

@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UILabel *company;
@property (nonatomic, strong) UILabel *evaluateTime;
@property (nonatomic, strong) UILabel *manner;
@property (nonatomic, strong) UILabel *direction;
@property (nonatomic, strong) UILabel *comment;
@property (nonatomic, strong) UIImageView *segmentLine;
@property (nonatomic, strong) UIImageView *starNor;
@property (nonatomic, strong) UIImageView *starSelact;
@property (nonatomic, strong) UIView *mannerStarViews;
@property (nonatomic, strong) UIView *directionStarViews;

@end

@protocol FounderDetailCellDelegate <NSObject>

- (void)lookFounderRelationNumber:(NSString *)type;

@end

@interface FounderDetailCell : BaseTableViewCell

@property (nonatomic, strong) UILabel *text1;
@property (nonatomic, strong) UILabel *text2;
@property (nonatomic, strong) UIImageView *segmentLine;
@property (nonatomic, strong) UILabel *cellSegmentLine;
@property(nonatomic, weak) id <FounderDetailCellDelegate> delegate;

@end
