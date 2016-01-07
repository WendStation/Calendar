//
//  SearchProjectTableViewCell.m
//  Calendar
//
//  Created by 刘花椒 on 15/11/11.
//
//

#import "SearchProjectTableViewCell.h"
#import "ProjectListItem.h"

@implementation SearchProjectTableViewCell

- (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object{
    CGFloat cellHeight = 0;
    if ([object isKindOfClass:[ProjectListItem class]]) {
        ProjectListItem *item = (ProjectListItem *)object;
        CGSize size = [self calculateCellHeight:item.abstract textFont:[UIFont systemFontOfSize:14] contentSize:CGSizeMake(SCREEN_WIDTH - evaluate(20), CGFLOAT_MAX)];
        cellHeight += size.height + 139 - 28;
    }
    return cellHeight;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.title];
        [self.contentView addSubview:self.name];
        [self.contentView addSubview:self.abstract];
        [self.contentView addSubview:self.status];
        [self.contentView addSubview:self.categoryDefine];
        [self.contentView addSubview:self.segmentLine];
        [self.contentView addSubview:self.cellSegmentLine];
    }
    return self;
}

- (void)prepareForReuse{
    [super prepareForReuse];
    self.title.text = nil;
    self.name.text = nil;
    self.abstract.text = nil;
    self.status.text = nil;
    self.categoryDefine.text = nil;
}

- (void)setData:(ProjectListItem *)item{
    if (![item.title isEqualToString:@"(null)"] && item.title.length > 0) {
        self.title.text = item.title;
    } else {
        self.title.text = @"";
    }
    
    if (![item.ownerName isEqualToString:@"(null)"] && item.ownerName.length > 0) {
        self.name.text = item.ownerName;
    } else {
        self.name.text = @"";
    }
    
    if (![item.abstract isKindOfClass:[NSNull class]] && item.abstract.length > 0) {
        NSMutableAttributedString * attrS = [[NSMutableAttributedString alloc] initWithString:item.abstract];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 10;
        NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:14],NSParagraphStyleAttributeName:style};
        [attrS addAttributes:attribute range:NSMakeRange(0, item.abstract.length)];
        self.abstract.attributedText = attrS;
        [self.abstract sizeToFit];
    } else {
        self.abstract.text = @"";
    }
    
    if (![item.statusText1 isEqualToString:@"(null)"] && item.statusText1.length > 0) {
        self.status.text = item.statusText1;
    } else {
        self.status.text = @"";
    }
    if (![item.statusText2 isEqualToString:@"(null)"] && item.statusText2.length > 0) {
        self.categoryDefine.text = item.statusText2;
    } else {
        self.categoryDefine.text = @"";
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.cellSegmentLine.frame = CGRectMake(0, 0, SCREEN_WIDTH, 8);
    self.title.frame = CGRectMake(evaluate(10),self.cellSegmentLine.bottom + 15, 190, 17);
    self.name.frame = CGRectMake(SCREEN_WIDTH - evaluate(10) - 100, self.title.top , 100, 17);
        
    CGSize size = [self calculateCellHeight:self.abstract.text textFont:self.abstract.font contentSize:CGSizeMake(SCREEN_WIDTH - evaluate(20), CGFLOAT_MAX)];
    self.abstract.frame = CGRectMake(evaluate(10), self.title.bottom + 15, SCREEN_WIDTH - evaluate(20), size.height);
    
    self.segmentLine.frame = CGRectMake(evaluate(10), self.height - 35, SCREEN_WIDTH - evaluate(10), 1);
    self.status.frame = CGRectMake(evaluate(10), self.segmentLine.bottom, 100, 34);
    self.categoryDefine.frame = CGRectMake(SCREEN_WIDTH - evaluate(10) - 150, self.segmentLine.bottom, 150, 34);
    
}

#pragma mark property
- (UILabel *)title{
    if (!_title) {
        _title = [[UILabel alloc] init];
        _title.backgroundColor = [UIColor clearColor];
        _title.textColor = BLACK_COLOR;
        _title.font = [UIFont systemFontOfSize:16];
    }
    return _title;
}

- (UILabel *)name{
    if (!_name) {
        _name = [[UILabel alloc] init];
        _name.backgroundColor = [UIColor clearColor];
        _name.textColor = BLACK_COLOR;
        _name.font = [UIFont systemFontOfSize:16];
        _name.textAlignment = NSTextAlignmentRight;
    }
    return _name;
}

- (UILabel *)abstract{
    if (!_abstract) {
        _abstract = [[UILabel alloc] init];
        _abstract.backgroundColor = [UIColor clearColor];
        _abstract.textColor = DARKGRAY_COLOR;
        _abstract.font = [UIFont systemFontOfSize:14];
        _abstract.numberOfLines = 0;
        _abstract.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _abstract;

}

- (UILabel *)status{
    if (!_status) {
        _status = [[UILabel alloc] init];
        _status.backgroundColor = [UIColor clearColor];
        _status.textColor = LIGHTGRAY_COLOR;
        _status.font = [UIFont systemFontOfSize:14];
    }
    return _status;
}

- (UILabel *)categoryDefine{
    if (!_categoryDefine) {
        _categoryDefine = [[UILabel alloc] init];
        _categoryDefine.backgroundColor = [UIColor clearColor];
        _categoryDefine.textColor = LIGHTGRAY_COLOR;
        _categoryDefine.textAlignment = NSTextAlignmentRight;
        _categoryDefine.font = [UIFont systemFontOfSize:14];
    }
    return _categoryDefine;
}

- (UIImageView *)segmentLine{
    if (!_segmentLine) {
        _segmentLine = [[UIImageView alloc] init];
        _segmentLine.backgroundColor = [UIColor clearColor];
        _segmentLine.image = [UIImage imageNamed:@"line"];
    }
    return _segmentLine;
}

- (UILabel *)cellSegmentLine{
    if (!_cellSegmentLine) {
        _cellSegmentLine = [[UILabel alloc] init];
        _cellSegmentLine.backgroundColor = RGBCOLOR(240, 239, 245);
    }
    return _cellSegmentLine;
}

@end
