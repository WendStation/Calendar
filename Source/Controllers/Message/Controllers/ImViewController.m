//
//  ImViewController.m
//  Calendar
//
//  Created by 刘花椒 on 15/12/10.
//
//

#import "ImViewController.h"
#import "GroupListDatasource.h"
#import "GroupListDatabase.h"
#import "ImManager.h"
#import "KeyboardView.h"
#import "MessageCell.h"
#import "messageCellFrame.h"
#import "GroupListItem.h"

static NSString *const cellIdentifier=@"message";
static const NSInteger keyBoardHeight = 40;

@interface ImViewController ()<UITableViewDelegate,
                             UITableViewDataSource,
                              KeyboardViewDelegate,
                              MessageCellDelegate,
                                UITextViewDelegate>

@property (nonatomic, strong) GroupListDatasource *Ds;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) KeyboardView *keyBordView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *newDataArray;
@property (nonatomic, assign) BOOL recording;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, assign) NSInteger lastMessageTime;
@property (nonatomic, assign) CGFloat previousTextViewContentHeight;
@property (nonatomic, assign) CGFloat normalTextViewContentHeight;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, assign) CGFloat lastKeyboardHeight;

@end

@implementation ImViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [ImManager shareInstance].mesageRequestCircleSeconds = 2;
    [[ImManager shareInstance] onStop];
    [[ImManager shareInstance] onStart];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardWillHideNotification object:nil];
    [self getNewestGlobalMessage];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [ImManager shareInstance].mesageRequestCircleSeconds = 60;
    [ImViewController cancelPreviousPerformRequestsWithTarget:self];

    //把未读的消息置为已读
    [self.Ds updateNewestMessageReceived:[self.groupId integerValue]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BACKGROUND_COLOR;
    self.title = self.imTitle;
    self.Ds = [[GroupListDatasource alloc] init];
    self.newDataArray = [NSMutableArray arrayWithCapacity:0];
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.keyBordView];
    
    [self.tableView registerClass:[MessageCell class] forCellReuseIdentifier:cellIdentifier];
    self.automaticallyAdjustsScrollViewInsets=NO;
    [self getGlobalMessage:NO];
    [self.Ds updateNewestMessageReceived:[self.groupId integerValue]];
}

- (void)getNewestGlobalMessage {
    __weak typeof(self) weakSelf = self;
    [self.Ds getNewestMessageByGroupIdFromDatabase:self.groupId complete:^(id object) {
        if ([object isKindOfClass:[NSMutableArray class]]) {
            [self performSelector:@selector(getNewestGlobalMessage) withObject:nil afterDelay:2];
            NSArray *array = (NSArray *)object;
            if (array.count == 0) {
                return ;
            }
            for(ChatMessageListItem *item in array){
                weakSelf.lastMessageTime = [item.time longLongValue]/1000;
                NSString *time = [NSDate compareTimeWithOldTime:weakSelf.lastMessageTime NewTime:[item.time longLongValue] / 1000];
                messageCellFrame *cellFrame = [[messageCellFrame alloc]init];
                if (time) {
                    cellFrame.isTimeShow = YES;
                    cellFrame.currentTimeStr = time;
                }else {
                    cellFrame.isTimeShow = NO;
                }
                cellFrame.model = item;
                [weakSelf.dataArray addObject:cellFrame];
            }
            [weakSelf.tableView.header endRefreshing];
            [weakSelf.tableView reloadData];
            [weakSelf tableViewScrollCurrentIndexPath:weakSelf.dataArray.count - 1 animated:NO];
        }
    }];
}

- (void)getGlobalMessage {
    [self getGlobalMessage:NO];
}

