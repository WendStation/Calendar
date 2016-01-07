//
//  ProjectDetailTableViewCell.m
//  Calendar
//
//  Created by 刘花椒 on 15/11/5.
//
//

#import "ProjectDetailTableViewCell.h"



#pragma mark 团队情况
@interface TeamInfoTableViewCell ()

@property(nonatomic, strong)NSMutableArray *teamInfoAry;

@end

@implementation TeamInfoTableViewCell

- (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object{
    NSMutableArray *ary = (NSMutableArray *)object;
    CGFloat cellHeight = 0;
    if (ary.count > 0) {
        for (NSInteger i = 0; i < [ary count]; i++) {
            ProjectTeamsInfoItem *item = [ary objectAtIndex:i];
            cellHeight += [self calculateCellHeight:item.name textFont:[UIFont systemFontOfSize:15] contentSize:CGSizeMake(SCREEN_WIDTH - evaluate(20), CGFLOAT_MAX)].height;
            cellHeight += [self calculateCellHeight:item.info textFont:[UIFont systemFontOfSize:15] contentSize:CGSizeMake(SCREEN_WIDTH - evaluate(20), CGFLOAT_MAX)].height;
        }
    }
    return cellHeight + (ary.count * 2 + 1)* 10;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        self.teamInfoAry = [NSMutableArray array];
    }
    return self;
}

- (void)prepareForReuse{
    [super prepareForReuse];
    [self removeAllSubviews];
    [self.teamInfoAry removeAllObjects];
}

