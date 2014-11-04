//
//  Config.h
//  MyNetworkKit
//
//  Created by wadexiong on 14/11/4.
//  Copyright (c) 2014年 xiong. All rights reserved.
//

#ifndef MyNetworkKit_Config_h
#define MyNetworkKit_Config_h

#define kShouldPrintReachabilityFlags 1

//** 重写NSLog函数 1)类 2)方法 3)代码行位置 */
#if DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"\nfunction:%s line:%d content:%s\n", __FUNCTION__, __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(FORMAT, ...) nil
#endif

#endif