- (void)getGlobalMessage:(BOOL)isLoadMore {
    __weak  typeof(self) weakSelf = self;
    [self.Ds getGlobalMessageByGroupIdFromDatabase:self.groupId isLoadMore:isLoadMore complete:^(id object) {
        if ([object isKindOfClass:[NSMutableArray class]]) {
            NSArray *array = (NSArray *)object;
            if (array.count == 0) {
                if (weakSelf.dataArray.count != 0) {
                    [AlertManager showAlertText:@"亲，已无更多历史消息了哦!" withCloseSecond:1];
                }
                [weakSelf.tableView.header endRefreshing];
                return ;
            }
            for (NSInteger i = 0; i < [array count]; i++) {
                ChatMessageListItem *item = (ChatMessageListItem *)[array objectAtIndex:i];
                if (weakSelf.lastMessageTime == 0) {
                    weakSelf.lastMessageTime = [item.time longLongValue] / 1000;
                }
                NSString *time;
                if (i == [array count] - 1) {
                    time = [NSDate compareTimeWithOldTime:0 NewTime:[item.time longLongValue] / 1000];
                } else {
                    ChatMessageListItem *lastItem = (ChatMessageListItem *)[array objectAtIndex:i + 1];
                    time = [NSDate compareTimeWithOldTime:[lastItem.time longLongValue] / 1000 NewTime:[item.time longLongValue] / 1000];
                }
                messageCellFrame *cellFrame = [[messageCellFrame alloc] init];
                if (time) {
                    cellFrame.isTimeShow = YES;
                    cellFrame.currentTimeStr = time;
                }else {
                    cellFrame.isTimeShow = NO;
                }
                if (item.isError) {
                    cellFrame.isErrorImageShow = YES;
                }
                cellFrame.model = item;
                [weakSelf.dataArray insertObject:cellFrame atIndex:0];
            }
            [weakSelf.tableView reloadData];
            if (!isLoadMore) {
                [weakSelf tableViewScrollCurrentIndexPath:weakSelf.dataArray.count animated:YES];
            } else {
                [weakSelf.tableView.header endRefreshing];
                [weakSelf tableViewScrollCurrentIndexPath:array.count + 1 animated:NO];
            }
        }
    }];
}

#pragma mark - 下拉刷新
- (void)downRefresh {
    [self getGlobalMessage:YES];
}

