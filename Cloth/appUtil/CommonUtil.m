//
//  CommonUtil.m
//  Cloth
//
//  Created by ss4346 on 13-9-22.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import "CommonUtil.h"
#import "SBJsonParser.h"
#import "Reachability.h"

#define SEVER_URL @"http://42.96.192.186/f/test.html"

@implementation CommonUtil

+(void) createNavigationItem:(UIViewController *) view text:(NSString *)string
{
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 170, 35)];
    title.textColor = [UIColor whiteColor];
    title.backgroundColor = [UIColor clearColor];
    title.text = string;
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont fontWithName:@"Helvetica-Bold" size:19];
    view.tabBarController.navigationItem.titleView = title;
}

+(NSMutableDictionary *)readPlist
{
    NSString *filePath = [self dataFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSMutableDictionary *tableDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
        return tableDictionary;
    } else {
        NSMutableDictionary *pollHistory = [[NSMutableDictionary alloc] init];
        return pollHistory;
    }
}

+(void)writeDataToPlist:(NSString *)key value:(NSString *)value;
{

    NSString *filePath= [self dataProvinceFilePath];
    
    NSMutableDictionary *history = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSMutableDictionary *tableDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
        history = tableDictionary;
    } else {
        NSMutableDictionary *pollHistory = [[NSMutableDictionary alloc] init];
        history = pollHistory;
    }
    
    if (((![key isKindOfClass:[NSNull class]]) && ![key isEqualToString:@""] && key != nil)&&((![value isKindOfClass:[NSNull class]]) && ![value isEqualToString:@""] && value != nil)) {
        [history setValue:value forKey:key];
    }
    [history writeToFile:filePath atomically:YES];
    
}

+(NSMutableArray *)getPlistValue
{
    NSString *filePath= [self dataProvinceFilePath];
    
    NSMutableDictionary *history = nil;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        NSMutableDictionary *tableDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
        history = tableDictionary;
    } else {
        NSMutableDictionary *pollHistory = [[NSMutableDictionary alloc] init];
        history = pollHistory;
    }
    
    NSString *string = [history objectForKey:@"province"];
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSMutableArray *array = [parser objectWithString:string];
    return array;

}

+(void)writePlist:(NSString *)userName  password:(NSString *)password userType:(NSString *)userType totalCredit:(NSString *)totalCredit costCredit:(NSString *)costCredit imagePath:(NSString *)imagePath 
{
    NSMutableDictionary *history = [CommonUtil readPlist];
    
    if (![userName isKindOfClass:[NSNull class]] && userName != nil){
        [history setValue:userName    forKey:@"username"];
    }
    
    if (![password isKindOfClass:[NSNull class]] && password != nil){
        [history setValue:password       forKey:@"password"];
    }
    
    if (![userType isKindOfClass:[NSNull class]] && userType != nil){
        [history setValue:userType       forKey:@"usertype"];
    }
    
    if (![totalCredit isKindOfClass:[NSNull class]] && totalCredit != nil){
        [history setValue:totalCredit       forKey:@"totalCredit"];
    }
    
    if (![costCredit isKindOfClass:[NSNull class]] && costCredit != nil){
        [history setValue:costCredit       forKey:@"costCredit"];
    }
    
    if (![imagePath isKindOfClass:[NSNull class]] && imagePath != nil){
        [history setValue:imagePath       forKey:@"imagePath"];
    }
    
    [history writeToFile:[CommonUtil dataFilePath] atomically:YES];
}

+(void)writeLocation:(NSString *)location
{
    NSMutableDictionary *history = [CommonUtil readPlist];
    
    if (![location isKindOfClass:[NSNull class]] && location != nil){
        [history setValue:location    forKey:@"location"];
    }
    
    [history writeToFile:[CommonUtil dataFilePath] atomically:YES];
}

+(void)writeCity:(NSString *)city
{
    NSMutableDictionary *history = [CommonUtil readPlist];
    
    if (![city isKindOfClass:[NSNull class]] && city != nil){
        [history setValue:city    forKey:@"city"];
    }
    
    [history writeToFile:[CommonUtil dataFilePath] atomically:YES];
}

+(NSString *)dataProvinceFilePath
{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask , YES);
    NSString *documentDirectory =[path objectAtIndex:0];
    return [documentDirectory stringByAppendingPathComponent:@"province.plist"];
}

+(NSString *)dataFilePath
{
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask , YES);
    NSString *documentDirectory =[path objectAtIndex:0];
    return  [documentDirectory stringByAppendingPathComponent:@"user.plist"];
}

+(NSString *)getUserType
{
    NSMutableDictionary *pollHistory = [self readPlist];
    NSString *name = [pollHistory objectForKey:@"usertype"];
    return name;
}

+(NSString *)getUserName
{
    NSMutableDictionary *pollHistory = [self readPlist];
    NSString *name = [pollHistory objectForKey:@"username"];
    return name;
}

+(NSString *)getPassword
{
    NSMutableDictionary *pollHistory = [self readPlist];
    NSString *name = [pollHistory objectForKey:@"password"];
    return name;
}

+(NSString *)getTotalCredit
{
    NSMutableDictionary *pollHistory = [self readPlist];
    NSString *name = [pollHistory objectForKey:@"totalCredit"];
    return name;
}

+(NSString *)getCostCredit
{
    NSMutableDictionary *pollHistory = [self readPlist];
    NSString *name = [pollHistory objectForKey:@"costCredit"];
    return name;
}

+(NSString *)getImagePath
{
    NSMutableDictionary *pollHistory = [self readPlist];
    NSString *name = [pollHistory objectForKey:@"imagePath"];
    return name;
}

+(NSString *)getLocation
{
    NSMutableDictionary *pollHistory = [self readPlist];
    NSString *name = [pollHistory objectForKey:@"location"];
    return name;
}

+(NSString *)getCity
{
    NSMutableDictionary *pollHistory = [self readPlist];
    NSString *name = [pollHistory objectForKey:@"city"];
    return name;
}

+(int)existNetWork
{
    Reachability *r = [Reachability reachabilityWithHostName:SEVER_URL];
    
    if([r currentReachabilityStatus] == NotReachable){
        //   NSLog(@"没有网络");
        [SVProgressHUD showErrorWithStatus:@"当前无网络连接"];
        return 0;
    }else if([r currentReachabilityStatus] == ReachableViaWWAN){
        //   NSLog(@"正在使用3G网络");
        return 1;
    }else if([r currentReachabilityStatus] == ReachableViaWiFi){
        //  NSLog(@"正在使用wifi网络");

        return 1;
    }
    
    return NO;
}

+(BOOL)clearTemp:(NSString*)path
{
    //删除缓存文件
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSLog(@"the image is exist");
        NSFileManager *defaultManager;
        
        defaultManager = [NSFileManager defaultManager];
        NSError *error = [[NSError alloc] init];
        [defaultManager removeItemAtPath:path error:&error];
        return YES;
    }else{
        return NO;
    }
}


@end
