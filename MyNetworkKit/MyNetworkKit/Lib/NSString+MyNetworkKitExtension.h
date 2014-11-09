//
//  NSString+MyNetworkKitExtension.h
//  MyNetworkKit
//
//  Created by wadexiong on 14/11/7.
//  Copyright (c) 2014年 xiong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIImage.h>

@interface NSString (MyNetworkKitExtension)

/** 生成唯一的字符串内容 */
+ (NSString *) my_uniqueString;

/** 返回经过md5加密后的字符串 */
- (NSString *) my_md5;

/** 对含有中文的URL进行编码 */
- (NSString *) my_urlEncodedString;

/** 恢复成包含中文的URL */
- (NSString *) my_urlDecodedString;

/** 返回资源文件的所造工程的路径 */
+ (NSString *) my_mainBundlePath:(NSString *)fileName;

/** 获取手机上App的 AppName.app 目录 */
+ (NSString *) getHomePath;

/** 获取手机上App的 Documents 目录 */
+ (NSString *) getDocumentsPath;

/** 获取手机上App的 Caches 目录 */
+ (NSString *) getCachesPath;

/** 获取手机上App的 tmp 目录 */
+ (NSString *) getTmpPath;

/** 获取Bundle Name (工程名) */
+ (NSString *) getMainBundleName;

/** 获取 工程的 Version */
+ (NSString *) getVersionForMainBundle;

@end
