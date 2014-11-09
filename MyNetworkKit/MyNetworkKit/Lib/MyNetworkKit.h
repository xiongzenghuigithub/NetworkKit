
#ifndef MyNetworkKit_Config_h
#define MyNetworkKit_Config_h

#define kShouldPrintReachabilityFlags 1


//TODO: 1)iOS设备类型判断  2)iOS系统版本判断
#if TARGET_OS_IPHONE
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000
#define NEEDS_DISPATCH_RETAIN_RELEASE 0
#else
#define NEEDS_DISPATCH_RETAIN_RELEASE 1
#endif
#else
//mac os target
#endif


/** 重写NSLog函数 1)类 2)方法 3)代码行位置 */
#if DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"\nfunction:%s line:%d content:%s\n", __FUNCTION__, __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(FORMAT, ...) nil
#endif


/** 限制iOS系统版本 */
#ifndef __IPHONE_4_0
#error "MyNetworkKit只支持iOS系统4.0以后"
#endif

#import "Reachability.h"
#import "NSString+MyNetworkKitExtension.h"
#import "UIImage+MyNetworkKitExtension.h"
#import "NSDictionary+RequestEncode.h"
#import "UIImageView+MyNetworkKitExtension.h"
#import "NSDate+RFC1123.h"
#import "NSData+MKBase64.h"


/** 框架的 通知 和 默认值 定义 */

//1. 请求操作队列的设置
#define kMyNetworkKitOperationQueueCountChanged         @"kMyNetworkKitOperationQueueCountChanged"  //队列并发数量改变时的通知key
#define kMyNetworkKitOperationQueueMaxCount             10                            //请求队列默认的最大并发数

//3. 各种缓存的设置
#define kMyNetworkKitDefualtDirectory                   @"MyNetworkKitCache"          //手机上得缓存目录下的文件夹名
#define kMyNetworkKitDefaultCachaDuration               60                            //默认的缓存存在时间为一分钟
#define kMyNetworkKitDefaultHeadRequestCacheDuration    3600*60*24                    //默认的head request缓存时间为一天
#define kMyNetworkKitDefaultImageCacheDuration          3600*60*24                    //默认的图片缓存时间
#define kMyNetworkKitDefaultRequestTimeOut              30                            //默认的请求超时为30秒

#endif
