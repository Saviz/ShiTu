
//
//  VLRequest.m
//  HuXiu
//
//  Created by zhangting on 15/1/9.
//  Copyright (c) 2015年 Lei Yan. All rights reserved.
//

#import "SGRequest.h"
#import "AFNetworking.h"

#define userKey [[[UIDevice currentDevice] identifierForVendor] UUIDString]
#define deviceInfo [[UIDevice currentDevice] name];
#define deviceOS [NSString stringWithFormat:@"%@ %@",[[UIDevice currentDevice] systemName],[[UIDevice currentDevice] systemVersion]];
#define deviceType [[UIDevice currentDevice] model];
#define SGAppVersion    [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define SGAppBuild  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]

@interface SGRequest()
{
    NSMutableDictionary *_paramMutableDic;
}

@property(strong, nonatomic)SGRequestType requestType;
@property(strong, nonatomic)NSMutableString *urlString;

@property(retain, nonatomic)AFHTTPRequestOperation *afRequest;
@end


static NSString *_serverConfigURLStr = nil;

@implementation SGRequest

#pragma mark - serverConfigURLStr 
+(void)setServerConfigURLStr:(NSString*)serverConfig
{
    _serverConfigURLStr = serverConfig;
}

+(NSString*)serverConfigURLStr
{
    return _serverConfigURLStr;
}

#pragma mark - lifeCycle

-(id)init
{
    self = [super init];
    if (self !=nil )
    {
        _isUseCache = YES;
        _retryCount = 0;
        _paramMutableDic = [NSMutableDictionary dictionary];
        
        
    }
    return self;
}

-(id)initWithRequestType:(SGRequestType)requestType
{
    self = [self init];
    if (self)
    {
        _requestType = requestType;
        _urlString = [NSMutableString string];
        
    }
    return self;
}


+(id)requestWithType:(SGRequestType)requestType
{
    return [[SGRequest alloc] initWithRequestType:requestType];
}


+(id)requestWithDominString:(NSString*)dominString;
{
    SGRequest *request = [[SGRequest alloc] init];
    request.dominString = dominString;
    return request;
}

+(id)requestWithDominString:(NSString*)dominString withType:(SGRequestType)requestType
{
    SGRequest *request = [[SGRequest alloc] initWithRequestType:requestType];
    request.dominString = dominString;
    return request;
    
}
-(void)dealloc
{
    self.requestType = nil;
    self.urlString = nil;
}

#pragma mark - utility method

-(void)addDefaultUserKey
{
    _paramMutableDic[@"userKey"]=[NSString stringWithFormat:@"vid:%@",userKey];
}
-(void)addDefaultDeviceInfo
{
    _paramMutableDic[@"deviceInfo"] = deviceInfo;
}

-(void)addParam:(NSString*)param forKey:(NSString*)key
{
    if (param.length == 0 || key.length == 0)
    {
        /**
         *  logwarning
         */
        if(key.length>0)
        {
            _paramMutableDic[key] = [NSNull null];
        }
        
        return;
    }
     _paramMutableDic[key] = param;
}

-(void)addParamObj:(id)param forKey:(NSString *)key
{
    if (param == nil || key.length ==0)
    {
        return;
    }
    _paramMutableDic[key] = param;
}
-(NSString*)buildParameterForPostRequest
{
    NSMutableString *urlStr = [NSMutableString string];
    
    for (NSString *key in _paramMutableDic)
    {
//        NSString *param = _paramMutableDic[key];
        
        id param = _paramMutableDic[key];
        if ([param isKindOfClass:[NSString class]])
        {
            [urlStr appendString:[NSString stringWithFormat:@"%@=%@",key,param]];
        }
        if ([param isKindOfClass:[NSDictionary class]])
        {
            if (param != nil)
            {
                NSError *error;
                
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:&error];
                if (!jsonData)
                {
                    NSLog(@"json erro %@",error);
                    return @"[]";
                }
                else
                {
                    [urlStr appendString:[NSString stringWithFormat:@"%@=%@",key,[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding]]];
                }
                
            }
        }
        
    }
    return urlStr;
}

