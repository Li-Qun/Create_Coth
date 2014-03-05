//
//  NewsCell.h
//  Cloth
//
//  Created by ss4346 on 13-9-13.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"

@interface NewsCell : UITableViewCell

@property (strong,nonatomic) IBOutlet UILabel *title;
@property (strong,nonatomic) IBOutlet UILabel *date;
@property (strong,nonatomic) IBOutlet EGOImageView *head;

@end
