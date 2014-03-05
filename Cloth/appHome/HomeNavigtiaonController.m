//
//  HomeNavigtiaonController.m
//  Cloth
//
//  Created by ss4346 on 13-9-6.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import "HomeNavigtiaonController.h"


@interface HomeNavigtiaonController ()

@end

@implementation HomeNavigtiaonController

static CGFloat const CustomNavigationBarHeight = 74;

- (CGSize)sizeThatFits:(CGSize)size{
    size.width = 1024;
    size.height = CustomNavigationBarHeight;
    return size;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLayoutSubviews
{
    [[UINavigationBar appearance] setFrame:CGRectMake(0, 0, 320, 20)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //设置导航栏效果
    [self.navigationBar setShadowImage:[[UIImage alloc] init]];
    self.navigationBar.clipsToBounds = YES;
    [self.navigationBar setBarStyle:UIBarStyleBlackOpaque];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
