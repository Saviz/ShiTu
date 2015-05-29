//
//  STPicInfo.h
//  ShiTu
//
//  Created by openapp on 15/5/29.
//  Copyright (c) 2015年 Tudo Gostoso Internet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface STPicInfo : NSObject

@property (nonatomic, retain) NSString *url;
@property (nonatomic, assign) CLLocationCoordinate2D gps;
@property (nonatomic, assign) BOOL isGpsSetted;



@end
