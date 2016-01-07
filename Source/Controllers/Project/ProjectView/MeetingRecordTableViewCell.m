//
//  MeetingRecordTableViewCell.m
//  Calendar
//
//  Created by 刘花椒 on 15/11/16.
//
//

#import "MeetingRecordTableViewCell.h"

@implementation MeetingRecordTableViewCell

- (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object{
    if ([object isKindOfClass:[ProjectMeetingRecordItem class]]) {
        ProjectMeetingRecordItem *item = (ProjectMeetingRecordItem *)object;
//        if (item.needfeedback) {
//            return 113 + item.attendees.count * 25;
//        } else {
            return 113 + item.attendees.count * 25 - 34;
        //}
    }else{
        return 0;
    }
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.item = [[ProjectMeetingRecordItem alloc] init];
        [self.contentView  addSubview:self.cellSegmentLine];
        [self.contentView addSubview:self.startTime];
        [self.contentView addSubview:self.stateText];
        [self.contentView addSubview:self.segmentLine];
        [self.contentView addSubview:self.location];
    }
    return self;
}

- (void)prepareForReuse{
    [super prepareForReuse];
}

- (void)setData:(ProjectMeetingRecordItem *)item{
    self.item = item;
    
    if (![item.startTime isEqualToString:@"(null)"] && item.startTime.length > 0) {
        self.startTime.text = item.startTime;
    }else{
        self.startTime.text = @"";
    }
    
    if (![item.stateText isEqualToString:@"(null)"] && item.stateText.length > 0) {
        self.stateText.text = item.stateText;
    }else{
        self.stateText.text = @"";
    }
    
    if (![item.location isEqualToString:@"(null)"] && item.location.length > 0) {
        self.location.text = item.location;
    }else{
        self.location.text = @"";
    }
    
    if (item.attendees.count > 0) {
        for (NSInteger i = 0; i < item.attendees.count; i++) {
            [[self viewWithTag:(100 + i)] removeFromSuperview];
            [[self viewWithTag:(200 + i)] removeFromSuperview];
            [[self viewWithTag:(300 + i)] removeFromSuperview];

        }
    }
    if (item.attendees.count > 0) {
        CGFloat height = 68;
        for (NSInteger i = 0; i < [item.attendees count]; i++) {
            ProjectAttendeesItem *attendeesItem = [item.attendees objectAtIndex:i];
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(evaluate(10), height + 10 , evaluate(100), 15)];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.font = [UIFont systemFontOfSize:14];
            titleLabel.text = attendeesItem.company;
            titleLabel.textColor = BLACK_COLOR;
            titleLabel.tag = 100 + i;
            [self addSubview:titleLabel];
            
            CGSize size = [self calculateCellHeight:attendeesItem.name textFont:[UIFont systemFontOfSize:14] contentSize:CGSizeMake(MAXFLOAT, 15)];
            UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.right + 10, titleLabel.top, size.width, 15)];
            nameLabel.backgroundColor = [UIColor clearColor];
            nameLabel.font = [UIFont systemFontOfSize:14];
            nameLabel.text = attendeesItem.name;
            nameLabel.textColor = BLACK_COLOR;
            nameLabel.tag = 200 + i;
            [self addSubview:nameLabel];
            
            UIButton *phoneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            phoneBtn.frame = CGRectMake(nameLabel.right + 10, titleLabel.top - 5, 100, 24);
            phoneBtn.userInteractionEnabled = YES;
            phoneBtn.backgroundColor = [UIColor clearColor];
            [phoneBtn setTitle:attendeesItem.phone forState:UIControlStateNormal];
            [phoneBtn setTitleColor:BLACK_COLOR forState:UIControlStateNormal];
            [phoneBtn addTarget:self action:@selector(phoneBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            phoneBtn.titleLabel.font = [UIFont systemFontOfSize:14];
            phoneBtn.tag = 300 + i;
            [self.contentView addSubview:phoneBtn];
            
            height = titleLabel.bottom;
        }
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.cellSegmentLine.frame = CGRectMake(0, 0, SCREEN_WIDTH, 8);
    self.startTime.frame = CGRectMake(evaluate(10), self.cellSegmentLine.bottom, 150, 34);
    self.stateText.frame = CGRectMake(self.startTime.right + 10, self.startTime.top, SCREEN_WIDTH - self.startTime.right - 10 - evaluate(10), 34);
    self.segmentLine.frame = CGRectMake(evaluate(10), self.startTime.bottom, SCREEN_WIDTH - evaluate(20), 1);
    self.location.frame = CGRectMake(evaluate(10), self.segmentLine.bottom + 10, SCREEN_WIDTH - evaluate(20), 15);
//    if (self.item.needfeedback) {
//        self.segmentLine1.frame = CGRectMake(evaluate(10), self.height - 34, SCREEN_WIDTH - evaluate(10), 1);
//        self.meetingFeedBack.frame = CGRectMake(SCREEN_WIDTH - evaluate(10) - evaluate(69), self.segmentLine1.bottom + 5, evaluate(69), 24);
//    }

}

