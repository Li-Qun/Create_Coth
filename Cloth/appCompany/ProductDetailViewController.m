//
//  ProductDetailViewController.m
//  Cloth
//
//  Created by ss4346 on 13-9-23.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import "ProductDetailViewController.h"
#import <ShareSDK/ShareSDK.h>

@interface ProductDetailViewController ()

@end

@implementation ProductDetailViewController

@synthesize moreInfor = _moreInfor;
@synthesize contentId = _contentId;

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
    informationID = [self.moreInfor objectForKey:@"id"];
    forIsFavorite = [self.moreInfor objectForKey:@"is_fav"];
    
	[self createNavigationbarItem];
    [self createMainView];
    [self addData];
}

#pragma -mark cusotm method
-(void)shareMore
{
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"ShareSDK"  ofType:@"jpg"];
    
    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:@"服装定制"
                                       defaultContent:@"服装定制"
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:@"服装定制"
                                                  url:@"服装定制"
                                          description:@"服装定制"
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

- (void)addComments
{
    //判断当前是否有网络
    if ([CommonUtil existNetWork] == 0) {
        return;
    };
    
    if([[CommonUtil getUserName] isEqualToString:@""] || [CommonUtil getUserName] == nil){
        UIAlertView *myalert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"评论功能需要登陆"  delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil,nil];
        [myalert show];
        return;
    }
    
    [SVProgressHUD show];
    NSURL *url = [[NSURL alloc] initWithString:AJAX_URL];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:ADD_COMMENT         forKey:ACTION];
    [request setPostValue:[CommonUtil getUserName]         forKey:FIRST_NAME];
    [request setPostValue:[CommonUtil getPassword]         forKey:PASSWORD];
    [request setPostValue:[CommonUtil getUserType]         forKey:ACCOUNT_TYPE];
    [request setPostValue:informationID                    forKey:CONTENT_ID];
    [request setPostValue:self.contentId                   forKey:CONTENT_TYPE];
    [request setPostValue:searchField.text                 forKey:TEXT];
    
    [request setCompletionBlock:^{
        [SVProgressHUD dismiss];
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSDictionary *dictionary = [parser objectWithString:[request responseString]];
        if ([[dictionary objectForKey:@"state"]intValue] == 1) {
            UIAlertView *myalert = [[UIAlertView alloc] initWithTitle:@"提示" message:[dictionary objectForKey:@"message"]  delegate:self cancelButtonTitle:@"确认" otherButtonTitles:nil,nil];
            [myalert show];
        }
        NSLog(@"LOG >>>> %@",[request responseString]);
        
        
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
    if(![[CommonUtil getUserName] isEqualToString:@""] && [CommonUtil getUserName] != nil){
        
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
            [request setPostValue:self.contentId                   forKey:CONTENT_TYPE];
            
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

-(void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)viewComments
{
    //commentsView
    CommentsViewController *view = [self.storyboard instantiateViewControllerWithIdentifier:@"commentsView"];
    view.contentId = informationID;
    view.contentType = self.contentId;
    [self.navigationController pushViewController:view animated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma -mark UI init
- (void)addData
{
    labelType.text      = [self.moreInfor objectForKey:@"title"];
    labelPrice.text     = [self.moreInfor objectForKey:@"price"];
    labelContent.text   = [self.moreInfor objectForKey:@"description"];
    labelFavorate.text  = [self.moreInfor objectForKey:@"fav_count"];
    labelTelephone.text = [self.moreInfor objectForKey:@"telephone"];

    //设置头像
    NSString *path = [self.moreInfor objectForKey:@"image_path"];
    if (path != nil &&(![path isEqualToString:@""])) {
        NSString *imageUrl = IMAGE_TEMP(path);
        NSLog(@"product detail image url >>>>>>> %@",imageUrl);
        NSURL *url = [[NSURL alloc] initWithString:imageUrl];
        [imageHead setImageURL:url];
    }else{
        [imageHead setImage:[UIImage imageNamed:@"icon_default"]];
    }
}

- (void)createMainView
{
    rootView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:self.view.frame];
    
    imageHead =  [[EGOImageView alloc]initWithFrame:CGRectMake(20, 10, 280, 150)];
    imageHead.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"icon_default"]];
    
    labelType = [[UILabel alloc]initWithFrame:CGRectMake(15, 170, 280, 20)];
    labelType.textAlignment = NSTextAlignmentCenter;
    
    UILabel *labelPrice1 = [[UILabel alloc] initWithFrame:CGRectMake(15, 195, 50, 20)];
    labelPrice1.text = @"价格:";
    
    labelPrice = [[UILabel alloc] initWithFrame:CGRectMake(75, 195, 230, 20)];
    
    UILabel *labelFavorate1 = [[UILabel alloc] initWithFrame:CGRectMake(15, 220, 50, 20)];
    labelFavorate1.text = @"收藏:";
    
    labelFavorate = [[UILabel alloc] initWithFrame:CGRectMake(75, 220, 230, 20)];

    UILabel *labelTelephone1 = [[UILabel alloc] initWithFrame:CGRectMake(15, 245, 230, 20)];
    labelTelephone1.text = @"电话:";
    
    labelTelephone = [[UILabel alloc] initWithFrame:CGRectMake(75, 245, 230, 20)];
    
    labelContent = [[UITextView alloc] initWithFrame:CGRectMake(15, 270, 290, 100)];
    [labelContent setFont:[UIFont fontWithName:@"Helvetica" size:16]];
    [labelContent setEditable:NO];
    
    //创建搜索栏
    int height = rootView.frame.size.height -103;

    searchField = [[UITextField alloc] initWithFrame:CGRectMake(5, 5, 210, 30)];
    searchField.layer.cornerRadius = 15;
    searchField.backgroundColor = [UIColor whiteColor];
    
    UIView *searchView = [[UIView alloc]initWithFrame:CGRectMake(0, height, 320, 40)];
    searchView.backgroundColor = [UIColor lightGrayColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(220, 10, 20, 20);
    [btn addTarget:self action:@selector(addComments) forControlEvents:UIControlEventTouchUpInside];
    [btn setImage:[UIImage imageNamed:@"btn_add_comments"] forState:UIControlStateNormal];
    [searchView addSubview:btn];
    [searchView addSubview:searchField];
    
    UIButton *share =[UIButton buttonWithType:UIButtonTypeCustom];
    share.frame = CGRectMake(250, height+5, 30, 30);
    share.backgroundColor = [UIColor clearColor];
    [share setImage:[UIImage imageNamed:@"ic_share"] forState:UIControlStateNormal];
    [share addTarget:self action:@selector(shareMore) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *favorate =[UIButton buttonWithType:UIButtonTypeCustom];
    favorate.frame = CGRectMake(285, height+5, 30, 30);
    favorate.backgroundColor = [UIColor clearColor];
    [favorate setImage:[UIImage imageNamed:@"ic_favorate"] forState:UIControlStateNormal];
    [favorate addTarget:self action:@selector(addFavorite) forControlEvents:UIControlEventTouchUpInside];
    
    [rootView addSubview:imageHead];
    [rootView addSubview:labelType];
    [rootView addSubview:labelPrice1];
    [rootView addSubview:labelPrice];
    [rootView addSubview:labelFavorate1];
    [rootView addSubview:labelFavorate];
    [rootView addSubview:labelContent];
    [rootView addSubview:labelTelephone1];
    [rootView addSubview:labelTelephone];
    [rootView addSubview:searchView];
    [rootView addSubview:share];
    [rootView addSubview:favorate];
    [self.view addSubview:rootView];
    
}

- (void)createNavigationbarItem
{
    self.navigationItem.title = @"产品详情";
    
    //    UIBarButtonItem *anotherButton = [[UIBarButtonItem alloc] initWithTitle:@"查看评价" style:UIBarButtonItemStylePlain target:self action:@selector(viewComments)];
    //    self.navigationItem.rightBarButtonItem = anotherButton;
    ////
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
    
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0, 0, 50, 25);
    [rightButton setTitle:@"评价" forState:UIControlStateNormal];
    [rightButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13]];
    [rightButton setTitleColor:[UIColor colorWithRed:145/255.0 green:26/255.0 blue:152/255.0 alpha:1.0] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(viewComments) forControlEvents:UIControlEventTouchUpInside];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"btn_location"] forState:UIControlStateNormal];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] init];
    [rightItem setCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightItem;
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
