//
//  projectTableViewCell.m
//  Calendar
//
//  Created by 刘花椒 on 15/10/29.
//
//

#import "projectTableViewCell.h"

@implementation ProjectTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor whiteColor];
        self.item = [[ProjectListItem alloc] init];
        [self.contentView addSubview:self.cellSegmentLine];
        [self.contentView addSubview:self.projectName];
        [self.contentView addSubview:self.agentUserName];
        [self.contentView addSubview:self.founderName];
        [self.contentView addSubview:self.phoneBtn];
        [self.contentView addSubview:self.segmentLine];
        [self.contentView addSubview:self.progressStatus];
        [self.contentView addSubview:self.projectDatail];
    }
    return self;
}

- (void)prepareForReuse{
    [super prepareForReuse];
    self.projectName.text = nil;
    self.agentUserName.text = nil;
    self.founderName.text = nil;
    self.progressStatus.text = nil;
    self.projectDatail.text = nil;
}

- (void)setData:(ProjectListItem *)item projectType:(ProjectRequestType )projectType{
    self.item = item;
    self.projectType = projectType;
    
    if (![self.item.title isEqualToString:@"(null)"] && self.item.title.length > 0) {
        self.projectName.text = self.item.title;
    }else {
        self.projectName.text = @"";
    }
    if (projectType == OnlineProject) {
        if (![self.item.agentName isEqualToString:@"(null)"] && self.item.agentName.length > 0) {
            self.agentUserName.text = self.item.agentName;
        }else {
            self.agentUserName.text = @"";
        }
    }
    if (![self.item.ownerName isEqualToString:@"(null)"] && self.item.ownerName.length > 0) {
        self.founderName.text = self.item.ownerName;
    }else {
        self.founderName.text = @"";
    }
    
    if (![self.item.phone isEqualToString:@"(null)"] && self.item.phone.length > 0) {
        [self.phoneBtn setTitle:self.item.phone forState:UIControlStateNormal];
    }else {
        [self.phoneBtn setTitle:@"" forState:UIControlStateNormal];
    }
    
    
    if (![self.item.statusText1 isEqualToString:@"(null)"] && self.item.statusText1.length > 0) {
        self.progressStatus.text = self.item.statusText1;
    } else{
        self.progressStatus.text = @"";
    }
    
    
    if (![self.item.statusText2 isEqualToString:@"(null)"] && self.item.statusText2.length > 0) {
        self.projectDatail.text = self.item.statusText2;
    } else{
        self.projectDatail.text = @"";
    }
    
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.projectName.frame = CGRectMake(evaluate(10), 15 + 8, 200, 20);
    self.agentUserName.frame = CGRectMake(SCREEN_WIDTH - 100 - evaluate(10), 15 + 8, 100, 20);
    self.founderName.frame = CGRectMake(evaluate(10), self.projectName.bottom + 10, 100, 20);
    self.phoneBtn.frame = CGRectMake(self.founderName.right, self.projectName.bottom + 10, 120, 20);
    self.progressStatus.frame = CGRectMake(evaluate(10), 80 + 8, 100, 20);
    self.projectDatail.frame = CGRectMake(SCREEN_WIDTH - 250 - evaluate(10), 80 + 8, 250, 20);

}

- (void)phoneBtnClicked{
    [CommonAPI callPhone:self.phoneBtn.titleLabel.text];
    NSLog(@"联系创始人");
}

#pragma mark --preporty
- (UILabel *)projectName{
    if (!_projectName) {
        _projectName = [[UILabel alloc] init];
        _projectName.backgroundColor = [UIColor clearColor];
        _projectName.textColor = BLACK_COLOR;
        _projectName.font = [UIFont systemFontOfSize:16];
    }
    return _projectName;
}

- (UILabel *)agentUserName{
    if (!_agentUserName) {
        _agentUserName = [[UILabel alloc] init];
        _agentUserName.textAlignment = NSTextAlignmentRight;
        _agentUserName.backgroundColor = [UIColor clearColor];
        _agentUserName.textColor = BLACK_COLOR;
        _agentUserName.font = [UIFont systemFontOfSize:16];
    }
    return _agentUserName;
}

- (UILabel *)founderName{
    if (!_founderName) {
        _founderName = [[UILabel alloc] init];
        _founderName.backgroundColor = [UIColor clearColor];
        _founderName.textColor = BLACK_COLOR;
        _founderName.font = [UIFont systemFontOfSize:16];
    }
    return _founderName;
}

- (UIButton *)phoneBtn{
    if (!_phoneBtn) {
        _phoneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_phoneBtn addTarget:self action:@selector(phoneBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        _phoneBtn.backgroundColor = [UIColor clearColor];
        [_phoneBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
        [_phoneBtn setTitleColor:BLUE_COLOR forState:UIControlStateNormal];
        _phoneBtn.titleLabel.textAlignment = NSTextAlignmentRight;
    }
    return _phoneBtn;
}

- (UIImageView *)segmentLine{
    if (!_segmentLine) {
        _segmentLine = [[UIImageView alloc] init];
        _segmentLine.backgroundColor = [UIColor clearColor];
        _segmentLine.frame = CGRectMake(0, 70 + 8, SCREEN_WIDTH, 1);
        _segmentLine.image = [UIImage imageNamed:@"line"];
    }
    return _segmentLine;
}

- (UILabel *)progressStatus{
    if (!_progressStatus) {
        _progressStatus = [[UILabel alloc] init];
        _progressStatus.backgroundColor = [UIColor clearColor];
        _progressStatus.textColor = LIGHTGRAY_COLOR;
        _progressStatus.font = [UIFont systemFontOfSize:14];
    }
    return _progressStatus;
}

- (UILabel *)projectDatail{
    if (!_projectDatail) {
        _projectDatail = [[UILabel alloc] init];
        _projectDatail.backgroundColor = [UIColor clearColor];
        _projectDatail.textColor = LIGHTGRAY_COLOR;
        _projectDatail.font = [UIFont systemFontOfSize:14];
        _projectDatail.textAlignment = NSTextAlignmentRight;
    }
    return _projectDatail;
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
