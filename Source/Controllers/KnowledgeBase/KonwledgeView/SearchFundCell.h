//
//  SearchFundCell.h
//  Calendar
//
//  Created by 刘花椒 on 15/11/24.
//
//

#import "BaseTableViewCell.h"

@interface SearchFundCell : BaseTableViewCell

@property(nonatomic, strong)UILabel *name;
@property(nonatomic, strong)UILabel *currentType;
@property(nonatomic, strong)UILabel *financingRound;
@property(nonatomic, strong)UIImageView *segmentLine;

@end
