//
//  VLRequest.h
//  HuXiu
//
//  Created by zhangting on 15/1/9.
//  Copyright (c) 2015年 Lei Yan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NSString* SGRequestType;

/**
 *  网络请求处理回调
 *
 *  @param resultDic 服务器请求数据结果
 *  @param error     错误信息，如果无则为nil
 */
typedef void(^SGRequestFinishAction)(NSDictionary *resultDic,NSError *error);
typedef void(^SGRequestFinishActionWithStr)(NSString *resultStr,NSError *error);

typedef enum _HTTPMethd
{
    HTTPMethod_Get,
    HTTPMethod_Post
}HTTPMethd;

/**
 表示动态配置域名服务状态
 */
typedef enum _SGRequestURLConfigStatus
{
    SGRequestConfigStatus_NotStarting,
    SGRequestConfigStatus_Getting,
    SGReqeustConfigStatus_Success,
    SGRequestConfigStatus_Failed
}SGRequestURLConfigStatus;

#define DeviceOS [NSString stringWithFormat:@"%@ %@",[[UIDevice currentDevice] systemName],[[UIDevice currentDevice] systemVersion]]
#define DeviceType [[UIDevice currentDevice] model]



@interface SGRequest : NSObject
@property(strong,nonatomic)NSString *dominString;//域名
@property(readonly, nonatomic)SGRequestType requestType;
@property(readonly, nonatomic)NSMutableString *urlString;
//附加参数如 a=b&c=d
@property(strong, nonatomic)NSString *addtionalParamString;

@property(assign,nonatomic)BOOL isUseCache;

/**
 *  1、网络请求失败后重新请求的次数
    2、默认为0，不重新请求
    3、重复请求次数不包括第一次请求，如retryCount=2，失败后重复请求两次
 */
@property(assign,nonatomic)int retryCount;


+(NSString*)serverConfigURLStr;


/**
 *  根据请求类型初始化
 *
 *  @param requestType 请求类型
 *
 *  @return VLRequest
 */
-(id)initWithRequestType:(SGRequestType)requestType;
+(id)requestWithType:(SGRequestType)requestType;
+(id)requestWithDominString:(NSString*)dominString;
+(id)requestWithDominString:(NSString*)dominString withType:(SGRequestType)requestType;

/**
 *  动态添加参数
 *
 *  @param parame 参数值
 *  @param key    参数名称
 */
-(void)addParam:(NSString*)param forKey:(NSString*)key;
-(void)addParamObj:(id)param forKey:(NSString *)key;
-(void)addDefaultUserKey;//venderID
-(void)addDefaultDeviceInfo;//deviceName
/**
 *  启动网络请求
 *
 *  @param finishAction 网络请求结束回调
 *  @param method       HTTP请求方式
 */
-(void)startRequestwithMethod:(HTTPMethd)method WithFinishAction:(SGRequestFinishAction)finishAction ;
//上传图片
-(void)startUploadData:(NSData*)imageData imagePath:(NSString*)path ByPostWithFinishAction:(SGRequestFinishActionWithStr)finishAction;
+ (BOOL)resultOK:(NSDictionary*)dic;
@end