- (void)setData:(NSMutableArray *)teamInfoAry{
    [self.teamInfoAry addObjectsFromArray:teamInfoAry];
    
    CGFloat height = 0;
    for (NSInteger i = 0; i < [self.teamInfoAry count]; i++) {
        ProjectTeamsInfoItem *item = [self.teamInfoAry objectAtIndex:i];
       
        UILabel *name = [[UILabel alloc] init];
        CGSize nameSize = [self calculateCellHeight:item.name textFont:[UIFont systemFontOfSize:15] contentSize:CGSizeMake(SCREEN_WIDTH - evaluate(20), CGFLOAT_MAX)];
        name.frame = CGRectMake(evaluate(10),height + 14, nameSize.width + 8, 22);
        name.backgroundColor = RGBACOLOR(50, 188, 198, 0.2);
        name.layer.borderColor = RGBCOLOR(50, 188, 198).CGColor;
        name.layer.borderWidth = 1.0;
        name.clipsToBounds = YES;
        name.layer.cornerRadius = 5;
        name.font = [UIFont systemFontOfSize:15];
        name.text = item.name;
        name.textAlignment = NSTextAlignmentCenter;
        name.textColor = BLACK_COLOR;
        [self addSubview:name];
        
        CGSize positionSize = [self calculateCellHeight:item.position textFont:[UIFont systemFontOfSize:15] contentSize:CGSizeMake(SCREEN_WIDTH - evaluate(20), CGFLOAT_MAX)];
        UILabel *position = [[UILabel alloc] initWithFrame:CGRectMake(name.right + 10, name.top, positionSize.width, name.height)];
        position.backgroundColor = [UIColor clearColor];
        position.text = item.position;
        position.textColor = DARKGRAY_COLOR;
        position.font = [UIFont systemFontOfSize:15];
        [self addSubview:position];
        
        
        CGFloat width = SCREEN_WIDTH;
        if (![item.email isEqualToString:@"(null)"] && item.email.length > 0) {
            UIImage *image = [UIImage imageNamed:@"bplist_bt_email"];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.backgroundColor = [UIColor clearColor];
            button.frame = CGRectMake(width - image.size.width - evaluate(10), name.top - 7, image.size.width, image.size.height);
            [button setImage:image forState:UIControlStateNormal];
            button.tag = 100 + i;
            [button addTarget:self action:@selector(emailClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
            width = button.frame.origin.x;
        }
        if (![item.weixin isEqualToString:@"(null)"] && item.weixin.length > 0) {
            UIImage *image = [UIImage imageNamed:@"bplist_bt_wechat"];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.backgroundColor = [UIColor clearColor];
            if (![item.email isEqualToString:@"(null)"] && item.email.length > 0) {
               button.frame = CGRectMake(width - 25 - image.size.width, name.top - 7, image.size.width, image.size.height);
            }else{
                button.frame = CGRectMake(width - image.size.width - evaluate(10), name.top - 7, image.size.width, image.size.height);
            }
            
            [button setImage:image forState:UIControlStateNormal];
            button.titleLabel.text = item.weixin;
            button.tag = 200 + i;
            [button addTarget:self action:@selector(weixinClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
            width = button.frame.origin.x;
        }
        if (![item.phone isEqualToString:@"(null)"] && item.phone.length > 0) {
            UIImage *image = [UIImage imageNamed:@"bplist_bt_phone"];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.backgroundColor = [UIColor clearColor];
            if (([item.weixin isEqualToString:@"(null)"] && item.weixin.length > 0) || (![item.email isEqualToString:@"(null)"] && item.email.length > 0)) {
                button.frame = CGRectMake(width - 25 - image.size.width, name.top - 7, image.size.width, image.size.height);
            }else {
                button.frame = CGRectMake(width - image.size.width - evaluate(10), name.top - 7, image.size.width, image.size.height);
            }
            
            [button setImage:image forState:UIControlStateNormal];
            [button setTitle:item.phone forState:UIControlStateNormal];
            button.tag = 300 + i;
            [button addTarget:self action:@selector(phoneClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
        }
        
        
        
        CGSize contentSize = [self calculateCellHeight:item.info textFont:[UIFont systemFontOfSize:15] contentSize:CGSizeMake(SCREEN_WIDTH - evaluate(20), CGFLOAT_MAX)];
        UILabel *content = [[UILabel alloc] initWithFrame:CGRectMake(evaluate(10), name.bottom + 14, SCREEN_WIDTH - evaluate(20), contentSize.height)];
        content.backgroundColor = [UIColor clearColor];
        content.numberOfLines = 0;
        NSMutableAttributedString * attrS = [[NSMutableAttributedString alloc] initWithString:item.info];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 10;
        NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:15],NSParagraphStyleAttributeName:style,NSForegroundColorAttributeName:DARKGRAY_COLOR};
        [attrS addAttributes:attribute range:NSMakeRange(0, item.info.length)];
        content.attributedText = attrS;
        [content sizeToFit];
        content.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:content];
        
        height = content.bottom;
    }
}

- (void)emailClicked:(id)sender{
    UIButton *button = (UIButton *)sender;
    ProjectTeamsInfoItem *item = [self.teamInfoAry objectAtIndex:button.tag - 100];
    if (self.delegate && [self.delegate respondsToSelector:@selector(relationProjectFounder:relationWay:)]) {
        [self.delegate relationProjectFounder:item relationWay:@"email"];
    }
}

- (void)weixinClicked:(id)sender{
    UIButton *button = (UIButton *)sender;
    ProjectTeamsInfoItem *item = [self.teamInfoAry objectAtIndex:button.tag - 200];
    if (self.delegate && [self.delegate respondsToSelector:@selector(relationProjectFounder:relationWay:)]) {
        [self.delegate relationProjectFounder:item relationWay:@"weixin"];
    }
}

- (void)phoneClicked:(id)sender{
    UIButton *button = (UIButton *)sender;
    ProjectTeamsInfoItem *item = [self.teamInfoAry objectAtIndex:button.tag - 300];
    if (self.delegate && [self.delegate respondsToSelector:@selector(relationProjectFounder:relationWay:)]) {
        [self.delegate relationProjectFounder:item relationWay:@"phone"];
    }
}
@end

#pragma mark 运营数据

@implementation OperationDataTableViewCell

- (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object{
    
    NSString *operationDataStr = (NSString *)object;
    if (![operationDataStr isEqualToString:@"(null)"] && operationDataStr.length > 0) {
        CGSize size = [self calculateCellHeight:operationDataStr textFont:[UIFont systemFontOfSize:15] contentSize:CGSizeMake(SCREEN_WIDTH - evaluate(20), CGFLOAT_MAX)];
        return size.height + 20;
    } else {
        return 0;
    }
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.operationDataLabel];
    }
    return self;
}

- (void)prepareForReuse{
    [super prepareForReuse];
    self.operationDataLabel.text = nil;
}

- (void)setData:(NSString *)operationDatas{
    if (![operationDatas isEqualToString:@"(null)"] && operationDatas.length > 0) {
        NSMutableAttributedString * attrS = [[NSMutableAttributedString alloc] initWithString:operationDatas];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 10;
        NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:15],NSParagraphStyleAttributeName:style};
        [attrS addAttributes:attribute range:NSMakeRange(0, operationDatas.length)];
        self.operationDataLabel.attributedText = attrS;
        [self.operationDataLabel sizeToFit];

    } else {
        self.operationDataLabel.text = @"";
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGSize size = [self calculateCellHeight:self.operationDataLabel.text textFont:[UIFont systemFontOfSize:15] contentSize:CGSizeMake(SCREEN_WIDTH - evaluate(20), CGFLOAT_MAX)];
    self.operationDataLabel.frame = CGRectMake(evaluate(10), 10, SCREEN_WIDTH - evaluate(20), size.height);
}

- (UILabel *)operationDataLabel{
    if (!_operationDataLabel) {
        _operationDataLabel = [[UILabel alloc] init];
        _operationDataLabel.backgroundColor = [UIColor clearColor];
        _operationDataLabel.font = [UIFont systemFontOfSize:15];
        _operationDataLabel.textColor = DARKGRAY_COLOR;
        _operationDataLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _operationDataLabel.numberOfLines = 0;
    }
    return _operationDataLabel;
}

@end


#pragma mark 相关网址
@interface RelatedHttpURLTableViewCell ()

@property(nonatomic, strong)NSMutableArray *httpUrlAry;

@end

@implementation RelatedHttpURLTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        self.httpUrlAry = [NSMutableArray array];
    }
    return self;
}

