//
//  MessageTableViewCell.m
//  Calendar
//
//  Created by 刘花椒 on 15/12/7.
//
//

#import "GroupListCell.h"
#import "GroupListItem.h"

static const CGFloat redPointWidth = 17;

@interface GroupListCell ()

@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *message;
@property (nonatomic, strong) UILabel *redPoint;

@end

@implementation GroupListCell

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.redPoint removeFromSuperview];
}

- (void)setData:(id)sender {
    if ([sender isKindOfClass:[GroupListItem class]]) {
        GroupListItem *item = (GroupListItem *)sender;
        [self.icon setImageWithURL:[NSURL URLWithString:item.logoUrl]];
        self.title.text = item.name;
        if (item.unReadMessageNum > 0) {
            self.redPoint.text = [NSString stringWithFormat:@"%ld",(long)item.unReadMessageNum];
            CGSize size = [self calculateCellHeight:self.title.text textFont:[UIFont systemFontOfSize:16] contentSize:self.title.size];
            self.redPoint.frame = CGRectMake(self.title.left + size.width + 5, self.title.top + 1, redPointWidth, redPointWidth);
            [self addSubview:self.redPoint];
        }
        NSDate *date = [NSDate dateFromUtcTimeStamp:item.lastSendTime withFormat:[NSDate timestampFormatString]];
        if ([date isToday]) {
            self.time.text = [NSString stringWithFormat:@"今天 %@",[date stringWithFormat:@"HH:mm"]];
        } else {
            self.time.text = [date stringWithFormat:@"MM-dd HH:mm"];
        }
        self.message.text = item.lastMessage;
    }
}

- (UILabel *)redPoint {
    if (!_redPoint) {
        _redPoint = [[UILabel alloc] init];
        _redPoint.backgroundColor = RGBCOLOR(242, 100, 98);
        _redPoint.font = [UIFont systemFontOfSize:10];
        _redPoint.textColor = [UIColor whiteColor];
        _redPoint.textAlignment = NSTextAlignmentCenter;
        _redPoint.clipsToBounds = YES;
        _redPoint.layer.cornerRadius = redPointWidth / 2.0;
    }
    return _redPoint;
}

@end
