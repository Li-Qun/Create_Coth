//
//  CompanyViewController.h
//  Cloth
//
//  Created by ss4346 on 13-9-6.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "CommonUtil.h"
#import "CommonValue.h"
#import "CompanyCell.h"
#import "SelectionCell.h"
#import "SGFocusImageItem.h"
#import "SGFocusImageFrame.h"
#import "TableViewWithBlock.h"
#import "CityViewController.h"
#import "SearchViewController.h"
#import "PullingRefreshTableView.h"
#import "CompanyDetailViewController.h"


@interface CompanyViewController : UIViewController<UISearchBarDelegate,UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate,UITextFieldDelegate,SGFocusImageFrameDelegate,PullingRefreshTableViewDelegate>
{
    //UI组件
    UIScrollView *scrollTab;
    UIButton *submit;
    UIScrollView *myScrollView;
    UISearchBar *mySearchBar;
    UITextField *searchField;
    TableViewWithBlock *titleTB;
    
    //左右滑动部分
	UIPageControl *pageControl;
    int currentPage;
    int totalPage;
    int idPage;
    
    BOOL pageControlUsed;
    BOOL isOpened;
    NSString *areaId;
    
    //标题数据
    NSArray * titielArray;
    NSInteger selectedTag;
    
    NSMutableArray *advList;
    NSMutableArray *topList;
    NSMutableArray *allList;
    NSMutableArray *broughList;
    
    
}
@end
