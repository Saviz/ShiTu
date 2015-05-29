//
//  MCSogouPicResult.m
//  mycity
//
//  Created by openapp on 15/5/21.
//  Copyright (c) 2015年 openapp. All rights reserved.
//

#import "MCSogouPicResult.h"
#import "AFNetworking.h"
#import "NSString+URLEncoding.h"

@implementation MCSogouPicResult

- (void)getPicInfoWithUrl:(NSString *)url {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"application/x-javascript"];
    NSString *reqUrl = [@"http://pic.sogou.com/ris?flag=1&query=" stringByAppendingFormat:@"%@", [url urlEncodeUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"%@", reqUrl);
    [manager
     GET:reqUrl
     parameters:nil
     success:^(AFHTTPRequestOperation *operation, id responseObject) {
         NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
         NSString *response = [[NSString alloc] initWithData:responseObject encoding:gbkEncoding];
         //NSLog(@"%@", response);
         
         NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\\"items\\\":(\\[.*?\\}\\])" options:0 error:NULL];
         NSTextCheckingResult *newSearchString = [regex firstMatchInString:response options:0 range:NSMakeRange(0, [response length])];
         NSString *json = [response substringWithRange:[newSearchString rangeAtIndex:1]];
         //NSLog(@"%@", json);
         
         [self.delegate
          doneWithSimilars:[NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil]
          ];
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         NSLog(@"Error: %@", error);
         [self.delegate doneWithSimilars:nil];
     }
     ];
}

@end