#pragma mark - tableVIew代理
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageCell* cell=[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    if (cell==nil) {
        cell=[[MessageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.delegate = self;
    cell.cellFrame = self.dataArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dataArray[indexPath.row] cellHeight] ;
}

#pragma mark - cell的代理
//cell的代理，即点击内容播放声音
- (void)MessageCell:(MessageCell *)messageCell tapContent:(NSString *)content {
    NSLog(@"%s",__func__);
}

- (void)hideKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - scroolView代理
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

#pragma mark - 开始、结束记录声音协议
- (void)beginRecord {
    NSLog(@"%s",__func__);
}

- (void)stopRecord {
    NSLog(@"结束录音....");
    NSLog(@"%s",__func__);
}

#pragma mark - 键盘的监听
-(void)keyboardShow:(NSNotification *)note {
    CGRect keyBoardRect = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat deltaY = keyBoardRect.size.height;
    CGFloat offsetY;
    if (deltaY != self.lastKeyboardHeight) {
        offsetY = deltaY - self.lastKeyboardHeight;
    } else {
        offsetY = deltaY;
    }
    [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
        UIEdgeInsets insets = UIEdgeInsetsMake(0.0f, 0.0f, self.tableView.contentInset.bottom + offsetY, 0.0f);
        self.tableView.contentInset = insets;
        self.tableView.scrollIndicatorInsets = insets;
        [self tableViewScrollCurrentIndexPath:self.dataArray.count animated:NO];
        self.keyBordView.frame = CGRectMake(self.keyBordView.frame.origin.x, self.keyBordView.frame.origin.y - offsetY, self.keyBordView.frame.size.width, self.keyBordView.frame.size.height);
    }];
    self.lastKeyboardHeight = deltaY;
}

-(void)keyboardHide:(NSNotification *)note {
    CGRect keyBoardRect = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat deltaY = keyBoardRect.size.height;
    [UIView animateWithDuration:[note.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
        UIEdgeInsets insets = UIEdgeInsetsMake(0.0f, 0.0f, self.tableView.contentInset.bottom - deltaY, 0.0f);
        self.tableView.contentInset = insets;
        self.tableView.scrollIndicatorInsets = insets;
        [self tableViewScrollCurrentIndexPath:self.dataArray.count animated:NO];
        self.keyBordView.frame = CGRectMake(0, SCREEN_HEIGHT - keyBoardHeight - 64, SCREEN_WIDTH, keyBoardHeight);
    }];
    self.lastKeyboardHeight = deltaY;
}

#pragma mark - keyboardView代理
//sendButton的代理hjlerhgljrhg
- (void)sendMessage {
    self.content=[self.keyBordView.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (![self.content isEqualToString:@""]) {
        [self sendMessage:self.keyBordView.textView];
    } else {
        self.keyBordView.textView.text=@"";
        NSLog(@"您输入的是空格");
    }
    [self KeyboardVIew:self.keyBordView textViewHeightChange:self.keyBordView.textView];
}

- (void)KeyboardVIew:(KeyboardView *)keyboardView textFileBegin:(UITextField *)textField {
    [self tableViewScrollCurrentIndexPath:self.dataArray.count animated:YES];
}

- (void)tableViewScrollCurrentIndexPath:(NSInteger)dataArrayIndex animated:(BOOL)animated {
    if (dataArrayIndex > [self.tableView numberOfRowsInSection:0] || [self.tableView numberOfRowsInSection:0] == 0) {
        return;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:dataArrayIndex-1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:animated];
}

- (void)sendMessage:(UITextView *)textView {
    UInt64 recordTime = [[NSDate date] timeIntervalSince1970]*1000;
    NSNumber *timeStamp = [NSNumber numberWithLongLong:recordTime];
    NSMutableDictionary *message = [NSMutableDictionary dictionaryWithCapacity:0];
    [message setObject:@"text" forKey:@"type"];
    [message setObject:textView.text forKey:@"content"];
    [message setObject:timeStamp forKey:@"time"];
    
    NSMutableDictionary *userDict = [NSMutableDictionary dictionaryWithCapacity:0];
    [userDict setObject:[[NSDate date] string] forKey:@"creationTime"];
    [userDict setObject:message forKey:@"message"];
    [userDict setObject:timeStamp forKey:@"sendTime"];
    [userDict setObject:[[CacheManager sharedInstance] userId] forKey:@"from"];
    [userDict setObject:[[CacheManager sharedInstance] userName] forKey:@"name"];
    [userDict setObject:self.projectId forKey:@"projectId"];
    [userDict setObject:self.groupId forKey:@"groupId"];
    [userDict setObject:@"1" forKey:@"received"];
    [userDict setObject:@"" forKey:@"avatar"];
    [userDict setObject:@"" forKey:@"toUser"];
    ChatMessageListItem *item = [[ChatMessageListItem alloc] initWithMessageItem:userDict];
    
    NSString *time = [NSDate compareTimeWithOldTime:self.lastMessageTime NewTime:[item.time longLongValue] / 1000];
    messageCellFrame *cellFrame = [[messageCellFrame alloc] init];
    if (time) {
        cellFrame.isTimeShow = YES;
        cellFrame.currentTimeStr = time;
    }else {
        cellFrame.isTimeShow = NO;
    }
    self.lastMessageTime = [item.time longLongValue] / 1000;
    cellFrame.isIndeicatorShow = YES;
    cellFrame.model = item;
    [self.dataArray addObject:cellFrame];
    [self.tableView reloadData];
    [self tableViewScrollCurrentIndexPath:self.dataArray.count animated:NO];
    
    [self.Ds sendMessageGroupId:self.groupId content:textView.text model:item tableName:GlobalMessageTableName succeed:^(id object) {
        messageCellFrame *cellFrame = (messageCellFrame *)self.dataArray.lastObject;
        cellFrame.isIndeicatorShow = NO;
        [self.tableView reloadData];
    } failed:^(id object) {
        messageCellFrame *cellFrame = (messageCellFrame *)self.dataArray.lastObject;
        cellFrame.isIndeicatorShow = NO;
        cellFrame.isErrorImageShow = YES;
        [self.tableView reloadData];
    }];
    textView.text = @"";
}

- (BOOL)KeyboardVIew:(KeyboardView *)keyboardView sendMessage:(UITextView *)textView currentMessage:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        self.content = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (![self.content isEqualToString:@""]) {
            [self sendMessage:textView];
        } else {
            //如果输入的是空格可以进一步处理
            textView.text=@"";
            NSLog(@"您输入的是空格");
        }
        //恢复原始状态
        [self KeyboardVIew:keyboardView textViewDidChang:textView];
        return NO;
    }
    return YES;
}

