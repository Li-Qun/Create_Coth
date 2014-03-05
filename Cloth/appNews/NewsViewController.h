//
//  NewsViewController.h
//  Cloth
//
//  Created by ss4346 on 13-9-12.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "NewsCell.h"
#import "CommonUtil.h"
#import "CommonValue.h"
#import "ASIFormDataRequest.h"
#import "PullingRefreshTableView.h"
#import "NewsDetailViewController.h"

@interface NewsViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,PullingRefreshTableViewDelegate>
{
    //UI组件
    UIScrollView *scrollTab;
    UIButton *submit;
    
    PullingRefreshTableView *mainTableView;
    
    //左右滑动部分
	UIPageControl *pageControl;
    int currentPage;
    BOOL pageControlUsed;
    
    //标题数据
    NSMutableArray * titielArray;
    NSInteger selectedTag;
    BOOL refreshing;
    
    NSMutableArray *newsList;
    NSMutableArray *topList;
    int totalPage;
    int idPage;
    
    UIView *rootView;
}
@end
