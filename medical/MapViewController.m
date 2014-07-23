//
//  MapViewController.m
//  medical
//
//  Created by Xinbao Dong on 7/17/14.
//  Copyright (c) 2014 Xinbao Dong. All rights reserved.
//

#import "MapViewController.h"

@interface RouteAnnotation : BMKPointAnnotation
{
	int _type; ///<0:起点 1：终点 2：公交 3：地铁 4:驾乘 5:途经点
	int _degree;
}

@property (nonatomic) int type;
@property (nonatomic) int degree;
@end

@implementation RouteAnnotation

@synthesize type = _type;
@synthesize degree = _degree;
@end


@interface MapViewController ()<BMKMapViewDelegate, BMKLocationServiceDelegate, BMKRouteSearchDelegate, BMKGeoCodeSearchDelegate, UIAlertViewDelegate, BMKPoiSearchDelegate>

@property (nonatomic, retain)BMKMapView *mapView;//地图界面
@property (nonatomic, retain)BMKLocationService *locationService;//定位服务
@property (nonatomic, retain)BMKPoiSearch *POISearch;//POI周边搜索

@property (nonatomic, retain)NSMutableArray *pathArray;//路径

@property (nonatomic, retain)BMKRouteSearch *search;//路径规划

@property (nonatomic, retain)CLLocation *currentLocation;//当前定位点
@property (nonatomic, retain)NSString *city;//当前定位城市

//POICallback 判断（设置）是否为POI周边搜索回调过来的。
//@property (nonatomic, assign)BOOL POICallback;
//POICallbackPosition 设置POI返回的坐标（经纬度）
//@property (nonatomic, assign)CLLocationCoordinate2D POICallbackPosition;
//判断是否为首次进入页面
@property (nonatomic, assign)BOOL firstIn;
@end

@implementation MapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _pathArray = [[NSMutableArray alloc] init];
    
    _mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 568)];
    [self.view addSubview:_mapView];
    _locationService = [[BMKLocationService alloc] init];
    _search = [[BMKRouteSearch alloc] init];
    _POISearch  = [[BMKPoiSearch alloc] init];
//    _geoSearch = [[BMKGeoCodeSearch alloc] init];
    _mapView.zoomLevel = 12.;
    //以上为初始化各项服务及界面
    _firstIn = YES;
