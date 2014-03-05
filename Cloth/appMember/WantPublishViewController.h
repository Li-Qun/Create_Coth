//
//  WantPublishViewController.h
//  Cloth
//
//  Created by ss4346 on 13-9-10.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "CommonValue.h"
#import "SBJsonParser.h"
#import "SVProgressHUD.h"
#import "SelectionCell.h"
#import "ASIHTTPRequest.h"
#import "BlockAlertView.h"
#import "WantPublishCell.h"
#import "ASIFormDataRequest.h"
#import "DateViewController.h"
#import "TableViewWithBlock.h"
#import "PullingRefreshTableView.h"
#import "ProductDetailViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "UITableView+DataSourceBlocks.h"

@class TableViewWithBlock;

@interface WantPublishViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIScrollViewDelegate,UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,PullingRefreshTableViewDelegate,ASIHTTPRequestDelegate>
{
    BOOL isOpened;
    //左右滑动部分
	UIPageControl *pageControl;
    int currentPage;
    BOOL pageControlUsed;
    
    //创建已发布信息 界面
    TPKeyboardAvoidingScrollView *didPublishView;
    UITextField *tfPrice;
    UITextField *tfTitle;
    UITextField *tfPhone;
    UITextView  *tfOther;
    
    UIButton *btnProvince;
    UIButton *btnCity;
    UIButton *btnBorough;
    UIButton *btnCat;
    
    TableViewWithBlock *provinceTB;
    TableViewWithBlock *cityTB;
    TableViewWithBlock *boroughTB;
    TableViewWithBlock *catTB;
    
    UIButton *addImage;
    
    //创建发布新信息 界面
    PullingRefreshTableView *doPublishView;
    
    //选择图片
    UIImage *chosenImage;
    NSString *tempImagePath;
    
    //数据列表
    NSMutableArray *totalList;
    NSMutableArray *provinceList;
    NSMutableArray *cityList;
    NSMutableArray *broughList;
    NSMutableArray *titielArray;
    
    NSString *broughId;
    NSString *type;
    
    //修改信息
    BOOL isChange;
    NSDictionary *tradeCell;
    
    int totalPage;
    int idPage;

}

@property (strong,nonatomic) IBOutlet UIButton *didPublish;
@property (strong,nonatomic) IBOutlet UIButton *doPublish;
@property (strong,nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong,nonatomic) NSString *index;



@end
