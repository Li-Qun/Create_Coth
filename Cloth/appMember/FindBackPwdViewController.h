//
//  FindBackPwdViewController.h
//  Cloth
//
//  Created by ss4346 on 13-9-26.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonUtil.h"
#import "SBJsonParser.h"
#import "SVProgressHUD.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "ChangePWDViewController.h"

@interface FindBackPwdViewController : UIViewController<ASIHTTPRequestDelegate>

@property (strong,nonatomic) IBOutlet UITextField *textPhone;
@property (strong,nonatomic) IBOutlet UITextField *textEmail;

-(IBAction)getPhoneCode:(id)sender;
-(void)changePwdByPhone;
-(IBAction)getEmailCode:(id)sender;
-(void)changePwdByEmail;

@end
