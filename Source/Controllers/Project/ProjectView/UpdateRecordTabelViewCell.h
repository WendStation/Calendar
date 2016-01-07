//
//  UpdateRecordTabelViewCell.h
//  Calendar
//
//  Created by 刘花椒 on 15/11/11.
//
//

#import "BaseTableViewCell.h"
#import "ProjectDetailItem.h"

@interface UpdateRecordTabelViewCell : BaseTableViewCell

@property(nonatomic, strong)UILabel *createTime;
@property(nonatomic, strong)UILabel *status;
@property(nonatomic, strong)UILabel *name;
@property(nonatomic, strong)UILabel *comment;
@property(nonatomic, strong)UIImageView* cellSegmentLine;

- (void)setData:(ProjectUpdateRecordItem *)item;

@end
