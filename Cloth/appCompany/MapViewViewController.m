//
//  MapViewViewController.m
//  Cloth
//
//  Created by ss4346 on 13-12-24.
//  Copyright (c) 2013年 ss4346. All rights reserved.
//

#import "MapViewViewController.h"

@interface MapViewViewController ()
{
    
    BMKAnnotationView* newAnnotation;
}

@end

@implementation MapViewViewController

//@synthesize mapView = _mapView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //适配ios7
    if( ([[[UIDevice currentDevice] systemVersion] doubleValue]>=7.0))
    {
        //        self.edgesForExtendedLayout=UIRectEdgeNone;
        self.navigationController.navigationBar.translucent = NO;
    }
	_search = [[BMKSearch alloc]init];
    
    // 设置地图级别

    _mapView = [[BMKMapView alloc]initWithFrame:CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height - [UIApplication sharedApplication].statusBarFrame.size.height -44)];
    _mapView.compassPosition = CGPointMake(10,10);
    _mapView.compassPosition = CGPointMake(10,10);
    _mapView.showMapScaleBar = true;
    [_mapView setZoomLevel:13];
    _mapView.isSelectedAnnotationViewFront = YES;
    [self onClickOk];
    [self.view addSubview:_mapView];
}


-(void)viewWillAppear:(BOOL)animated {
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _search.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    
    [self createNavigationbarItem];
}

-(void)viewWillDisappear:(BOOL)animated {
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _search.delegate = nil; // 不用时，置nil
}


- (void)viewDidUnload {
    [super viewDidUnload];
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
}

- (void)dealloc {

    if (_search != nil) {

        _search = nil;
    }
    if (_mapView) {

        _mapView = nil;
    }
}

-(IBAction)onClickOk
{
    //城市内检索，请求发送成功返回YES，请求发送失败返回NO
	BOOL flag = [_search poiSearchInCity:[CommonUtil getCity] withKey:self.address pageIndex:1];

//    BOOL flag = [_search poiSearchInCity:@"沈阳市" withKey:@"超市" pageIndex:1];
	if (flag) {

		NSLog(@"search success.");
	}
    else{
        NSLog(@"search failed!");
    }
    
}

-(void)backAction
{
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)createNavigationbarItem
{
    self.navigationItem.title = @"地图";
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 0, 50, 25);
    [leftButton setTitle:@"返回" forState:UIControlStateNormal];
    [leftButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:13]];
    [leftButton setTitleColor:[UIColor colorWithRed:145/255.0 green:26/255.0 blue:152/255.0 alpha:1.0] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"btn_location"] forState:UIControlStateNormal];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] init];
    [leftItem setCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftItem;
}


#pragma mark -
#pragma mark implement BMKMapViewDelegate

/**
 *根据anntation生成对应的View
 *@param mapView 地图View
 *@param annotation 指定的标注
 *@return 生成的标注View
 */
- (BMKAnnotationView *)mapView:(BMKMapView *)view viewForAnnotation:(id <BMKAnnotation>)annotation
{
    // 生成重用标示identifier
    NSString *AnnotationViewID = @"xidanMark";
	
    // 检查是否有重用的缓存
    BMKAnnotationView* annotationView = [view dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    
    // 缓存没有命中，自己构造一个，一般首次添加annotation代码会运行到此处
    if (annotationView == nil) {
        annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
		((BMKPinAnnotationView*)annotationView).pinColor = BMKPinAnnotationColorRed;
		// 设置重天上掉下的效果(annotation)
        ((BMKPinAnnotationView*)annotationView).animatesDrop = YES;
    }
	
    // 设置位置
	annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height * 0.5));
    annotationView.annotation = annotation;
    // 单击弹出泡泡，弹出泡泡前提annotation必须实现title属性
	annotationView.canShowCallout = YES;
    // 设置是否可以拖拽
    annotationView.draggable = NO;
    
    return annotationView;
}
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{
    [mapView bringSubviewToFront:view];
    [mapView setNeedsDisplay];
}
- (void)mapView:(BMKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    NSLog(@"didAddAnnotationViews");
}

#pragma mark -
#pragma mark implement BMKSearchDelegate

- (void)onGetPoiResult:(NSArray*)poiResultList searchType:(int)type errorCode:(int)error
{
    // 清楚屏幕中所有的annotation
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
	[_mapView removeAnnotations:array];
    
    if (error == BMKErrorOk) {
		BMKPoiResult* result = [poiResultList objectAtIndex:0];
        
        if (poiResultList.count == 0) {
            [SVProgressHUD showErrorWithStatus:@"暂无结果"];
        }
        
		for (int i = 0; i < result.poiInfoList.count; i++) {
            BMKPoiInfo* poi = [result.poiInfoList objectAtIndex:i];
            BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
            item.coordinate = poi.pt;
            item.title = poi.name;
            [_mapView addAnnotation:item];
            if(i == 0)
            {
                //将第一个点的坐标移到屏幕中央
                _mapView.centerCoordinate = poi.pt;

            }

		}
	} else if (error == BMKErrorRouteAddr){
        NSLog(@"起始点有歧义");
    } else {
        // 各种情况的判断。。。
    }
}

- (void)setMapRegionWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    BMKCoordinateRegion region;
    if (!_isSetMapSpan)//这里用一个变量判断一下,只在第一次锁定显示区域时 设置一下显示范围 Map Region
    {
        region = BMKCoordinateRegionMake(coordinate, BMKCoordinateSpanMake(0.05, 0.05));//越小地图显示越详细
        _isSetMapSpan = YES;
        [_mapView setRegion:region animated:YES];//执行设定显示范围
    }
    
    [_mapView setCenterCoordinate:coordinate animated:YES];//根据提供的经纬度为中心原点 以动画的形式移动到该区域
}


@end
