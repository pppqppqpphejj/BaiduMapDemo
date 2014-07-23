//
//  AppDelegate.h
//  medical
//
//  Created by Xinbao Dong on 7/16/14.
//  Copyright (c) 2014 Xinbao Dong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BMapKit.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    BMKMapManager* _mapManager;
}

@property (strong, nonatomic) UIWindow *window;

@end
