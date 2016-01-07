//
//  LoginViewController.m
//  Calendar
//
//  Created by 刘花椒 on 15/12/21.
//
//

#import "LoginViewController.h"
#import "MoreDatasource.h"
#import "ViewManager.h"

#define textFieldHeight   55

@interface LoginViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) MoreDatasource *Ds;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewBottom;
@property (nonatomic, assign) CGFloat offY;

@end

@implementation LoginViewController

- (IBAction)login:(id)sender {
    if (self.userNameTextField.text.length == 0) {
        [AlertManager showAlertText:@"亲，用户名不能为空！" withCloseSecond:1];
        return;
    } else if (self.passwordTextField.text.length == 0) {
        [AlertManager showAlertText:@"亲，密码不能为空！" withCloseSecond:1];
        return;
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:self.userNameTextField.text forKey:@"userName"];
        [self.view endEditing:YES];
        MBProgressHUD *hud = [AlertManager getAlertTextWithAss:@""];
        [hud show:YES];
        
        [self.Ds postLogin:self.userNameTextField.text password:self.passwordTextField.text succeed:^(id object) {
            [hud show:YES];
            NSDictionary *dict = (NSDictionary *)object;
            if ([[dict objectForKey:@"code"] intValue] == NETWORK_CODE_SUCCESS) {
                [[ViewManager sharedInstance] showMainTabView];
            }
        } failed:^(id object) {
            [hud show:YES];
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"userName"]) {
        self.userNameTextField.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    }
    self.Ds = [[MoreDatasource alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboadWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gesture.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:gesture];
}

#pragma mark textFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark keyboad
- (void)keyboadWillShow:(NSNotification *)note{
    NSDictionary *info = [note userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    self.offY = keyboardSize.height - (SCREEN_HEIGHT - self.loginBtn.bottom);
    if (self.offY > 0) {
        [UIView animateWithDuration:0.25 animations:^{
            self.viewTop.constant = - self.offY;
            self.viewBottom.constant = self.offY;
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)note{
    [UIView animateWithDuration:0.25 animations:^{
        self.viewTop.constant = 0;
        self.viewBottom.constant = 0;
    }];
}

- (void)hideKeyboard{
    [self.userNameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
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
