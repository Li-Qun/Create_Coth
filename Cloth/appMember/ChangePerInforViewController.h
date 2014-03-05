//
//  ChangePerInforViewController.h
//  Cloth
//
//  Created by ss4346 on 13-9-28.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonUtil.h"
#import "SBJsonParser.h"
#import "SVProgressHUD.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "TPKeyboardAvoidingScrollView.h"

@interface ChangePerInforViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate>{
    UIImage *chosenImage;
    NSString *tempImagePath;
}

@property  (strong,nonatomic) IBOutlet TPKeyboardAvoidingScrollView *myScrollView;
@property  (strong,nonatomic) IBOutlet UITextField *textPwd;
@property  (strong,nonatomic) IBOutlet UITextField *textChangePwd;
@property  (strong,nonatomic) IBOutlet UITextField *textRePwd;
@property  (strong,nonatomic) IBOutlet UITextField *textPhone;
@property  (strong,nonatomic) IBOutlet UITextField *textPhoneCode;
@property  (strong,nonatomic) IBOutlet UITextField *textEmail;
@property  (strong,nonatomic) IBOutlet UITextField *textEmailCode;
@property  (strong,nonatomic) IBOutlet UIButton *btnImage;

-(IBAction)getPhoneCode:(id)sender;
-(IBAction)getEmailCode:(id)sender;
-(IBAction)saveInfor:(id)sender;
-(IBAction)cancel:(id)sender;
-(IBAction)getAPhoto:(id)sender;

@end
