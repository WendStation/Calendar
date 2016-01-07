//
//  UpdateRecordTabelViewCell.m
//  Calendar
//
//  Created by 刘花椒 on 15/11/11.
//
//

#import "UpdateRecordTabelViewCell.h"

@implementation UpdateRecordTabelViewCell

- (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object{
    CGFloat cellHeight = 0;
    if ([object isKindOfClass:[ProjectUpdateRecordItem class]]) {
        ProjectUpdateRecordItem *item = (ProjectUpdateRecordItem *)object;
        if ([item.type isEqualToString:@"operation"]) {
            return 100.0f;
        } else if ([item.type isEqualToString:@"grade"]) {
            CGSize size = [self calculateCellHeight:item.comment textFont:[UIFont systemFontOfSize:15] contentSize:CGSizeMake(SCREEN_WIDTH - evaluate(20), CGFLOAT_MAX)];
            cellHeight = size.height + 100 - 28;
            return cellHeight;
        } else {
            
        }
    }
    return 100.0f;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.createTime];
        [self.contentView addSubview:self.status];
        [self.contentView addSubview:self.name];
        [self.contentView addSubview:self.comment];
        [self.contentView addSubview:self.cellSegmentLine];
    }
    return self;
}

- (void)prepareForReuse{
    [super prepareForReuse];
    self.createTime.text = nil;
    self.status.text = nil;
    self.name.text = nil;
    self.comment.text = nil;
    //self.cellSegmentLine = nil;
}

- (void)setData:(ProjectUpdateRecordItem *)item{
    if (![item.creationTime isEqualToString:@"(null)"] && item.creationTime.length > 9) {
        self.createTime.text = item.creationTime;
    } else {
        self.createTime.text = @"";
    }
    self.name.text = item.name;
    if ([item.type isEqualToString:@"operation"]) {
        self.status.text = @"修改状态";
        NSString *fromStatus = [[CacheManager sharedInstance] getProjectStatusDescritionForCode:item.fromStatus];
        NSString *toStatus = [[CacheManager sharedInstance] getProjectStatusDescritionForCode:item.toStatus];
        self.comment.text = [NSString stringWithFormat:@"“%@”改为“%@”",fromStatus,toStatus];
    } else if ([item.type isEqualToString:@"grade"]) {
        self.status.text = @"进展更新";
        self.comment.text = item.comment;
    } else {
        self.status.text = @"备注";
        self.name.text = @"系统";
    }
    if (![self.comment.text isEqualToString:@"(null)"] && self.comment.text.length > 0) {
        NSMutableAttributedString * attrS = [[NSMutableAttributedString alloc] initWithString:self.comment.text];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 10;
        NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:15],NSParagraphStyleAttributeName:style};
        [attrS addAttributes:attribute range:NSMakeRange(0, self.comment.text.length)];
        self.comment.attributedText = attrS;
        [self.comment sizeToFit];
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.createTime.frame = CGRectMake(evaluate(10), 15, 200, 15);
    self.status.frame = CGRectMake(SCREEN_WIDTH - evaluate(10) - 100, 15, 100, 15);
    self.name.frame = CGRectMake(evaluate(10), self.createTime.bottom + 10, SCREEN_WIDTH, 16);
    CGSize size = [self calculateCellHeight:self.comment.text textFont:[UIFont systemFontOfSize:15] contentSize:CGSizeMake(SCREEN_WIDTH - evaluate(20), CGFLOAT_MAX)];
    self.comment.frame = CGRectMake(evaluate(10), self.name.bottom + 7, SCREEN_WIDTH - evaluate(20), size.height);
    self.cellSegmentLine.frame = CGRectMake(0, self.height - 1, SCREEN_WIDTH, 1);

}

#pragma mark property
- (UILabel *)createTime {
    if (!_createTime) {
        _createTime = [[UILabel alloc] init];
        _createTime.backgroundColor = [UIColor clearColor];
        _createTime.textColor = BLACK_COLOR;
        _createTime.font = [UIFont systemFontOfSize:14];
    }
    return _createTime;
}

- (UILabel *)status{
    if (!_status) {
        _status = [[UILabel alloc] init];
        _status.backgroundColor = [UIColor clearColor];
        _status.textColor = BLACK_COLOR;
        _status.font = [UIFont systemFontOfSize:14];
        _status.textAlignment = NSTextAlignmentRight;
    }
    return _status;
}

- (UILabel *)name{
    if (!_name) {
        _name = [[UILabel alloc] init];
        _name.backgroundColor = [UIColor clearColor];
        _name.textColor = DARKGRAY_COLOR;
        _name.font = [UIFont systemFontOfSize:15];
    }
    return _name;
}

- (UILabel *)comment{
    if (!_comment) {
        _comment = [[UILabel alloc] init];
        _comment.backgroundColor = [UIColor clearColor];
        _comment.textColor = DARKGRAY_COLOR;
        _comment.font = [UIFont systemFontOfSize:15];
        _comment.lineBreakMode = NSLineBreakByWordWrapping;
        _comment.numberOfLines = 0;
    }
    return _comment;
}

- (UIImageView *)cellSegmentLine{
    if (!_cellSegmentLine) {
        _cellSegmentLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line"]];
        _cellSegmentLine.backgroundColor = [UIColor clearColor];
    }
    return _cellSegmentLine;
}

@end
