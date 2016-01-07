//
//  MessageCell.m
//  MessageDemo
//
//  Created by wufei on 15/12/10.
//  Copyright (c) 2015年 wufei. All rights reserved.
//

#import "MessageCell.h"
#import "MessageContentView.h"
#import "UIImageView+WebCache.h"
#import "UIImage+StrethImage.h"

static const NSInteger lineSpace = 2;

@interface MessageCell()<MessageContentViewDelegate,
                                    PPLabelDelegate>

@property (nonatomic, strong) UIImageView *icon;
@property (nonatomic, strong) MessageContentView *messageView;
@property (nonatomic, strong) MessageContentView *currentMessageView;
@property (nonatomic, strong) NSString *contentStr;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) NSArray *matches;

@end

@implementation MessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.contentView addSubview:self.timeLabel];
        [self.contentView addSubview:self.icon];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.messageView];
        //菊花view；
        [self.contentView addSubview:self.indicatorView];
        //发送错误图片
        [self.contentView addSubview:self.errorImageView];
        self.messageView.contentLabel.delegate = self;
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.nameLabel.text=nil;
    self.timeLabel.frame=CGRectZero;
    self.timeLabel.text=nil;
}

-(void)setCellFrame:(messageCellFrame *)cellFrame
{
    _cellFrame=cellFrame;
    ChatMessageListItem *model=cellFrame.model;
    self.timeLabel.text=self.cellFrame.currentTimeStr;
    self.timeLabel.frame=cellFrame.timeRect;
    self.icon.frame=cellFrame.iconRect;
    [self.icon sd_setImageWithURL:[NSURL URLWithString:model.avatar] placeholderImage:[UIImage imageNamed:@"chatfrom_doctor_icon"]];
    if (![model.fromUser isEqualToString:[CacheManager sharedInstance].userId]) {
        self.nameLabel.text=model.name;
        self.nameLabel.frame=cellFrame.nameRect;
        self.errorImageView.image=nil;
    } else {
        //解决namelabel控件复用出现的问题
        self.nameLabel.frame=cellFrame.nameRect;
        //设置菊花的frame
        self.indicatorView.frame=cellFrame.indicatorRect;
        if (self.cellFrame.isIndeicatorShow) {
            [self.indicatorView startAnimating];
        }
        else
            [self.indicatorView stopAnimating];
        
        self.errorImageView.image=[UIImage imageNamed:@"tanhao"];
        //设置错误图片的frame
        self.errorImageView.frame=cellFrame.errorImageRect;
        if (self.cellFrame.isErrorImageShow) {
            self.errorImageView.hidden=NO;
        }
        else
            self.errorImageView.hidden=YES;
    }
    
    self.messageView.model=model;
    self.messageView.frame=cellFrame.messageViewRect;
    [self setBackGroundImageViewImage:self.messageView from:@"chatfrom_bg_normal" to:@"chatto_bg_normal"];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:lineSpace];//调整行间距
    self.messageView.contentLabel.text=model.content;
    
    NSError *error = NULL;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
    
    self.matches = [detector matchesInString:self.messageView.contentLabel.text options:0 range:NSMakeRange(0, self.messageView.contentLabel.text.length)];
    
    [self highlightLinksWithIndex:NSNotFound];
    //菊花
}

#pragma mark - 懒加载
- (UILabel *)timeLabel {
    if (_timeLabel==nil) {
        _timeLabel=[[UILabel alloc]init];
        _timeLabel.textColor=[UIColor whiteColor];
        _timeLabel.font=[UIFont systemFontOfSize:10.f];
        _timeLabel.backgroundColor=[UIColor colorWithRed:17/255.0 green:17/255.0 blue:17/255.0 alpha:0.2];
        _timeLabel.clipsToBounds=YES;
        _timeLabel.layer.cornerRadius=3.0f;
        _timeLabel.textAlignment=NSTextAlignmentCenter;
        _timeLabel.lineBreakMode=NSLineBreakByWordWrapping;
    }
    return _timeLabel;
}
-(UIImageView *)icon
{
    if (_icon==nil) {
        _icon=[[UIImageView alloc]init];
    }
    return _icon;
}
-(UILabel *)nameLabel
{
    if (_nameLabel==nil) {
        _nameLabel=[[UILabel alloc]init];
        _nameLabel.font=[UIFont systemFontOfSize:12];
        _nameLabel.textColor=[UIColor colorWithRed:138.0f/255 green:138.0f/255 blue:138.0f/255 alpha:1.0];
    }
    return _nameLabel;
}
-(MessageContentView *)messageView
{
    if (_messageView==nil) {
        _messageView=[[MessageContentView alloc]initWithFrame:CGRectZero];
        _messageView.delegate=self;
    }
    return _messageView;
}
-(UIActivityIndicatorView *)indicatorView
{
    if (_indicatorView==nil) {
        _indicatorView=[[UIActivityIndicatorView alloc]init];
        _indicatorView.activityIndicatorViewStyle=UIActivityIndicatorViewStyleGray;
        
    }
    return _indicatorView;
}
-(UIImageView *)errorImageView
{
    if (_errorImageView==nil) {
        _errorImageView=[[UIImageView alloc]init];
        
    }
    return _errorImageView;
}