- (void)KeyboardVIew:(KeyboardView *)keyboardView textViewBegin:(UITextView *)textView {
    [textView becomeFirstResponder];
    if(!self.previousTextViewContentHeight) {
        CGFloat maxHeight = [self.keyBordView maxHeight];
        CGSize size = [textView sizeThatFits:CGSizeMake(textView.frame.size.width, maxHeight)];
        CGFloat textViewContentHeight = size.height;
        self.previousTextViewContentHeight = textViewContentHeight;
    }
    [self tableViewScrollCurrentIndexPath:self.dataArray.count animated:YES];
}
- (void)textViewDidEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
}
//改变textView的高度
- (void)KeyboardVIew:(KeyboardView *)keyboardView textViewHeightChange:(UITextView *)textView {
    [self tableViewScrollCurrentIndexPath:self.dataArray.count animated:YES];
    textView.text = @"";
    if(!self.previousTextViewContentHeight) {
        CGFloat maxHeight = [self.keyBordView maxHeight];
        CGSize size = [textView sizeThatFits:CGSizeMake(textView.frame.size.width, maxHeight)];
        CGFloat textViewContentHeight = size.height;
        self.previousTextViewContentHeight = textViewContentHeight;
    }
    [self KeyboardVIew:keyboardView textViewDidChang:textView];
}

- (void)KeyboardVIew:(KeyboardView *)keyboardView textViewDidChang:(UITextView *)textView {
    CGFloat maxHeight = [self.keyBordView maxHeight];
    CGSize size = [textView sizeThatFits:CGSizeMake(textView.frame.size.width, maxHeight)];
    CGFloat textViewContentHeight = size.height;
    BOOL isShrinking = textViewContentHeight < self.previousTextViewContentHeight;
    CGFloat changeInHeight = textViewContentHeight - self.previousTextViewContentHeight;
    
    if(!isShrinking && self.previousTextViewContentHeight == maxHeight) {
        changeInHeight = 0;
    } else {
        changeInHeight = MIN(changeInHeight, maxHeight - self.previousTextViewContentHeight);
    }
    if(changeInHeight != 0.0f) {
        //改变控件的位置
        [self ChangeHeight:changeInHeight isShrinking:isShrinking];
        self.previousTextViewContentHeight = MIN(textViewContentHeight, maxHeight);
    }
}

- (void)ChangeHeight:(CGFloat)changeInHeight isShrinking:(BOOL)isShrinking {
    [UIView animateWithDuration:0.15f
                     animations:^{
                         
                         UIEdgeInsets insets = UIEdgeInsetsMake(0.0f,0.0f,self.tableView.contentInset.bottom + changeInHeight, 0.0f);
                         self.tableView.contentInset = insets;
                         self.tableView.scrollIndicatorInsets = insets;
                         [self tableViewScrollCurrentIndexPath:self.dataArray.count animated:YES];
                         
                         if(isShrinking) {
                             // if shrinking the view, animate text view frame BEFORE input view frame
                             [self.keyBordView adjustTextViewHeightBy:changeInHeight];
                         }
                         CGRect inputViewFrame = self.keyBordView.frame;
                         self.keyBordView.frame = CGRectMake(0.0f,inputViewFrame.origin.y - changeInHeight,inputViewFrame.size.width,inputViewFrame.size.height + changeInHeight);
                         
                         self.keyBordView.backImageView.frame = self.keyBordView.bounds;
                         if(!isShrinking) {
                             [self.keyBordView adjustTextViewHeightBy:changeInHeight];
                         }
                     }
                     completion:^(BOOL finished) {
                     }];
}

#pragma mark - 懒加载
- (UITableView *)tableView {
    if (_tableView==nil) {
        _tableView=[[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - keyBoardHeight - 64) style:UITableViewStylePlain];
        _tableView.delegate=self;
        _tableView.dataSource=self;
        _tableView.backgroundColor=[UIColor colorWithRed:236.0 green:235.0 blue:243.0 alpha:1.0];
        [_tableView registerClass:[MessageCell class] forCellReuseIdentifier:cellIdentifier];
        _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        _tableView.allowsSelection=NO;
        _tableView.backgroundView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"chat_bg_default"]];
        _tableView.header=[MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(downRefresh)];
    }
    return _tableView;
}

- (KeyboardView *)keyBordView {
    if (_keyBordView == nil) {
        _keyBordView = [[KeyboardView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT - keyBoardHeight - 64, SCREEN_WIDTH, keyBoardHeight)];
        _keyBordView.delegate = self;
        
    }
    return _keyBordView;
}

- (NSMutableArray *)dataArray {
    if (_dataArray ==  nil) {
        _dataArray = [[NSMutableArray alloc]init];
        
    }
    return _dataArray;
}

- (NSMutableArray *)newDataArray {
    if (_newDataArray == nil) {
        _newDataArray = [[NSMutableArray alloc]init];
    }
    return _newDataArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
