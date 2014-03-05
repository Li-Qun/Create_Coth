//
//  MoreWeiboViewController.m
//  Cloth
//
//  Created by ss4346 on 13-9-9.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//
#import <Parse/Parse.h>
#import <ShareSDK/ShareSDK.h>
#import "MoreWeiboViewController.h"

@interface MoreWeiboViewController ()

@end

@implementation MoreWeiboViewController

@synthesize tableView = _tableView;

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
    array = [[NSArray alloc] initWithObjects:@"新浪微博", @"腾讯微博",nil];
    _appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    [self createNavigationItem];
    [self createSubView];
}

#pragma -mark button action

- (void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)shareToSinaWeiboAuth
{
    [ShareSDK authWithType:ShareTypeSinaWeibo                                              //需要授权的平台类型
                   options:nil                                          //授权选项，包括视图定制，自动授权
                    result:^(SSAuthState state, id<ICMErrorInfo> error) {       //授权返回后的回调方法
                        if (state == SSAuthStateSuccess)
                        {
                            NSLog(@"成功");
                            
                        }
                        else if (state == SSAuthStateFail)
                        {
                            NSLog(@"失败");
                        }
                    }];

    
}

- (void)shareToTecentWeiboAuth
{
    [ShareSDK authWithType:ShareTypeTencentWeibo                                              //需要授权的平台类型
                   options:nil                                          //授权选项，包括视图定制，自动授权
                    result:^(SSAuthState state, id<ICMErrorInfo> error) {       //授权返回后的回调方法
                        if (state == SSAuthStateSuccess)
                        {
                            NSLog(@"成功");
                            
                        }
                        else if (state == SSAuthStateFail)
                        {
                            NSLog(@"失败");
                        }
                    }];
}


#pragma -mark UI init
- (void)createSubView
{
    //设置背景
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
}

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


#pragma  -mark tableview datasource delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"moreWeiboCell";
    MoreWeiboCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if(indexPath.section == 0 ){
        cell.title.text = [array objectAtIndex:0];
    }
    
    if(indexPath.section == 1 ){
        cell.title.text = [array objectAtIndex:1];
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int index =indexPath.section;
    if (index == 0) {
        [self shareToSinaWeiboAuth];
    }else if(index == 1){
        [self shareToTecentWeiboAuth];
    }
    return indexPath;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