- (void)setData:(NSMutableArray *)httpUrlAry{
    if (httpUrlAry.count > 0) {
        [self.httpUrlAry removeAllObjects];
        [self.httpUrlAry addObjectsFromArray:httpUrlAry];
    } else {
        return;
    }
    
    CGFloat buttonWidth = SCREEN_WIDTH / 7.0 * 2;
    UIScrollView *linksScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100)];
    linksScrollView.contentSize = CGSizeMake(buttonWidth * self.httpUrlAry.count, 100);
    linksScrollView.backgroundColor = [UIColor clearColor];
    linksScrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:linksScrollView];
    
    for (NSInteger i = 0; i < self.httpUrlAry.count; i++) {
        RelatedHttpUrlItem *item = [self.httpUrlAry objectAtIndex:i];
        UIButton *linkButton = [UIButton buttonWithType:UIButtonTypeCustom];
        linkButton.backgroundColor = [UIColor clearColor];
        linkButton.frame = CGRectMake(i * buttonWidth, 0, buttonWidth, 100);
        linkButton.tag = 100 + i;
        
        UIImageView *icon = [[UIImageView alloc] init];
        icon.backgroundColor = [UIColor clearColor];
        if ([item.type isEqualToString:@"website"]) {
            icon.image = [UIImage imageNamed:@"list_icon_link"];
        } else if ([item.type isEqualToString:@"android"]) {
            icon.image = [UIImage imageNamed:@"list_icon_android"];
        } else if ([item.type isEqualToString:@"ios"]) {
            icon.image = [UIImage imageNamed:@"list_icon_apple"];
        } else if ([item.type isEqualToString:@"video"]) {
            icon.image = [UIImage imageNamed:@"list_icon_video"];
        } else if ([item.type isEqualToString:@"account"]) {
            icon.image = [UIImage imageNamed:@"list_icon_demo"];
        } else {
            icon.image = [UIImage imageNamed:@"list_icon_all"];
        }
        icon.frame = CGRectMake((buttonWidth - icon.image.size.width) / 2, 20, icon.image.size.width, icon.image.size.height);
        [linkButton addSubview:icon];
        
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = LIGHTGRAY_COLOR;
        titleLabel.font = [UIFont systemFontOfSize:11];
        titleLabel.frame = CGRectMake(0, icon.bottom + 10, buttonWidth, 14);
        titleLabel.text = item.name;
        [linkButton addSubview:titleLabel];
        
        [linkButton addTarget:self action:@selector(linkButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [linksScrollView addSubview:linkButton];
    }
}

- (void)linkButtonClicked:(id)sender{
    UIButton *linkButton = (UIButton *)sender;
    RelatedHttpUrlItem *item = [self.httpUrlAry objectAtIndex:linkButton.tag - 100];
    if ([self.delegate respondsToSelector:@selector(cellButtonClick:urlLink:)]) {
        [self.delegate cellButtonClick:sender urlLink:item.url];
    }
}

- (void)prepareForReuse{
    [super prepareForReuse];
    [self removeAllSubviews];
    [self.httpUrlAry removeAllObjects];
}

@end

#pragma mark 项目详述
@interface ProjectDescriptionTableViewCell ()

@property(nonatomic, strong)NSMutableArray *companyDetailAry;

@end

@implementation ProjectDescriptionTableViewCell

- (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object{
    NSMutableArray *ary = (NSMutableArray *)object;
    CGFloat cellHeight = 0;
    if (ary.count > 0) {
        for (NSInteger i = 0; i < [ary count]; i++) {
            CompanyDetailItem *item = [ary objectAtIndex:i];
            cellHeight += [self calculateCellHeight:item.title textFont:[UIFont systemFontOfSize:15] contentSize:CGSizeMake(SCREEN_WIDTH - evaluate(20), CGFLOAT_MAX)].height;
            cellHeight += [self calculateCellHeight:item.content textFont:[UIFont systemFontOfSize:15] contentSize:CGSizeMake(SCREEN_WIDTH - evaluate(20), CGFLOAT_MAX)].height;
        }
    }
    return cellHeight + (ary.count * 2 + 1) * 10;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        self.companyDetailAry = [NSMutableArray array];
    }
    return self;
}

- (void)prepareForReuse{
    [super prepareForReuse];
    [self removeAllSubviews];
    [self.companyDetailAry removeAllObjects];
}

- (void)setData:(NSMutableArray *)companyDetailAry{
    [self.companyDetailAry addObjectsFromArray:companyDetailAry];
    
    CGFloat height = 0;
    for (NSInteger i = 0; i < [self.companyDetailAry count]; i++) {
        CompanyDetailItem *item = [self.companyDetailAry objectAtIndex:i];
        
        CGSize titleSize = [self calculateCellHeight:item.title textFont:[UIFont systemFontOfSize:15] contentSize:CGSizeMake(SCREEN_WIDTH - evaluate(20), CGFLOAT_MAX)];
        UILabel *title = [[UILabel alloc] init];
        title.frame = CGRectMake(evaluate(10),height + 14, titleSize.width + 8, 22);
        title.backgroundColor = RGBACOLOR(50, 188, 198, 0.2);
        title.layer.borderColor = RGBCOLOR(50, 188, 198).CGColor;
        title.layer.borderWidth = 1.0;
        title.clipsToBounds = YES;
        title.layer.cornerRadius = 5;
        title.font = [UIFont systemFontOfSize:15];
        title.text = item.title;
        title.textAlignment = NSTextAlignmentCenter;
        title.textColor = BLACK_COLOR;
        [self addSubview:title];
        
        CGSize contentSize = [self calculateCellHeight:item.title textFont:[UIFont systemFontOfSize:15] contentSize:CGSizeMake(SCREEN_WIDTH - evaluate(20), CGFLOAT_MAX)];
        UILabel *content = [[UILabel alloc] initWithFrame:CGRectMake(evaluate(10), title.bottom + 14, SCREEN_WIDTH - evaluate(20), contentSize.height)];

        content.numberOfLines = 0;
        NSMutableAttributedString * attrS = [[NSMutableAttributedString alloc] initWithString:item.content];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 10;
        NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:15],NSParagraphStyleAttributeName:style,NSForegroundColorAttributeName:DARKGRAY_COLOR};
        [attrS addAttributes:attribute range:NSMakeRange(0, item.content.length)];
        content.attributedText = attrS;
        [content sizeToFit];
        content.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:content];
        
        height = content.bottom;
    }
}

