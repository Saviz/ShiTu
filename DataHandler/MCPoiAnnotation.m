//
//  MCPoiAnnotation.m
//  mycity
//
//  Created by openapp on 15/5/15.
//  Copyright (c) 2015年 openapp. All rights reserved.
//

#import "MCPoiAnnotation.h"

@implementation MCPoiAnnotation

- (instancetype)initWithImage:(NSString *)imgUrl title:(NSString *)t gps:(NSString *)pos {
    self = [super init];
    if (self) {
        self.title = t;
        self.imageUrl = [NSURL URLWithString:imgUrl];
        NSArray *latlng = [pos componentsSeparatedByString:@","];
        self.coordinate = CLLocationCoordinate2DMake([[latlng objectAtIndex:0] doubleValue], [[latlng objectAtIndex:1] doubleValue]);
    }
    return self;
}


- (MCPoiAnnotationView *)viewForAnnotation {
    MCPoiAnnotationView *view = [[MCPoiAnnotationView alloc] initWithAnnotation:self reuseIdentifier:MapPoiReusedIdentifier];
    view.enabled = YES;
    view.canShowCallout = YES;
    return view;
}

@end

@implementation MCPoiAnnotationView

- (void)setAnnotation:(id<MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[MCPoiAnnotation class]]) {
        MCPoiAnnotation *poiAnnotation = (MCPoiAnnotation *)annotation;
        if (self.imageview == nil){
            self.imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
            [self addSubview:self.imageview];
        }
        [self.imageview setImageWithURL:poiAnnotation.imageUrl];
        //self.image = self.imageview.image;
        
    }
    [super setAnnotation:annotation];
}

@end
