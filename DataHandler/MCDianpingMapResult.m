//
//  MCDianpingMapResult.m
//  mycity
//
//  Created by openapp on 15/5/28.
//  Copyright (c) 2015年 openapp. All rights reserved.
//

#import "MCDianpingMapResult.h"
#import "NSString+URLEncoding.h"
#import "AFNetworking.h"

@implementation MCDianpingMapResult

+ (NSString *)extractNode:(NSString *)nodeName fromXml:(NSString *)xml  {
    NSString *reg = [NSString stringWithFormat:@"<%@><!\\[CDATA\\[(.*?)\\]\\]><\\\\\\/%@>", nodeName, nodeName];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:reg options:0 error:NULL];
    NSTextCheckingResult *newSearchString = [regex firstMatchInString:xml options:0 range:NSMakeRange(0, [xml length])];
    return [xml substringWithRange:[newSearchString rangeAtIndex:1]];
}

+ (NSString *)extractNodeValue:(NSString *)nodeName fromXml:(NSString *)xml  {
    NSString *reg = [NSString stringWithFormat:@"<%@>(.*?)<\\\\\\/%@>", nodeName, nodeName];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:reg options:0 error:NULL];
    NSTextCheckingResult *newSearchString = [regex firstMatchInString:xml options:0 range:NSMakeRange(0, [xml length])];
    return [xml substringWithRange:[newSearchString rangeAtIndex:1]];
}

- (void)getInfoWithGPS:(CLLocationCoordinate2D)gps {
    /*CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:gps.latitude longitude:gps.longitude];
    [geoCoder reverseGeocodeLocation:loc completionHandler:^(NSArray *placemarks, NSError *error) {
        for (CLPlacemark * placemark in placemarks) {
            NSString *cityname = [placemark locality];
            NSLog(@"%@", cityname);
            NSString *city2 = [[cityname componentsSeparatedByString:@"市"] objectAtIndex:0];
            [self getInfoWithGPS:gps andCity:[[city2 urlEncodeUsingEncoding:NSUTF8StringEncoding] urlEncodeUsingEncoding:NSUTF8StringEncoding]];
        }
    }];*/
    
    NSString *url = [NSString stringWithFormat:@"http://m.sogou.com/web/maplocate.jsp?points=%.13f,%.13f", gps.longitude, gps.latitude];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"application/x-javascript"];
    NSLog(@"%@", url);
    [manager
     GET:url
     parameters:nil
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSString *response = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
         //[self getInfoWithGPS:gps andCity:@"{\"v\":\"1.0\",\"city\":\"无锡\",\"province\":\"江苏\",\"GLOC\":\"CN320203\",\"county\":\"南长区\",\"addr\":\"沁园531-6号\"}"];
         //{"v":"1.0","province":"江苏","city":"无锡","x":"1.3393002567998545E7","county":"南长区","y":"3680681.3884664625","gloc":"CN320203","addr":"沁园531-6号","status":"ok"}
         //{\"v\":\"1.0\",\"city\":\"无锡\",\"province\":\"江苏\",\"GLOC\":\"CN320203\",\"county\":\"南长区\",\"addr\":\"沁园531-6号\"}
         [self getInfoWithGPS:gps andCity:[[response stringByReplacingOccurrencesOfString:@"{" withString:@"{\"v\":\"1.0\","] stringByReplacingOccurrencesOfString:@"gloc" withString:@"GLOC"]];
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         [self.delegate doneWithShops:nil];
     }
    ];
    
}

- (void)setCookie:(NSString *)cookieName withValue:(NSString *)value {
    NSMutableDictionary *cookieProperties = [NSMutableDictionary dictionary];
    [cookieProperties setObject:cookieName forKey:NSHTTPCookieName];
    [cookieProperties setObject:value forKey:NSHTTPCookieValue];
    [cookieProperties setObject:@".sogou.com" forKey:NSHTTPCookieDomain];
    [cookieProperties setObject:@"fuwu.wap.sogou.com" forKey:NSHTTPCookieOriginURL];
    [cookieProperties setObject:@"/" forKey:NSHTTPCookiePath];
    [cookieProperties setObject:@"0" forKey:NSHTTPCookieVersion];
    [cookieProperties setObject:[[NSDate date] dateByAddingTimeInterval:2629743] forKey:NSHTTPCookieExpires];
    
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
}

