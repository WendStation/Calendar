//
//  AddProjectViewController.m
//  Calendar
//
//  Created by 刘花椒 on 15/11/27.
//
//

#import "AddProjectViewController.h"
#import "UIPlaceHolderTextView.h"
#import "ChooseSomeoneViewController.h"
#import "ProjectListDatasource.h"

@interface AddProjectViewController ()<UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightItem;
@property(nonatomic, strong)NSArray *titleAry;
@property(nonatomic, strong)NSArray *placeHolderAry;
@property(nonatomic, strong)NSMutableDictionary *projectDict;
@property(nonatomic, strong)NSString *category_id;
@property(nonatomic, strong)ProjectListDatasource *ds;
@property(nonatomic, assign)CGFloat keyboardHeight;

@end

@implementation AddProjectViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.customer != nil) {
        NSString *key = self.titleAry[0][4];
        [self.projectDict setObject:self.customer.name forKey:key];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:4 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleAry = @[@[@"项目名称",@"品类",@"CEO姓名",@"CEO手机",@"推荐人"],@[@"项目简介"]];
    self.placeHolderAry = @[@[@"请填写项目名称",@"请选择项目品类",@"请填写CEO姓名",@"请填写CEO手机",@"请选择推荐人"],@[ @"请填写项目简介"]];
    self.ds = [[ProjectListDatasource alloc] init];
    self.tableView.estimatedRowHeight = 44;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.showsVerticalScrollIndicator = NO;
    
    self.projectDict = [NSMutableDictionary dictionary];
    [self.projectDict setObject:@"" forKey:@"项目名称"];
    [self.projectDict setObject:@"" forKey:@"品类"];
    [self.projectDict setObject:@"" forKey:@"CEO姓名"];
    [self.projectDict setObject:@"" forKey:@"CEO手机"];
    [self.projectDict setObject:@"" forKey:@"推荐人"];
    [self.projectDict setObject:@"" forKey:@"项目简介"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)finished:(id)sender {
    [self hideKeyboard:nil];
    if (![[NetworkManager sharedInstance] checkNetAndToken]) {
        [AlertManager showAlertText:@"亲！网络不给力，暂时无法添加" withCloseSecond:1];
        return;
    }
    __block BOOL isExist = NO;
    NSArray *array = self.projectDict.allValues;
    [array enumerateObjectsUsingBlock:^(NSString *str, NSUInteger idx, BOOL *stop) {
        if ([str isEqualToString:@""]) {
            *stop = YES;
            isExist = YES;
        }
    }];
    if (isExist) {
        [AlertManager showAlertText:@"数据填写不全哦！" withCloseSecond:1];
        return;
    } else {
        if ([[self.projectDict objectForKey:@"CEO手机"] length] != 11) {
            [AlertManager showAlertText:@"手机号输入有误！" withCloseSecond:1];
            return;
        } else {
            NSMutableDictionary *paras = [NSMutableDictionary dictionaryWithDictionary:self.projectDict];
            [paras setObject:self.category_id forKey:@"品类"];
            [paras setObject:self.customer.userId forKey:@"推荐人"];
            
            [self.ds postAddProjectInfo:paras succeed:^(NSDictionary *dict) {
                //NSLog(@"%@",dict);
            } failed:^{
                
            }];
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.titleAry.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [self.titleAry.firstObject count];
    } else{
        return [self.titleAry.lastObject count];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        if (indexPath.row == 0 || indexPath.row == 2 || indexPath.row == 3) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"cell0"];
            UILabel *title = (UILabel *)[cell viewWithTag:1];
            title.text = [self.titleAry.firstObject objectAtIndex:indexPath.row];
            title.font = [UIFont systemFontOfSize:14];
            title.textColor = LIGHTGRAY_COLOR;
            
            UIPlaceHolderTextView *view = (UIPlaceHolderTextView *)[cell viewWithTag:2];
            view.delegate = self;
            view.placeholder = [self.placeHolderAry.firstObject objectAtIndex:indexPath.row];
            view.font = [UIFont systemFontOfSize:14];
            view.placeholderColor = LIGHTGRAY_COLOR;
            view.textColor = BLACK_COLOR;
            
            if (indexPath.row == 0) {
                NSString *str = [self.projectDict objectForKey:@"项目名称"];
                if (str.length > 0) {
                    view.text = [self.projectDict objectForKey:@"项目名称"];
                }
            } else if (indexPath.row == 2) {
                NSString *str = [self.projectDict objectForKey:@"CEO姓名"];
                if (str.length > 0) {
                    view.text = [self.projectDict objectForKey:@"CEO姓名"];
                }
            } else {
                NSString *str = [self.projectDict objectForKey:@"CEO手机"];
                if (str.length > 0) {
                    view.text = [self.projectDict objectForKey:@"CEO手机"];
                }
                view.keyboardType = UIKeyboardTypeNumberPad;
            }

        } else{
            cell = [tableView dequeueReusableCellWithIdentifier:@"cell1"];
            UILabel *title = (UILabel *)[cell viewWithTag:1];
            title.text = [self.titleAry.firstObject objectAtIndex:indexPath.row];
            title.font = [UIFont systemFontOfSize:14];
            title.textColor = LIGHTGRAY_COLOR;
            
            UILabel *content = (UILabel *)[cell viewWithTag:2];
            content.font = [UIFont systemFontOfSize:14];
            content.textColor = LIGHTGRAY_COLOR;
            
            if (indexPath.row == 1) {
                NSString *str = [self.projectDict objectForKey:@"品类"];
                if (str.length > 0) {
                    content.text = str;
                    content.textColor = BLACK_COLOR;
                } else {
                    content.text = [self.placeHolderAry.firstObject objectAtIndex:indexPath.row];
                }
            } else if (indexPath.row == 4) {
                NSString *str = [self.projectDict objectForKey:@"推荐人"];
                if (str.length > 0) {
                    content.text = str;
                    content.textColor = BLACK_COLOR;
                } else {
                    content.text = [self.placeHolderAry.firstObject objectAtIndex:indexPath.row];
                }
            }
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"cell2"];
        UILabel *title = (UILabel *)[cell viewWithTag:1];
        title.text = [self.titleAry.lastObject objectAtIndex:indexPath.row];
        title.font = [UIFont systemFontOfSize:14];
        title.textColor = LIGHTGRAY_COLOR;
        
        UIPlaceHolderTextView *view = (UIPlaceHolderTextView *)[cell viewWithTag:2];
        view.delegate = self;
        view.placeholder = [self.placeHolderAry.lastObject objectAtIndex:indexPath.row];
        view.font = [UIFont systemFontOfSize:14];
        view.placeholderColor = LIGHTGRAY_COLOR;
        view.textColor = BLACK_COLOR;
        
        NSString *str = [self.projectDict objectForKey:@"项目简介"];
        if (str.length > 0) {
            view.text = [self.projectDict objectForKey:@"项目简介"];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.row == 1) {
            [self hideKeyboard:nil];
            [self selectCategoryDefine];
        } else if (indexPath.row == 4) {
            [self hideKeyboard:nil];
            ChooseSomeoneViewController *vc = (ChooseSomeoneViewController *)[CommonAPI getUIViewControllerForID:@"ChooseSomeoneViewController" formStoryboard:@"CalendarStoryboard"];
            vc.isMultiSelect = NO;
            vc.isSelectEthercap = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
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


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0;
    } else {
        return 8;
    }
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
        if (index.row == 0 || index.row == 2 || index.row == 3) {
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

@end
