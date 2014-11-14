//
//  MyFileManager.m
//  MyNetworkKit
//
//  Created by wadexiong on 14/11/13.
//  Copyright (c) 2014年 xiong. All rights reserved.
//

#import "MyFileManager.h"
#import <Foundation/Foundation.h>

@implementation MyFileManager

+ (void)writeTo:(NSString *)filePath Data:(NSData *)data{
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        
        NSLog(@"%@ - 已经存在 , 正在删除文件, 然后重新写入文件!" , filePath);
        
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        [data writeToFile:filePath atomically:YES];
    }
}

+ (NSData *)responseDataFromPath:(NSString *)filePath {
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        
        @autoreleasepool {
            NSData * data = [[NSData alloc] initWithContentsOfFile:filePath];
            if (data != nil) {
                return data;
            }
            return  nil;
        }
    }
    return nil;
}

@end
