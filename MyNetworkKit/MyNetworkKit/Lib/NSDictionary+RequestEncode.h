//
//  NSDictionary+RequestEncode.h
//  MyNetworkKit
//
//  Created by xiongzenghui on 14/11/8.
//  Copyright (c) 2014年 xiong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (RequestEncode)

/** 把字典组装成: name=zs&age=19&addr=%E6%B9%96%E5%8D%97(中文需要编码) URL的附加参数 */
-(NSString*) urlEncodedKeyValueString;

/** 把JSON字典转化为NSString */
-(NSString*) jsonEncodedKeyValueString;

/** 把pList文件转化为NSString */
-(NSString*) plistEncodedKeyValueString;

@end
