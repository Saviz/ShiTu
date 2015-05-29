//
//  STPicInfo.m
//  ShiTu
//
//  Created by openapp on 15/5/29.
//  Copyright (c) 2015年 Tudo Gostoso Internet. All rights reserved.
//

#import "STPicInfo.h"

@implementation STPicInfo

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isGpsSetted = NO;
        self.url = nil;
    }
    return self;
}


- (void)setGps:(CLLocationCoordinate2D)gps {
    self.isGpsSetted = YES;
    self.gps = gps;
}


@end
