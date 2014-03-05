//
//  CompanyDetailViewController.m
//  Cloth
//
//  Created by ss4346 on 13-9-22.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import "CompanyDetailViewController.h"
#import <ShareSDK/ShareSDK.h>

@interface CompanyDetailViewController ()

@end

@implementation CompanyDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //初始化数据
    productList = [[NSMutableArray alloc] init];
    informationID = [self.dictionary objectForKey:@"id"];
    forIsFavorite = [self.dictionary objectForKey:@"is_fav"];
    
    //初始化UI
    [self createNavigationbarItem];
    [self createSlideView];
    [self createClearView];
    [self getList];
}

#pragma -mark custom method
- (void)getList
{
    //判断当前是否有网络
    if ([CommonUtil existNetWork] == 0) {
        return;
    };
    
    [SVProgressHUD show];
    NSURL *url = [[NSURL alloc] initWithString:AJAX_URL];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:RETRIEVE_PRODUCTS         forKey:ACTION];
    
    if ([CommonUtil getUserName] !=nil && [[CommonUtil getUserName] isEqualToString:@""]) {
        [request setPostValue:[CommonUtil getUserName]         forKey:FIRST_NAME];
        [request setPostValue:[CommonUtil getPassword]         forKey:PASSWORD];
        [request setPostValue:[CommonUtil getUserType]         forKey:ACCOUNT_TYPE];
        [request setPostValue:@"1"                             forKey:FOR_IS_FAV];
    }
//    [request setPostValue:[self.dictionary objectForKey:@"id"] forKey:MANUFACTURER_ID];
    [request setPostValue:@"18" forKey:MANUFACTURER_ID];
    
    [request setCompletionBlock:^{
        [SVProgressHUD dismiss];
        NSString *responseString = [request responseString];
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSArray *array = [parser objectWithString:responseString];
        [productList removeAllObjects];
        
        for (int i= 0; i < array.count; i++) {
            [productList addObject:[array objectAtIndex:i]];
        }
        
        [tableProduct reloadData];
        NSLog(@"response >>>>>> %@",responseString);
        
    }];
    [request setFailedBlock:^{
        [SVProgressHUD dismiss];
        NSString *responseString = [request responseString];
        NSLog(@">>>>>>%@",responseString);
    }];
    
    [request startAsynchronous];
}

-(void)addFavorite
{
    //判断当前是否有网络
    if ([CommonUtil existNetWork] == 0) {
        return;
    };
    
    //判断用户是否登陆
    if([CommonUtil getUserName] !=nil && [[CommonUtil getUserName] isEqualToString:@""]){
        
        [SVProgressHUD show];
        NSURL *url = [[NSURL alloc] initWithString:AJAX_URL];
        __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        [request setRequestMethod:@"POST"];
        
        //判断用户是否点击收藏
        if ([forIsFavorite isEqualToString:@"0"]){
            //点击收藏
            [request setPostValue:ADD_FAVORITE                     forKey:ACTION];
            [request setPostValue:[CommonUtil getUserName]         forKey:FIRST_NAME];
            [request setPostValue:[CommonUtil getPassword]         forKey:PASSWORD];
            [request setPostValue:[CommonUtil getUserType]         forKey:ACCOUNT_TYPE];
            [request setPostValue:informationID                    forKey:CONTENT_ID];
            [request setPostValue:@"3"                             forKey:CONTENT_TYPE];
            
            [request setCompletionBlock:^{
                [SVProgressHUD dismiss];
                SBJsonParser *parser = [[SBJsonParser alloc] init];
                NSDictionary *dictionary = [parser objectWithString:[request responseString]];
                if ([[dictionary objectForKey:@"state"]intValue] == 1) {
                    UIAlertView *myalert = [[UIAlertView alloc] initWithTitle:@"提示" message:[dictionary objectForKey:@"message"]  delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil,nil];
                    [myalert show];
                    forIsFavorite = @"1";
                }
                NSLog(@"LOG >>>> %@",[request responseString]);
                
                
            }];
            [request setFailedBlock:^{
                [SVProgressHUD dismiss];
                NSString *responseString = [request responseString];
                NSLog(@">>>>>>%@",responseString);
            }];
            
            [request startAsynchronous];
        }else{
            //取消收藏
            [request setPostValue:DELETE_FAVORITE                  forKey:ACTION];
            [request setPostValue:[CommonUtil getUserName]         forKey:FIRST_NAME];
            [request setPostValue:[CommonUtil getPassword]         forKey:PASSWORD];
            [request setPostValue:[CommonUtil getUserType]         forKey:ACCOUNT_TYPE];
            [request setPostValue:informationID                    forKey:CONTENT_ID];
            [request setPostValue:@"3"                             forKey:CONTENT_TYPE];
            [request setCompletionBlock:^{
                [SVProgressHUD dismiss];
                NSString *responseString = [request responseString];
                SBJsonParser *parser = [[SBJsonParser alloc] init];
                NSDictionary *dictionary = [parser objectWithString:[request responseString]];
                if ([[dictionary objectForKey:@"state"]intValue] == 1) {
                    UIAlertView *myalert = [[UIAlertView alloc] initWithTitle:@"提示" message:[dictionary objectForKey:@"message"]  delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil,nil];
                    [myalert show];
                    forIsFavorite = @"0";
                }
                NSLog(@"LOG >>>> %@",responseString);
                
                
            }];
            [request setFailedBlock:^{
                [SVProgressHUD dismiss];
                NSString *responseString = [request responseString];
                NSLog(@">>>>>>%@",responseString);
            }];
            
            [request startAsynchronous];
        }
    }else{
        UIAlertView *myalert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"收藏需要您登陆"  delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil,nil];
        [myalert show];
    }
}


