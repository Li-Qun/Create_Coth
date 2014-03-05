//
//  SignUpViewController.m
//  Cloth
//
//  Created by ss4346 on 13-9-9.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import "SignUpViewController.h"
#import "UserCenterViewController.h"

@interface SignUpViewController ()

@end

@implementation SignUpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createSubView];
    [self createNavigationItem];
    
}

#pragma mark - button selector
-(void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)hadAccount:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)submit:(id)sender
{
    NSString *strName   = self.name.text;
    NSString *strPwd    = self.pwd.text;
    NSString *strRePwd  = self.repwd.text;
    
    if ([strName isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"用户名不能为空"];
        return;
    }
    
    if ([strPwd isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"密码不能为空"];
        return;
    }
    
    if (![strPwd isEqualToString:strRePwd])
    {
        [SVProgressHUD showErrorWithStatus:@"两次输入密码不一致"];
        return;
    }
    
    [self postSomeData];

}

#pragma mark - Button action

//发送http请求
- (void)postSomeData
{
    //判断当前是否有网络
    if ([CommonUtil existNetWork] == 0) {
        return;
    };
    
    [SVProgressHUD show];
    NSURL *url = [[NSURL alloc] initWithString:AJAX_URL];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    [request setRequestMethod:@"POST"];
    [request setPostValue:REGISTER_ACTION   forKey:ACTION ];
    [request setPostValue:self.name.text    forKey:FIRST_NAME];
    [request setPostValue:self.pwd.text     forKey:PASSWORD];
    [request setPostValue:@"1"              forKey:ACCOUNT_TYPE];
    [request startAsynchronous];
    
}

#pragma mark - ASIHttpDelegate
- (void)requestFinished:(ASIHTTPRequest *)request {
    NSLog(@"request finished");
    [SVProgressHUD dismiss];
    NSString *jsonString = [request responseString];
    SBJsonParser *parser =[[SBJsonParser alloc] init];
    NSDictionary *dictionary = [parser objectWithString:jsonString];
    int state = [[dictionary objectForKey:@"state"]intValue];
    if (state == 1) {
        //登录成功
        //保存数据到本地
        [CommonUtil writePlist:self.name.text password:self.pwd.text userType:@"1" totalCredit:[dictionary objectForKey:@"total_credit"] costCredit:[dictionary objectForKey:@"consumed_credit"] imagePath:[dictionary objectForKey:@"image_path"]];
        
        NSLog(@">>>>>>>>>>> %@>>>>> %@>>>>>> %@",[CommonUtil getUserName],[CommonUtil getPassword],[CommonUtil getUserType]);
        //返回根view
        [self dismissViewControllerAnimated:YES completion:nil];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else if (state == 0) {
        //登陆失败
        NSString *string = [dictionary objectForKey:@"message"]; 
        [SVProgressHUD showErrorWithStatus:string];    
    }
}

- (void)createSubView
{
    //设置背景
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    
    //设置边框
	self.viewName.layer.borderWidth = 1;
    self.viewName.layer.borderColor = [[UIColor lightGrayColor]CGColor];
    self.viewPwd.layer.borderWidth  = 1;
    self.viewPwd.layer.borderColor  = [[UIColor lightGrayColor] CGColor];
    self.viewRePwd.layer.borderWidth= 1;
    self.viewRePwd.layer.borderColor= [[UIColor lightGrayColor] CGColor];
}

- (void)createNavigationItem
{
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, 50, 25);
    [leftButton setTitle:@"返回" forState:UIControlStateNormal];
    [leftButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13]];
    [leftButton setTitleColor:[UIColor colorWithRed:145/255.0 green:26/255.0 blue:152/255.0 alpha:1.0] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"btn_location"] forState:UIControlStateNormal];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] init];
    [leftItem setCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    NSLog(@"request failed");
    [SVProgressHUD dismiss];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
