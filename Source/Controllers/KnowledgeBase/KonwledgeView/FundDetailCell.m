//
//  FundDetailCell.m
//  Calendar
//
//  Created by 刘花椒 on 15/11/25.
//
//

#import "FundDetailCell.h"

@implementation FundDetailCell

- (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object index:(NSIndexPath *)index{
    CGFloat height = 44;
    if ([object isKindOfClass:[NSString class]]) {
        NSString *content = (NSString *)object;
        if (index.row == 2 || index.row == 3) {
            CGSize size = [self calculateCellHeight:content textFont:[UIFont systemFontOfSize:16] contentSize:CGSizeMake(SCREEN_WIDTH - evaluate(20), CGFLOAT_MAX)];
            height += size.height + 14;
        }
    } else if ([object isKindOfClass:[NSArray class]]) {
        NSArray *address = (NSArray *)object;
        NSString *content = @"";
        if (address.count > 0) {
            for (NSDictionary *dict in address) {
                content = [content stringByAppendingFormat:@"%@%@\n",[dict objectForKey:@"city"],[dict objectForKey:@"address"]];
            }
        } else {
            content = [NSString stringWithFormat:@"目前没有填写地址"];
        }
        CGSize size = [self calculateCellHeight:content textFont:[UIFont systemFontOfSize:16] contentSize:CGSizeMake(SCREEN_WIDTH - evaluate(20), CGFLOAT_MAX)];
        height += size.height + 28;
    }
    return height;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.text1];
        [self.contentView addSubview:self.text2];
        [self.contentView addSubview:self.segmentLine];
        [self.contentView addSubview:self.addressLine];
    }
    return self;
}

- (void)prepareForReuse{
    [super prepareForReuse];
    self.text1.text = nil;
    self.text2.text = nil;
    self.addressLine.hidden = YES;
}

- (void)setData:(id)sender{
    if ([sender isKindOfClass:[NSMutableArray class]]) {
        NSMutableArray *array = (NSMutableArray *)sender;
        self.text1.text = [array firstObject];
        if ([self.text1.text isEqualToString:@"介绍"] || [self.text1.text isEqualToString:@"备注"]) {
            NSString *str = [array lastObject];
            NSMutableAttributedString * attrS = [[NSMutableAttributedString alloc] initWithString:str];
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.lineSpacing = 10;
            NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:16],NSParagraphStyleAttributeName:style};
            [attrS addAttributes:attribute range:NSMakeRange(0, str.length)];
            self.text2.attributedText = attrS;
            [self.text2 sizeToFit];

        }else if ([self.text1.text isEqualToString:@"地址"]){
            NSMutableArray *address = [array lastObject];
            NSString *content = @"";
            if (address.count > 0) {
                for (NSDictionary *dict in address) {
                    content = [content stringByAppendingFormat:@"%@%@\n",[dict objectForKey:@"city"],[dict objectForKey:@"address"]];
                }
            } else {
                content = [NSString stringWithFormat:@"目前没有填写地址"];
            }
            
            NSMutableAttributedString * attrS = [[NSMutableAttributedString alloc] initWithString:content];
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.lineSpacing = 10;
            NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:16],NSParagraphStyleAttributeName:style};
            [attrS addAttributes:attribute range:NSMakeRange(0, content.length)];
            self.text2.attributedText = attrS;
            [self.text2 sizeToFit];
            self.addressLine.hidden = NO;

//            UIImageView *line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line"]];
//            line.backgroundColor = [UIColor clearColor];
//            line.frame = CGRectMake(evaluate(10), 44, SCREEN_WIDTH - evaluate(20), 1);
//            [self addSubview:line];
            
        } else {
            NSString *str = [array lastObject];
            if ([self.text1.text isEqualToString:@"名气"] || [self.text1.text isEqualToString:@"投资概率"]) {
                if ([str isEqualToString:@"100"]) {
                    self.text2.text = @"大";
                } else if ([str isEqualToString:@"0"]){
                    self.text2.text = @"小";
                } else {
                    self.text2.text = [array lastObject];
                }
            } else if ([self.text1.text isEqualToString:@"币种"]) {
                if ([str isEqualToString:@"1"]) {
                    self.text2.text = @"人民币";
                } else if ([str isEqualToString:@"2"]) {
                    self.text2.text = @"美元";
                } else if ([str isEqualToString:@"3"]) {
                    self.text2.text = @"人民币/美元";
                } else {
                    self.text2.text = [array lastObject];
                }
            }  else if ([self.text1.text isEqualToString:@"是否战投"] || [self.text1.text isEqualToString:@"新三板"] || [self.text1.text isEqualToString:@"本身是小公司创业"]) {
                if ([str isEqualToString:@"1"]) {
                    self.text2.text = @"是";
                } else if ([str isEqualToString:@"0"]) {
                    self.text2.text = @"否";
                } else {
                    self.text2.text = [array lastObject];
                }
            } else {
                self.text2.text = [array lastObject];
            }
        }
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.text1.frame = CGRectMake(evaluate(10), 0, 150, 44);
    CGSize size = [self calculateCellHeight:self.text2.text textFont:[UIFont systemFontOfSize:16] contentSize:CGSizeMake(SCREEN_WIDTH - evaluate(20), CGFLOAT_MAX)];
    
    if ([self.text1.text isEqualToString:@"介绍"] || [self.text1.text isEqualToString:@"备注"] || [self.text1.text isEqualToString:@"地址"]) {
        if ([self.text1.text isEqualToString:@"地址"]) {
            self.text2.frame = CGRectMake(evaluate(10), self.text1.bottom + 14, SCREEN_WIDTH - evaluate(20), size.height);
        }else{
            self.text2.frame = CGRectMake(evaluate(10), self.text1.bottom, SCREEN_WIDTH - evaluate(20), size.height);
        }
    } else {
        self.text2.frame = CGRectMake(SCREEN_WIDTH - evaluate(10) - size.width, 0, size.width, 44);
    }
    self.segmentLine.hidden = NO;
    self.segmentLine.frame = CGRectMake(evaluate(10), self.height - 1, SCREEN_WIDTH - evaluate(20), 1);
    if ([self.text1.text isEqualToString:@"本身是小公司创业"]) {
        self.segmentLine.hidden = YES;
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
        _text2.numberOfLines = 0;
        _text2.lineBreakMode = NSLineBreakByWordWrapping;
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

- (UIImageView *)addressLine{
    if (!_addressLine) {
        _addressLine = [[UIImageView alloc] init];
        _addressLine.backgroundColor = [UIColor clearColor];
        _addressLine.image = [UIImage imageNamed:@"line"];
        _addressLine.hidden = YES;
        _addressLine.frame = CGRectMake(evaluate(10), 44, SCREEN_WIDTH - evaluate(20), 1);
    }
    return _addressLine;
}

@end
