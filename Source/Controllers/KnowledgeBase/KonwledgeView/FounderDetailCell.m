//
//  FounderDetailCell.m
//  Calendar
//
//  Created by 刘花椒 on 15/11/25.
//
//

#import "FounderDetailCell.h"
#import "FounderDetailItem.h"

@implementation CommentFounderCell

- (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object{
    CGFloat height = 75;
    if ([object isKindOfClass:[FounderEvaluateListItem class]]) {
        FounderEvaluateListItem *item = (FounderEvaluateListItem *)object;
        if (![item.comment isEqualToString:@"(null)"] && item.comment.length > 0) {
            CGSize size = [self calculateCellHeight:item.comment textFont:[UIFont systemFontOfSize:16] contentSize:CGSizeMake(SCREEN_WIDTH - evaluate(20), CGFLOAT_MAX)];
            height += size.height;
        }
    }
    return height;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.name];
        [self.contentView addSubview:self.evaluateTime];
        [self.contentView addSubview:self.manner];
        [self.contentView addSubview:self.direction];
        [self.contentView addSubview:self.comment];
        [self.contentView addSubview:self.segmentLine];
        [self.contentView addSubview:self.mannerStarViews];
        [self.contentView addSubview:self.directionStarViews];
    }
    return self;
}

- (void)prepareForReuse{
    [super prepareForReuse];
}

