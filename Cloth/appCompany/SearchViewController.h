//
//  SearchViewController.h
//  Cloth
//
//  Created by ss4346 on 13-10-10.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonUtil.h"
#import "CompanyCell.h"
#import "CommonValue.h"
#import "SBJsonParser.h"
#import "PullingRefreshTableView.h"
#import "CompanyDetailViewController.h"

@interface SearchViewController : UIViewController<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate,PullingRefreshTableViewDelegate>
{
 
    UITextField *searchField;
    
    PullingRefreshTableView *myTableView;
    
    NSMutableArray *allList;
    NSInteger totalPage;
    NSInteger currentPage;

}

@end
