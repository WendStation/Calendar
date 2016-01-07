//
//  AddCCViewController.m
//  Calendar
//
//  Created by 刘花椒 on 15/11/28.
//
//

#import "AddCCViewController.h"
#import "UIPlaceHolderTextView.h"
#import "ProjectListDatasource.h"

@interface AddCCViewController ()<UITableViewDataSource,
                                    UITableViewDelegate,
                                      UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightItem;
@property (nonatomic, strong) NSArray *titleAry;
@property (nonatomic, strong) NSArray *placeHolderAry;
@property (nonatomic, strong) NSMutableDictionary *projectDict;
@property (nonatomic, strong) NSString *category_id;
@property (nonatomic, assign) CGFloat keyboardHeight;
@property (nonatomic, strong) ProjectListDatasource *ds;

@end

@implementation AddCCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleAry = @[@[@"项目名称",@"品类",@"CEO姓名",@"相关网址",@"公司电话"],@[@"备注信息"]];
    self.placeHolderAry = @[@[@"请填写项目名称",@"选填",@"选填",@"选填",@"选填"],@[@"帮助leads同学更快找到电话的其他线索，选填"]];
    self.ds = [[ProjectListDatasource alloc] init];
    
    self.tableView.estimatedRowHeight = 44;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.showsVerticalScrollIndicator = NO;
    
    self.projectDict = [NSMutableDictionary dictionary];
    [self.projectDict setObject:@"" forKey:@"项目名称"];
    [self.projectDict setObject:@"" forKey:@"品类"];
    [self.projectDict setObject:@"" forKey:@"CEO姓名"];
    [self.projectDict setObject:@"" forKey:@"相关网址"];
    [self.projectDict setObject:@"" forKey:@"公司电话"];
    [self.projectDict setObject:@"" forKey:@"备注信息"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];

}

- (IBAction)finished:(id)sender {
    [self hideKeyboard:nil];
    if (![[NetworkManager sharedInstance] checkNetAndToken]) {
        [AlertManager showAlertText:@"亲！网络不给力，暂时无法添加" withCloseSecond:1];
        return;
    }
    if (![[self.projectDict objectForKey:@"项目名称"] length] > 0) {
        [AlertManager showAlertText:@"项目名称不能为空！" withCloseSecond:1];
        return;
    } else {
        NSMutableDictionary *paras = [NSMutableDictionary dictionaryWithDictionary:self.projectDict];
        if (self.category_id.length > 0) {
            [paras setObject:self.category_id forKey:@"品类"];
        }
        [self.ds postAddCCInfo:paras succeed:^(NSDictionary *dict) {
            //NSLog(@"%@",dict);
        } failed:^{
            
        }];        
    }
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.titleAry.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return [self.titleAry.firstObject count];
    } else {
        return [self.titleAry.lastObject count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        if (indexPath.row == 1) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"cell1"];
            UILabel *title = [cell viewWithTag:1];
            title.text = [self.titleAry.firstObject objectAtIndex:indexPath.row];
            UILabel *content = [cell viewWithTag:2];
            NSString *str = [self.projectDict objectForKey:title.text];
            if (str.length > 0) {
                content.text = str;
                content.textColor = BLACK_COLOR;
            } else {
                content.text = [self.placeHolderAry.firstObject objectAtIndex:indexPath.row];
            }
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"cell0"];
            UILabel *title = [cell viewWithTag:1];
            title.text = [self.titleAry.firstObject objectAtIndex:indexPath.row];
            UIPlaceHolderTextView *textView = (UIPlaceHolderTextView *)[cell viewWithTag:2];
            textView.delegate = self;
            if (indexPath.row == 4) {
                textView.keyboardType = UIKeyboardTypeNumberPad;
            }
            NSString *str = [self.projectDict objectForKey:title.text];
            if (str.length > 0) {
                textView.text = str;
            } else {
                textView.placeholder = [self.placeHolderAry.firstObject objectAtIndex:indexPath.row];
                textView.placeholderColor = LIGHTGRAY_COLOR;
            }
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell2"];
        UILabel *title = [cell viewWithTag:1];
        title.text = [self.titleAry.lastObject objectAtIndex:indexPath.row];
        UIPlaceHolderTextView *textView = (UIPlaceHolderTextView *)[cell viewWithTag:2];
        textView.delegate = self;
        NSString *str = [self.projectDict objectForKey:title.text];
        if (str.length > 0) {
            textView.text = str;
        } else {
            textView.placeholder = [self.placeHolderAry.lastObject objectAtIndex:indexPath.row];
            textView.placeholderColor = LIGHTGRAY_COLOR;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 1) {
            [self selectCategoryDefine];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0;
    } else {
        return 8.0f;
    }
}

- (void)selectCategoryDefine{
    [self hideKeyboard:nil];
    
    NSArray *firstGradeAry = [[CacheManager sharedInstance] getFirstGradeCategory];
    NSArray *secondGradeAry = [[CacheManager sharedInstance] getSecondGradeCategory:[firstGradeAry objectAtIndex:2]];
    
    NSMutableArray *rowsAry = [NSMutableArray array];
    [rowsAry addObject:firstGradeAry];
    [rowsAry addObject:secondGradeAry];
    
    NSArray *initialSelection = @[@2, @0];
    
    [ActionSheetMultipleStringPicker showPickerWithTitle:@"选择品类" rows:rowsAry initialSelection:initialSelection doneBlock:^(ActionSheetMultipleStringPicker *picker, NSArray *selectedIndexes, id selectedValues) {
        
        NSLog(@"%@", selectedIndexes);
        NSLog(@"%@", [selectedValues componentsJoinedByString:@" - "]);
        
        NSString *desContent = [selectedValues componentsJoinedByString:@" - "];
        [self.projectDict setObject:desContent forKey:@"品类"];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        self.category_id = [[CacheManager sharedInstance] getSecondGradeCategoryId:selectedValues];
        
    } cancelBlock:^(ActionSheetMultipleStringPicker *picker) {
        
        NSLog(@"picker = %@", picker);
        
    } origin:self.view];
}


- (void)textViewDidChange:(UITextView *)textView
{
    CGRect bounds = textView.bounds;
    CGSize maxSize = CGSizeMake(bounds.size.width, CGFLOAT_MAX);
    CGSize newSize = [textView sizeThatFits:maxSize];
    if (newSize.height < 20) {
        newSize = CGSizeMake(newSize.width, 20);
    }
    if (bounds.size.height != newSize.height) {
        bounds.size = newSize;
        textView.bounds = bounds;
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
    }
    CGPoint pos = [textView convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *index = [self.tableView indexPathForRowAtPoint:pos];
    [self.tableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
}

-(void)textViewDidEndEditing:(UITextView *)textView {
    CGPoint pos = [textView convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *index = [self.tableView indexPathForRowAtPoint:pos];
    if (index.section == 0) {
        if (index.row == 0 || index.row == 2 || index.row == 3 || index.row == 4) {
            [self.projectDict setObject:textView.text forKey:[self.titleAry.firstObject objectAtIndex:index.row]];
        }
    } else if (index.section == 1) {
        [self.projectDict setObject:textView.text forKey:[self.titleAry.lastObject objectAtIndex:index.row]];
    }
}

-(void)hideKeyboard:(id)sender
{
    [self.view endEditing:YES];
}

-(void)keyboardShow:(NSNotification *)aNotification
{
    NSDictionary *info = [aNotification userInfo];
    NSValue *aValue = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [aValue CGRectValue].size;
    
    self.keyboardHeight = keyboardSize.height;
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
