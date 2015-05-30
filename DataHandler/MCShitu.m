//
//  MCShitu.m
//  mycity
//
//  Created by openapp on 15/5/28.
//  Copyright (c) 2015年 openapp. All rights reserved.
//

#import "MCShitu.h"
#import "MCBaiduPicResult.h"
#import "MCBaiduMoreResult.h"
#import "MCSogouPicResult.h"
#import "MCDianpingMapResult.h"

@interface MCShitu ()<MCBaiduPicResultDelegate, MCSogouPicResultDelegate, MCDianpingMapResultDelegate, MCBaiduMoreResultDelegate>
@end
@implementation MCShitu {
    NSArray *dianping;
    NSDictionary *baidu;
    NSDictionary *baidum;
    NSDictionary *sogou;
    NSArray *keywords;
    NSUInteger done;
    MCDianpingMapResult *dp;
    MCBaiduPicResult *bd;
    MCBaiduMoreResult *bm;
    MCSogouPicResult *sg;
    NSRegularExpression *regex1;
    NSRegularExpression *regex2;
}

- (void)doneWithMore:(NSDictionary *)info {
    baidum = info;
    [self isDone];
}

- (void)doneWithSimilars:(NSDictionary *)info {
    sogou = info;
    [self isDone];
}

- (void)doneWithSimilars:(NSDictionary *)info andKeywords:(NSArray *)key {
    keywords = key;
    baidu = info;
    [self isDone];
}

- (void)doneWithShops:(NSArray *)info {
    dianping = info;
    [self isDone];
}

- (NSString *)pureString:(NSString *)modifiedString{
    //NSString *modifiedString = [regex1 stringByReplacingMatchesInString:str options:0 range:NSMakeRange(0, [str length]) withTemplate:@" "];
    NSString *ret = [regex2 stringByReplacingMatchesInString:modifiedString options:0 range:NSMakeRange(0, [modifiedString length]) withTemplate:@""];
    return ret;
}

- (void)isDone {
    done += 1;
    if (done > 3){
        NSMutableArray *dpArr = [NSMutableArray arrayWithCapacity:10];
        for (NSDictionary *dict in dianping) {
            [dpArr addObject:[[dict objectForKey:@"title"] stringByAppendingFormat:@";;;%@|||", [dict objectForKey:@"dish"]]];
        }
        //NSLog(@"dianping:%@", [dpArr componentsJoinedByString:@""]);
        
        NSMutableArray *bdArr = [NSMutableArray arrayWithCapacity:baidum.count+baidu.count];
        for (NSDictionary *dict in baidu) {
            [bdArr addObject:[[dict objectForKey:@"fromPageTitle"] stringByAppendingFormat:@";;;%@|||", [dict objectForKey:@"textHost"]]];
        }
        
        for (NSDictionary *dict in baidum) {
            [bdArr addObject:[[dict objectForKey:@"fromPageTitle"] stringByAppendingFormat:@";;;%@|||", [dict objectForKey:@"textHost"]]];
        }
        
        NSString *baiduStr1 = [keywords componentsJoinedByString:@";;;"];
        NSString *baiduStr2 = [bdArr componentsJoinedByString:@""];
        NSString *baiduStr = [self pureString:[baiduStr1 stringByAppendingFormat:@"\t%@", baiduStr2]];
        NSString *convertedString = [baiduStr mutableCopy];
        
        CFStringRef transform = CFSTR("Any-Hex/Java");
        CFStringTransform((__bridge CFMutableStringRef)convertedString, NULL, transform, YES);

        //NSLog(@"baidu:%@", convertedString);
        
        NSMutableArray *sgArr = [NSMutableArray arrayWithCapacity:[sogou count]];
        for (NSDictionary *dict in sogou) {
            [sgArr addObject:[[dict objectForKey:@"title"] stringByAppendingString:@";;;|||"]];
        }
        //NSLog(@"sogou:%@", [sgArr componentsJoinedByString:@""]);
        
        
        
        [self.delegate doneWithShops:[dpArr componentsJoinedByString:@""] baidu:convertedString sogou:[sgArr componentsJoinedByString:@""]];
    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        dp = [[MCDianpingMapResult alloc] init];
        dp.delegate = self;
        
        bd = [[MCBaiduPicResult alloc] init];
        bd.delegate = self;
        
        sg = [[MCSogouPicResult alloc] init];
        sg.delegate = self;
        
        bm = [[MCBaiduMoreResult alloc] init];
        bm.delegate = self;
        
        NSError *error = nil;
        regex1 = [NSRegularExpression regularExpressionWithPattern:@"[;|]" options:0 error:&error];
        regex2 = [NSRegularExpression regularExpressionWithPattern:@"<.*?>" options:0 error:&error];

    }
    return self;
}

- (void)fetchWithGPS:(CLLocationCoordinate2D)gps andImage:(NSString *)imageUrl {
    done = 0;
    dianping = nil;
    baidu = nil;
    sogou = nil;
    keywords = nil;
    baidum = nil;
    //[self.delegate doneWithShops:@"a" baidu:@"b" sogou:@"c"];
    [dp getInfoWithGPS:gps];
    [bd getPicInfoWithUrl:imageUrl];
    [sg getPicInfoWithUrl:imageUrl];
    [bm getPicInfoWithUrl:imageUrl];
}
@end
