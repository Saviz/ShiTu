//
//  MCBaiduMoreResult.h
//  ShiTu
//
//  Created by openapp on 15/5/30.
//  Copyright (c) 2015年 Tudo Gostoso Internet. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MCBaiduMoreResultDelegate <NSObject>
- (void)doneWithMore:(NSDictionary *)info;
@end

@interface MCBaiduMoreResult : NSObject

@property (nonatomic, weak) id<MCBaiduMoreResultDelegate> delegate;
- (void)getPicInfoWithUrl:(NSString *)url;

@end
