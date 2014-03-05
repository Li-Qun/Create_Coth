//
//  ChangePWDViewController.h
//  Cloth
//
//  Created by ss4346 on 13-10-13.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBJsonParser.h"

@interface ChangePWDViewController : UIViewController

@property (strong,nonatomic) IBOutlet UITextField *code;
@property (strong,nonatomic) IBOutlet UITextField *textNewPwd;
@property (strong,nonatomic) IBOutlet UITextField *textReNewPwd;

@property (strong,nonatomic) NSString *type;
@property (strong,nonatomic) NSString *infor;

-(IBAction)submit:(id)sender;

@end