- (void)addComments
{
    //判断当前是否有网络
    if ([CommonUtil existNetWork] == 0) {
        return;
    };
    
    if([[CommonUtil getUserName] isEqualToString:@""]){
        UIAlertView *myalert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"收藏需要您登陆"  delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil,nil];
        [myalert show];
        return;
    }
    
    if ([CommonUtil getUserName] != nil && [[CommonUtil getUserName] isEqualToString:@""]) {
        [SVProgressHUD show];
        NSURL *url = [[NSURL alloc] initWithString:AJAX_URL];
        __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        [request setRequestMethod:@"POST"];
        [request setPostValue:ADD_COMMENT         forKey:ACTION];
        
        [request setPostValue:[CommonUtil getUserName]         forKey:FIRST_NAME];
        [request setPostValue:[CommonUtil getPassword]         forKey:PASSWORD];
        [request setPostValue:[CommonUtil getUserType]         forKey:ACCOUNT_TYPE];
        [request setPostValue:informationID                    forKey:CONTENT_ID];
        [request setPostValue:@"3"                             forKey:CONTENT_TYPE];
        [request setPostValue:searchField.text                 forKey:TEXT];
        
        [request setCompletionBlock:^{
            [SVProgressHUD dismiss];
            SBJsonParser *parser = [[SBJsonParser alloc] init];
            NSDictionary *dictionary = [parser objectWithString:[request responseString]];
            if ([[dictionary objectForKey:@"state"]intValue] == 1) {
                UIAlertView *myalert = [[UIAlertView alloc] initWithTitle:@"提示" message:[dictionary objectForKey:@"message"]  delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil,nil];
                [myalert show];
                forIsFavorite = @"1";
            }
            NSLog(@"LOG >>>> %@",[request responseString]);
            
            
        }];
        
        [request setFailedBlock:^{
            [SVProgressHUD dismiss];
            NSString *responseString = [request responseString];
            NSLog(@">>>>>>%@",responseString);
        }];
        
        [request startAsynchronous];
    }else{
        UIAlertView *myalert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"使用该功能请先登录"  delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil,nil];
        [myalert show];
    }
    
    
}

- (void)btnIntroduceAction
{
    [myScrollView setContentOffset:CGPointMake(320*0, 0)];
    btnIntroduce.selected = YES;
    btnQualification.selected = NO;
    btnPoduct.selected = NO;
}

