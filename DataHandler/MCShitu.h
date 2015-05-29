//
//  MCShitu.h
//  mycity
//
//  Created by openapp on 15/5/28.
//  Copyright (c) 2015年 openapp. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@protocol MCShituDelegate <NSObject>
- (void)doneWithShops:(NSString *)shops baidu:(NSString *)baidu sogou:(NSString *)sogou;
@end

@interface MCShitu : NSObject

@property (nonatomic, weak) id<MCShituDelegate> delegate;

- (void)fetchWithGPS:(CLLocationCoordinate2D)gps andImage:(NSString *)imageUrl;

@end
