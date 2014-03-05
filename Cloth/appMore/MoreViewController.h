//
//  MoreViewController.h
//  Cloth
//
//  Created by ss4346 on 13-9-6.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoreCell.h"
#import "CommonUtil.h"
#import "MoreWeiboViewController.h"
#import "MoreOnlineViewController.h"
#import "MoreAboutUsViewController.h"
#import "MoreNotificationViewController.h"

@interface MoreViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>{
    NSArray *array;
    NSArray *images;
}

@property (strong,nonatomic) IBOutlet UITableView *tableView;

@end
