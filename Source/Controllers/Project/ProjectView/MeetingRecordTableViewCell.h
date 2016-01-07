//
//  MeetingRecordTableViewCell.h
//  Calendar
//
//  Created by 刘花椒 on 15/11/16.
//
//

#import "BaseTableViewCell.h"
#import "ProjectDetailItem.h"

@interface MeetingRecordTableViewCell : BaseTableViewCell

@property(nonatomic, strong)UILabel *cellSegmentLine;
@property(nonatomic, strong)UILabel *startTime;
@property(nonatomic, strong)UILabel *stateText;
@property(nonatomic, strong)UILabel *location;
@property(nonatomic, strong)UIImageView *segmentLine;
@property(nonatomic, strong)UIImageView *segmentLine1;
//@property(nonatomic, strong)UIButton *meetingFeedBack;
@property(nonatomic, strong)ProjectMeetingRecordItem *item;

- (void)setData:(ProjectMeetingRecordItem *)item;

@end
