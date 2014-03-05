//
//  SignUpViewController.h
//  Cloth
//
//  Created by ss4346 on 13-9-9.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "SBJsonParser.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@interface SignUpViewController : UIViewController<ASIHTTPRequestDelegate>

@property (strong,nonatomic) IBOutlet UIView *viewName;
@property (strong,nonatomic) IBOutlet UIView *viewPwd;
@property (strong,nonatomic) IBOutlet UIView *viewRePwd;

@property (strong,nonatomic) IBOutlet UITextField *name;
@property (strong,nonatomic) IBOutlet UITextField *pwd;
@property (strong,nonatomic) IBOutlet UITextField *repwd;

-(IBAction)hadAccount:(id)sender;
-(IBAction)submit:(id)sender;

@end