- (void)btnQualificationAction
{
    [myScrollView setContentOffset:CGPointMake(320*1, 0)];
    btnIntroduce.selected = NO;
    btnQualification.selected = YES;
    btnPoduct.selected = NO;
}

- (void)btnPoductAction
{
    [myScrollView setContentOffset:CGPointMake(320*2, 0)];
    btnIntroduce.selected = NO;
    btnQualification.selected = NO;
    btnPoduct.selected = YES;
}

- (void)btnActionShow
{
    if (currentPage == 0) {
        [self btnIntroduceAction];
    }
    else if (currentPage == 1){
        [self btnQualificationAction];
    }
    else if (currentPage ==2){
        [self btnPoductAction];
    }
}

-(void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)toTel
{
    NSString *str = [self.dictionary objectForKey:@"phone"];
    NSString *phoneNumber = [NSString stringWithFormat:@"tel://%@",str];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:phoneNumber]];
}

-(void)toAdr
{
    MapViewViewController *view = [MapViewViewController alloc];
    view.address = labelAdr.text;
    [self.navigationController pushViewController:view animated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)shareMore
{
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"ShareSDK"  ofType:@"jpg"];
    
    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:@"分享内容"
                                       defaultContent:@"默认分享内容，没内容时显示"
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:@"ShareSDK"
                                                  url:@"http://www.sharesdk.cn"
                                          description:@"这是一条测试信息"
                                            mediaType:SSPublishContentMediaTypeNews];
    
    [ShareSDK showShareActionSheet:nil
                         shareList:nil
                           content:publishContent
                     statusBarTips:YES
                       authOptions:nil
                      shareOptions: nil
                            result:^(ShareType type, SSPublishContentState state, id<ISSStatusInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                if (state == SSPublishContentStateSuccess)
                                {
                                    NSLog(@"分享成功");
                                }
                                else if (state == SSPublishContentStateFail)
                                {
                                    NSLog(@"分享失败,错误码:%d,错误描述:%@", [error errorCode], [error errorDescription]);
                                }
                            }];
}