//    _POICallback = NO;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(10, 500, 30, 30);
    [button setTitle:@"当前" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(startLocation:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeSystem];
    button1.frame = CGRectMake(80, 500, 30, 30);
    [button1 setTitle:@"驾车" forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(drivingSearch:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button1];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeSystem];
    button2.frame = CGRectMake(150, 500, 30, 30);
    [button2 setTitle:@"公交" forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(busSearch:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
    
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeSystem];
    button3.frame = CGRectMake(220, 500, 30, 30);
    [button3 setTitle:@"步行" forState:UIControlStateNormal];
    [button3 addTarget:self action:@selector(walkingSearch:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button3];
    
    UIButton *button4 = [UIButton buttonWithType:UIButtonTypeSystem];
    button4.frame = CGRectMake(290, 500, 30, 30);
    [button4 setTitle:@"周边" forState:UIControlStateNormal];
    [button4 addTarget:self action:@selector(listPointOfInterest:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button4];
    
//    [self getTargetLocationInformation];
    [self startLocation:nil];//开始定位
    
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locateIn:) name:@"locateIn" object:nil];
    
	// Do any additional setup after loading the view, typically from a nib.
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [_mapView viewWillAppear];
    _mapView.delegate = self;
    _locationService.delegate = self;
    _search.delegate = self;
    _POISearch.delegate = self;
//    _geoSearch.delegate = self;
    //    [self startLocation];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    if (_POICallback) {//如果是POI周边搜索回调过来的，则地图放大
//        BMKCoordinateRegion region;
//        CLLocationCoordinate2D center;
//        center.latitude = (_POICallbackPosition.latitude + self.destination2D.latitude) / 2.;
//        center.longitude = (_POICallbackPosition.longitude + self.destination2D.longitude) / 2.;
//        region.center = center;
//        BMKCoordinateSpan span;
//        span.latitudeDelta = _POICallbackPosition.latitude - self.destination2D.latitude;
//        span.longitudeDelta = _POICallbackPosition.longitude - self.destination2D.longitude;
//        if (span.latitudeDelta < 0) {
//            span.latitudeDelta = -span.latitudeDelta;
//        }
//        if (span.longitudeDelta < 0) {
//            span.longitudeDelta = -span.longitudeDelta;
//        }
//        region.span = span;
//        [_mapView setRegion:[_mapView regionThatFits:region] animated:YES];
////        [_mapView setCenterCoordinate:_POICallbackPosition animated:YES];
//        _POICallback = NO;
//    
//    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_mapView viewWillDisappear];
    _mapView.delegate = nil;
    _locationService.delegate = nil;
    _search.delegate = nil;
    _POISearch.delegate = nil;
    [self stopLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//显示兴趣点
- (void)listPointOfInterest: (UIButton *)btn
{
//    POITableViewController *vc = [[POITableViewController alloc] init];
//    vc.location = self.destination2D;
//    [self presentViewController:vc animated:YES completion:nil];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"医院周边信息" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"药店", @"银行", @"加油站", nil];
    [alert show];
}

#pragma mark - alert view delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
//    NSLog(@"%d", buttonIndex);
    if (buttonIndex == 0) {
        return ;
    }
    NSString *str = [alertView buttonTitleAtIndex:buttonIndex];
    BMKNearbySearchOption *option = [[BMKNearbySearchOption alloc] init];
    option.location = _destination2D;
    option.keyword = str;
    option.pageCapacity = 20;
    
    BOOL flag = [_POISearch poiSearchNearBy:option];
    if(flag) {
        NSLog(@"城市内检索发送成功");
    } else {
        NSLog(@"城市内检索发送失败");
    }
}

- (void)onGetPoiResult:(BMKPoiSearch *)searcher result:(BMKPoiResult *)result errorCode:(BMKSearchErrorCode)errorCode
{
    
    if (errorCode == BMK_SEARCH_NO_ERROR) {
        CLLocationCoordinate2D max = _destination2D;
        CLLocationCoordinate2D min = _destination2D;
        [self clear];
        for (BMKPoiInfo *info in result.poiInfoList) {
            BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
            item.coordinate = info.pt;
            item.title = info.name;
            item.subtitle = info.address;
            [_mapView addAnnotation:item];
            max.latitude = item.coordinate.latitude > max.latitude ? item.coordinate.latitude : max.latitude;
            max.longitude = item.coordinate.longitude > max.longitude ? item.coordinate.longitude : max.longitude;
            min.latitude = item.coordinate.latitude < min.latitude ? item.coordinate.latitude : min.latitude;
            min.longitude = item.coordinate.longitude < min.longitude ? item.coordinate.longitude : min.longitude;
        }
    
        BMKCoordinateRegion region;
        CLLocationCoordinate2D center;

        center.latitude = (max.latitude + min.latitude) / 2.;
        center.longitude = (max.longitude + min.longitude) / 2.;
        region.center = center;
        BMKCoordinateSpan span;
        span.latitudeDelta = max.latitude - min.latitude;
        span.longitudeDelta = max.longitude - min.longitude;

        region.span = span;
        [_mapView setRegion:[_mapView regionThatFits:region] animated:YES];
	} else if (errorCode == BMK_SEARCH_AMBIGUOUS_ROURE_ADDR){
        NSLog(@"起始点有歧义");
    } else {
        // 各种情况的判断。。。
    }
}

//进入定位
- (void)startLocation: (UIButton *)btn
{
    NSLog(@"进入普通定位态");
    [_locationService startUserLocationService];
    _mapView.showsUserLocation = NO;//先关闭显示的定位图层
    _mapView.userTrackingMode = BMKUserTrackingModeNone;//设置定位的状态
    _mapView.showsUserLocation = YES;
    [_mapView setCenterCoordinate:self.currentLocation.coordinate animated:YES];
}

//结束定位
- (void)stopLocation
{
    [_locationService stopUserLocationService];
    _mapView.showsUserLocation = NO;
}

//定位失败
- (void)mapView:(BMKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    NSLog(@"location error");
}

//标记视图
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        newAnnotationView.pinColor = BMKPinAnnotationColorGreen;
        newAnnotationView.animatesDrop = NO;
        BMKPointAnnotation *p = annotation;
        if (p.coordinate.longitude == _destination2D.longitude && p.coordinate.latitude == _destination2D.latitude) {
            newAnnotationView.image = [UIImage imageNamed:@"icon_openmap_item"];
        }else {
            newAnnotationView.image = [UIImage imageNamed:@"icon_openmap_item_highlight"];
        }
        
        //        newAnnotationView.enabled3D = YES;
        return newAnnotationView;
    }
    return nil;
}