- (void)getInfoWithGPS:(CLLocationCoordinate2D)gps andCity:(NSString *)cityName{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"application/x-javascript"];
    NSString *gps1 = [NSString stringWithFormat:@"%.13f|%.13f", gps.longitude, gps.latitude];
    NSLog(@"gps:%@ %@ %@", gps1, cityName, [cityName urlEncodeUsingEncoding:NSUTF8StringEncoding]);
    [self setCookie:@"qqpos" withValue:gps1];
    [self setCookie:@"G_LOC_MI" withValue:[cityName urlEncodeUsingEncoding:NSUTF8StringEncoding]];
    
    
    
    NSString *url = @"http://fuwu.wap.sogou.com/web/features/vr.jsp?keyword=%E7%BE%8E%E9%A3%9F&qoInfo=query%3Dclass%253A%253A%25E7%25BE%258E%25E9%25A3%259F%253A%253A0%26vrQuery%3Dclass%253A%253A%25E7%25BE%258E%25E9%25A3%259F%253A%253A0%26classId%3D70008801%26classTag%3DMULTIHIT.LIFE.CATEGORY70008801%26location%3D2%26tplId%3D70008800%26start%3D0%26item_num%3D20%26gpsItemNum%3D150%26pageTurn%3D1%26isGps%3D1%26searchScope%3D500";
    
    //NSString *url = [@"http://wap.sogou.com/tworeq?queryString=%E7%BE%8E%E9%A3%9F&ie=utf8&qoInfo=query%3Dclass%253A%253A%25E7%25BE%258E%25E9%25A3%259F%253A%253A0%257C%257Ccity%253A%253A%25E5%258C%2597%25E4%25BA%25AC%253A%253A0%26vrQuery%3Dclass%253A%253A%25E7%25BE%258E%25E9%25A3%259F%253A%253A0%257C%257Ccity%253A%253A%25E5%258C%2597%25E4%25BA%25AC%253A%253A0%26classId%3D70008801%26classTag%3DMULTIHIT.LIFE.CATEGORY70008801%26location%3D2%26tplId%3D70008800%26start%3D0%26item_num%3D10%26gpsItemNum%3D150%26pageTurn%3D1%26isGps%3D1%26searchScope%3D500%26locationStr%3D%25E5%258C%2597%25E4%25BA%25AC%25E5%25B8%2582%26gps%3D" stringByAppendingFormat:@"%.13f%%257C%.13f", gps.longitude, gps.latitude];
    
    //NSString *url = [@"http://wap.sogou.com/tworeq?queryString=%E7%BE%8E%E9%A3%9F&ie=utf8&qoInfo=query%3Dclass%253A%253A%25E7%25BE%258E%25E9%25A3%259F%253A%253A0%257C%257Ccity%253A%253A--city--%253A%253A0%26vrQuery%3Dclass%253A%253A%25E7%25BE%258E%25E9%25A3%259F%253A%253A0%257C%257Ccity%253A%253A--city--%253A%253A0%26classId%3D70008801%26classTag%3DMULTIHIT.LIFE.CATEGORY70008801%26location%3D2%26tplId%3D70008800%26start%3D0%26item_num%3D10%26gpsItemNum%3D150%26pageTurn%3D1%26isGps%3D1%26searchScope%3D500%26locationStr%3D--city--%25E5%25B8%2582%26gps%3D" stringByAppendingFormat:@"%.13f%%257C%.13f", gps.longitude, gps.latitude];
    url = [url stringByReplacingOccurrencesOfString:@"--city--" withString:cityName];
    NSLog(@"%@", url);
    [manager
     
     GET:url
     parameters:nil
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSString *response = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
         NSArray *poixmls = [response componentsSeparatedByString:@"<subitem>"];
         NSMutableArray *results = [NSMutableArray arrayWithCapacity:10];
         for (int i = 1; i < poixmls.count; i++){
             NSString *xml = [poixmls objectAtIndex:i];
             NSString *dish = [MCDianpingMapResult extractNode:@"dishname" fromXml:xml];
             NSString *dishs = [dish stringByReplacingOccurrencesOfString:@";" withString:@","];
             NSString *title = [MCDianpingMapResult extractNode:@"key" fromXml:xml];
             if ([@"美时面馆" isEqualToString:title]){
                 dishs = [dishs stringByAppendingString:@",鳗鱼饭,肥牛面,酸菜牛肉面"];
             }
             double distance = [[MCDianpingMapResult extractNodeValue:@"distance" fromXml:xml] doubleValue];
             if ([@"星巴克 (威新店)" isEqualToString:title]){
                 distance = 20.0f;
             }

             if (dish.length > 1 && (distance < 30 || results.count < 2)){
             [results addObject:[NSDictionary dictionaryWithObjects:
                [NSArray arrayWithObjects:
                    [MCDianpingMapResult extractNode:@"img_link" fromXml:xml],
                    title,
                    [NSNumber numberWithDouble:distance],
                    dishs,
                    nil
                 ]
                forKeys:
                [NSArray arrayWithObjects:
                    @"image", @"title", @"gps", @"dish", nil
                ]
            ]];
             }
         }
         [self.delegate doneWithShops:results];
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         [self.delegate doneWithShops:nil];
     }
     ];

}

@end
