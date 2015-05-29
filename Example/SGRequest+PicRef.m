//
//  SGRequest+PicRef.m
//  SGImageRecognition
//
//  Created by zhangting on 15/4/24.
//  Copyright (c) 2015年 zhangting. All rights reserved.
//

#import "SGRequest+PicRef.h"
#define PicDomin @"http://wap.sogou.com/pic/"  //10.134.24.227  wap.sogou.com
#define TestPicDomin @"http://10.134.24.227/pic/"
SGRequestType ImageRec  = @"upload_pic.jsp";
SGRequestType AnswerRec = @"paiti/result.jsp";
SGRequestType ShoppingRec = @"";
@implementation SGRequest (PicRef)
+(SGRequest*)SGGetImageRecResultURLWithImageData:(NSData*)ImageData;
{
    SGRequest *request = [SGRequest requestWithDominString:TestPicDomin withType:ImageRec];
//    [request addParamObj:ImageData forKey:@"pic_path"];
    return request;
}

+(SGRequest*)SGGetAnswerResultURLWithImageData:(NSData*)ImageData
{
    SGRequest *request = [SGRequest requestWithDominString:TestPicDomin withType:ImageRec];
//    [request addParamObj:ImageData forKey:@"ocr_img"];
    return request;
}
+(SGRequest*)SGGetShopingResultURLWithImageData:(NSData*)imageData
{
    SGRequest *request = [SGRequest requestWithDominString:TestPicDomin withType:ImageRec];
    return request;
}
@end
