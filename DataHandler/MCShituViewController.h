//
//  MCShituViewController.h
//  mycity
//
//  Created by openapp on 15/5/28.
//  Copyright (c) 2015年 openapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>


@interface MCShituViewController : UIViewController

+ (instancetype)createWebViewPageWithGPS:(CLLocationCoordinate2D)gps andImageUrl:(NSString *)imageUrl;

@property (nonatomic) CLLocationCoordinate2D gps;
@property (nonatomic, retain) NSString *imageUrl;

@end
