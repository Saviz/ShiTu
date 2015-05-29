//
//  MCSogouPicResult.h
//  mycity
//
//  Created by openapp on 15/5/28.
//  Copyright (c) 2015年 openapp. All rights reserved.
//


#import <Foundation/Foundation.h>

@protocol MCSogouPicResultDelegate <NSObject>
- (void)doneWithSimilars:(NSDictionary *)info;
@end

@interface MCSogouPicResult : NSObject

@property (nonatomic, weak) id<MCSogouPicResultDelegate> delegate;

- (void)getPicInfoWithUrl:(NSString *)url;

@end