- (void)setData:(id)sender{
    if ([sender isKindOfClass:[FounderEvaluateListItem class]]) {
        FounderEvaluateListItem *item = (FounderEvaluateListItem *)sender;
        self.name.text = [NSString stringWithFormat:@"%@  %@",item.name,item.company];
        self.evaluateTime.text = item.evaluateTime;
        self.manner.text = @"态度";
        for (NSInteger i = 0; i < item.manner; i++) {
            self.starSelact = [[UIImageView alloc] init];
            self.starSelact.backgroundColor = [UIColor clearColor];
            self.starSelact.image = [UIImage imageNamed:@"kb_icon_-star_selact"];
            if (SCREEN_WIDTH > 320) {
                self.starSelact.frame = CGRectMake((self.starSelact.image.size.width + 8)*i, 0, self.starSelact.image.size.width, self.starSelact.image.size.height);
            } else {
                self.starSelact.frame = CGRectMake((15 + 6)*i, 0, 15, 14);
            }
            
            [self.mannerStarViews addSubview:self.starSelact];
        }
        for (NSInteger i = item.manner; i < 5; i++) {
            self.starNor = [[UIImageView alloc] init];
            self.starNor.backgroundColor = [UIColor clearColor];
            self.starNor.image = [UIImage imageNamed:@"kb_icon_-star_nor"];
            if (SCREEN_WIDTH > 320) {
                self.starNor.frame = CGRectMake((self.starNor.image.size.width + 8)*i, 0, self.starNor.image.size.width, self.starNor.image.size.height);
            } else {
                self.starNor.frame = CGRectMake((15 + 6)*i, 0, 15, 14);
            }
            [self.mannerStarViews addSubview:self.starNor];
        }
        
        self.direction.text = @"专业度";
        for (NSInteger i = 0; i < item.direction; i++) {
            self.starSelact = [[UIImageView alloc] init];
            self.starSelact.backgroundColor = [UIColor clearColor];
            self.starSelact.image = [UIImage imageNamed:@"kb_icon_-star_selact"];
            if (SCREEN_WIDTH > 320) {
                self.starSelact.frame = CGRectMake((self.starSelact.image.size.width + 8)*i, 0, self.starSelact.image.size.width, self.starSelact.image.size.height);
            } else {
                self.starSelact.frame = CGRectMake((15 + 6)*i, 0, 15, 14);
            }
            [self.directionStarViews addSubview:self.starSelact];
        }
        for (NSInteger i = item.direction; i < 5; i++) {
            self.starNor = [[UIImageView alloc] init];
            self.starNor.backgroundColor = [UIColor clearColor];
            self.starNor.image = [UIImage imageNamed:@"kb_icon_-star_nor"];
            if (SCREEN_WIDTH > 320) {
                self.starNor.frame = CGRectMake((self.starNor.image.size.width + 8)*i, 0, self.starNor.image.size.width, self.starNor.image.size.height);
            } else {
                self.starNor.frame = CGRectMake((15 + 6)*i, 0, 15, 14);
            }
            [self.directionStarViews addSubview:self.starNor];
        }
        
        NSMutableAttributedString * attrS = [[NSMutableAttributedString alloc] initWithString:item.comment];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 10;
        NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:16],NSParagraphStyleAttributeName:style};
        [attrS addAttributes:attribute range:NSMakeRange(0, item.comment.length)];
        self.comment.attributedText = attrS;
        [self.comment sizeToFit];
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.name.frame = CGRectMake(evaluate(10), 14, 200, 15);
    self.evaluateTime.frame = CGRectMake(SCREEN_WIDTH - evaluate(10) - 150, 14, 150, 15);
    
    CGSize mannerSize = [self calculateCellHeight:self.manner.text textFont:[UIFont systemFontOfSize:14] contentSize:CGSizeMake(100, CGFLOAT_MAX)];
    CGSize directionSize = [self calculateCellHeight:self.direction.text textFont:[UIFont systemFontOfSize:14] contentSize:CGSizeMake(100, CGFLOAT_MAX)];
    if (SCREEN_WIDTH > 320) {
        UIImage *star = [UIImage imageNamed:@"kb_icon_-star_nor"];
        self.manner.frame = CGRectMake(evaluate(10), self.name.bottom + 14, mannerSize.width, star.size.height);
        self.mannerStarViews.frame = CGRectMake(self.manner.right + 8, self.name.bottom + 14, star.size.width * 5 + 4 * 8, star.size.height);
        
        self.directionStarViews.frame = CGRectMake(SCREEN_WIDTH - evaluate(10) - self.mannerStarViews.width, self.mannerStarViews.top, self.mannerStarViews.width, self.mannerStarViews.height);
        self.direction.frame = CGRectMake(SCREEN_WIDTH - self.directionStarViews.width - directionSize.width - 8 - evaluate(10), self.name.bottom + 14, directionSize.width, self.mannerStarViews.size.height);
    } else {
        self.manner.frame = CGRectMake(evaluate(10), self.name.bottom + 14, mannerSize.width, 15);
        self.mannerStarViews.frame = CGRectMake(self.manner.right + 8, self.name.bottom + 14, 15 * 5 + 4 * 6, 14);
        self.directionStarViews.frame = CGRectMake(SCREEN_WIDTH - evaluate(10) - self.mannerStarViews.width, self.mannerStarViews.top, self.mannerStarViews.width, self.mannerStarViews.height);
        self.direction.frame = CGRectMake(SCREEN_WIDTH - self.directionStarViews.width - directionSize.width - 8 - evaluate(10), self.name.bottom + 14, directionSize.width, 15);
    }
   
    CGSize commentSize = [self calculateCellHeight:self.comment.text textFont:[UIFont systemFontOfSize:16] contentSize:CGSizeMake(SCREEN_WIDTH - evaluate(20), CGFLOAT_MAX)];
    self.comment.frame = CGRectMake(evaluate(10), self.manner.bottom + 14, SCREEN_WIDTH - evaluate(20), commentSize.height);
    self.segmentLine.frame = CGRectMake(0, self.height - 1, SCREEN_WIDTH, 1);
}

- (UILabel *)name{
    if (!_name) {
        _name = [[UILabel alloc] init];
        _name.backgroundColor = [UIColor clearColor];
        _name.font = [UIFont systemFontOfSize:14];
        _name.textColor = LIGHTGRAY_COLOR;
    }
    return _name;
}

