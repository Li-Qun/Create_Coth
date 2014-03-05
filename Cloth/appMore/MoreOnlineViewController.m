//
//  MoreOnlineViewController.m
//  Cloth
//
//  Created by ss4346 on 13-9-9.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import "MoreOnlineViewController.h"

@interface MoreOnlineViewController ()

@end

@implementation MoreOnlineViewController

@synthesize advice = _advice;
@synthesize email  = _email;
@synthesize labelAdvice = _labelAdvice;
@synthesize labelEmail = _labelEmail;

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
}

#pragma -mark button action

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)submit:(id)sender
{
    //判断当前是否有网络
    if ([CommonUtil existNetWork] == 0) {
        return;
    };
    
    [SVProgressHUD show];
    NSURL *url = [[NSURL alloc] initWithString:AJAX_URL];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:FEEDBACK                  forKey:ACTION];
    [request setPostValue:self.email.text           forKey:EMAIL];
    [request setPostValue:self.advice.text          forKey:CONTENT];

    
    [request setCompletionBlock:^{
        [SVProgressHUD dismiss];
        NSString *responseString = [request responseString];
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *dictionary = [parser objectWithString:responseString];
        NSString *state = [dictionary objectForKey:@"state"];
        if ([state isEqualToString:@"ok"]) {
            UIAlertView *myalert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"提交成功"  delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil,nil];
            [myalert show];
            [self backAction];
        }
        NSLog(@"response string >>>>>> %@",responseString);
    }];
    [request setFailedBlock:^{
        [SVProgressHUD dismiss];
        NSString *responseString = [request responseString];
        NSLog(@">>>>>>%@",responseString);
    }];
    
    [request startAsynchronous];
}

-(void)textViewDidChange:(UITextView *)textView
{
    if (self.advice.text.length == 0) {
        [self.labelAdvice setHidden:NO];
    }else{
        [self.labelAdvice setHidden:YES];
    }
    
    if (self.email.text.length == 0) {
        [self.labelEmail setHidden:NO];
    }else{
        [self.labelEmail setHidden:YES];
    }
}


#pragma -mark UI init
- (void)createSubView
{
    //设置背景
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    
    self.advice.layer.cornerRadius = 4;
    self.advice.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.advice.layer.borderWidth = 1;
    
    self.email.layer.cornerRadius = 4;
    self.email.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    self.email.layer.borderWidth = 1;
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
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 50, 25);
    [rightButton setTitle:@"提交" forState:UIControlStateNormal];
    [rightButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13]];
    [rightButton setTitleColor:[UIColor colorWithRed:145/255.0 green:26/255.0 blue:152/255.0 alpha:1.0] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(submit:) forControlEvents:UIControlEventTouchUpInside];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"btn_location"] forState:UIControlStateNormal];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] init];
    [rightItem setCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