//在屏幕中画的路线的参数
- (BMKOverlayView*)mapView:(BMKMapView *)map viewForOverlay:(id<BMKOverlay>)overlay
{
	if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView *polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:1];
        //        polylineView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        polylineView.strokeColor = [UIColor colorWithRed:30./255. green:144./255. blue:1. alpha:1.];
        polylineView.lineWidth = 3.0;
        return polylineView;
    }
	return nil;
}

//处理位置坐标更新
- (void)didUpdateUserLocation:(BMKUserLocation *)userLocation
{
    [_mapView updateLocationData:userLocation];
    [self updateLocalInformation:userLocation];
    if (_firstIn) {
//        [self getTargetLocationInformation];
//        [_mapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
        [self addTargetAnnotation];
        _firstIn = NO;
        BMKCoordinateRegion region;
        CLLocationCoordinate2D center;
        center.latitude = (userLocation.location.coordinate.latitude + self.destination2D.latitude) / 2.;
        center.longitude = (userLocation.location.coordinate.longitude + self.destination2D.longitude) / 2.;
        region.center = center;
        BMKCoordinateSpan span;
        span.latitudeDelta = userLocation.location.coordinate.latitude - self.destination2D.latitude;
        span.longitudeDelta = userLocation.location.coordinate.longitude - self.destination2D.longitude;
        if (span.latitudeDelta < 0) {
            span.latitudeDelta = -span.latitudeDelta;
        }
        if (span.longitudeDelta < 0) {
            span.longitudeDelta = -span.longitudeDelta;
        }
//        span.longitudeDelta = span.longitudeDelta < 0 ? -span.longitudeDelta : span.longitudeDelta;
        
        NSLog(@"%f %f\n %f %f", self.destination2D.latitude, self.destination2D.longitude, userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
        
        region.span = span;
//        [_mapView setCenterCoordinate:center animated:YES];
        [_mapView setRegion:[_mapView regionThatFits:region] animated:YES];
    }
}

//更新本地信息
- (void)updateLocalInformation: (BMKUserLocation *)userLocation
{
    _currentLocation = userLocation.location;
    CLGeocoder *Geocoder=[[CLGeocoder alloc] init];
    _city = [[NSString alloc] init];
    [Geocoder reverseGeocodeLocation:_currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *place = [placemarks firstObject];
        //        cityStr = placemark.thoroughfare;
        _city = place.locality;
    }];

}

//- (void)getTargetLocationInformation
//{
//    BMKGeoCodeSearchOption *geocodeSearchOption = [[BMKGeoCodeSearchOption alloc]init];
//    geocodeSearchOption.city= _city;
//    geocodeSearchOption.address = _destination;
//    BOOL flag = [_geoSearch geoCode:geocodeSearchOption];
//    if(flag)
//    {
//        NSLog(@"geo检索发送成功");
//    }
//    else
//    {
//        NSLog(@"geo检索发送失败");
//    }
//}

