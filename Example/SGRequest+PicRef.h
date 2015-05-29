//
//  SGRequest+PicRef.h
//  SGImageRecognition
//
//  Created by zhangting on 15/4/24.
//  Copyright (c) 2015年 zhangting. All rights reserved.
//

#import "SGRequest.h"

extern SGRequestType ImageRec;
extern SGRequestType AnswerRec;
extern SGRequestType ShoppingRec;

@interface SGRequest (PicRef)

+(SGRequest*)SGGetImageRecResultURLWithImageData:(NSData*)ImageData;

+(SGRequest*)SGGetAnswerResultURLWithImageData:(NSData*)ImageData;

+(SGRequest*)SGGetShopingResultURLWithImageData:(NSData*)imageData;
@end
