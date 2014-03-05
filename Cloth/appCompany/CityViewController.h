//
//  CityViewController.h
//  Cloth
//
//  Created by ss4346 on 13-9-27.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <AddressBook/AddressBook.h>
#import <MapKit/MapKit.h>
#import <UIKit/UIKit.h>
#import "Cell1.h"
#import "Cell2.h"
#import "SBJsonParser.h"

@interface CityViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    UIButton *cityLabel;
    UITableView *myTableView;
    
    NSMutableArray *provinceList;
    NSMutableArray *cityList;
    NSString *strCity;
        
}

@property (assign)BOOL isOpen;
@property (nonatomic,retain)NSIndexPath *selectIndex;

@end