@end

#pragma mark 投资亮点
@interface InvestHighlightsTableViewCell ()

@property(nonatomic, strong)ProjectDetailItem *item;

@end

@implementation InvestHighlightsTableViewCell

- (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object{
    CGFloat cellHeight;
    ProjectDetailItem *item = (ProjectDetailItem *)object;
    
    if (![item.investHighlights isEqualToString:@"(null)"] && item.investHighlights.length > 0){
        CGSize size = [self calculateCellHeight:item.investHighlights textFont:[UIFont systemFontOfSize:15] contentSize:CGSizeMake(SCREEN_WIDTH - evaluate(20), CGFLOAT_MAX)];
        return cellHeight = size.height + 20;
    } else {
        cellHeight = 0;
    }
    return cellHeight;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        self.item = [[ProjectDetailItem alloc] init];
        [self.contentView addSubview:self.investHighlightsLabel];
    }
    return self;
}

- (void)prepareForReuse{
    [super prepareForReuse];
    self.investHighlightsLabel.text = nil;
}

- (void)setData:(ProjectDetailItem *)item{
    if (![item.investHighlights isEqualToString:@"(null)"] && item.investHighlights.length > 0) {
        self.item = item;
        NSMutableAttributedString * attrS = [[NSMutableAttributedString alloc] initWithString:item.investHighlights];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.lineSpacing = 10;
        NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:15],NSParagraphStyleAttributeName:style};
        [attrS addAttributes:attribute range:NSMakeRange(0, item.investHighlights.length)];
        
        self.investHighlightsLabel.attributedText = attrS;
        [self.investHighlightsLabel sizeToFit];
    } else{
        self.investHighlightsLabel.text = @"";
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGSize size = [self calculateCellHeight:self.investHighlightsLabel.text textFont:[UIFont systemFontOfSize:15] contentSize:CGSizeMake(SCREEN_WIDTH - evaluate(20), CGFLOAT_MAX)];
    self.investHighlightsLabel.frame = CGRectMake(evaluate(10), 10, SCREEN_WIDTH - evaluate(20), size.height);
}

