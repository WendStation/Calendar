//
//  TaskListCell.m
//  Calendar
//
//  Created by 刘花椒 on 15/12/15.
//
//

#import "TaskListCell.h"
#import "TaskListItem.h"

@interface TaskListCell ()

@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *text;

@end

@implementation TaskListCell

- (void)setData:(id)sender {
    if ([sender isKindOfClass:[TaskListItem class]]) {
        TaskListItem *item = (TaskListItem *)sender;
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
