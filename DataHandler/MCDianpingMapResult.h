//
//  MCDianpingMapResult.h
//  mycity
//
//  Created by openapp on 15/5/28.
//  Copyright (c) 2015年 openapp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@protocol MCDianpingMapResultDelegate <NSObject>
- (void)doneWithShops:(NSArray *)info;
@end

@interface MCDianpingMapResult : NSObject

@property (nonatomic, weak) id<MCDianpingMapResultDelegate> delegate;

- (void)getInfoWithGPS:(CLLocationCoordinate2D)gps;

@end

