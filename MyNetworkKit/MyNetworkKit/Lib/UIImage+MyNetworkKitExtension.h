//
//  UIImage+MyNetworkKitExtension.h
//  MyNetworkKit
//
//  Created by wadexiong on 14/11/7.
//  Copyright (c) 2014年 xiong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (MyNetworkKitExtension)

/** 传入图片名创建UIImange对象 */
+ (UIImage *)createImageWithName:(NSString *)name;

/** 使用base64将UIImage对象转成NSString */
- (NSString *)base64;

/** 返回拉伸的图片 */
- (UIImage *)getStrechableImage;

@end
