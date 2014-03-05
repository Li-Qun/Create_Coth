//
//  LoginViewController.m
//  Cloth
//
//  Created by ss4346 on 13-9-9.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import "LoginViewController.h"
#import <ShareSDK/ShareSDK.h>

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize viewName = _viewName;
@synthesize viewPwd  = _viewPwd;
@synthesize name     = _name;
@synthesize pwd      = _pwd;

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
    [self createNavigationBarItem];
}


#pragma mark - Button selector 
- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)submit:(id)sender
{
    [self postSomeData];
}

#pragma mark - Button action
- (void)loginByTecent:(id)sender
{
    [ShareSDK getUserInfoWithType:ShareTypeTencentWeibo
                      authOptions:nil
                           result:^(BOOL result, id<ISSUserInfo> userInfo, id<ICMErrorInfo> error) {
                               
                               if (result)
                               {
                                   PFQuery *query = [PFQuery queryWithClassName:@"UserInfo"];
                                   [query whereKey:@"uid" equalTo:[userInfo uid]];
                                   [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                                       
                                       NSLog(@"uid  >>   %@",[userInfo uid]);
                                       if ([objects count] == 0)
                                       {
      
                                           
                                           [self signUpForWeibo:[userInfo uid] type:@"2"];
                                           
                                       }
                                       else
                                       {
                                           [self signUpForWeibo:[userInfo uid] type:@"2"];
                                           
                                       }
                                   }];
                                   
                                   
                                   
                               }
                               
                           }];
}


- (void)loginBySina:(id)sender
{
    [ShareSDK getUserInfoWithType:ShareTypeSinaWeibo
                      authOptions:nil
                           result:^(BOOL result, id<ISSUserInfo> userInfo, id<ICMErrorInfo> error) {
                               
                               if (result)
                               {
                                   PFQuery *query = [PFQuery queryWithClassName:@"UserInfo"];
                                   [query whereKey:@"uid" equalTo:[userInfo uid]];
                                   [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

                                       NSLog(@"uid  >>   %@",[userInfo uid]);
                                       if ([objects count] == 0)
                                       {
 
                                           [self signUpForWeibo:[userInfo uid] type:@"3"];
                                           
                                       }
                                       else
                                       {
                                           [self signUpForWeibo:[userInfo uid] type:@"3"];
                                           
                                       }
                                   }];
                                   
                                   
                                   
                               }
                               
                           }];
   
}

//微博注册方法
- (void)signUpForWeibo:(NSString *)name type:(NSString *)type
{
    //判断当前是否有网络
    if ([CommonUtil existNetWork] == 0) {
        return;
    };
    
    [SVProgressHUD show];
    NSURL *url = [[NSURL alloc] initWithString:AJAX_URL];
    __weak  ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:REGISTER_ACTION   forKey:ACTION ];
    [request setPostValue:name              forKey:FIRST_NAME];
    [request setPostValue:name              forKey:PASSWORD];
    [request setPostValue:type              forKey:ACCOUNT_TYPE];
    
    [request setCompletionBlock:^{
        [self signInWeibo:name type:type];
        
    }];
    [request setFailedBlock:^{
        [SVProgressHUD dismiss];
        NSString *responseString = [request responseString];
        NSLog(@">>>>>>%@",responseString);
    }];
    
    [request startAsynchronous];
}

