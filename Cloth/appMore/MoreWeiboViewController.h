//
//  MoreWeiboViewController.h
//  Cloth
//
//  Created by ss4346 on 13-9-9.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoreWeiboCell.h"

@interface MoreWeiboViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    NSArray *array;
    
@private
    AppDelegate *_appDelegate;

}

@property (strong,nonatomic) IBOutlet UITableView *tableView;

@end
