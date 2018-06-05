//
//  ViewController.m
//  TrackLocation
//
//  Created by 区振轩 on 2018/5/31.
//  Copyright © 2018年 区振轩. All rights reserved.
//

#import "ViewController.h"
#import <MAMapKit/MAMapKit.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    MAMapView * mapView = [[MAMapView alloc] initWithFrame:self.view.frame];
    MAUserLocation * location = [[MAUserLocation alloc] init];
    
    mapView.showsUserLocation = YES;
    mapView.userTrackingMode = MAUserTrackingModeFollow;
    
//    location.location = [[CLLocation alloc] initWithLatitude:23.3 longitude:113.2];
    
    
    
//    mapView.userLocation =
    
    
    
    
    [self.view addSubview:mapView];
    
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