//设置目标标注（即终点）
- (void)addTargetAnnotation
{
    BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
    item.coordinate = self.destination2D;
    item.title = self.targetTitle;
    item.subtitle = @"终点";
    [_mapView addAnnotation:item];
}

//NSNotification回调函数
//- (void)locateIn: (NSNotification *)notification
//{
//    BMKPoiInfo *info = (BMKPoiInfo *)notification.object;
//    [self clear];
//    BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
//    item.coordinate = info.pt;
//    item.title = info.name;
//    item.subtitle = info.address;
//    [_mapView addAnnotation:item];
////    _POICallbackPosition = info.pt;
////    _POICallback = YES;
//    
//    
//}

//清除之前的路线和标记(保留终点)
- (void)clear
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:_mapView.annotations];
    int i = 0;
    while (i < array.count) {
        BMKPointAnnotation *item = array[i];
        if (item.coordinate.latitude == self.destination2D.latitude && item.coordinate.longitude == self.destination2D.longitude) {
            [array removeObject:item];
            i --;
        }
        i ++;
    }
    [_mapView removeAnnotations:array];
    array = [NSMutableArray arrayWithArray:_mapView.overlays];
    [_mapView removeOverlays:array];

}

#pragma marks - search and delegate

//driving search
- (void)drivingSearch:(UIButton *)button
{
    
    BMKPlanNode *start = [[BMKPlanNode alloc] init];
    CLLocationCoordinate2D startPt = CLLocationCoordinate2DMake(_currentLocation.coordinate.latitude, _currentLocation.coordinate.longitude);
    start.name = _city;
    start.pt = startPt;
    
    BMKPlanNode *end = [[BMKPlanNode alloc] init];

    end.pt = _destination2D;
    
    BMKDrivingRoutePlanOption *option = [[BMKDrivingRoutePlanOption alloc] init];
    option.from = start;
    option.to = end;
    BOOL flag = [_search drivingSearch:option];
    if (!flag) {
        NSLog(@"driving search failed");
    }
    
}

//driving search delegate
- (void)onGetDrivingRouteResult:(BMKRouteSearch *)searcher result:(BMKDrivingRouteResult *)result errorCode:(BMKSearchErrorCode)error
{
    NSLog(@"onGetDrivingRouteResult:error:%d",error);
    [self clear];
    if (error == BMK_SEARCH_NO_ERROR) {
        BMKDrivingRouteLine *plan = (BMKDrivingRouteLine*)[result.routes objectAtIndex:0];
        // 计算路线方案中的路段数目
		int size = [plan.steps count];
		int planPointCounts = 0;
		for (int i = 0; i < size; i++) {
            BMKDrivingStep *transitStep = [plan.steps objectAtIndex:i];
//            if(i==0){
//                RouteAnnotation *item = [[RouteAnnotation alloc]init];
//                item.coordinate = plan.starting.location;
//                item.title = @"起点";
//                item.type = 0;
//                [_mapView addAnnotation:item]; // 添加起点标注
//                
//            }else if(i==size-1){
////                RouteAnnotation *item = [[RouteAnnotation alloc]init];
////                item.coordinate = plan.terminal.location;
////                item.title = @"终点";
////                item.type = 1;
////                [_mapView addAnnotation:item]; // 添加终点标注
////                
////                self.targetLocation = item.coordinate;
////                NSLog(@"Driving: %f %f", item.coordinate.latitude, item.coordinate.longitude);
//                
//            }
            //添加annotation节点
//            RouteAnnotation *item = [[RouteAnnotation alloc]init];
//            item.coordinate = transitStep.entrace.location;
//            NSArray *array = [transitStep.entraceInstruction componentsSeparatedByString:@"，"];
//            item.title = [array objectAtIndex:0];
//            if (array.count > 1) {
//                item.subtitle = [array objectAtIndex:1];
//            }
//            item.degree = transitStep.direction * 30;
//            item.type = 4;
//            [_mapView addAnnotation:item];
            //轨迹点总数累计
            planPointCounts += transitStep.pointsCount;
        }
        // 添加途经点
        if (plan.wayPoints) {
            for (BMKPlanNode *tempNode in plan.wayPoints) {
                RouteAnnotation *item = [[RouteAnnotation alloc]init];
                item = [[RouteAnnotation alloc]init];
                item.coordinate = tempNode.pt;
                item.type = 5;
                item.title = tempNode.name;
                [_mapView addAnnotation:item];
                
            }
        }
        //轨迹点
        BMKMapPoint  *temppoints = new BMKMapPoint[planPointCounts];
        int i = 0;
        for (int j = 0; j < size; j++) {
            BMKDrivingStep *transitStep = [plan.steps objectAtIndex:j];
            int k=0;
            for(k=0;k<transitStep.pointsCount;k++) {
                temppoints[i].x = transitStep.points[k].x;
                temppoints[i].y = transitStep.points[k].y;
                i++;
            }
            
        }
        // 通过points构建BMKPolyline
		BMKPolyline *polyLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
		[_mapView addOverlay:polyLine]; // 添加路线overlay,调用委托- (BMKOverlayView*)mapView:(BMKMapView *)map viewForOverlay:(id<BMKOverlay>)overlay
		delete []temppoints;
        
		
	}else {
        NSLog(@"%u", error);
    }
    
}

