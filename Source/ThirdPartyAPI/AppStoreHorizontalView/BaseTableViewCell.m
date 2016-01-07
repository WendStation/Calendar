//
//  BaseTableViewCell.m
//  AppStore(Horizontal)Demo
//
//  Created by liaoyp on 15/4/24.
//  Copyright (c) 2015年 liaoyp. All rights reserved.
//

#import "BaseTableViewCell.h"

@implementation BaseTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (CGSize)calculateCellHeight:(NSString *)textStr textFont:(UIFont *)textFont contentSize:(CGSize)contentSize{
    if (![textStr isKindOfClass:[NSNull class]] && textStr.length > 0) {
        NSString *content = [textStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSMutableAttributedString * attrS = [[NSMutableAttributedString alloc] initWithString:content];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 10;
        NSDictionary *attribute = @{NSFontAttributeName:textFont,NSParagraphStyleAttributeName:style};
        [attrS addAttributes:attribute range:NSMakeRange(0, content.length)];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, contentSize.width, CGFLOAT_MAX)];
        label.attributedText = attrS;
        label.numberOfLines = 0;
        [label sizeToFit];
        return label.size;
    } else {
        return CGSizeZero;
    }
}

@end
