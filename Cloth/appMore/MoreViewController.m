//
//  MoreViewController.m
//  Cloth
//
//  Created by ss4346 on 13-9-6.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import "MoreViewController.h"

@interface MoreViewController ()

@end

@implementation MoreViewController

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
    array  = [[NSArray alloc] initWithObjects:@"关于我们", @"微博设置", @"在线反馈", @"通知消息",nil];
    images = [[NSArray alloc] initWithObjects:@"more_aboutus", @"more_weibo", @"more_online", @"more_mess", nil];
    
    //设置背景
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self createNavigationBarItem];
}

#pragma -mark tableview delegate datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"moreCell";
    MoreCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.title.text = [array objectAtIndex: indexPath.section];
    cell.image.image = [UIImage imageNamed:[images objectAtIndex:indexPath.section]];

    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger row = [indexPath row];
    NSLog(@"will select row is %d  section is %d",row,indexPath.section);
    MoreAboutUsViewController *aboutUs      = [self.storyboard instantiateViewControllerWithIdentifier:@"moreAboutMe"];
    MoreWeiboViewController   *weibo        = [self.storyboard instantiateViewControllerWithIdentifier:@"moreWeibo"];
    MoreWeiboViewController   *online       = [self.storyboard instantiateViewControllerWithIdentifier:@"moreOnline"];
    MoreWeiboViewController   *notification = [self.storyboard instantiateViewControllerWithIdentifier:@"moreNotification"];
    
    switch (indexPath.section) {
        case 0:
            [self.navigationController pushViewController:aboutUs animated:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case 1:
            [self.navigationController pushViewController:weibo animated:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case 2:
            [self.navigationController pushViewController:online animated:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        case 3:
            [self.navigationController pushViewController:notification animated:YES];
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
    }

    return indexPath;
}

#pragma -mark ui init
-(void)createNavigationBarItem
{
    [CommonUtil createNavigationItem:self text:@"更多"];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] init];
    self.tabBarController.navigationItem.leftBarButtonItem = leftItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
