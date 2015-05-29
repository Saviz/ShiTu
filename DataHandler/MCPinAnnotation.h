//
//  MCPinAnnotation.h
//  mycity
//
//  Created by openapp on 15/5/15.
//  Copyright (c) 2015年 openapp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#define MapPinReusedIdentifier @"CENTERPIN"

@interface MCPinAnnotation : NSObject <MKAnnotation>

@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;

- (instancetype)initWithColor:(MKPinAnnotationColor)color;
- (MKPinAnnotationView *)viewForAnnotation;

@end
