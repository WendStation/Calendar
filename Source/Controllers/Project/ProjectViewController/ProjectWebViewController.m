//
//  ProjectWebViewController.m
//  Calendar
//
//  Created by 刘花椒 on 15/11/14.
//
//

#import "ProjectWebViewController.h"

@interface ProjectWebViewController ()

@end

@implementation ProjectWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"查看BP";
    // Do any additional setup after loading the view
    if (self.bpFilePath) {
        UIWebView *myWebView = [[UIWebView alloc] init];
        myWebView.scalesPageToFit = YES;

        NSURL *url = [NSURL fileURLWithPath:self.bpFilePath];
        NSString *pathType = [self mimeType:url];
        NSData *data = [NSData dataWithContentsOfFile:self.bpFilePath];
        [myWebView loadData:data MIMEType:pathType textEncodingName:@"UTF-8" baseURL:nil];
        [self.view addSubview:myWebView];
        
        WS(weakWebview);
        [myWebView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(weakWebview.view.mas_top);
            make.bottom.equalTo(weakWebview.view.mas_bottom);
            make.left.equalTo(weakWebview.view.mas_left);
            make.right.equalTo(weakWebview.view.mas_right);
        }];
    }
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.isFull = YES;
    [CommonAPI setOrientation:UIInterfaceOrientationMaskAll];
}


-(void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [CommonAPI setOrientation:UIInterfaceOrientationMaskPortrait];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    delegate.isFull = NO;
    
}


- (NSString *)mimeType:(NSURL *)url
{
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLResponse *response = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    return response.MIMEType;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
