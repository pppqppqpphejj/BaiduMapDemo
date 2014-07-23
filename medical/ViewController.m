//
//  ViewController.m
//  medical
//
//  Created by Xinbao Dong on 7/17/14.
//  Copyright (c) 2014 Xinbao Dong. All rights reserved.
//

#import "ViewController.h"
#import "MapViewController.h"

@interface ViewController ()

@end

@implementation ViewController

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
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.frame = CGRectMake(10, 500, 30, 30);
    [button setTitle:@"当前" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(presentMapView) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    // Do any additional setup after loading the view.
}

- (void)presentMapView
{
    MapViewController *vc = [[MapViewController alloc] init];
//    vc.destination = @"浙一医院";
//    vc.targetCity = @"杭州";
    CLLocationCoordinate2D de;
    de.latitude = 30.263540;
    de.longitude = 120.182821;
    vc.destination2D = de;
    [self presentViewController:vc animated:NO completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
