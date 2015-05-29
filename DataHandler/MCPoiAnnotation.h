//
//  MCPoiAnnotation.h
//  mycity
//
//  Created by openapp on 15/5/15.
//  Copyright (c) 2015年 openapp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <AFNetworking/UIImageView+AFNetworking.h>

#define MapPoiReusedIdentifier @"MAPPOIS"

@interface MCPoiAnnotationView : MKAnnotationView

@property (nonatomic, retain) UIImageView *imageview;

@end


@interface MCPoiAnnotation : NSObject <MKAnnotation>

@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@property (nonatomic, readwrite, copy) NSString *title;
@property (nonatomic, readwrite, copy) NSURL *imageUrl;

- (MCPoiAnnotationView *)viewForAnnotation;
- (instancetype)initWithImage:(NSString *)imgUrl title:(NSString *)t gps:(NSString *)pos;

@end

