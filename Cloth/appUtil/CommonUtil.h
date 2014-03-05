//
//  CommonUtil.h
//  Cloth
//
//  Created by ss4346 on 13-9-22.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
#import "SVProgressHUD.h"

@interface CommonUtil : NSObject

+(void)writePlist:(NSString *)userName  password:(NSString *)password userType:(NSString *)userType totalCredit:(NSString *)totalCredit costCredit:(NSString *)costCredit imagePath:(NSString *)imagePath ;
+(void)writeDataToPlist:(NSString *)key value:(NSString *)value;

+(NSMutableDictionary *)readPlist;
+(NSString *)dataFilePath;
+(NSString *)dataProvinceFilePath;
+(NSString *)getUserType;
+(NSString *)getUserName;
+(NSString *)getPassword;
+(NSString *)getTotalCredit;
+(NSString *)getCostCredit;
+(NSString *)getImagePath;
+(NSString *)getLocation;
+(NSString *)getCity;
+(NSMutableArray *)getPlistValue;
+(void)writeLocation:(NSString *)location;
+(void)writeCity:(NSString *)city;
+(int)existNetWork;

+(void) createNavigationItem:(UIViewController *) view text:(NSString *)string;
+(BOOL)clearTemp:(NSString*)path;
@end
