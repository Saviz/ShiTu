//
//  MCCache.h
//  mycity
//
//  Created by openapp on 15/5/13.
//  Copyright (c) 2015年 openapp. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCCache : NSObject

+ (NSData *)loadCacheDataFromFile:(NSString *)fileName;
+ (NSDictionary *)loadCacheJsonFromFile:(NSString *)fileName;

+ (BOOL)writeCacheData:(NSData *)data toFile:(NSString *)fileName;
+ (BOOL)writeCacheJson:(NSDictionary *)json toFile:(NSString *)fileName;

+ (BOOL)writeCacheData:(NSData *)data toFile:(NSString *)fileName expireAfter:(NSUInteger)seconds;
+ (BOOL)writeCacheJson:(NSDictionary *)json toFile:(NSString *)fileName expireAfter:(NSUInteger)seconds;

+ (BOOL)fileExist:(NSString *)fileName;
+ (NSString *)getFilename:(NSString *)fileName atDirectory:(NSSearchPathDirectory)directory;

@end
