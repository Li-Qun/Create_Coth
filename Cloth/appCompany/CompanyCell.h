//
//  CompanyCell.h
//  Cloth
//
//  Created by ss4346 on 13-9-20.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"

@interface CompanyCell : UITableViewCell

@property (strong,nonatomic) IBOutlet EGOImageView *head;
@property (strong,nonatomic) IBOutlet UIImageView *level;
@property (strong,nonatomic) IBOutlet UILabel *title;
@property (strong,nonatomic) IBOutlet UILabel *content;
@property (strong,nonatomic) IBOutlet UILabel *date;

@end
