//
//  DateViewController.h
//  Cloth
//
//  Created by ss4346 on 13-10-14.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SBJsonParser.h"

@interface DateViewController : UIViewController<UITextFieldDelegate>
{
    UIDatePicker *myDatePicker;
    UIView *datePickerView;
    int flag;
}

@property (strong,nonatomic) IBOutlet UITextField *startTime;
@property (strong,nonatomic) IBOutlet UITextField *endTime;

@property (strong,nonatomic) NSString *index;
@property (strong,nonatomic) NSDictionary *tradeCell;

-(IBAction)submit:(id)sender;

@end
