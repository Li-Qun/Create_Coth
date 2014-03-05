//
//  WantPublishCell.h
//  Cloth
//
//  Created by ss4346 on 13-9-10.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"

@interface WantPublishCell : UITableViewCell

@property (strong,nonatomic) IBOutlet EGOImageView *head;
@property (strong,nonatomic) IBOutlet UILabel *title;
@property (strong,nonatomic) IBOutlet UILabel *material;
@property (strong,nonatomic) IBOutlet UILabel *price;
@property (strong,nonatomic) IBOutlet UILabel *favourate;

@end