//bus search
- (void)busSearch: (UIButton *)button
{

    BMKPlanNode *start = [[BMKPlanNode alloc] init];
    CLLocationCoordinate2D startPt = CLLocationCoordinate2DMake(_currentLocation.coordinate.latitude, _currentLocation.coordinate.longitude);
    start.name = _city;
    start.pt = startPt;
    
    BMKPlanNode *end = [[BMKPlanNode alloc] init];
    end.pt = _destination2D;
    
    
    BMKTransitRoutePlanOption *option = [[BMKTransitRoutePlanOption alloc] init];
    option.from = start;
    option.to = end;
    option.city = _city;
    
    BOOL flag = [_search transitSearch:option];
    if(flag) {
        NSLog(@"bus search success");
    } else {
        NSLog(@"bus search failed");
    }
}

//bus search delegate
- (void)onGetTransitRouteResult:(BMKRouteSearch*)searcher result:(BMKTransitRouteResult*)result errorCode:(BMKSearchErrorCode)error
{
    [self clear];
    if (error == BMK_SEARCH_NO_ERROR) {
		BMKTransitRouteLine *plan = (BMKTransitRouteLine*)[result.routes objectAtIndex:0];
        // 计算路线方案中的路段数目
		int size = [plan.steps count];
		int planPointCounts = 0;
		for (int i = 0; i < size; i++) {
            BMKTransitStep *transitStep = [plan.steps objectAtIndex:i];
            if(i == 0){
                RouteAnnotation *item = [[RouteAnnotation alloc]init];
                item.coordinate = plan.starting.location;
                item.title = @"起点";
                item.type = 0;
                [_mapView addAnnotation:item]; // 添加起点标注
                
            }else if(i == size-1){
//                RouteAnnotation *item = [[RouteAnnotation alloc]init];
//                item.coordinate = plan.terminal.location;
//                item.title = @"终点";
//                item.type = 1;
//                [_mapView addAnnotation:item]; // 添加起点标注
//                
//                self.targetLocation = item.coordinate;
            }
            RouteAnnotation *item = [[RouteAnnotation alloc]init];
            item.coordinate = transitStep.entrace.location;
            NSArray *array = [transitStep.instruction componentsSeparatedByString:@"，"];
            item.title = [array objectAtIndex:0];
            if (array.count > 1) {
                item.subtitle = [array objectAtIndex:1];
            }
            item.type = 3;
            [_mapView addAnnotation:item];
            
            //轨迹点总数累计
            planPointCounts += transitStep.pointsCount;
        }
        
        //轨迹点
        BMKMapPoint  *temppoints = new BMKMapPoint[planPointCounts];
        int i = 0;
        for (int j = 0; j < size; j++) {
            BMKTransitStep *transitStep = [plan.steps objectAtIndex:j];
            int k=0;
            for(k=0;k<transitStep.pointsCount;k++) {
                temppoints[i].x = transitStep.points[k].x;
                temppoints[i].y = transitStep.points[k].y;
                i++;
            }
            
        }
        // 通过points构建BMKPolyline
		BMKPolyline *polyLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
		[_mapView addOverlay:polyLine]; // 添加路线overlay
		delete []temppoints;
	}
    
}