- (void)signInWeibo:(NSString *)name type:(NSString *)type
{
    //判断当前是否有网络
    if ([CommonUtil existNetWork] == 0) {
        return;
    };
    
    NSURL *url = [[NSURL alloc] initWithString:AJAX_URL];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];

    [request setRequestMethod:@"POST"];
    [request setPostValue:LOGIN_ACTION      forKey:ACTION ];
    [request setPostValue:name              forKey:FIRST_NAME];
    [request setPostValue:name              forKey:PASSWORD];
    [request setPostValue:type              forKey:ACCOUNT_TYPE];
    [request setPostValue:@"1"              forKey:FOR_LOGIN];
    
    [request setCompletionBlock:^{
        [SVProgressHUD dismiss];
        NSString *jsonString = [request responseString];
        
        SBJsonParser *parser =[[SBJsonParser alloc] init];
        NSDictionary *dictionary = [parser objectWithString:jsonString];
        NSDictionary *userData = [dictionary objectForKey:@"user_data"];
        int state = [[dictionary objectForKey:@"state"]intValue];
        if (state == 1) {
            //登录成功
            //保存用户信息到本地
            [CommonUtil writePlist:name password:name userType:type totalCredit:[userData objectForKey:@"total_credit"] costCredit:[userData objectForKey:@"consumed_credit"] imagePath:[userData objectForKey:@"image_path"]];
            
            NSLog(@">>>>>>>>>>>  %@>>>>> %@>>>>>> %@>>>>> %@",[CommonUtil getUserName],[CommonUtil getPassword],[CommonUtil getUserType],[CommonUtil getTotalCredit]);
            
            [self dismissViewControllerAnimated:YES completion:nil];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }else if (state == 0) {
            //登陆失败
            NSString *string = [dictionary objectForKey:@"message"];
            
            [SVProgressHUD showErrorWithStatus:string];
            
        }
        
    }];
    [request setFailedBlock:^{
        [SVProgressHUD dismiss];
        NSString *responseString = [request responseString];
        NSLog(@">>>>>>%@",responseString);
    }];
    
    [request startAsynchronous];
}

//登陆方法
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
    [request setPostValue:LOGIN_ACTION      forKey:ACTION ];
    [request setPostValue:self.name.text    forKey:FIRST_NAME];
    [request setPostValue:self.pwd.text     forKey:PASSWORD];
    [request setPostValue:USER_NORMAL       forKey:ACCOUNT_TYPE];
    [request setPostValue:@"1"              forKey:FOR_LOGIN];
    
    [request startAsynchronous];

}

#pragma mark - ASIHttpDelegate
- (void)requestFinished:(ASIHTTPRequest *)request {
    [SVProgressHUD dismiss];
    NSString *jsonString = [request responseString];
    
    NSLog(@"         %@",jsonString);
    
    SBJsonParser *parser =[[SBJsonParser alloc] init];
    NSDictionary *dictionary = [parser objectWithString:jsonString];
    NSDictionary *userData = [dictionary objectForKey:@"user_data"];
    int state = [[dictionary objectForKey:@"state"]intValue];
    if (state == 1) {
        //登录成功
        //保存用户信息到本地
        [CommonUtil writePlist:self.name.text password:self.pwd.text userType:@"1" totalCredit:[userData objectForKey:@"total_credit"] costCredit:[userData objectForKey:@"consumed_credit"] imagePath:[userData objectForKey:@"image_path"]];
        
        NSLog(@">>>>>>>>>>>  %@>>>>> %@>>>>>> imagePath%@>>>>> %@",[CommonUtil getUserName],[CommonUtil getPassword],[CommonUtil getUserType],[CommonUtil getImagePath]);
        
        [self dismissViewControllerAnimated:YES completion:nil];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else if (state == 0) {
        //登陆失败
        NSString *string = [dictionary objectForKey:@"message"];
    
        [SVProgressHUD showErrorWithStatus:string];

    }
    
    
    NSLog(@"finished");
}


- (void)requestFailed:(ASIHTTPRequest *)request {
    [SVProgressHUD dismiss];
    NSLog(@"failed");
}

#pragma mark - ui init
-(void)createSubView
{
    //设置背景
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    
    self.viewName.layer.borderWidth = 1;
    self.viewName.layer.borderColor = [[UIColor lightGrayColor]CGColor];
    self.viewPwd.layer.borderWidth  = 1;
    self.viewPwd.layer.borderColor  = [[UIColor lightGrayColor] CGColor];
}

-(void)createNavigationBarItem
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