- (UILabel *)evaluateTime{
    if (!_evaluateTime) {
        _evaluateTime = [[UILabel alloc] init];
        _evaluateTime.backgroundColor = [UIColor clearColor];
        _evaluateTime.font = [UIFont systemFontOfSize:14];
        _evaluateTime.textColor = LIGHTGRAY_COLOR;
        _evaluateTime.textAlignment = NSTextAlignmentRight;
    }
    return _evaluateTime;
}

- (UILabel *)manner{
    if (!_manner) {
        _manner = [[UILabel alloc] init];
        _manner.backgroundColor = [UIColor clearColor];
        _manner.font = [UIFont systemFontOfSize:14];
        _manner.textColor = BLACK_COLOR;
    }
    return _manner;
}

- (UILabel *)direction{
    if (!_direction) {
        _direction = [[UILabel alloc] init];
        _direction.backgroundColor = [UIColor clearColor];
        _direction.font = [UIFont systemFontOfSize:14];
        _direction.textColor = BLACK_COLOR;
    }
    return _direction;
}

- (UILabel *)comment{
    if (!_comment) {
        _comment = [[UILabel alloc] init];
        _comment.backgroundColor = [UIColor clearColor];
        _comment.font = [UIFont systemFontOfSize:16];
        _comment.textColor = BLACK_COLOR;
        _comment.numberOfLines = 0;
        _comment.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _comment;
}

- (UIImageView *)segmentLine{
    if (!_segmentLine) {
        _segmentLine = [[UIImageView alloc] init];
        _segmentLine.backgroundColor = [UIColor clearColor];
        _segmentLine.image = [UIImage imageNamed:@"line"];
    }
    return _segmentLine;
}

- (UIView *)mannerStarViews{
    if (!_mannerStarViews) {
        _mannerStarViews = [[UIView alloc] init];
        _mannerStarViews.backgroundColor = [UIColor clearColor];
//        UIImage *star = [UIImage imageNamed:@"kb_icon_-star_nor"];
//        _mannerStarViews.size = CGSizeMake(star.size.width * 5 + 4 * 8, star.size.height);
    }
    return _mannerStarViews;
}

- (UIView *)directionStarViews{
    if (!_directionStarViews) {
        _directionStarViews = [[UIView alloc] init];
        _directionStarViews.backgroundColor = [UIColor clearColor];
//        UIImage *star = [UIImage imageNamed:@"kb_icon_-star_nor"];
//        _directionStarViews.size = CGSizeMake(star.size.width * 5 + 4 * 8, star.size.height);
    }
    return _directionStarViews;
}

@end



@implementation FounderDetailCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.text1];
        [self.contentView addSubview:self.text2];
        [self.contentView addSubview:self.segmentLine];
    }
    return self;
}

- (void)lookPhone:(UITapGestureRecognizer *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(lookFounderRelationNumber:)]) {
        [self.delegate lookFounderRelationNumber:@"phone"];
    }
}

- (void)lookWeiChat:(UITapGestureRecognizer *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(lookFounderRelationNumber:)]) {
        [self.delegate lookFounderRelationNumber:@"weixin"];
    }
}

- (void)lookEmail:(UITapGestureRecognizer *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(lookFounderRelationNumber:)]) {
        [self.delegate lookFounderRelationNumber:@"email"];
    }
}

