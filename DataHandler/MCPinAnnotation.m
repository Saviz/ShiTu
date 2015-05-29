//
//  MCPinAnnotation.m
//  mycity
//
//  Created by openapp on 15/5/15.
//  Copyright (c) 2015年 openapp. All rights reserved.
//

#import "MCPinAnnotation.h"

@implementation MCPinAnnotation {
    MKPinAnnotationColor pinColor;
}

- (instancetype)initWithColor:(MKPinAnnotationColor)color {
    self = [super init];
    pinColor = color;
    return self;
}

- (MKPinAnnotationView *)viewForAnnotation {
    MKPinAnnotationView *view = [[MKPinAnnotationView alloc] initWithAnnotation:self reuseIdentifier:MapPinReusedIdentifier];
    view.pinColor = pinColor;
    view.animatesDrop = YES;
    return view;
}

@end
