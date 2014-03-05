//
//  NewsDetailViewController.m
//  Cloth
//
//  Created by ss4346 on 13-9-22.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import "NewsDetailViewController.h"
#import <ShareSDK/ShareSDK.h>

@interface NewsDetailViewController ()

@end

@implementation NewsDetailViewController

@synthesize dictionaryData = _dictionaryData;

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
    
    [self createNavigationBarItem];
    [self createClearView];
    [self getDetailInfor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [mySearchBar resignFirstResponder];
}

#pragma -mark custom method
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
    [request setPostValue:self.informationID                     forKey:CONTENT_ID];
    [request setPostValue:@"4"                             forKey:CONTENT_TYPE];
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

/**
 *添加收藏
 */
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
            [request setPostValue:self.informationID               forKey:CONTENT_ID];
            [request setPostValue:@"4"                             forKey:CONTENT_TYPE];
            
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
            [request setPostValue:self.informationID               forKey:CONTENT_ID];
            [request setPostValue:@"4"                             forKey:CONTENT_TYPE];
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
}


- (void)getDetailInfor
{
    
    //判断当前是否有网络
    if ([CommonUtil existNetWork] == 0) {
        return;
    };
    
    [SVProgressHUD show];
    NSURL *url = [[NSURL alloc] initWithString:AJAX_URL];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setRequestMethod:@"POST"];
    [request setPostValue:RETRIEVE_INFORMATION                 forKey:ACTION];
    
    if([[CommonUtil getUserName] isEqualToString:@""]){
        [request setPostValue:[CommonUtil getUserName]         forKey:FIRST_NAME];
        [request setPostValue:[CommonUtil getPassword]         forKey:PASSWORD];
        [request setPostValue:[CommonUtil getUserType]         forKey:ACCOUNT_TYPE];
        [request setPostValue:@"1"                             forKey:FOR_IS_FAV];
    }
    [request setPostValue:self.informationID                   forKey:INFORMATION_ID];
    
    [request setCompletionBlock:^{
        [SVProgressHUD dismiss];
        NSString *responseString = [request responseString];
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        self.dictionaryData = [parser objectWithString:responseString];
        NSString *htmlString = [self.dictionaryData objectForKey:@"description"];
        [webView loadHTMLString:htmlString baseURL:nil];
        
        forIsFavorite = [self.dictionaryData objectForKey:@"is_fav"];
        if ([forIsFavorite isEqualToString:@"0"]) {
            [favorate setImage:[UIImage imageNamed:@"ic_favorate"] forState:UIControlStateNormal];
        }
    }];
    [request setFailedBlock:^{
        [SVProgressHUD dismiss];
        NSString *responseString = [request responseString];
        NSLog(@">>>>>>%@",responseString);
    }];
    
    [request startAsynchronous];
}

#pragma -mark UI init
-(void)createNavigationBarItem
{
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
    
    [self.navigationItem setTitle:@"详情"];
}


- (void)createClearView
{
    TPKeyboardAvoidingScrollView *rootView = [[TPKeyboardAvoidingScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height-40)];
    
    
    int height = self.view.frame.size.height - 40- 44;
    
    lableTittle = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 320, 25)];
    [lableTittle setTextAlignment:NSTextAlignmentCenter];
    [lableTittle setFont:[UIFont fontWithName:@"Helvetica-Bold" size:18]];
    [lableTittle setText:self.strTitle];
    
    lableContent = [[UILabel alloc] initWithFrame:CGRectMake(0, 40, 320, 25)];
    [lableContent setTextAlignment:NSTextAlignmentCenter];
    [lableContent setText:self.strDate];
    
    UILabel *labelLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 66, 320, 2)];
    [labelLine setBackgroundColor:[CommonValue purpuleColor]];
    
    //创建WebView
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 70, 320, height - 70)];

    //创建搜索栏
    
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
    
    favorate =[UIButton buttonWithType:UIButtonTypeCustom];
    favorate.frame = CGRectMake(285, height+5, 30, 30);
    favorate.backgroundColor = [UIColor clearColor];
    [favorate setImage:[UIImage imageNamed:@"ic_favorate"] forState:UIControlStateNormal];
    [favorate addTarget:self action:@selector(addFavorite) forControlEvents:UIControlEventTouchUpInside];
    
    
    [rootView addSubview:lableTittle];
    [rootView addSubview:lableContent];
    [rootView addSubview:labelLine];
    [rootView addSubview:webView];
    [rootView addSubview:searchView];
    [rootView addSubview:share];
    [rootView addSubview:favorate];
    [self.view addSubview:rootView];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"search bar search button clicked and text is>>>>>>> %@",searchField.text);
    [mySearchBar resignFirstResponder];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    //点击空处，取消键盘
    [mySearchBar resignFirstResponder];
    [super touchesEnded:touches withEvent:event];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
