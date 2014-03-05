//
//  ChangePWDViewController.m
//  Cloth
//
//  Created by ss4346 on 13-10-13.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import "ChangePWDViewController.h"

@interface ChangePWDViewController ()

@end

@implementation ChangePWDViewController

@synthesize textNewPwd   = _textNewPwd;
@synthesize textReNewPwd = _textReNewPwd;
@synthesize type         = _type;
@synthesize code         = _code;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createNavigationItem];
}

#pragma mark custom method
-(void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(IBAction)submit:(id)sender
{
    //判断当前是否有网络
    if ([CommonUtil existNetWork] == 0) {
        return;
    };
    
    //判断密码是否符合规范
    if (self.textNewPwd.text == nil || [self.textNewPwd.text isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"密码不能为空" ];
        return;
    }
    
    if (self.textReNewPwd.text == nil || [self.textReNewPwd.text isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"确认密码不能为空" ];
        return;
    }
    
    if (![self.textReNewPwd.text isEqualToString:self.textNewPwd.text]) {
        [SVProgressHUD showErrorWithStatus:@"两次输入密码不能为空" ];
        return;
    }
    
    [SVProgressHUD show];
    NSURL *url = [[NSURL alloc] initWithString:AJAX_URL];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:RESET_PASSWORD                   forKey:ACTION];
    
    if ([self.type isEqualToString:EMAIL]) {
        [request setPostValue:self.type                     forKey:DEVICE];
        [request setPostValue:self.infor                    forKey:EMAIL];
        [request setPostValue:self.code.text                forKey:EMAIL_CAPTCHA];
    }else if ([self.type isEqualToString:TELEPHONE]) {
        [request setPostValue:self.type                     forKey:DEVICE];
        [request setPostValue:self.infor                    forKey:TELEPHONE];
        [request setPostValue:self.code.text                forKey:TELEPHONE_CAPTCHA];
    }else{
        [SVProgressHUD showErrorWithStatus:@"改不了" duration:3];
        return;
    }
    [request setPostValue:self.textNewPwd.text          forKey:PASSWORD];
    [request setPostValue:TELEPHONE_RESET_PASSWORD      forKey:TYPE];
    
    [request setCompletionBlock:^{
        [SVProgressHUD dismiss];
        NSString *responseString = [request responseString];
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *dictionary = [parser objectWithString:responseString];
        int state = [[dictionary objectForKey:@"state"] intValue];
        NSLog(@"response >>>>>  %@",responseString);
        
        if (state == 1) {
            UIAlertView *myalert = [[UIAlertView alloc] initWithTitle:@"提示" message:[dictionary objectForKey:@"message"]  delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil,nil];
            [myalert show];
            [CommonUtil writeDataToPlist:@"password" value:self.textNewPwd.text];
            NSLog(@"123123 >>>>>>> %@",[CommonUtil getUserName]);
        }else{
            UIAlertView *myalert = [[UIAlertView alloc] initWithTitle:@"提示" message:[dictionary objectForKey:@"修改失败"] delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil,nil];
            [myalert show];
        }
        
    }];
    [request setFailedBlock:^{
        [SVProgressHUD dismiss];
        NSString *responseString = [request responseString];
        NSLog(@">>>>>>%@",responseString);
    }];
    
    [request startAsynchronous];
}

#pragma mark UI init
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
    
    self.navigationItem.title = @"找回密码";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