//walk search
-(void)walkingSearch:(UIButton *)button
{
	
	BMKPlanNode *start = [[BMKPlanNode alloc] init];
    CLLocationCoordinate2D startPt = CLLocationCoordinate2DMake(_currentLocation.coordinate.latitude, _currentLocation.coordinate.longitude);
    start.name = _city;
    start.pt = startPt;
    
    BMKPlanNode *end = [[BMKPlanNode alloc] init];
    end.pt = _destination2D;
    
    
    BMKWalkingRoutePlanOption *walkingRouteSearchOption = [[BMKWalkingRoutePlanOption alloc] init];
    walkingRouteSearchOption.from = start;
    walkingRouteSearchOption.to = end;
    BOOL flag = [_search walkingSearch:walkingRouteSearchOption];
    if(flag) {
        NSLog(@"walk search success");
    } else {
        NSLog(@"walk search failed");
    }
    
}

- (void)onGetWalkingRouteResult:(BMKRouteSearch*)searcher result:(BMKWalkingRouteResult*)result errorCode:(BMKSearchErrorCode)error
{
    [self clear];
	if (error == BMK_SEARCH_NO_ERROR) {
        BMKWalkingRouteLine* plan = (BMKWalkingRouteLine*)[result.routes objectAtIndex:0];
		int size = [plan.steps count];
		int planPointCounts = 0;
		for (int i = 0; i < size; i++) {
            BMKWalkingStep* transitStep = [plan.steps objectAtIndex:i];
//            if(i==0){
//                RouteAnnotation* item = [[RouteAnnotation alloc]init];
//                item.coordinate = plan.starting.location;
//                item.title = @"起点";
//                item.type = 0;
//                [_mapView addAnnotation:item]; // 添加起点标注
//                
//            }else if(i==size-1){
////                RouteAnnotation* item = [[RouteAnnotation alloc]init];
////                item.coordinate = plan.terminal.location;
////                item.title = @"终点";
////                item.type = 1;
////                [_mapView addAnnotation:item]; // 添加起点标注
//                
////                self.targetLocation = item.coordinate;
//            }
//            //添加annotation节点
//            RouteAnnotation* item = [[RouteAnnotation alloc]init];
//            item.coordinate = transitStep.entrace.location;
//            NSArray *array = [transitStep.entraceInstruction componentsSeparatedByString:@"，"];
//            item.title = [array objectAtIndex:0];
//            if (array.count > 1) {
//                item.subtitle = [array objectAtIndex:1];
//            }
//            item.degree = transitStep.direction * 30;
//            item.type = 4;
//            [_mapView addAnnotation:item];
            //轨迹点总数累计
            planPointCounts += transitStep.pointsCount;
        }
        
        //轨迹点
        BMKMapPoint * temppoints = new BMKMapPoint[planPointCounts];
        int i = 0;
        for (int j = 0; j < size; j++) {
            BMKWalkingStep* transitStep = [plan.steps objectAtIndex:j];
            int k=0;
            for(k=0;k<transitStep.pointsCount;k++) {
                temppoints[i].x = transitStep.points[k].x;
                temppoints[i].y = transitStep.points[k].y;
                i++;
            }
        }
        // 通过points构建BMKPolyline
		BMKPolyline* polyLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
		[_mapView addOverlay:polyLine]; // 添加路线overlay
		delete []temppoints;
	}
    
}

@end