/**
 *  动态拼装get请求URL
 *
 *  @return urlString
 */
-(NSString*)buildURLStringForGetReqeust
{
    if (self.dominString.length == 0)
    {
        assert(self.dominString);
        return nil;
    }
    NSMutableString *urlStr = [NSMutableString string];
    [urlStr appendString:self.dominString];
    if (self.requestType.length>0)
    {
        [urlStr appendString:self.requestType];
    }
    
    [urlStr appendString:@"?"];
    
    if(self.addtionalParamString.length>0)
    {
        [urlStr appendString:self.addtionalParamString];
    }
    
    for (NSString *key in _paramMutableDic)
    {
        NSString *param = _paramMutableDic[key];
        if (param.length>0)
        {
            [urlStr appendString:[NSString stringWithFormat:@"%@=%@&",key,param]];
        }
    }
    self.urlString = urlStr;
    return self.urlString;
}

-(NSString*)buildURLStringForPostRequest
{
    if (self.dominString.length == 0)
    {
        assert(self.dominString);
        return nil;
    }
    NSMutableString *preDominString = [NSMutableString string];
    [preDominString appendString:_dominString];
    if (self.requestType.length>0)
    {
        [preDominString appendString:self.requestType];
    }
    if (self.addtionalParamString.length>0)
    {
        [preDominString appendString:self.addtionalParamString];
    }
    self.urlString = preDominString;
    return self.urlString;
}


static SGRequestURLConfigStatus _URLConfigStatus;
-(void)getURLConfigQueue:(dispatch_queue_t)queue
{
    /**
     *  动态获取服务器地址配置
     *
     *  @return 无返回值
     */
#ifdef DEBUG
    _serverConfigURLStr = @"http://10.12.131.40:8888";
    
#else
    _serverConfigURLStr = @"http://10.12.131.40:8888";
#endif
    _URLConfigStatus = SGReqeustConfigStatus_Success;

}

#pragma mark - request references
-(void)startRequestwithMethod:(HTTPMethd)method WithFinishAction:(SGRequestFinishAction)finishAction 
{
    /**
     *  是否开启网络请求各种异常判断
     */
    if (_URLConfigStatus == SGReqeustConfigStatus_Success || self.dominString.length>0)
    {
        /**
         *  域名已进行配置，可直接进行请求
         */
        [self doStartWithFinishAction:finishAction withMethod:method];
        return;
    }
    
    static dispatch_queue_t queue = nil;
    static dispatch_once_t oneToken;
    dispatch_once(&oneToken, ^{
        queue = dispatch_queue_create("SGRequest", DISPATCH_QUEUE_SERIAL);
    });
    dispatch_async(queue, ^{
        if (_URLConfigStatus != SGReqeustConfigStatus_Success )
        {
            if (_URLConfigStatus != SGRequestConfigStatus_Getting)
            {
                _URLConfigStatus = SGRequestConfigStatus_Getting;
                [self getURLConfigQueue:queue];
            }
        }
        while (_URLConfigStatus == SGRequestConfigStatus_Getting)
        {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        if (_URLConfigStatus == SGReqeustConfigStatus_Success)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self doStartWithFinishAction:finishAction withMethod:method];

            });
            return ;
        }
        else
        {
            NSError *error = [NSError errorWithDomain:@"SGRequestError" code:0 userInfo:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                finishAction(nil,error);
            });
        }
        
    });
        
}

-(void)doStartWithFinishAction:(SGRequestFinishAction)finishAction withMethod:(HTTPMethd)method
{
    if (method == HTTPMethod_Get)
    {
        [self doStartGetWithFinishAction:finishAction];
    }
    else
    {
        [self doStartPostWithFinishAction:finishAction];
    }
}