- (void)meetingFeedBackClicked{
    NSLog(@"会议反馈");
}

- (void)phoneBtnClicked:(id)sender{
    UIButton *button = (UIButton *)sender;
    [CommonAPI callPhone:button.titleLabel.text];
    NSLog(@"联系创始人");
}

#pragma mark property

//- (UIButton *)meetingFeedBack{
//    if (!_meetingFeedBack) {
//        _meetingFeedBack = [UIButton buttonWithType:UIButtonTypeCustom];
//        _meetingFeedBack.backgroundColor = [UIColor clearColor];
//        _meetingFeedBack.clipsToBounds = YES;
//        _meetingFeedBack.layer.cornerRadius = 5;
//        _meetingFeedBack.layer.borderColor = RGBCOLOR(50, 188, 198).CGColor;
//        _meetingFeedBack.layer.borderWidth = 1.0;
//        [_meetingFeedBack setTitle:@"会议反馈" forState:UIControlStateNormal];
//        [_meetingFeedBack setTitleColor:RGBCOLOR(50, 188, 198) forState:UIControlStateNormal];
//        _meetingFeedBack.titleLabel.font = [UIFont systemFontOfSize:14];
//        [_meetingFeedBack addTarget:self action:@selector(meetingFeedBackClicked) forControlEvents:UIControlEventTouchUpInside];
//        [self.contentView addSubview:_meetingFeedBack];
//    }
//    return _meetingFeedBack;
//}

- (UILabel *)startTime{
    if (!_startTime) {
        _startTime = [[UILabel alloc] init];
        _startTime.backgroundColor = [UIColor clearColor];
        _startTime.textColor = BLACK_COLOR;
        _startTime.font = [UIFont systemFontOfSize:14];
    }
    return _startTime;
}

- (UILabel *)stateText{
    if (!_stateText) {
        _stateText = [[UILabel alloc] init];
        _stateText.backgroundColor = [UIColor clearColor];
        _stateText.textColor = BLACK_COLOR;
        _stateText.font = [UIFont systemFontOfSize:14];
        _stateText.textAlignment = NSTextAlignmentRight;
    }
    return _stateText;
}

- (UILabel *)location{
    if (!_location) {
        _location = [[UILabel alloc] init];
        _location.backgroundColor = [UIColor clearColor];
        _location.textColor = RGBCOLOR(106, 106, 106);
        _location.font = [UIFont systemFontOfSize:14];
    }
    return _location;
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

- (UIImageView *)segmentLine1{
    if (!_segmentLine1) {
        _segmentLine1 = [[UIImageView alloc] init];
        _segmentLine1.backgroundColor = [UIColor clearColor];
        _segmentLine1.image = [UIImage imageNamed:@"line"];
        [self addSubview:_segmentLine1];
    }
    return _segmentLine1;
}

@end