#pragma mark property

- (UILabel *)investHighlightsLabel{
    if (!_investHighlightsLabel) {
        _investHighlightsLabel = [[UILabel alloc] init];
        _investHighlightsLabel.backgroundColor = [UIColor clearColor];
        _investHighlightsLabel.font = [UIFont systemFontOfSize:15];
        _investHighlightsLabel.textColor = DARKGRAY_COLOR;
        _investHighlightsLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _investHighlightsLabel.numberOfLines = 0;
        
    }
    return _investHighlightsLabel;
}

@end



#pragma mark 项目的基本信息
@interface ProjectDetailTableViewCell ()

@property(nonatomic, strong)ProjectDetailItem *item;
@property(nonatomic, strong)NSString *descriptionTitle;

@end

@implementation ProjectDetailTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (NSString *)nameStringsMatching:(NSMutableArray *)array{
    NSString *str = @"";
    for (NSInteger i = 0; i < [array count]; i++) {
        if ([[array objectAtIndex:i] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = (NSDictionary *)[array objectAtIndex:i];
            if (dict && [dict objectForKey:@"text"]) {
                if (i == 0) {
                    str = [NSString stringWithFormat:@"%@%@",str,[dict objectForKey:@"text"]];
                } else {
                    str = [NSString stringWithFormat:@"%@/%@",str,[dict objectForKey:@"text"]];
                }
            }
        } else {
            if (i == 0) {
                str = [NSString stringWithFormat:@"%@%@",str,[array objectAtIndex:i]];
            } else {
                str = [NSString stringWithFormat:@"%@/%@",str,[array objectAtIndex:i]];
            }
        }
    }
    return str;
}

- (NSString *)investorLevelValueAry:(NSArray *)valueAry{
    NSString * strList = @"";
    for (NSInteger i = 0; i < valueAry.count;  i++) {
        strList = [NSString stringWithFormat:@"%@ %@等级可见",strList, [valueAry objectAtIndex:i]];
    }
    return strList;
}

- (NSString *)currentTypeValueAry:(NSArray *)valueAry{
    NSString * strList = @"";
    for (NSInteger i = 0; i < valueAry.count;  i++) {
        if ([[valueAry objectAtIndex:i] isEqualToString:@"$"]) {
            strList = [NSString stringWithFormat:@"%@美元 ",strList];
        } else {
            strList = [NSString stringWithFormat:@"%@人民币 ",strList];
        }
    }
    return strList;
}

- (NSString *)stageValueAry:(NSArray *)valueAry{
    NSString * strList = @"";
    for (NSInteger i = 0; i < valueAry.count;  i++) {
        if (i == valueAry.count - 1) {
            strList = [NSString stringWithFormat:@"%@%@",strList,[valueAry objectAtIndex:i]];
        } else {
            strList = [NSString stringWithFormat:@"%@%@、",strList,[valueAry objectAtIndex:i]];
        }
    }
    strList = [NSString stringWithFormat:@"仅%@可见",strList];
    return strList;
}

- (NSString *)highlightsValueAry:(NSArray *)valueAry{
    NSString * strList = @"";
    for (NSInteger i = 0; i < valueAry.count;  i++) {
        if (i == valueAry.count - 1) {
            strList = [NSString stringWithFormat:@"%@%@",strList,[valueAry objectAtIndex:i]];
        } else {
            strList = [NSString stringWithFormat:@"%@%@，",strList,[valueAry objectAtIndex:i]];
        }
    }
    return strList;
}

- (CGFloat)tableView:(UITableView *)tableView rowHeightForObject:(id)object index:(NSIndexPath *)index{
    CGFloat cellHeight = 0;
    if ([object isKindOfClass:[ProjectDetailItem class]]) {
        ProjectDetailItem *item = (ProjectDetailItem *)object;
        NSString *descriptionStr = [NSString string];
        switch (index.row) {
            case 0:
                if (self.projectInformation == ProjectBasicInfo) {
                    descriptionStr = item.title;
                } else if (self.projectInformation == ProjectCompetition) {
                    if (item.competitors.count > 0) {
                       descriptionStr = [self nameStringsMatching:item.competitors];
                    }else {
                        descriptionStr = @"";
                    }
                } else {
                    if (![item.visibleMode isEqualToString:@"(null)"] && item.visibleMode.length > 0) {
                        if ([item.visibleMode isEqualToString:@"white"]) {
                            descriptionStr = @"白名单";
                        } else {
                            descriptionStr = @"黑名单";
                        }
                    }
                }
                break;
            case 1:
                if (self.projectInformation == ProjectBasicInfo) {
                    descriptionStr = item.agentUserName;
                } else if (self.projectInformation == ProjectCompetition) {
                    if (item.seen.count > 0) {
                        descriptionStr = [self nameStringsMatching:item.seen];
                    }else {
                        descriptionStr = @"";
                    }
                } else {
                    if (![item.visibleMode isEqualToString:@"(null)"] && item.visibleMode.length > 0) {
                        if ([item.visibleMode isEqualToString:@"white"]) {
                            if (item.whiteList.count > 0) {
                                descriptionStr = [self nameStringsMatching:item.whiteList];
                            }
                        } else {
                            if (item.rejected.count > 0) {
                                descriptionStr = [self nameStringsMatching:item.rejected];
                            }
                        }
                    }
                }
                break;
            case 2:
                if (self.projectInformation == ProjectBasicInfo) {
                    descriptionStr = item.operatorUserName;
                } else if (self.projectInformation == ProjectCompetition) {
                    if (item.existing.count > 0) {
                        descriptionStr = [self nameStringsMatching:item.existing];
                    }else {
                        descriptionStr = @"";
                    }
                } else {
                    descriptionStr = [self investorLevelValueAry:item.investorLevel];
                }
                break;
            case 3:
                if (self.projectInformation == ProjectBasicInfo) {
                    descriptionStr = item.referralUserName;
                } else if (self.projectInformation == ProjectVisibility) {
                    if (item.fundType == 0) {
                        descriptionStr = @"不可见";
                    } else {
                        descriptionStr = @"可见";
                    }
                }
                break;
            case 4:
                if (self.projectInformation == ProjectBasicInfo) {
                    descriptionStr = item.categoryName;
                } else if (self.projectInformation == ProjectVisibility) {
                    descriptionStr = [self currentTypeValueAry:item.currentType];
                }
                break;
            case 5:
                if (self.projectInformation == ProjectBasicInfo) {
                    descriptionStr = item.location;
                } else if (self.projectInformation == ProjectVisibility) {
                    descriptionStr = [self stageValueAry:item.stage];
                }
                break;
            case 6:
                descriptionStr = [self highlightsValueAry:self.item.highlights];
                break;
            case 7:
                descriptionStr = item.financingScale;
                break;
            default:
                descriptionStr = item.shareProportion;
                break;
        }
        CGSize size = [self calculateCellHeight:descriptionStr textFont:[UIFont systemFontOfSize:16] contentSize:CGSizeMake(evaluate(160), CGFLOAT_MAX)];
        if (size.height > 40) {
            cellHeight = size.height + 19.5;
        } else {
            cellHeight = size.height + 9.5;
        }
        if (cellHeight < 39) {
            return 39.0f;
        }else{
            return cellHeight;
        }
    }
    return 0;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        self.item = [[ProjectDetailItem alloc] init];
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.descriptionLabel];
        [self.contentView addSubview:self.cellSegmentLine];
    }
    return self;
}