-(void)doStartGetWithFinishAction:(SGRequestFinishAction)finishAction
{
    if (finishAction == nil)
    {
        /**
         *  logwarning
         */
        return;
    }
    static AFHTTPRequestOperationManager *afRequestOperationManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        afRequestOperationManager = [[AFHTTPRequestOperationManager alloc] init];
    });
    /**
     *  动态构建URLString
     */
    [self buildURLStringForGetReqeust];
    
    self.afRequest = [afRequestOperationManager GET:self.urlString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject)
                      {
                          if ([responseObject isKindOfClass:[NSNull class]])
                          {
                              responseObject = nil;
                          }
                          finishAction(responseObject,nil);
                      }
                      failure:^(AFHTTPRequestOperation *operation, NSError *error)
                     {
                         finishAction(nil,error);
                     }];
    
    AFHTTPResponseSerializer *serializer = self.afRequest.responseSerializer;
    serializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/html", nil];
    [afRequestOperationManager.requestSerializer setTimeoutInterval:8];
}

-(void)doStartPostWithFinishAction:(SGRequestFinishAction)finishAction
{
    if (finishAction == nil)
    {
        
        return;
    }
    static AFHTTPRequestOperationManager *afRequestOperationManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        afRequestOperationManager = [[AFHTTPRequestOperationManager alloc] init];
        [afRequestOperationManager.requestSerializer setTimeoutInterval:5];
        NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        afRequestOperationManager.responseSerializer.stringEncoding = gbkEncoding;
    });

    NSString *postUrl = [[[self buildURLStringForPostRequest] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] copy];
    self.afRequest = [afRequestOperationManager POST:postUrl parameters:_paramMutableDic success:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        if ([responseObject isKindOfClass:[NSNull class]])
        {
            responseObject = nil;
        }
        finishAction(responseObject,nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        finishAction(nil,error);
    }];
    
    AFHTTPResponseSerializer *serializer = self.afRequest.responseSerializer;
    serializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/html", nil];
    
    afRequestOperationManager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
}

-(void)startUploadData:(NSData*)imageData imagePath:(NSString*)path ByPostWithFinishAction:(SGRequestFinishActionWithStr)finishAction
{
    /**
     *  是否开启网络请求各种异常判断
     */
    if (_URLConfigStatus == SGReqeustConfigStatus_Success || self.dominString.length>0)
    {
        /**
         *  域名已进行配置，可直接进行请求
         */
        [self doUploadImageData:imageData imagePath:path finishAction:finishAction];
        return;
    }
}
-(void)doUploadImageData:(NSData*)imageData imagePath:(NSString*)path finishAction:(SGRequestFinishActionWithStr)finishAction
{
    if (finishAction == nil)
    {
        return;
    }
    
    static AFHTTPRequestOperationManager *afRequestOperationManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        afRequestOperationManager = [[AFHTTPRequestOperationManager alloc] init];
        [afRequestOperationManager.requestSerializer setTimeoutInterval:10];
        NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        afRequestOperationManager.responseSerializer.stringEncoding = gbkEncoding;
    });
    
    NSString *postUrl = [[[self buildURLStringForPostRequest] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] copy];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.requestSerializer setValue:[@"SogouImageRecognition_ios/" stringByAppendingString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]] forHTTPHeaderField:@"User-Agent"];
    [manager.requestSerializer setValue:[@"SogouImageRecognition_ios/" stringByAppendingString:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]] forHTTPHeaderField:@"appversion"];
    [manager POST:postUrl parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:path fileName:@"imageName.jpg" mimeType:@"image/jpeg"];
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSNull class]])
        {
            responseObject = nil;
        }
        finishAction(responseObject,nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        finishAction(nil,error);
    }];
    AFHTTPResponseSerializer *serializer = manager.responseSerializer;
    serializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/html",@"text/plain", nil];
    
}

+ (BOOL)resultOK:(NSDictionary*)dic
{
    if ([dic isKindOfClass:NSDictionary.class])
    {
        int ret = [dic[@"retInfo"] intValue];
        return ret == 0;
    }
    
    return NO;
}

-(void)cancel
{
    [self.afRequest cancel];
}
-(BOOL)isEqual:(SGRequest*)request
{
    return [request.urlString isEqualToString:self.urlString];
}
-(NSString*)description
{
    NSMutableString *str = [NSMutableString string];
    [str appendString:self.urlString];
    NSLog(@"%@",str);
    return str;
}

@end
