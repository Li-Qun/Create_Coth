//
//  ChangePerInforViewController.m
//  Cloth
//
//  Created by ss4346 on 13-9-28.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import "ChangePerInforViewController.h"

@interface ChangePerInforViewController ()

@end

@implementation ChangePerInforViewController

@synthesize myScrollView    = _myScrollView;
@synthesize textPwd         = _textPwd;
@synthesize textChangePwd   = _textChangePwd;
@synthesize textRePwd       = _textRePwd;
@synthesize textPhone       = _textPhone;
@synthesize textPhoneCode   = _textPhoneCode;
@synthesize textEmail       = _textEmail;
@synthesize textEmailCode   = _textEmailCode;

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
    
    //初始化数据
    tempImagePath = [ NSTemporaryDirectory() stringByAppendingPathComponent:@"temp_image.png"];
	
}

#pragma -mark button action
//从手机获取验证码
-(IBAction)getPhoneCode:(id)sender
{
    //判断当前是否有网络
    if ([CommonUtil existNetWork] == 0) {
        return;
    };
        
    if (![self.textPhone.text isEqualToString:@""]) {
        
        NSString *regex = @"^((13[0-9])|(147)|(15[^4,\\D])|(18[0,5-9]))\\d{8}$";
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        if (![pred evaluateWithObject:self.textPhone.text]) {
            [SVProgressHUD showErrorWithStatus:@"请输入正确的手机号码" ];
            return;
        }
        
        [SVProgressHUD show];
        NSURL *url = [[NSURL alloc] initWithString:AJAX_URL];
        __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        [request setRequestMethod:@"POST"];
        [request setPostValue:GET_CAPTCHA                   forKey:ACTION ];
        [request setPostValue:[CommonUtil getUserName]      forKey:FIRST_NAME];
        [request setPostValue:[CommonUtil getPassword]      forKey:PASSWORD];
        [request setPostValue:[CommonUtil getUserType]      forKey:ACCOUNT_TYPE];
        [request setPostValue:self.textPhone.text           forKey:TELEPHONE];
        [request setPostValue:TELEPHONE_VALIDATE            forKey:TYPE];
        
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
    }else{
        [SVProgressHUD showErrorWithStatus:@"请输入手机号"];
    }
    
    
}
//从邮箱获取验证码
-(IBAction)getEmailCode:(id)sender
{
    //判断当前是否有网络
    if ([CommonUtil existNetWork] == 0) {
        return;
    };
    
    if (![self.textEmail.text isEqualToString:@""]) {
        
        NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
        if(![emailTest evaluateWithObject:self.textEmail.text]){
            [SVProgressHUD showErrorWithStatus:@"邮箱格式不正确"];
            return;
        }
        
        [SVProgressHUD show];
        NSURL *url = [[NSURL alloc] initWithString:AJAX_URL];
        __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        [request setRequestMethod:@"POST"];
        [request setPostValue:GET_CAPTCHA                   forKey:ACTION ];
        [request setPostValue:[CommonUtil getUserName]      forKey:FIRST_NAME];
        [request setPostValue:[CommonUtil getPassword]      forKey:PASSWORD];
        [request setPostValue:[CommonUtil getUserType]      forKey:ACCOUNT_TYPE];
        [request setPostValue:self.textEmail.text           forKey:EMAIL];
        [request setPostValue:EMAIL_VALIDATE                forKey:TYPE];
        
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
    }else{
        [SVProgressHUD showErrorWithStatus:@"请输入邮箱"];
    }
    
    
}
//修改用户信息
-(IBAction)saveInfor:(id)sender
{
    //判断当前是否有网络
    if ([CommonUtil existNetWork] == 0) {
        return;
    };

    NSURL *url = [[NSURL alloc] initWithString:AJAX_URL];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [SVProgressHUD show];
    [request setRequestMethod:@"POST"];
    [request setPostValue:EDIT_USER_ACTION              forKey:ACTION ];
    [request setPostValue:[CommonUtil getUserName]      forKey:FIRST_NAME];
    [request setPostValue:[CommonUtil getUserType]      forKey:ACCOUNT_TYPE];
   
    if (![self.textPwd.text isEqualToString:@""]) {
        [request setPostValue:self.textPwd.text             forKey:PASSWORD];
    }else{
        [SVProgressHUD showErrorWithStatus:@"请输入当前密码"];
        return;
    }
    
    if (![self.textChangePwd.text isEqualToString:self.textRePwd.text]) {
        [SVProgressHUD showErrorWithStatus:@"两次输入密码不一致"];
        return;
    }
    
    if ((![self.textChangePwd.text isEqualToString:@""])&&(![self.textRePwd.text isEqualToString:@""])) {
        [request setPostValue:self.textPwd.text             forKey:OLD_PASSWORD];
        [request setPostValue:self.textRePwd.text           forKey:NES_PASSWORD];
    }
    else{
        [request setPostValue:@""                           forKey:OLD_PASSWORD];
        [request setPostValue:@""                           forKey:NES_PASSWORD];
    }
    
    if ((![self.textPhone.text isEqualToString:@""])&&(![self.textPhoneCode.text isEqualToString:@""])) {
        [request setPostValue:self.textPhone.text           forKey:TELEPHONE];
        [request setPostValue:self.textPhoneCode.text       forKey:TELEPHONE_CAPTCHA];
    }
    else{
        [request setPostValue:@""                           forKey:TELEPHONE];
        [request setPostValue:@""                           forKey:TELEPHONE_CAPTCHA];
    }
    
    if ((![self.textEmail.text isEqualToString:@""])&&(![self.textEmailCode.text isEqualToString:@""])) {
        [request setPostValue:self.textEmail.text           forKey:EMAIL];
        [request setPostValue:self.textEmailCode.text       forKey:EMAIL_CAPTCHA];
    }
    else{
        [request setPostValue:@""                           forKey:EMAIL];
        [request setPostValue:@""                           forKey:EMAIL_CAPTCHA];
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:tempImagePath]) {
        [request setFile:tempImagePath                      forKey:LOCAL_FILE];
    }
