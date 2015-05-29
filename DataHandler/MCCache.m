//
//  MCCache.m
//  mycity
//
//  Created by openapp on 15/5/13.
//  Copyright (c) 2015年 openapp. All rights reserved.
//

#import "MCCache.h"
#import <Foundation/Foundation.h>

#define PREF_KEY (@"cache.time.")

@implementation MCCache

#pragma mark - basic

+ (BOOL)fileExist:(NSString *)fileName {
    return [[NSFileManager defaultManager] fileExistsAtPath:fileName];
}


+ (NSString *)getFilename:(NSString *)fileName atDirectory:(NSSearchPathDirectory)directory {
    NSArray * paths = NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES);
    if ([paths count] < 1) {
        return nil;
    }
    return [[paths objectAtIndex:0] stringByAppendingFormat:@"/%@", fileName];
}

+ (NSDictionary *)toJson:(NSData *)data {
    if (data){
        return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    }
    return nil;
}

+ (NSData *)fromJson:(NSDictionary *)json {
    if (json){
        return [NSJSONSerialization dataWithJSONObject:json options:0 error:nil];
    }
    return nil;
}

#pragma mark - load
+ (NSData *)loadDataFromFile:(NSString *)fileName atDirectory:(NSSearchPathDirectory)directory {
    NSString *fName = [MCCache getFilename:fileName atDirectory:directory];
                         
    if (fName != nil && [MCCache fileExist:fName]){
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSInteger expire = [userDefaults integerForKey:[MCCache keyForExpire:fileName atDirectory:directory]];
        if (expire > 0){
            if (expire < (NSInteger)[[NSDate date] timeIntervalSince1970]){
                //date expired
                [userDefaults removeObjectForKey:[MCCache keyForExpire:fileName atDirectory:directory]];
                [[NSFileManager defaultManager] removeItemAtPath:fName error:nil];
                return nil;
            }
        }
        return [NSData dataWithContentsOfFile:fName];
    }
    return nil;
}

+ (NSData *)loadCacheDataFromFile:(NSString *)fileName {
    return [MCCache loadDataFromFile:fileName atDirectory:NSCachesDirectory];
}

+ (NSDictionary *)loadCacheJsonFromFile:(NSString *)fileName {
    return [MCCache toJson:[MCCache loadCacheDataFromFile:fileName]];
}

+ (NSString *)keyForExpire:(NSString *)fileName atDirectory:(NSSearchPathDirectory)directory {
    return [PREF_KEY stringByAppendingFormat:@"%ld-%@", directory, fileName];
}

#pragma mark - write
+ (BOOL)writeData:(NSData *)data toFile:(NSString *)fileName atDirectory:(NSSearchPathDirectory)directory expireAfter:(NSUInteger)seconds{
    if (data != nil) {
        NSString *fileWithPathName = [MCCache getFilename:fileName atDirectory:directory];
        if (seconds > 0){
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setInteger:((NSInteger)[[NSDate date] timeIntervalSince1970])+seconds
                             forKey:[MCCache keyForExpire:fileName atDirectory:directory]];
            [userDefaults synchronize];
        }
        [data writeToFile:fileWithPathName atomically:YES];
    }
    return NO;
}

+ (BOOL)writeCacheData:(NSData *)data toFile:(NSString *)fileName {
    return [MCCache writeCacheData:data toFile:fileName expireAfter:0];
}

+ (BOOL)writeCacheJson:(NSDictionary *)json toFile:(NSString *)fileName {
    return [MCCache writeCacheJson:json toFile:fileName expireAfter:0];
}

+ (BOOL)writeCacheData:(NSData *)data toFile:(NSString *)fileName expireAfter:(NSUInteger)seconds {
    
    return [MCCache writeData:data toFile:fileName atDirectory:NSCachesDirectory expireAfter:seconds];
}

+ (BOOL)writeCacheJson:(NSDictionary *)json toFile:(NSString *)fileName expireAfter:(NSUInteger)seconds {
    return [MCCache writeCacheData:[MCCache fromJson:json] toFile:fileName expireAfter:seconds];
}

@end
