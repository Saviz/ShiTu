//
//  MCResultView.h
//  ShiTu
//
//  Created by xingzhenzhen on 15/5/30.
//  Copyright (c) 2015年 Tudo Gostoso Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MCResultViewDelegate <NSObject>

- (void) didSelectFoodNameResult:(NSString *)foodName;
- (void) didReshotButtonClick;

@end

@interface MCResultView : UIView

@property(nonatomic, weak)id<MCResultViewDelegate> delegate;
- (instancetype)initWithFrame:(CGRect)frame WithURL:(NSString*)url WithResult:(NSArray *)result;

@end
