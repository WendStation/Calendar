//
//  SearchFounderCell.h
//  Calendar
//
//  Created by 刘花椒 on 15/11/24.
//
//

#import "BaseTableViewCell.h"
#import "SearchFounderListItem.h"

@interface SearchFounderCell : BaseTableViewCell

@property(nonatomic, strong)UILabel *name;
@property(nonatomic, strong)UIButton *phone;
@property(nonatomic, strong)UILabel *company;
@property(nonatomic, strong)UIImageView *segmentLine;

@end