-(void)setBackGroundImageViewImage:(MessageContentView *)messageView from:(NSString *)from to:(NSString *)to
{
    UIImage *normal=nil ;
    if(![messageView.model.fromUser isEqualToString:[CacheManager sharedInstance].userId]){
        
        normal=[UIImage strethImageWithName:from];
 
    }else{
        
        normal=[UIImage strethImageWithName:to];
    }
    messageView.backImageView.image=normal;
}
- (void)awakeFromNib {
    // Initialization code
}
-(void)messageContentViewLongPress:(MessageContentView *)messageContentView content:(NSString *)content
{
    [self becomeFirstResponder];
    UIMenuController *menu=[UIMenuController sharedMenuController];
    UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyItemClicked:)];
    menu.menuItems = @[copyItem];
    [menu setTargetRect:messageContentView.backImageView.frame inView:messageContentView];
    [menu setMenuVisible:YES animated:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuShow:) name:UIMenuControllerWillShowMenuNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuHide:) name:UIMenuControllerWillHideMenuNotification object:nil];
    self.contentStr=content;
    self.currentMessageView=messageContentView;
}
- (void)copyItemClicked:(UIMenuItem *)item
{
    UIPasteboard *pasterboard = [UIPasteboard generalPasteboard];
    pasterboard.string = self.contentStr;
}
-(void)messageContentViewTapPress:(MessageContentView *)messageContentView content:(NSString *)content
{
    if([self.delegate respondsToSelector:@selector(MessageCell:tapContent:)]){
        [self.delegate MessageCell:self tapContent:content];
    }
}
-(void)menuShow:(UIMenuController *)menu
{
    [self setBackGroundImageViewImage:self.currentMessageView from:@"chatfrom_bg_normal" to:@"chatto_bg_normal"];
}
-(void)menuHide:(UIMenuController *)menu
{
    [self setBackGroundImageViewImage:self.currentMessageView from:@"chatfrom_bg_normal@2x" to:@"chatto_bg_normal@2x"];
    [self resignFirstResponder];
    self.currentMessageView=nil;
}
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if(action ==@selector(copy:)){
        
        return YES;
    }
    return [super canPerformAction:action withSender:sender];
}

-(void)copy:(id)sender
{
    [[UIPasteboard generalPasteboard]setString:self.contentStr];
}
-(BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark -

-(BOOL)label:(PPLabel *)label didBeginTouch:(UITouch *)touch onCharacterAtIndex:(CFIndex)charIndex {
    
    [self highlightLinksWithIndex:charIndex];
    return YES;
}

-(BOOL)label:(PPLabel *)label didMoveTouch:(UITouch *)touch onCharacterAtIndex:(CFIndex)charIndex {
    
    [self highlightLinksWithIndex:charIndex];
    return YES;
}

-(BOOL)label:(PPLabel *)label didEndTouch:(UITouch *)touch onCharacterAtIndex:(CFIndex)charIndex {
    
    [self highlightLinksWithIndex:NSNotFound];
    
    for (NSTextCheckingResult *match in self.matches) {
        
        if ([match resultType] == NSTextCheckingTypeLink) {
            
            NSRange matchRange = [match range];
            
            if ([self isIndex:charIndex inRange:matchRange]) {
                if ([self.delegate respondsToSelector:@selector(hideKeyboard)]) {
                    [self.delegate hideKeyboard];
                }
                [[UIApplication sharedApplication] openURL:match.URL];
                break;
            }
        }
    }
    return YES;
    
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch* touch= [touches anyObject];
    
    if ([touch.view isKindOfClass:[UILabel class]]) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(hideKeyboard)]) {
        [self.delegate hideKeyboard];
    }
}

- (BOOL)label:(PPLabel *)label didCancelTouch:(UITouch *)touch
{
    
    [self highlightLinksWithIndex:NSNotFound];
    return YES;
}

#pragma mark -

- (BOOL)isIndex:(CFIndex)index inRange:(NSRange)range {
    return index > range.location && index < range.location+range.length;
}

- (void)highlightLinksWithIndex:(CFIndex)index {
    
    NSMutableAttributedString* attributedString = [self.messageView.contentLabel.attributedText mutableCopy];
    
    for (NSTextCheckingResult *match in self.matches) {
        
        if ([match resultType] == NSTextCheckingTypeLink) {
            
            NSRange matchRange = [match range];
            
            if ([self isIndex:index inRange:matchRange]) {
                [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:matchRange];
            }
            else {
                [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:matchRange];
            }
            
            [attributedString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:matchRange];
        }
    }
    
    self.messageView.contentLabel.attributedText = attributedString;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
