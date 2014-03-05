//
//  CommentsViewController.h
//  Cloth
//
//  Created by ss4346 on 13-9-23.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentsCell.h"
#import "SBJsonParser.h"

@interface CommentsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray *totalList;
}

@property (strong,nonatomic) IBOutlet UILabel *labelTitle;
@property (strong,nonatomic) IBOutlet UILabel *labelContent;
@property (strong,nonatomic) IBOutlet UITableView *comentTable;

@property (strong,nonatomic) NSString *contentId;
@property (strong,nonatomic) NSString *contentType;

@end