- (void)prepareForReuse{
    [super prepareForReuse];
    self.titleLabel.text = nil;
    self.descriptionLabel.text = nil;
}

- (void)setData:(ProjectDetailItem *)item title:(NSString *)title index:(NSIndexPath *)index{
    self.item = item;
    self.titleLabel.text = title;
    self.cellSegmentLine.hidden = NO;

    switch (index.row) {
        case 0:
            if (self.projectInformation == ProjectBasicInfo) {
                if (![self.item.title isEqualToString:@"(null)"] && self.item.title.length > 0) {
                    self.descriptionLabel.text = self.item.title;
                } else {
                    self.descriptionLabel.text = @"";
                }
            } else if (self.projectInformation == ProjectCompetition) {
                if (item.competitors.count > 0) {
                    self.descriptionLabel.text = [self nameStringsMatching:item.competitors];
                }else {
                    self.descriptionLabel.text = @"";
                }
            } else {
                if (![item.visibleMode isEqualToString:@"(null)"] && item.visibleMode.length > 0) {
                    if ([item.visibleMode isEqualToString:@"white"]) {
                        self.descriptionLabel.text = @"白名单";
                    } else {
                        self.descriptionLabel.text = @"黑名单";
                    }
                }
            }
            break;
        case 1:
            if (self.projectInformation == ProjectBasicInfo) {
                if (![self.item.agentUserName isEqualToString:@"(null)"] && self.item.agentUserName.length > 0) {
                    self.descriptionLabel.text = self.item.agentUserName;
                }else{
                    self.descriptionLabel.text = @"";
                }
            } else if (self.projectInformation == ProjectCompetition) {
                if (item.seen.count > 0) {
                    self.descriptionLabel.text = [self nameStringsMatching:item.seen];
                }else {
                    self.descriptionLabel.text = @"";
                }
            } else {
                if (![item.visibleMode isEqualToString:@"(null)"] && item.visibleMode.length > 0) {
                    if ([item.visibleMode isEqualToString:@"white"]) {
                        if (item.whiteList.count > 0) {
                            self.descriptionLabel.text = [self nameStringsMatching:item.whiteList];
                        }
                    } else {
                        if (item.rejected.count > 0) {
                            self.descriptionLabel.text = [self nameStringsMatching:item.rejected];
                        }
                    }
                }
            }
            break;
        case 2:
            if (self.projectInformation == ProjectBasicInfo) {
                if (![self.item.operatorUserName isEqualToString:@"(null)"] && self.item.operatorUserName.length > 0) {
                    self.descriptionLabel.text = self.item.operatorUserName;
                }else{
                    self.descriptionLabel.text = @"";
                }
            } else if (self.projectInformation == ProjectCompetition) {
                if (item.existing.count > 0) {
                    self.descriptionLabel.text = [self nameStringsMatching:item.existing];
                }else {
                    self.descriptionLabel.text = @"";
                }
            } else {
                self.descriptionLabel.text = [self investorLevelValueAry:self.item.investorLevel];
            }
            break;
        case 3:
            if (self.projectInformation == ProjectBasicInfo) {
                if (![self.item.referralUserName isEqualToString:@"(null)"] && self.item.referralUserName.length > 0) {
                    self.descriptionLabel.text = self.item.referralUserName;
                }else{
                    self.descriptionLabel.text = @"";
                }
            } else if (self.projectInformation == ProjectVisibility) {
                if (self.item.fundType == 0) {
                    self.descriptionLabel.text = @"不可见";
                } else {
                    self.descriptionLabel.text = @"可见";
                }
            }
            break;
        case 4:
            if (self.projectInformation == ProjectBasicInfo) {
                if (![self.item.categoryName isEqualToString:@"(null)"] && self.item.categoryName.length > 0) {
                    self.descriptionLabel.text = self.item.categoryName;
                }else {
                    self.descriptionLabel.text = @"";
                }
            } else if (self.projectInformation == ProjectVisibility) {
                self.descriptionLabel.text = [self currentTypeValueAry:self.item.currentType];
            }
            break;
        case 5:
            if (self.projectInformation == ProjectBasicInfo) {
                if (![self.item.location isEqualToString:@"(null)"] && self.item.location.length > 0) {
                    self.descriptionLabel.text = self.item.location;
                }else {
                    self.descriptionLabel.text = @"";
                }
            } else if (self.projectInformation == ProjectVisibility) {
                self.descriptionLabel.text = [self stageValueAry:self.item.stage];
            }
            break;
        case 6:
            if (self.item.highlights.count > 0) {
                self.descriptionLabel.text = [self highlightsValueAry:self.item.highlights];
            }else {
                self.descriptionLabel.text = @"";
            }
            break;
        case 7:
            if (![self.item.financingScale isEqualToString:@"(null)"] && self.item.financingScale.length > 0) {
                self.descriptionLabel.text = self.item.financingScale;
            }else {
                self.descriptionLabel.text = @"";
            }
            break;
        default:
            self.cellSegmentLine.hidden = YES;
            if (![self.item.shareProportion isEqualToString:@"(null)"] && self.item.shareProportion.length > 0) {
                self.descriptionLabel.text = self.item.shareProportion;
            }else {
                self.descriptionLabel.text = @"";
            }
            break;
    }
    if (self.descriptionLabel.text.length > 0) {
        NSMutableAttributedString * attrS = [[NSMutableAttributedString alloc] initWithString:self.descriptionLabel.text];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.alignment = NSTextAlignmentRight;
        style.lineSpacing = 10;
        NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:16],NSParagraphStyleAttributeName:style};
        [attrS addAttributes:attribute range:NSMakeRange(0, self.descriptionLabel.text.length)];
        self.descriptionLabel.attributedText = attrS;
        [self.descriptionLabel sizeToFit];
    }
}

