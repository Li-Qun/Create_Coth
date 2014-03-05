//
//  LoginViewController.h
//  Cloth
//
//  Created by ss4346 on 13-9-9.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import <Parse/Parse.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "CommonUtil.h"
#import "SBJsonParser.h"
#import "SVProgressHUD.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"


@interface LoginViewController : UIViewController<ASIHTTPRequestDelegate>

@property (strong,nonatomic) IBOutlet UIView *viewName;
@property (strong,nonatomic) IBOutlet UIView *viewPwd;

@property (strong,nonatomic) IBOutlet UITextField *name;
@property (strong,nonatomic) IBOutlet UITextField *pwd;

- (IBAction)submit:(id)sender;
- (IBAction)loginByTecent:(id)sender;
- (IBAction)loginBySina:(id)sender;

@end
