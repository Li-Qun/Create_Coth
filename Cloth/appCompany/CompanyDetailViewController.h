//
//  CompanyDetailViewController.h
//  Cloth
//
//  Created by ss4346 on 13-9-22.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "CommonValue.h"
#import "EGOImageView.h"
#import "CompanyProductCell.h"
#import "ProductDetailViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "MapViewViewController.h"

@interface CompanyDetailViewController : UIViewController<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,UITextFieldDelegate>
{
    EGOImageView *imageHead;
    UILabel *labelTitle;
    UILabel *labelAdr;
    UILabel *labelTel;
    
    UIButton *btnIntroduce;
    UIButton *btnQualification;
    UIButton *btnPoduct;
    
    UIScrollView *myScrollView;
    TPKeyboardAvoidingScrollView *viewIntroduce;
    UITextView *textIntroduce;
    UIView *tableQualification;
    EGOImageView *imageQualification;
    UITableView *tableProduct;
    UITextField *searchField;
    
    UIPageControl *pageControl;
    int currentPage;
    BOOL pageControlUsed;
    NSString *forIsFavorite;
    NSString *informationID;
    
    NSMutableArray *productList;
}

@property (strong,nonatomic) NSDictionary *dictionary;

@end