#pragma -mark tableview delegate datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return productList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        
    //初始化cell部分
    static NSString *cellIdentifier = @"companyProductCell";
    CompanyProductCell *cell = (CompanyProductCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"CompanyProductCellNib" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    NSDictionary *dictionary = [productList objectAtIndex:indexPath.row];
    cell.labelTitle.text   = [dictionary objectForKey:@"name"];
    cell.labelContent.text = [dictionary objectForKey:@"description"];
    cell.labelPrice.text   = [dictionary objectForKey:@"price"];
    cell.labelFavorate.text= [dictionary objectForKey:@"fav_count"];
    [cell.imageHead setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_default"]]];
    NSString *imageUrl = [dictionary objectForKey:@"image_path"];
    NSLog(@"image url >>  %@",imageUrl);
    if (imageUrl != nil &&(![imageUrl isEqualToString:@""])) {
        NSURL *url = [[NSURL alloc] initWithString:COM_IMAGE(imageUrl)];
        [cell.imageHead setImageURL:url];
    }else{
        [cell.imageHead setImage:[UIImage imageNamed:@"icon_default"]];
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    int index =indexPath.row;
    ProductDetailViewController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"productDetailView"];
    view.moreInfor = [productList objectAtIndex:indexPath.row];
    view.contentId = @"3";
    [self.navigationController pushViewController:view animated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    return indexPath;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}
#pragma -mark UI init
- (void)createNavigationbarItem
{
    self.navigationItem.title = @"企业";
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, 50, 25);
    [leftButton setTitle:@"返回" forState:UIControlStateNormal];
    [leftButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13]];
    [leftButton setTitleColor:[UIColor colorWithRed:145/255.0 green:26/255.0 blue:152/255.0 alpha:1.0] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"btn_location"] forState:UIControlStateNormal];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] init];
    [leftItem setCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIButton *rightBtn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn1.frame = CGRectMake(0, 0, 25, 25);
    [rightBtn1 setImage:[UIImage imageNamed:@"icon_share"] forState:UIControlStateNormal];
    [rightBtn1.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13]];
    [rightBtn1 setTitleColor:[UIColor colorWithRed:145/255.0 green:26/255.0 blue:152/255.0 alpha:1.0] forState:UIControlStateNormal];
    [rightBtn1 addTarget:self action:@selector(shareMore) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn1 setBackgroundImage:[UIImage imageNamed:@"btn_location"] forState:UIControlStateNormal];
    
    UIButton *rightBtn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn2.frame = CGRectMake(30, 0, 25, 25);
    [rightBtn2 setImage:[UIImage imageNamed:@"icon_collect"] forState:UIControlStateNormal];
    [rightBtn2.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13]];
    [rightBtn2 setTitleColor:[UIColor colorWithRed:145/255.0 green:26/255.0 blue:152/255.0 alpha:1.0] forState:UIControlStateNormal];
    [rightBtn2 addTarget:self action:@selector(addFavorite) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn2 setBackgroundImage:[UIImage imageNamed:@"btn_location"] forState:UIControlStateNormal];
    
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 25)];
    [rightView addSubview:rightBtn1];
    [rightView addSubview:rightBtn2];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] init];
    [rightItem setCustomView:rightView];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)createClearView
{
    //设置背景
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background"]];
    
    //左上角图像
    imageHead = [[EGOImageView alloc] initWithFrame:CGRectMake(20, 10, 70, 70)];
    NSString *imageUrl = [self.dictionary objectForKey:@"image"];
    NSLog(@"image url >>  %@",imageUrl);
    if (imageUrl != nil &&(![imageUrl isEqualToString:@""])) {
        NSURL *url = [[NSURL alloc] initWithString:COM_IMAGE(imageUrl)];
        [imageHead setImageURL:url];
    }else{
        [imageHead setImage:[UIImage imageNamed:@"icon_default"]];
    }

    //标题label====================================================================
    labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(110, 15, 200, 20)];
    labelTitle.text = [self.dictionary objectForKey:@"name"];
    labelTitle.font = [UIFont fontWithName:@"Helvetica" size:18];
    labelTitle.backgroundColor = [UIColor clearColor];
    
    //地址label====================================================================
    UIView *viewAdr = [[UIView alloc] initWithFrame:CGRectMake(110, 40, 200, 20)];
    viewAdr.layer.borderWidth = 1;
    viewAdr.layer.borderColor = [[UIColor lightGrayColor]CGColor];
    UITapGestureRecognizer *toAdr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toAdr)];
    [viewAdr addGestureRecognizer:toAdr];
    
    UILabel *labelAdr1= [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
    labelAdr1.text = @"地址";
    labelAdr1.font = [UIFont fontWithName:@"Helvetica" size:12];
    labelAdr1.textColor = [UIColor lightGrayColor];
    labelAdr1.backgroundColor = [UIColor clearColor];
    [viewAdr addSubview:labelAdr1];

    labelAdr = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 130, 20)];
    labelAdr.text = [self.dictionary objectForKey:@"address"];
    labelAdr.textColor = [UIColor lightGrayColor];
    labelAdr.font = [UIFont fontWithName:@"Helvetica" size:12];
    labelAdr.backgroundColor = [UIColor clearColor];
    [viewAdr addSubview:labelAdr];
    
    UIButton *btnAdr = [UIButton buttonWithType:UIButtonTypeCustom];
    btnAdr.frame = CGRectMake(180, 2.5, 15, 15);
    [btnAdr setImage:[UIImage imageNamed:@"icon_adr"] forState:UIControlStateNormal ];
    [viewAdr addSubview:btnAdr];
    
    //电话label====================================================================
    UIView *viewTel = [[UIView alloc] initWithFrame:CGRectMake(110, 60, 200, 20)];
    viewTel.layer.borderWidth = 1;
    viewTel.layer.borderColor = [[UIColor lightGrayColor]CGColor];
    UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toTel)];
    [viewTel addGestureRecognizer:singleFingerTap];
    
    UILabel *labelTel1= [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 50, 20)];
    labelTel1.text = @"联系电话";
    labelTel1.textColor = [UIColor lightGrayColor];
    labelTel1.font = [UIFont fontWithName:@"Helvetica" size:12];
    labelTel1.backgroundColor = [UIColor clearColor];
    [viewTel addSubview:labelTel1];
    
    labelTel = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 130, 20)];
    labelTel.text = [self.dictionary objectForKey:@"phone"];
    labelTel.textColor = [UIColor lightGrayColor];
    labelTel.font = [UIFont fontWithName:@"Helvetica" size:12];
    labelTel.backgroundColor = [UIColor clearColor];
    [viewTel addSubview:labelTel];
    
    UIButton *btnTel = [UIButton buttonWithType:UIButtonTypeCustom];
    btnTel.frame = CGRectMake(180, 2.5, 15, 15);
    [btnTel setImage:[UIImage imageNamed:@"icon_tel"] forState:UIControlStateNormal ];
    [viewTel addSubview:btnTel];

    //创建3个button====================================================================
    btnIntroduce = [UIButton buttonWithType:UIButtonTypeCustom];
    btnIntroduce.frame = CGRectMake(0, 90, 106.6, 30);
    btnIntroduce.titleLabel.textColor = [UIColor blackColor];
    btnIntroduce.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    [btnIntroduce setBackgroundImage:[UIImage imageNamed:@"btn_com_selected"] forState:UIControlStateSelected];
    [btnIntroduce setBackgroundImage:[UIImage imageNamed:@"btn_com_normal"] forState:UIControlStateNormal];
    [btnIntroduce setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnIntroduce setTitle:@"企业简介" forState:UIControlStateNormal];
    [btnIntroduce addTarget:self action:@selector(btnIntroduceAction) forControlEvents:UIControlEventTouchUpInside];
    [self btnIntroduceAction ];
    
    btnQualification = [UIButton buttonWithType:UIButtonTypeCustom];
    btnQualification.frame = CGRectMake(106.6, 90, 106.6, 30);
    btnIntroduce.titleLabel.textColor = [UIColor blackColor];
    btnQualification.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    [btnQualification setBackgroundImage:[UIImage imageNamed:@"btn_com_selected"] forState:UIControlStateSelected];
    [btnQualification setBackgroundImage:[UIImage imageNamed:@"btn_com_normal"] forState:UIControlStateNormal];
    [btnQualification setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnQualification setTitle:@"企业资质" forState:UIControlStateNormal];
    [btnQualification addTarget:self action:@selector(btnQualificationAction) forControlEvents:UIControlEventTouchUpInside];
    
    btnPoduct = [UIButton buttonWithType:UIButtonTypeCustom];
    btnPoduct.frame = CGRectMake(213.2, 90, 106.6, 30);
    btnIntroduce.titleLabel.textColor = [UIColor blackColor];
    btnPoduct.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15];
    btnPoduct.titleLabel.textColor = [UIColor blackColor];
    [btnPoduct setBackgroundImage:[UIImage imageNamed:@"btn_com_selected"] forState:UIControlStateSelected];
    [btnPoduct setBackgroundImage:[UIImage imageNamed:@"btn_com_normal"] forState:UIControlStateNormal];
    [btnPoduct setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnPoduct setTitle:@"产品展示" forState:UIControlStateNormal];
    [btnPoduct addTarget:self action:@selector(btnPoductAction) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:imageHead];
    [self.view addSubview:labelTitle];
    [self.view addSubview:viewAdr];
    [self.view addSubview:viewTel];
    [self.view addSubview:btnIntroduce];
    [self.view addSubview:btnQualification];
    [self.view addSubview:btnPoduct];
}