- (NSString *)setDescriptionLabelText:(NSInteger)userId{
    Customer *customer = nil;
    customer = [[CustomerManager sharedInstance] searchUserFromId:userId];
    return customer.name;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGSize titleSize = [self calculateCellHeight:self.titleLabel.text textFont:[UIFont systemFontOfSize:16] contentSize:CGSizeMake(SCREEN_WIDTH - evaluate(20), CGFLOAT_MAX)];
    self.titleLabel.frame = CGRectMake(evaluate(10), 11, titleSize.width, 17);
    
    CGSize descriptionSize = [self calculateCellHeight:self.descriptionLabel.text textFont:[UIFont systemFontOfSize:16] contentSize:CGSizeMake(evaluate(160), CGFLOAT_MAX)];
    self.descriptionLabel.frame = CGRectMake(SCREEN_WIDTH - evaluate(170), 11, evaluate(160), descriptionSize.height);
    
    self.cellSegmentLine.frame = CGRectMake(evaluate(10), self.height - 1, SCREEN_WIDTH - evaluate(20), 1);
}

#pragma mark property
- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textColor = BLACK_COLOR;
    }
    return _titleLabel;
}

- (UILabel *)descriptionLabel{
    if (!_descriptionLabel) {
        _descriptionLabel = [[UILabel alloc] init];
        _descriptionLabel.backgroundColor = [UIColor clearColor];
        _descriptionLabel.font = [UIFont systemFontOfSize:16];
        _descriptionLabel.textColor = LIGHTGRAY_COLOR;
        _descriptionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _descriptionLabel.numberOfLines = 0;
    }
    return _descriptionLabel;
}

- (UIImageView *)cellSegmentLine{
    if (!_cellSegmentLine) {
        _cellSegmentLine = [[UIImageView alloc] init];
        _cellSegmentLine.backgroundColor = [UIColor clearColor];
        _cellSegmentLine.image = [UIImage imageNamed:@"line"];
    }
    return _cellSegmentLine;
}

@end
