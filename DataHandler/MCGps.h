//
//  MCGps.h
//  mycity
//
//  Created by openapp on 15/5/15.
//  Copyright (c) 2015年 openapp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MCGps : NSObject

+ (CLLocationCoordinate2D)transformFromWGSToGCJ:(CLLocationCoordinate2D)wgLoc;
+ (CLLocationCoordinate2D)transformFromGCJToWGS:(CLLocationCoordinate2D)mgLoc;

@end
