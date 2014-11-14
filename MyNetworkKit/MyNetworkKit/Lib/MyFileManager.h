//
//  MyFileManager.h
//  MyNetworkKit
//
//  Created by wadexiong on 14/11/13.
//  Copyright (c) 2014年 xiong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyFileManager : NSObject

/**
 *  写入文件，如果文件存在，删除后，再写入
 */
+ (void)writeResponseDataTo:(NSString *)filePath Data:(NSData *)data;

/**
 *  从response data的缓存文件返回NSData
 */
+ (NSData *)responseDataFromPath:(NSString *)filePath;

@end
