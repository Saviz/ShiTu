//
//  MCBaiduMoreResult.m
//  ShiTu
//
//  Created by openapp on 15/5/30.
//  Copyright (c) 2015年 Tudo Gostoso Internet. All rights reserved.
//

#import "MCBaiduMoreResult.h"
#import "AFNetworking.h"
#import "NSString+URLEncoding.h"

@implementation MCBaiduMoreResult

- (void)getPicInfoWithUrl:(NSString *)url {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"application/x-javascript"];
    //NSString *reqUrl = [@"http://image.baidu.com/n/pc_search?fm=searchresult&pos=urlsearch" stringByAppendingFormat:@"&queryImageUrl=%@", [url urlEncodeUsingEncoding:NSUTF8StringEncoding]];
    NSString *reqUrl = [@"http://image.baidu.com/n/similar?pn=30&rn=230" stringByAppendingFormat:@"&queryImageUrl=%@", [url urlEncodeUsingEncoding:NSUTF8StringEncoding]];
    
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
          doneWithMore:[NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil]
          ];
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         [self.delegate doneWithMore:nil];
     }
     ];
}

@end
