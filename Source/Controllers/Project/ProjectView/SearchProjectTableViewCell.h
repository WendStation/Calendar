//
//  SearchProjectTableViewCell.h
//  Calendar
//
//  Created by 刘花椒 on 15/11/11.
//
//

#import "BaseTableViewCell.h"

@interface SearchProjectTableViewCell : BaseTableViewCell

@property(nonatomic, strong)UILabel *title;
@property(nonatomic, strong)UILabel *name;
@property(nonatomic, strong)UILabel *abstract;
@property(nonatomic, strong)UILabel *status;
@property(nonatomic, strong)UILabel *categoryDefine;
@property(nonatomic, strong)UIImageView *segmentLine;
@property(nonatomic, strong)UILabel *cellSegmentLine;

@end
