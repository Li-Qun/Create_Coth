//
//  HomeTabBarController.m
//  Cloth
//
//  Created by ss4346 on 13-9-5.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import "HomeTabBarController.h"

@interface HomeTabBarController ()

@end

@implementation HomeTabBarController

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
    //设置底部选项卡颜色
    [self.tabBar setBackgroundImage:[UIImage imageNamed:@"bg_btm"]];
    
    [self.tabBar setTranslucent:NO];
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