- (void)createSlideView
{
    
    
//    int height = self.view.frame.size.height - 120 - 44;
    int height = [UIScreen mainScreen].bounds.size.height - [UIApplication sharedApplication].statusBarFrame.size.height - 120 -44;
    
    myScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 120, 320, height)];
    myScrollView.backgroundColor = [UIColor clearColor];
    myScrollView.contentSize = CGSizeMake(320*3, height);
    myScrollView.pagingEnabled = YES;
    myScrollView.clipsToBounds = NO;
    myScrollView.showsHorizontalScrollIndicator = NO;
    myScrollView.showsVerticalScrollIndicator = NO;
    myScrollView.scrollsToTop = NO;
    myScrollView.delegate = self;
    
    currentPage = 0;
    pageControl.numberOfPages = 3;
    pageControl.currentPage = 0;
    pageControl.backgroundColor = [UIColor clearColor];
    
    viewIntroduce = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:CGRectMake(320 * 0, 0, 320, height)];
    viewIntroduce.backgroundColor = [UIColor clearColor];
    
    textIntroduce = [[UITextView alloc] initWithFrame:CGRectMake(10, 20, 300, 200)];
    [textIntroduce setText:[self.dictionary objectForKey:@"m_info"]];
    [textIntroduce setTextColor:[UIColor blackColor]];
    [textIntroduce setEditable: NO];
    [textIntroduce setBackgroundColor:[UIColor clearColor]];
    [viewIntroduce addSubview:textIntroduce];
    
    
    UIView *searchView = [[UIView alloc] initWithFrame:CGRectMake(0, viewIntroduce.frame.size.height -40 , 320, 40)];
    searchView.backgroundColor = [CommonValue purpuleColor];
    searchField = [[UITextField alloc] initWithFrame:CGRectMake(5, 5, 285, 30)];
    searchField.placeholder = @"    输入评论";
    searchField.backgroundColor = [UIColor whiteColor];
    searchField.layer.cornerRadius = 15;
    searchField.delegate = self;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(295, 10, 20, 20);
    [btn addTarget:self action:@selector(addComments) forControlEvents:UIControlEventTouchUpInside];
    [btn setImage:[UIImage imageNamed:@"btn_add_comments"] forState:UIControlStateNormal];
    [searchView addSubview:btn];
    [searchView addSubview:searchField];
    [viewIntroduce addSubview:searchView];
    
    tableQualification = [[UIView alloc] initWithFrame:CGRectMake(320 * 1, 0, 320, height)];
    tableQualification.backgroundColor = [UIColor clearColor];
    
    imageQualification = [[EGOImageView alloc] initWithFrame:CGRectMake(10, 30, 300, 150)];
    [imageQualification setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_default"]]];
    
    NSString *imageUrl = [self.dictionary objectForKey:@"image_bg"];
    NSLog(@"image url >>  %@",imageUrl);
    if (imageUrl != nil &&(![imageUrl isEqualToString:@""])) {
        NSURL *url = [[NSURL alloc] initWithString:COM_IMAGE(imageUrl)];
        [imageQualification setImageURL:url];
    }else{
        [imageQualification setImage:[UIImage imageNamed:@"icon_default"]];
    }
    [tableQualification addSubview:imageQualification];

    tableProduct = [[UITableView alloc] initWithFrame:CGRectMake(320 * 2, 0, 320, height)];
    tableProduct.backgroundColor = [UIColor clearColor];
    [tableProduct setSeparatorColor:[CommonValue purpuleColor]];
    tableProduct.dataSource = self;
    tableProduct.delegate   = self;
    
    [myScrollView addSubview:viewIntroduce];
    [myScrollView addSubview:tableQualification];
    [myScrollView addSubview:tableProduct];
    [self.view addSubview:myScrollView];
}

#pragma mark textfield delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    return YES;
}

- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    return YES;
}
- (BOOL)textFieldShouldClear:(UITextField *)textField{
    return YES;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

//#pragma mark scrollview delegate
//// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    
//    CGFloat pageWidth = 320;
//    int page = floor((myScrollView.contentOffset.x - pageWidth / 3) / pageWidth) + 1;
//    
//    pageControl.currentPage = page;
//    currentPage = page;
//    pageControlUsed = NO;
//    [self btnActionShow];
//}
//
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    //暂不处理 - 其实左右滑动还有包含开始等等操作，这里不做介绍
//}

- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
{
    return YES;
}
- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
