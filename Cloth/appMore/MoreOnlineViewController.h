//
//  MoreOnlineViewController.h
//  Cloth
//
//  Created by ss4346 on 13-9-9.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "CommonUtil.h"
#import "SBJsonParser.h"
#import "SVProgressHUD.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@interface MoreOnlineViewController : UIViewController<UITextViewDelegate>

@property (strong,nonatomic) IBOutlet UITextView *advice;
@property (strong,nonatomic) IBOutlet UITextView *email;
@property (strong,nonatomic) IBOutlet UILabel *labelAdvice;
@property (strong,nonatomic) IBOutlet UILabel *labelEmail;

- (IBAction)submit:(id)sender;

@end
