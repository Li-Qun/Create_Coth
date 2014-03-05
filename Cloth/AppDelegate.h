//
//  AppDelegate.h
//  Cloth
//
//  Created by ss4346 on 13-9-5.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <AddressBook/AddressBook.h>
#import <MapKit/MapKit.h>
#import "CommonUtil.h"
#import "CommonValue.h"
#import "BMKMapManager.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate>{
    BMKMapManager* _mapManager;
    
    CLLocationManager *locationManager;
}

@property (strong, nonatomic) UIWindow *window;

@end
