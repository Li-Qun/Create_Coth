//
//  MoreAboutUsViewController.m
//  Cloth
//
//  Created by ss4346 on 13-9-9.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import "MoreAboutUsViewController.h"

@interface MoreAboutUsViewController ()

@end

@implementation MoreAboutUsViewController

@synthesize labelAdress = _labelAdress;
@synthesize labelPhone  = _labelPhone;
@synthesize labelEmail  = _labelEmail;
@synthesize lableTitle  = _lableTitle;
@synthesize lableContent= _lableContent;

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
    [self createSubView];
    [self createNavigationItem];
    [self getInfor];
}

#pragma -mark button action
-(void)getInfor
{
    //判断当前是否有网络
    if ([CommonUtil existNetWork] == 0) {
        return;
    };
    
    [SVProgressHUD show];
    NSURL *url = [[NSURL alloc] initWithString:AJAX_URL];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:RETRIEVE_ABOUT_US               forKey:ACTION];
    
    [request setCompletionBlock:^{
        [SVProgressHUD dismiss];
        NSString *responseString = [request responseString];
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        dictionary = [parser objectWithString:responseString];
        NSLog(@"response >>>>>>>  %@",responseString);
        [self changeInfor];
    }];
    [request setFailedBlock:^{
        [SVProgressHUD dismiss];
        NSString *responseString = [request responseString];
        NSLog(@">>>>>>%@",responseString);
    }];
    
    [request startAsynchronous];
}

- (void)changeInfor
{
    self.lableTitle.text    =  [dictionary objectForKey:@"name"];
    self.lableContent.text  =  [dictionary objectForKey:@"intro"];
    self.labelAdress.text   =  [dictionary objectForKey:@"addr"];
    self.labelEmail.text    =  [dictionary objectForKey:@"email"];
    self.labelPhone.text    =  [dictionary objectForKey:@"phone"];
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma -mark UI init
- (void)createSubView
{
    self.labelAdress.layer.cornerRadius = 3;
    self.labelPhone.layer.cornerRadius = 3;
    self.labelEmail.layer.cornerRadius = 3;
    
    //设置背景
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
