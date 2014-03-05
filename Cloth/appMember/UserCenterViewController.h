//
//  UserCenterViewController.h
//  Cloth
//
//  Created by ss4346 on 13-9-9.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cell.h"
#import "CommonUtil.h"
#import "MyUIGridView.h"
#import "FavorateCell.h"
#import "EGOImageView.h"
#import "CollapseClick.h"
#import "ASIHTTPRequest.h"
#import "UserCenterCell.h"
#import "ASIFormDataRequest.h"
#import "MyUIGridViewDelegate.h"
#import "LoginViewController.h"
#import "WantPublishViewController.h"
#import "ProductDetailViewController.h"

@interface UserCenterViewController : UIViewController<UIActionSheetDelegate,CollapseClickDelegate,ASIHTTPRequestDelegate,MyUIGridViewDelegate>{;
    NSArray *array;
    //用作点击按钮 图片的显示
    UIView *viewImage;
    
    MyUIGridView *newsGrid;
    MyUIGridView *supplyGrid;
    MyUIGridView *companyGrid;
    MyUIGridView *demandGrid;
    MyUIGridView *productGrid;
    
    NSMutableArray *newsArray;
    NSMutableArray *supplyArray;
    NSMutableArray *companyArray;
    NSMutableArray *demandArray;
    NSMutableArray *productArray;
    NSThread *thread;
}

@property (strong,nonatomic) IBOutlet EGOImageView *imageHead;
@property (strong,nonatomic) IBOutlet UILabel *textName;
@property (strong,nonatomic) IBOutlet UILabel *textLevel;
@property (strong,nonatomic) IBOutlet UILabel *totalCredit;
@property (strong,nonatomic) IBOutlet UILabel *costCredit;
@property (strong,nonatomic) IBOutlet UILabel *surplusCredit;

@property (strong,nonatomic) IBOutlet CollapseClick *collapseClickView;

@end
