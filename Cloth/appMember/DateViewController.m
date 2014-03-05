//
//  DateViewController.m
//  Cloth
//
//  Created by ss4346 on 13-10-14.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import "DateViewController.h"

@interface DateViewController ()

@end

@implementation DateViewController

@synthesize startTime = _startTime;
@synthesize endTime   = _endTime;

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
    [self createDatePickerView];
    
}

#pragma mark custom method
- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (NSString *)stringFromDate:(NSDate *)date{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *destDateString = [dateFormatter stringFromDate:date];   
    return destDateString;
}

-(IBAction)submit:(id)sender
{
    //判断当前是否有网络
    if ([CommonUtil existNetWork] == 0) {
        return;
    };
    
    [SVProgressHUD show];
    NSURL *url = [[NSURL alloc] initWithString:AJAX_URL];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:ADD_STICKY                            forKey:ACTION];
    [request setPostValue:[CommonUtil getUserName]              forKey:FIRST_NAME];
    [request setPostValue:[CommonUtil getPassword]              forKey:PASSWORD];
    [request setPostValue:[CommonUtil getUserType]              forKey:ACCOUNT_TYPE];
    [request setPostValue:[self.tradeCell objectForKey:@"id"]   forKey:CONTENT_ID];
    [request setPostValue:self.startTime.text                   forKey:START_DATE];
    [request setPostValue:self.endTime.text                     forKey:END_DATE];
    
    [request setCompletionBlock:^{
        [SVProgressHUD dismiss];
        NSString *responseString = [request responseString];
        NSLog(@"response >>> %@",responseString);
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *dictionary = [parser objectWithString:responseString];
        NSString *state = [dictionary objectForKey:@"state"];
        if (((![state isKindOfClass:[NSNull class]]) && state != nil)) {
            NSString *message = [dictionary objectForKey:@"message"];
            UIAlertView *myalert = [[UIAlertView alloc] initWithTitle:@"提示" message:message  delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil,nil];
            [myalert show];
            [self backAction];
        }
        
    }];
    [request setFailedBlock:^{
        [SVProgressHUD dismiss];
        NSString *responseString = [request responseString];
        NSLog(@">>>>>>%@",responseString);
    }];
    
    [request startAsynchronous];
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
    self.navigationItem.title = @"预约时间";
}

- (void) createDatePickerView
{
    datePickerView = [[UIView alloc] init];
    
    myDatePicker = [[UIDatePicker alloc] init];
    [myDatePicker setDatePickerMode:UIDatePickerModeDate];
    [datePickerView addSubview:myDatePicker];
    [datePickerView setAccessibilityLanguage:@"Chinese"];
    
    [self.view addSubview:myDatePicker];
    myDatePicker.frame = CGRectMake(0, self.view.frame.size.height +250, 320, 250);
}

- (void) showView
{
    [UIView animateWithDuration:0.5 animations:^{
        myDatePicker.frame = CGRectMake(0, self.view.frame.size.height -250 +35, 320, 250);
    }];
}

- (void) hideView
{
    [UIView animateWithDuration:0.5 animations:^{
        myDatePicker.frame = CGRectMake(0, self.view.frame.size.height +250, 320, 250);
    } completion:^(BOOL finished) {
    }];
}
#pragma mark - TextField delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.startTime) {
        flag = 1;
    }else{
        flag = 2;
    }
    [self showView];
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self hideView];
    if (flag == 1) {
        [self.startTime setText: [self stringFromDate:myDatePicker.date]];
    }else if(flag ==2){
        [self.endTime setText: [self stringFromDate:myDatePicker.date]];
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{

    [self hideView];
    if (flag == 1) {
        [self.startTime setText: [self stringFromDate:myDatePicker.date]];
    }else if(flag ==2){
        [self.endTime setText: [self stringFromDate:myDatePicker.date]];
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
