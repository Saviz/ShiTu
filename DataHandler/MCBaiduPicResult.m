//
//  MCBaiduPicResult.m
//  mycity
//
//  Created by openapp on 15/5/21.
//  Copyright (c) 2015年 openapp. All rights reserved.
//

#import "MCBaiduPicResult.h"
#import "AFNetworking.h"
#import "NSString+URLEncoding.h"

@implementation MCBaiduPicResult

- (void)getPicInfoWithUrl:(NSString *)url {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"application/x-javascript"];
    //NSString *reqUrl = [@"http://image.baidu.com/n/pc_search?fm=searchresult&pos=urlsearch" stringByAppendingFormat:@"&queryImageUrl=%@", [url urlEncodeUsingEncoding:NSUTF8StringEncoding]];
    NSString *reqUrl = [@"http://image.baidu.com/n/similar?rn=500" stringByAppendingFormat:@"&queryImageUrl=%@", [url urlEncodeUsingEncoding:NSUTF8StringEncoding]];
    
    NSLog(@"%@", reqUrl);
    [manager
     GET:reqUrl
     parameters:nil
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSString *response = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
         //NSLog(@"%@", response);
         /*NSRegularExpression *regexKey = [NSRegularExpression regularExpressionWithPattern:@"keywords:'(\\[.*?\\])" options:0 error:NULL];
         NSTextCheckingResult *newSearchStringKey = [regexKey firstMatchInString:response options:0 range:NSMakeRange(0, [response length])];
         NSString *jsonKey = [[response substringWithRange:[newSearchStringKey rangeAtIndex:1]] stringByReplacingOccurrencesOfString:@"\\x22" withString:@"\""];
         //NSLog(@"%@", jsonKey);
         */
         
         //NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"similarData.*?'(\\[.*?\\])'" options:0 error:NULL];
         NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"data.*?(\\[.*?\\]),\\\"" options:0 error:NULL];
         NSTextCheckingResult *newSearchString = [regex firstMatchInString:response options:0 range:NSMakeRange(0, [response length])];
         NSString *json = [[response substringWithRange:[newSearchString rangeAtIndex:1]] stringByReplacingOccurrencesOfString:@"\\x22" withString:@"\""];
         
         [self.delegate
          doneWithSimilars:[NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil]
          andKeywords:[NSJSONSerialization JSONObjectWithData:[@"[]" dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil]
          ];
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         [self.delegate doneWithSimilars:nil andKeywords:nil];
     }
     ];
}

@end
