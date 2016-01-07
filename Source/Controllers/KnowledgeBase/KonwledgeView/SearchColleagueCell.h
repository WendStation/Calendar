//
//  SearchColleagueCell.h
//  Calendar
//
//  Created by 刘花椒 on 15/11/24.
//
//

#import "BaseTableViewCell.h"

@protocol SearchColleagueCellDelegate <NSObject>

- (void)relationColleague:(NSString *)phone;
- (void)lookschedule:(Customer *)user;

@end

@interface SearchColleagueCell : BaseTableViewCell

@property(nonatomic, weak)id <SearchColleagueCellDelegate>delegate;
@property(nonatomic, strong)UILabel *name;
@property(nonatomic, strong)UILabel * position;
@property(nonatomic, strong)UIButton * phone;
@property(nonatomic, strong)UIButton * lookSchedule;
@property(nonatomic, strong)UIImageView *segmentLine;
@property(nonatomic, strong)Customer *user;

@end
