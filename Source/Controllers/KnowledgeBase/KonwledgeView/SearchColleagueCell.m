//
//  SearchColleagueCell.m
//  Calendar
//
//  Created by 刘花椒 on 15/11/24.
//
//

#import "SearchColleagueCell.h"

@implementation SearchColleagueCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.name];
        [self.contentView addSubview:self.position];
        [self.contentView addSubview:self.phone];
        [self.contentView addSubview:self.lookSchedule];
        [self.contentView addSubview:self.segmentLine];
    }
    return self;
}

- (void)prepareForReuse{
    [super prepareForReuse];
}

- (void)setData:(id)sender{
    if ([sender isKindOfClass:[Customer class]]) {
        Customer *user = (Customer *)sender;
        self.user = user;
        if (![user.name isEqualToString:@"(null)"] && user.name.length > 0) {
            self.name.text = user.name;
        }else{
            self.name.text = @"";
        }
        if (![user.company isEqualToString:@"(null)"] && user.company.length > 0) {
            self.position.text = user.company;
        }else{
            self.position.text = @"";
        }
        if (![user.phone isEqualToString:@"(null)"] && user.phone.length > 0) {
            [self.phone setTitle:user.phone forState:UIControlStateNormal];
        }else{
            [self.phone setTitle:@"" forState:UIControlStateNormal];
        }
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.name.frame = CGRectMake(evaluate(10), 9, 100, 18);
    
    CGSize size = [self calculateCellHeight:self.position.text textFont:[UIFont systemFontOfSize:16] contentSize:CGSizeMake(SCREEN_WIDTH - 100 - evaluate(20), CGFLOAT_MAX)];
    self.position.frame = CGRectMake(SCREEN_WIDTH - evaluate(10) - size.width, 9, size.width, 18);
    
    self.phone.frame = CGRectMake(evaluate(10), self.name.bottom + 6, 150, 16);
    self.lookSchedule.frame = CGRectMake(SCREEN_WIDTH - evaluate(10) - 100, self.name.bottom + 6, 100, 16);
    self.segmentLine.frame = CGRectMake(0, self.height - 1, SCREEN_WIDTH, 1);

}

- (void)callPhoneBtn:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (self.delegate && [self.delegate respondsToSelector:@selector(relationColleague:)]) {
        [self.delegate relationColleague:btn.titleLabel.text];
    }
}

- (void)lookSchedule:(id)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(lookschedule:)]) {
        [self.delegate lookschedule:self.user];
    }
}

- (UILabel *)name{
    if (!_name) {
        _name = [[UILabel alloc] init];
        _name.backgroundColor = [UIColor clearColor];
        _name.font = [UIFont systemFontOfSize:16];
        _name.textColor = BLACK_COLOR;
    }
    return _name;
}

- (UILabel *)position{
    if (!_position) {
        _position = [[UILabel alloc] init];
        _position.backgroundColor = [UIColor clearColor];
        _position.font = [UIFont systemFontOfSize:16];
        _position.textColor = BLACK_COLOR;
        _position.textAlignment = NSTextAlignmentRight;
    }
    return _position;
}

- (UIButton *)phone{
    if (!_phone) {
        _phone = [UIButton buttonWithType:UIButtonTypeCustom];
        _phone.backgroundColor = [UIColor clearColor];
        _phone.titleLabel.font = [UIFont systemFontOfSize:14];
        [_phone setTitleColor:BLUE_COLOR forState:UIControlStateNormal];
        [_phone addTarget:self action:@selector(callPhoneBtn:) forControlEvents:UIControlEventTouchUpInside];
        _phone.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    }
    return _phone;
}

- (UIButton *)lookSchedule{
    if (!_lookSchedule) {
        _lookSchedule = [UIButton buttonWithType:UIButtonTypeCustom];
        _lookSchedule.backgroundColor = [UIColor clearColor];
        [_lookSchedule setTitle:@"查看日程" forState:UIControlStateNormal];
        [_lookSchedule setTitleColor:BLUE_COLOR forState:UIControlStateNormal];
        [_lookSchedule addTarget:self action:@selector(lookSchedule:) forControlEvents:UIControlEventTouchUpInside];
        _lookSchedule.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight
        ;
        _lookSchedule.titleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _lookSchedule;
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
