//
//  NewsDetailViewController.h
//  Cloth
//
//  Created by ss4346 on 13-9-22.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonUtil.h"
#import "SBJsonParser.h"
#import "SVProgressHUD.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "TPKeyboardAvoidingScrollView.h"

@interface NewsDetailViewController : UIViewController <UIWebViewDelegate,UISearchBarDelegate>
{
    UIWebView *webView;
    UISearchBar *mySearchBar;
    UITextField *searchField;
    
    UIButton *favorate;
    NSString *forIsFavorite;
    
    UILabel *lableTittle;
    UILabel *lableContent;
}

@property (strong,nonatomic) NSDictionary *dictionaryData;
@property (strong,nonatomic) NSString *informationID;
@property (strong,nonatomic) NSString *strTitle;
@property (strong,nonatomic) NSString *strDate;

@end
