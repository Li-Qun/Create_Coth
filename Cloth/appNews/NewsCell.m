//
//  NewsCell.m
//  Cloth
//
//  Created by ss4346 on 13-9-13.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import "NewsCell.h"

@implementation NewsCell

@synthesize title = _title;
@synthesize head  = _head;
@synthesize date  = date;

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
