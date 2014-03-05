//
//  WantPublishCell.m
//  Cloth
//
//  Created by ss4346 on 13-9-10.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import "WantPublishCell.h"

@implementation WantPublishCell

@synthesize head      = _head;
@synthesize title     = _title;
@synthesize material  = _material;
@synthesize price     = _price;
@synthesize favourate = _favourate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
