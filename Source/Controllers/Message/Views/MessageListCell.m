//
//  MessageListCell.m
//  Calendar
//
//  Created by 刘花椒 on 15/12/9.
//
//

#import "MessageListCell.h"
#import "MessageListItem.h"

@interface MessageListCell ()

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *text;


@end

@implementation MessageListCell

- (void)setData:(id)sender {
    if ([sender isKindOfClass:[MessageListItem class]]) {
        MessageListItem *item = (MessageListItem *)sender;
        self.title.text = item.title;
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:item.text];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 5;
        NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:14], NSParagraphStyleAttributeName:style, NSForegroundColorAttributeName:DARKGRAY_COLOR};
        [string addAttributes:attribute range:NSMakeRange(0, item.text.length)];
        self.text.attributedText = string;
        [self.text sizeToFit];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
