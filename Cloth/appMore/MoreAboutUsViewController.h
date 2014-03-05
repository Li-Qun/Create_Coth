//
//  MoreAboutUsViewController.h
//  Cloth
//
//  Created by ss4346 on 13-9-9.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "SBJsonParser.h"

@interface MoreAboutUsViewController : UIViewController
{
    NSDictionary *dictionary;
}

@property (strong,nonatomic) IBOutlet UILabel *lableTitle;
@property (strong,nonatomic) IBOutlet UILabel *lableContent;
@property (strong,nonatomic) IBOutlet UILabel *labelAdress;
@property (strong,nonatomic) IBOutlet UILabel *labelPhone;
@property (strong,nonatomic) IBOutlet UILabel *labelEmail;

@end
