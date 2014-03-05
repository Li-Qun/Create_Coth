//
//  AppDelegate.m
//  Cloth
//
//  Created by ss4346 on 13-9-5.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//6B13C809-5FF6-4908-8533-2FE72A0AEACB

#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "SBJsonParser.h"
#import "APService.h"
#import "BMKMapManager.h"
#import "BMapKit.h"
#import <ShareSDK/ShareSDK.h>//添加
@implementation AppDelegate
{
//    BMKMapManager* _mapManager;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    
    //定位初始化
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    //创建线程的第一种方式
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(runThread) object:@"universe"];
    [thread start];
    

    
    [[UITabBar appearance] setSelectedImageTintColor:[UIColor whiteColor]];
    
    //设置tab bar icon 默认颜色
    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];


    //设置tab bar 文字选中效果
    NSDictionary *normalState =   @{ UITextAttributeTextColor : [UIColor whiteColor], UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetMake(0.0, 1.0)] };
    NSDictionary *selectedState = @{ UITextAttributeTextColor : [UIColor whiteColor], UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetMake(0.0, 1.0)] };
    [[UITabBarItem appearance] setTitleTextAttributes:normalState forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:selectedState forState:UIControlStateHighlighted];
    
    //设置导航栏颜色，无颜色渐变效果
    UIImage *image = [UIImage imageNamed:@"bg_nav"];
    [[UINavigationBar appearance] setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setTintColor:[CommonValue purpuleColor]];
    
    [Parse setApplicationId:@"GIk8Y50OyGSYaqEEzoMPzG4uYHgAGlDtwKF5q2iA"
                  clientKey:@"eH2xOCBA0LCSGVZ8AiGk6mA0yIknnXkYmA28Pmnx"];
    
    //参数为ShareSDK官网中添加应用后得到的AppKey
    [ShareSDK registerApp:@"a7823b99894"];
    
    //添加新浪微博应用
    [ShareSDK connectSinaWeiboWithAppKey:@"2173546047"
                               appSecret:@"344c4841c010cd29b68433c2b514b0bf"
                             redirectUri:@"http://www.fzdzsj.com/"];
    
    //添加腾讯微博应用
    [ShareSDK connectTencentWeiboWithAppKey:@"801404894"
                                  appSecret:@"e1dae8d2c070c26d276d8d773ff06319"
                                redirectUri:@"http://www.baidu.com"];
    
    // Required
    [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                   UIRemoteNotificationTypeSound |
                                                   UIRemoteNotificationTypeAlert)];
    // Required
    [APService setupWithOption:launchOptions];
    
    _mapManager = [[BMKMapManager alloc]init];
    // 如果要关注网络及授权验证事件，请设定     generalDelegate参数
    BOOL ret = [_mapManager start:@"D15bdb79d6c082849a4437c17b66fd1a"  generalDelegate:nil];
    if (!ret) {
        NSLog(@"manager start failed!");
    }else{
        NSLog(@"manager start success!");
    }

    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
        // app already launched
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        // This is the first launch ever
        [CommonUtil writeLocation:@"324"];
        [CommonUtil writeCity:@"海口市"];
        NSLog(@">>>>>%@",[CommonUtil getLocation]);
    }
    
    
   
    return YES;   
}

- (void)runThread
{
    
    [locationManager startUpdatingLocation];
}

// this delegate is called when the app successfully finds your current location
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    // this creates a MKReverseGeocoder to find a placemark using the found coordinates
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (error)
         {
             NSLog(@"failed with error: %@", error);
             return;
         }
         if(placemarks.count > 0)
         {
             
             NSString *city = @"";
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             
             if([placemark.addressDictionary objectForKey:@"SubAdministrativeArea"] != NULL)
                 city = [placemark.addressDictionary objectForKey:@"SubAdministrativeArea"];
             else if([placemark.addressDictionary objectForKey:@"City"] != NULL)
                 city = [placemark.addressDictionary objectForKey:@"City"];
             else if([placemark.addressDictionary objectForKey:@"Country"] != NULL)
                 city = [placemark.addressDictionary objectForKey:@"Country"];
             else
                city = @"海口市";
             
             [locationManager stopUpdatingLocation];
             [CommonUtil writeCity:city];
             
         }
     }];
}



- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // Required
    [APService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Required
    [APService handleRemoteNotification:userInfo];
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
   
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    
}

@end
