//
//  ProductDetailViewController.h
//  Cloth
//
//  Created by ss4346 on 13-9-23.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommonValue.h"
#import "EGOImageView.h"
#import "SBJsonParser.h"
#import "CommentsViewController.h"
#import "TPKeyboardAvoidingScrollView.h"

@interface ProductDetailViewController : UIViewController<UISearchBarDelegate>
{
    TPKeyboardAvoidingScrollView *rootView;
    
    EGOImageView *imageHead;
    UILabel *labelType;
    UILabel *labelPrice;
    UILabel *labelFavorate;
    UITextView *labelContent;
    UILabel *labelTelephone;
    UITextField *searchField;
    
    NSString *forIsFavorite;
    NSString *informationID;
}

@property (strong,nonatomic) NSDictionary *moreInfor;
@property (strong,nonatomic) NSString *contentId;

@end
