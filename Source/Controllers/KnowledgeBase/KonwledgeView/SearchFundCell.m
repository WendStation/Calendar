//
//  SearchFundCell.m
//  Calendar
//
//  Created by 刘花椒 on 15/11/24.
//
//

#import "SearchFundCell.h"
#import "SearchFounderListItem.h"

@interface SearchFundCell ()

@property(nonatomic, strong)SearchFounListItem *item;

@end

@implementation SearchFundCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor whiteColor];
        self.item = [[SearchFounListItem alloc] init];
        [self.contentView addSubview:self.name];
        [self.contentView addSubview:self.currentType];
        [self.contentView addSubview:self.financingRound];
        [self.contentView addSubview:self.segmentLine];
    }
    return self;
}

- (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object{
    return 59;
}

- (void)setData:(id)sender{
    if ([sender isKindOfClass:[SearchFounListItem class]]) {
        self.item = (SearchFounListItem *)sender;
        if (![self.item.name isEqualToString:@"(null)"] && self.item.name.length > 0) {
            self.name.text = self.item.name;
        } else {
            self.name.text = @"";
        }
        if (![self.item.currency isEqualToString:@"(null)"] && self.item.currency.length > 0) {
            NSString * strList = @"";
            NSArray *value = [CommonAPI shiftRightOperate:[self.item.currency intValue]];
            NSArray *type = [NSArray arrayWithObjects:@"人民币", @"美元", nil];
            if (value.count > 0) {
                for (int i = 0; i < type.count;  i++) {
                    if (i < value.count - 1) {
                        strList = [NSString stringWithFormat:@"%@%@/",strList, [type objectAtIndex:[[value objectAtIndex:i] intValue]]];
                    }else if (i == value.count - 1) {
                        strList = [NSString stringWithFormat:@"%@%@",strList, [type objectAtIndex:[[value objectAtIndex:i] intValue]]];
                    }
                }
            }
            self.currentType.text = strList;
        } else {
            self.currentType.text = @"";
        }
        if (![self.item.financingRound isEqualToString:@"(null)"] && self.item.financingRound.length > 0) {
            self.financingRound.text = self.item.financingRound;
        } else {
            self.financingRound.text = @"";
        }
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.name.frame = CGRectMake(evaluate(10), 9, SCREEN_WIDTH - evaluate(10), 18);
    self.currentType.frame = CGRectMake(evaluate(10), self.name.bottom + 6, 100, 16);
    CGSize size = [self calculateCellHeight:self.financingRound.text textFont:[UIFont systemFontOfSize:14] contentSize:CGSizeMake(SCREEN_WIDTH - 100, CGFLOAT_MAX)];
    self.financingRound.frame = CGRectMake(SCREEN_WIDTH - evaluate(10) - size.width, self.name.bottom + 6, size.width, 16);
    self.segmentLine.frame = CGRectMake(0, self.height - 1, SCREEN_WIDTH, 1);
}


#pragma mark property
- (UILabel *)name{
    if (!_name) {
        _name = [[UILabel alloc] init];
        _name.backgroundColor = [UIColor clearColor];
        _name.font = [UIFont systemFontOfSize:16];
        _name.textColor = BLACK_COLOR;
    }
    return _name;
}

- (UILabel *)currentType{
    if (!_currentType) {
        _currentType = [[UILabel alloc] init];
        _currentType.backgroundColor = [UIColor clearColor];
        _currentType.font = [UIFont systemFontOfSize:14];
        _currentType.textColor = LIGHTGRAY_COLOR;
    }
    return _currentType;
}

- (UILabel *)financingRound{
    if (!_financingRound) {
        _financingRound = [[UILabel alloc] init];
        _financingRound.backgroundColor = [UIColor clearColor];
        _financingRound.font = [UIFont systemFontOfSize:14];
        _financingRound.textColor = LIGHTGRAY_COLOR;
        _financingRound.textAlignment = NSTextAlignmentRight;
    }
    return _financingRound;
}

- (UIImageView *)segmentLine{
    if (!_segmentLine) {
        _segmentLine = [[UIImageView alloc] init];
        _segmentLine.backgroundColor = [UIColor clearColor];
        _segmentLine.image = [UIImage imageNamed:@"line"];
    }
    return _segmentLine;
}

@end