- (void)setData:(id)sender{
    if ([sender isKindOfClass:[NSMutableArray class]]) {
        NSMutableArray *array = (NSMutableArray *)sender;
        self.text1.text = [array firstObject];
        if ([self.text1.text isEqualToString:@"评价"]) {
            [self addSubview:self.cellSegmentLine];
        }
        NSString *str = [array lastObject];
        if ([self.text1.text isEqualToString:@"手机"] || [self.text1.text isEqualToString:@"微信"] || [self.text1.text isEqualToString:@"邮箱"]) {
            self.text2.text = [array lastObject];
         }else if ([self.text1.text isEqualToString:@"级别"]) {
            if ([str isEqualToString:@"100"]) {
                self.text2.text = @"高";
            }else if ([str isEqualToString:@"50"]) {
                self.text2.text = @"中";
            }else if ([str isEqualToString:@"0"]) {
                self.text2.text = @"低";
            }else{
                self.text2.text = @"未知";
            }
        }else if ([self.text1.text isEqualToString:@"推动力"]) {
            if ([str isEqualToString:@"100"]) {
                self.text2.text = @"强";
            }else if ([str isEqualToString:@"0"]) {
                self.text2.text = @"弱";
            }else{
                self.text2.text = @"未知";
            }
        }else if ([self.text1.text isEqualToString:@"好评"]) {
            if ([str isEqualToString:@"100"]) {
                self.text2.text = @"好评";
            }else if ([str isEqualToString:@"50"]) {
                self.text2.text = @"一般";
            }else if ([str isEqualToString:@"0"]) {
                self.text2.text = @"差评";
            }else{
                self.text2.text = @"未知";
            }
        }else if ([self.text1.text isEqualToString:@"投资概率"]) {
            if ([str isEqualToString:@"100"]) {
                self.text2.text = @"高";
            }else if ([str isEqualToString:@"0"]) {
                self.text2.text = @"低";
            }else{
                self.text2.text = @"未知";
            }
        }else if ([self.text1.text isEqualToString:@"名气"]) {
            if ([str isEqualToString:@"100"]) {
                self.text2.text = @"大";
            }else if ([str isEqualToString:@"0"]) {
                self.text2.text = @"小";
            }else{
                self.text2.text = @"未知";
            }
        }else{
            self.text2.text = [array lastObject];
        }
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if ([self.text1.text isEqualToString:@"评价"]) {
        self.text1.frame = CGRectMake(evaluate(10), 8, 100, 44);
    } else {
        self.text1.frame = CGRectMake(evaluate(10), 0, 100, 44);
    }
    CGSize size = [self calculateCellHeight:_text2.text textFont:[UIFont systemFontOfSize:16] contentSize:CGSizeMake(SCREEN_WIDTH - evaluate(20) - 100, CGFLOAT_MAX)];
    self.text2.frame = CGRectMake(SCREEN_WIDTH - evaluate(10) - size.width, 0, size.width, 44);
    self.segmentLine.frame = CGRectMake(0, self.height - 1, SCREEN_WIDTH, 1);
    if ([self.text1.text isEqualToString:@"手机"]) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lookPhone:)];
        [self.text2 addGestureRecognizer:tap];
    } else if ([self.text1.text isEqualToString:@"微信"]) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lookWeiChat:)];
        [self.text2 addGestureRecognizer:tap];
    } else if ([self.text1.text isEqualToString:@"邮箱"]) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lookEmail:)];
        [self.text2 addGestureRecognizer:tap];
    }
}

- (UILabel *)text1{
    if (!_text1) {
        _text1 = [[UILabel alloc] init];
        _text1.backgroundColor = [UIColor clearColor];
        _text1.font = [UIFont systemFontOfSize:16];
        _text1.textColor = LIGHTGRAY_COLOR;
    }
    return _text1;
}

- (UILabel *)text2{
    if (!_text2) {
        _text2 = [[UILabel alloc] init];
        _text2.backgroundColor = [UIColor clearColor];
        _text2.textAlignment = NSTextAlignmentRight;
        _text2.font = [UIFont systemFontOfSize:16];
        _text2.textColor = BLACK_COLOR;
        _text2.userInteractionEnabled = YES;
    }
    return _text2;
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
        _cellSegmentLine.frame = CGRectMake(0, 0, SCREEN_WIDTH, 8);
    }
    return _cellSegmentLine;
}

@end
