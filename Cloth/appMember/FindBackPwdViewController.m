//
//  FindBackPwdViewController.m
//  Cloth
//
//  Created by ss4346 on 13-9-26.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import "FindBackPwdViewController.h"

@interface FindBackPwdViewController ()

@end

@implementation FindBackPwdViewController

@synthesize textPhone       = _textPhone;
@synthesize textEmail       = _textEmail;


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
    [self createNavigationItem];
}

#pragma -mark button IBAction
-(IBAction)getEmailCode:(id)sender
{
    if ([self.textEmail.text isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"邮箱地址不能为空"];
        return;
    }
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    if(![emailTest evaluateWithObject:self.textEmail.text]){
        [SVProgressHUD showErrorWithStatus:@"邮箱格式不正确"];
        return;
    }
    
    //判断当前是否有网络
    if ([CommonUtil existNetWork] == 0) {
        return;
    };
    
    [SVProgressHUD show];
    NSURL *url = [[NSURL alloc] initWithString:AJAX_URL];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:GET_CAPTCHA                   forKey:ACTION];
    [request setPostValue:self.textEmail.text           forKey:EMAIL];
    [request setPostValue:EMAIL_RESET_PASSWORD          forKey:TYPE];
    
    [request setCompletionBlock:^{
        [SVProgressHUD dismiss];
        NSString *responseString = [request responseString];
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *dictionary = [parser objectWithString:responseString];
        int state = [[dictionary objectForKey:@"state"] intValue];
        NSLog(@"response >>>>>  %@",responseString);
        
        if (state == 1) {
            UIAlertView *myalert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"发送成功，请注意查收"  delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil,nil];
            [myalert show];
            [self changePwdByEmail];
        }else{
            UIAlertView *myalert = [[UIAlertView alloc] initWithTitle:@"提示" message:[dictionary objectForKey:@"message"] delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil,nil];
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

-(IBAction)getPhoneCode:(id)sender
{
    if ([self.textPhone.text isEqualToString:@""]) {
        [SVProgressHUD showErrorWithStatus:@"电话号码不能为空"];
        return;
    }
    
    NSString *regex = @"^((13[0-9])|(147)|(15[^4,\\D])|(18[0,5-9]))\\d{8}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if (![pred evaluateWithObject:self.textPhone.text]) {
        [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号码" ];
        return;
    }
    
    //判断当前是否有网络
    if ([CommonUtil existNetWork] == 0) {
        return;
    };
    
    [SVProgressHUD show];
    NSURL *url = [[NSURL alloc] initWithString:AJAX_URL];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:GET_CAPTCHA                   forKey:ACTION];
    [request setPostValue:self.textPhone.text           forKey:TELEPHONE];
    [request setPostValue:TELEPHONE_RESET_PASSWORD      forKey:TYPE];
    
    [request setCompletionBlock:^{
        [SVProgressHUD dismiss];
        NSString *responseString = [request responseString];
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *dictionary = [parser objectWithString:responseString];
        int state = [[dictionary objectForKey:@"state"] intValue];
        NSLog(@"response >>>>>  %@",responseString);
        
        if (state == 1) {
            UIAlertView *myalert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"发送成功，请注意查收"  delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil,nil];
            [myalert show];
            [self changePwdByPhone];
        }else{
            UIAlertView *myalert = [[UIAlertView alloc] initWithTitle:@"提示" message:[dictionary objectForKey:@"message"] delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil,nil];
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

-(void)changePwdByEmail
{
    ChangePWDViewController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"changePwdView"];
    view.type  = EMAIL;
    view.infor = self.textEmail.text;
    [self.navigationController pushViewController:view animated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)changePwdByPhone
{
    ChangePWDViewController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"changePwdView"];
    view.type = TELEPHONE;
    view.infor = self.textPhone.text;
    [self.navigationController pushViewController:view animated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark ui init
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
    // Dispose of any resources that can be recreated.
}

@end
