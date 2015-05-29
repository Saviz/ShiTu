//
//  MCMapViewController.h
//  mycity
//
//  Created by openapp on 15/5/15.
//  Copyright (c) 2015年 openapp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "STPicInfo.h"

@interface MCMapViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic, retain) STPicInfo* info;
+ (instancetype)createMapViewPageWithImageUrl:(NSString *)imageUrl;

@end
