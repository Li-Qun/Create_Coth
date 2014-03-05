//
//  Cell.h
//  naivegrid
//
//  Created by Apirom Na Nakorn on 3/6/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyUIGridViewCell.h"
#import "EGOImageView.h"

@interface Cell : MyUIGridViewCell {

}

@property (nonatomic, retain) IBOutlet EGOImageView *thumbnail;
@property (nonatomic, retain) IBOutlet UILabel *label;

@end
