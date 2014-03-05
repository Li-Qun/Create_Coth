//
//  SupplyDemandViewController.h
//  Cloth
//
//  Created by ss4346 on 13-9-14.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonValue.h"
#import "CommonUtil.h"
#import "CommonValue.h"
#import "SBJsonParser.h"
#import "SelectionCell.h"
#import "SupplayDemandCell.h"
#import "ASIFormDataRequest.h"
#import "TableViewWithBlock.h"
#import "PullingRefreshTableView.h"
#import "ProductDetailViewController.h"

@interface SupplyDemandViewController : UIViewController<UISearchBarDelegate,UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,PullingRefreshTableViewDelegate>
{
    //UI组件
    UIScrollView *scrollTab;
    UIButton *submit;
    UISearchBar *mySearchBar;
    UITextField *searchField;
    UIScrollView *myScrollView;
    UIButton *titleButton1;
    UIButton *titleButton2;
    TableViewWithBlock *titleTB;

    //左右滑动部分
	UIPageControl *pageControl;
    int currentPage;
    BOOL pageControlUsed;
    BOOL isOpened;
    
    //标题数据
    NSArray * titielArray;
    NSInteger selectedTag;
    NSInteger supplyDemandTag;
    
    NSMutableArray *totalList;
    NSMutableArray *topList;
    NSMutableArray *broughList;
    NSString *areaId;
    int totalPage;
    int idPage;
}

@end
