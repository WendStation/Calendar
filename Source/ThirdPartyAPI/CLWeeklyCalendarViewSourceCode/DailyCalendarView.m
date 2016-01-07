//
//  DailyCalendarView.m
//  Deputy
//
//  Created by Caesar on 30/10/2014.
//  Copyright (c) 2014 Caesar Li
//
#import "DailyCalendarView.h"
#import "NSDate+CL.h"
#import "UIColor+CL.h"
#import "NSDate+Escort.h"
#import "MacroDefinition.h"

@interface DailyCalendarView()
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UIImageView *dotImage;
@property (nonatomic, strong) UIView *dateLabelContainer;
@end


#define DATE_LABEL_FONT_SIZE 12
#define LABEL_SPACE 2

@implementation DailyCalendarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self addSubview:self.dateLabelContainer];
        [self addSubview:self.dotImage];
        UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dailyViewDidClick:)];
        [self addGestureRecognizer:singleFingerTap];
    }
    return self;
}

-(UIView *)dateLabelContainer
{
    if(!_dateLabelContainer){
        _dateLabelContainer = [[UIView alloc] initWithFrame:CGRectMake(0, LABEL_SPACE, self.bounds.size.width - LABEL_SPACE * 2, self.bounds.size.height - LABEL_SPACE * 2)];
        _dateLabelContainer.backgroundColor = [UIColor clearColor];
        _dateLabelContainer.layer.cornerRadius = _dateLabelContainer.frame.size.width / 2;
        _dateLabelContainer.clipsToBounds = YES;
        _dateLabelContainer.layer.borderColor = BLUE_COLOR.CGColor;
        
        [_dateLabelContainer addSubview:self.dateLabel];
    
    }
    return _dateLabelContainer;
}
-(UILabel *)dateLabel
{
    if(!_dateLabel){
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _dateLabelContainer.frame.size.width, _dateLabelContainer.frame.size.height)];
        _dateLabel.backgroundColor = [UIColor clearColor];
        _dateLabel.textColor = [UIColor blackColor];
        _dateLabel.textAlignment = NSTextAlignmentCenter;
        _dateLabel.font = [UIFont systemFontOfSize:DATE_LABEL_FONT_SIZE];
        _dateLabel.numberOfLines = 2;
    }
    
    return _dateLabel;
}
-(UIImageView *)dotImage {
    if (!_dotImage) {
        _dotImage = [[UIImageView alloc] initWithFrame:CGRectMake(_dateLabelContainer.frame.size.width / 2 - 2,_dateLabelContainer.frame.size.height - 5, 4, 4)];
        _dotImage.image = [UIImage imageNamed:@"point"];
        _dotImage.hidden = NO;
    }
    return _dotImage;
}

-(void)setDate:(NSDate *)date
{
    _date = date;
    
    [self setNeedsDisplay];
}

-(void)setShowDot:(BOOL)showDot
{
    _showDot = showDot;
    
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    
    if([self.date isDateToday]) {
        self.dateLabel.text = [NSString stringWithFormat:@"%@\n今日", [self.date weekDes]];
    }
    else {
        self.dateLabel.text = [NSString stringWithFormat:@"%@\n%@日", [self.date weekDes], [self.date getDateOfMonth]];
    }
    if (_showDot) {
        self.dotImage.hidden = NO;
    }
    else {
        self.dotImage.hidden = YES;
    }
}


-(void)markSelected:(BOOL)blnSelected
{
    //    DLog(@"mark date selected %@ -- %d",self.date, blnSelected);
    if([self.date isDateToday]){
        self.dateLabelContainer.layer.borderWidth = 1.f;
        self.dateLabel.textColor = (blnSelected)?[UIColor whiteColor]:BLACK_COLOR;
    }else{
        self.dateLabelContainer.layer.borderWidth = 0.f;
        self.dateLabel.textColor = (blnSelected)?[UIColor whiteColor]:[self colorByDate];
    }
    
    self.dateLabelContainer.backgroundColor = (blnSelected)?BLUE_COLOR: [UIColor whiteColor];
    
    self.dotImage.image = (blnSelected)?[UIImage imageNamed:@"point_white"]: [UIImage imageNamed:@"point"];
    
}
-(UIColor *)colorByDate
{
    return [self.date isPastDate]?[UIColor colorWithHex:0x8A8A8A]:BLACK_COLOR;
}

-(void)dailyViewDidClick: (UIGestureRecognizer *)tap
{
    [self.delegate dailyCalendarViewDidSelect: self.date];
}
@end

