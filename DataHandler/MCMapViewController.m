//
//  MCMapViewController.m
//  mycity
//
//  Created by openapp on 15/5/15.
//  Copyright (c) 2015年 openapp. All rights reserved.
//

#import "MCMapViewController.h"
#import "MCPinAnnotation.h"
#import "MCPoiAnnotation.h"
#import "MCGps.h"


@implementation MCMapViewController {
    MKMapView *map;
    MCPinAnnotation *centerPin;
    NSMutableArray *pois;
    CLLocationCoordinate2D gps;
}

+ (instancetype)createMapViewPageWithImageUrl:(NSString *)imageUrl
{
    MCMapViewController *instance = [[MCMapViewController alloc] init];
    instance.info = [[STPicInfo alloc] init];
    instance.info.url = imageUrl;
    return instance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    map = [[MKMapView alloc] initWithFrame:self.view.bounds];
    
    //CLLocationCoordinate2D c = CLLocationCoordinate2DMake(34.121, 115.21212);
    //CLLocationCoordinate2D c2 = [MCGps transformFromWGSToGCJ:c];
    //CLLocationCoordinate2D c3 =
    //NSLog(@"%f %f %f %f %f %f", c.longitude, c.latitude, c2.longitude, c2.latitude, c3.longitude, c3.latitude);
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(39.994104995623616, 116.33219413545702);
    self.info.gps = center;
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(center, 250, 250);
    [map setRegion:region animated:NO];
    
    centerPin = [[MCPinAnnotation alloc] initWithColor:MKPinAnnotationColorRed];
    centerPin.coordinate = center;
    [map addAnnotation:centerPin];
    
    map.delegate = self;
    
    
    pois = [[NSMutableArray alloc] init];
    [self loadPoiAt:map.region.center];
    
    [self.view addSubview:map];
    
    UIBarButtonItem * doneButton =
    [[UIBarButtonItem alloc]
     initWithBarButtonSystemItem:UIBarButtonSystemItemDone
     target:self
     action:@selector( doneFunc ) ];
    
    self.navigationItem.rightBarButtonItem = doneButton;
    self.navigationItem.leftBarButtonItem = nil;

}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    NSLog(@"%f - %f", mapView.region.center.latitude, mapView.region.center.longitude);
    
    [map removeAnnotation:centerPin];
    centerPin.coordinate = mapView.region.center;
    [map addAnnotation:centerPin];
    //overlay render if you want keep pin centerred
    
    
    [map removeAnnotations:pois];
    [pois removeAllObjects];
    [self loadPoiAt:mapView.region.center];
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MCPinAnnotation class]]){
        MCPinAnnotation *pinAnnotation = (MCPinAnnotation *)annotation;
        MKPinAnnotationView *pin = (MKPinAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier: MapPinReusedIdentifier];
        if (pin == nil) {
            pin = [pinAnnotation viewForAnnotation];
        } else {
            pin.annotation = annotation;
        }
        return pin;
    }
    if ([annotation isKindOfClass:[MCPoiAnnotation class]]){
        MCPoiAnnotation *poiAnnotation = (MCPoiAnnotation *)annotation;
        MCPoiAnnotationView *view = (MCPoiAnnotationView *) [mapView dequeueReusableAnnotationViewWithIdentifier: MapPoiReusedIdentifier];
        if (view == nil) {
            view = [poiAnnotation viewForAnnotation];
        } else {
            view.annotation = annotation;
        }
        return view;
    }
    return nil;
}

- (void)loadPoiAt:(CLLocationCoordinate2D)gcj{
    self.info.gps = [MCGps transformFromGCJToWGS:gcj];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [super viewWillDisappear:animated];
}

- (void)doneFunc {
    [self dismissViewControllerAnimated:NO completion:^(void){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TGLocationInfoGot"
            object:self.info];
    }];
    
}

@end
