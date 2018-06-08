//
//  ViewController.m
//  TrackLocation
//
//  Created by 区振轩 on 2018/5/31.
//  Copyright © 2018年 区振轩. All rights reserved.
//

#import "ViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <GCDAsyncSocket.h>


@interface ViewController () <MAMapViewDelegate,GCDAsyncSocketDelegate>
@property (nonatomic,assign) long writeTag ;
@property (nonatomic,assign) long readTag ;
@property (nonatomic,strong) NSTimer * timer;
@property (nonatomic,strong) GCDAsyncSocket * socket;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [AMapServices sharedServices].enableHTTPS = YES;
    
    _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    _writeTag  = 0;
    _readTag = 0;
    MAMapView * mapView = [[MAMapView alloc] initWithFrame:self.view.frame];
    MAUserLocation * location = [[MAUserLocation alloc] init];
    
    mapView.showsUserLocation = YES;
    mapView.userTrackingMode = MAUserTrackingModeFollow;
    
    MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
    pointAnnotation.coordinate = CLLocationCoordinate2DMake(23.149825 , 113.409873);
    pointAnnotation.title = @"我的位置";
    pointAnnotation.subtitle = @"ehang";
    mapView.delegate = self;
    [mapView addAnnotation:pointAnnotation];
    
    [self.view addSubview:mapView];
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    UIButton * connectBtn = [[UIButton alloc] initWithFrame:CGRectMake(screenWidth - 100, 64, 80, 40)];
    [connectBtn setTitle:@"连接" forState:UIControlStateNormal];
    [connectBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [connectBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:connectBtn];
}

- (void)btnClick:(UIButton *)btn{
    [self initTheSocke];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initTheSocke{
//    IP:120.78.166.65  PORT:554
    NSString * host = @"120.78.166.65";
    int port = 554;
    
    
    NSError * error = nil;
    [_socket connectToHost:host onPort:port error:&error];
    if (error) {
        NSLog(@"%@",error);
        return;
    }
    
    NSData *data =[@"I am cat."  dataUsingEncoding:NSUTF8StringEncoding];
    [_socket writeData:data withTimeout:5 tag:++_writeTag];
    
    typeof(self) weakSelf = self;
    _timer = [NSTimer scheduledTimerWithTimeInterval:2 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSData *data =[@"heart beat"  dataUsingEncoding:NSUTF8StringEncoding];
        [weakSelf.socket writeData:data withTimeout:5 tag:10];
//        [weakSelf.socket readDataWithTimeout:5 tag:99];
    }];

}




#pragma mark -socket的代理
#pragma mark 连接成功
-(void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port{
    NSLog(@"%s",__func__);
    [_socket readDataWithTimeout:-1 tag:99];
}


#pragma mark 断开连接
-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{
    [_timer invalidate];
    if (err) {
        NSLog(@"连接失败");
    }else{
        NSLog(@"正常断开");
    }
}


#pragma mark 数据发送成功
-(void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"%s",__func__);
    
    //发送完数据手动读取，-1不设置超时
    [_socket readDataWithTimeout:5 tag:tag];
}

#pragma mark 读取数据
-(void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSString *receiverStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%s %@",__func__,receiverStr);
    
    [_socket readDataWithTimeout:-1 tag:tag];
}









- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]] && [annotation.title isEqualToString:@"我的位置"])
    {
        static NSString *reuseIndetifier = @"annotationReuseIndetifier";
        MAAnnotationView *annotationView = (MAAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation
                                                          reuseIdentifier:reuseIndetifier];
        }
        
        UIImage * carImage =  [UIImage imageNamed:@"bmwCar"];
        UIImage * nomalImage = [self reSizeImage:carImage toSize:CGSizeMake(20, 20)];
        annotationView.image = nomalImage;
        return annotationView;
    }
    return nil;
}

- (UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize{
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return reSizeImage;
}
@end


