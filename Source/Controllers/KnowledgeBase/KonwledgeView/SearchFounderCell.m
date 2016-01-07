//
//  SearchFounderCell.m
//  Calendar
//
//  Created by 刘花椒 on 15/11/24.
//
//

#import "SearchFounderCell.h"
#import "SearchFounderListItem.h"

@interface SearchFounderCell ()

@property(nonatomic, strong)SearchFounderListItem *item;

@end

@implementation SearchFounderCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor whiteColor];
        self.item = [[SearchFounderListItem alloc] init];
        [self.contentView addSubview:self.name];
//        [self.contentView addSubview:self.phone];
        [self.contentView addSubview:self.company];
        [self.contentView addSubview:self.segmentLine];
    }
    return self;
}

- (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object{
    return 59;
}

- (void)setData:(id)sender{
    if ([sender isKindOfClass:[SearchFounderListItem class]]) {
        self.item = (SearchFounderListItem *)sender;
        if (![self.item.name isEqualToString:@"(null)"] && self.item.name.length > 0) {
            self.name.text = self.item.name;
        } else {
            self.name.text = @"";
        }
        if (![self.item.phone isEqualToString:@"(null)"] && self.item.phone.length > 0) {
            [self.phone setTitle:self.item.phone forState:UIControlStateNormal];
        } else {
            [self.phone setTitle:@"" forState:UIControlStateNormal];
        }
        if (![self.item.company isEqualToString:@"(null)"] && self.item.company.length > 0) {
            self.company.text = self.item.company;
        } else {
            self.company.text = @"";
        }
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.name.frame = CGRectMake(evaluate(10), 9, 150, 18);
    self.phone.frame = CGRectMake(SCREEN_WIDTH - 150 - evaluate(10), self.name.top, 150, 18);
    self.company.frame = CGRectMake(evaluate(10), self.name.bottom + 6, SCREEN_WIDTH - evaluate(10), 16);
    self.segmentLine.frame = CGRectMake(0, self.height - 1, SCREEN_WIDTH, 1);
}

- (void)callPhoneBtn:(id)sender{
    [CommonAPI callPhone:self.item.phone];
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

- (UIButton *)phone{
    if (!_phone) {
        _phone = [UIButton buttonWithType:UIButtonTypeCustom];
        _phone.backgroundColor = [UIColor clearColor];
        [_phone setTitleColor:BLUE_COLOR forState:UIControlStateNormal];
        _phone.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_phone addTarget:self action:@selector(callPhoneBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _phone;
}

- (UILabel *)company{
    if (!_company) {
        _company = [[UILabel alloc] init];
        _company.backgroundColor = [UIColor clearColor];
        _company.font = [UIFont systemFontOfSize:14];
        _company.textColor = LIGHTGRAY_COLOR;
    }
    return _company;
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
