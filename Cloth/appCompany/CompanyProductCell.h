//
//  CompanyProductCell.h
//  Cloth
//
//  Created by ss4346 on 13-9-23.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"

@interface CompanyProductCell : UITableViewCell

@property (strong,nonatomic) IBOutlet EGOImageView  *imageHead;
@property (strong,nonatomic) IBOutlet UILabel *labelTitle;
@property (strong,nonatomic) IBOutlet UILabel *labelContent;
@property (strong,nonatomic) IBOutlet UILabel *labelPrice;
@property (strong,nonatomic) IBOutlet UILabel *labelFavorate;

@end
