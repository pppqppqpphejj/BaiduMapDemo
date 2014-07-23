//
//  MapViewController.h
//  medical
//
//  Created by Xinbao Dong on 7/17/14.
//  Copyright (c) 2014 Xinbao Dong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"
@interface MapViewController : UIViewController
//@property (nonatomic, retain) NSString *destination;//输出目标地址
@property (nonatomic, retain) NSString *targetTitle;//目标名称
@property (nonatomic, retain) NSString *targetCity;//目标城市，暂无用
@property (nonatomic, assign) CLLocationCoordinate2D destination2D;//目标地址（经纬度）
@end