//    else{
//        [request setFile:@""                                forKey:FILE];
//    }
    
    [request setCompletionBlock:^{
        [SVProgressHUD dismiss];
        NSString *jsonString = [request responseString];
        NSLog(@"response text >>  %@",jsonString);
        SBJsonParser *parser =[[SBJsonParser alloc] init];
        NSDictionary *dictionary = [parser objectWithString:jsonString];
        int state = [[dictionary objectForKey:@"state"]intValue];
        if (state == 1) {
            //提示登录成功
            
            [SVProgressHUD showSuccessWithStatus:[dictionary objectForKey:@"message"]];
            
            //回到上一个界面
            [self dismissViewControllerAnimated:YES completion:nil];
            [self.navigationController popToRootViewControllerAnimated:YES];
        }else if (state == 0) {
            //提示登陆失败
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

-(IBAction)getAPhoto:(id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

-(IBAction)cancel:(id)sender
{
    [self backAction];
}

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma -mark UIImagePickerController delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    chosenImage = info[UIImagePickerControllerEditedImage];
    //删除缓存文件
    if ([[NSFileManager defaultManager] fileExistsAtPath:tempImagePath]) {
        NSLog(@"the image is exist");
        NSFileManager *defaultManager;
        
        defaultManager = [NSFileManager defaultManager];
        NSError *error = [[NSError alloc] init];
        [defaultManager removeItemAtPath:tempImagePath error:&error];
        
    }
    [UIImagePNGRepresentation(chosenImage) writeToFile:[ NSTemporaryDirectory() stringByAppendingPathComponent:@"temp_image.png"] atomically:YES];
    
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:tempImagePath];
    
    if (fileExists) {
        NSLog(@"success");
    }else{
        NSLog(@"failed");
    }
    [self.btnImage setImage:chosenImage forState:UIControlStateNormal];
    [self.btnImage setImage:[UIImage imageNamed:@"Icon-80.png"] forState:UIControlStateNormal];
    [picker dismissViewControllerAnimated:YES completion:NULL];    
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}



#pragma -mark UI init
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

- (void)createSubView
{
    [self.myScrollView setContentSize:CGSizeMake(320, 650)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
