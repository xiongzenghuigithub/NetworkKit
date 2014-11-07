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
+ (NSString *) uniqueString;

/** 返回经过md5加密后的字符串 */
- (NSString *) md5;

/** 对含有中文的URL进行编码 */
- (NSString *) my_urlEncodedString;

/** 恢复成包含中文的URL */
- (NSString *) my_urlDecodedString;

@end
