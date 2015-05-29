//
//  MCBaiduPicResult.h
//  mycity
//
//  Created by openapp on 15/5/21.
//  Copyright (c) 2015年 openapp. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MCBaiduPicResultDelegate <NSObject>
- (void)doneWithSimilars:(NSDictionary *)info andKeywords:(NSArray *)key;
@end

@interface MCBaiduPicResult : NSObject

@property (nonatomic, weak) id<MCBaiduPicResultDelegate> delegate;

- (void)getPicInfoWithUrl:(NSString *)url;

@end
