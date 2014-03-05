//
//  MapViewViewController.h
//  Cloth
//
//  Created by ss4346 on 13-12-24.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KYPointAnnotation.h"
#import "BMKMapView.h"
#import "BMapKit.h"


@interface MapViewViewController : UIViewController<BMKMapViewDelegate,BMKSearchDelegate>{
    
    BMKSearch* _search;
    
    BMKMapView *_mapView;
    
    NSMutableArray *totalArray;
    
    BOOL _isSetMapSpan;
    
}

@property (strong,nonatomic) NSString *address;
//@property (strong,nonatomic) IBOutlet BMKMapView *mapView;

@end
