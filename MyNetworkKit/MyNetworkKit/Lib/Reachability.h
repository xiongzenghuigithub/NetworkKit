//
//  Reachability.h
//  MyNetworkKit
//
//  Created by wadexiong on 14/11/4.
//  Copyright (c) 2014年 xiong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>

@class Reachability;

//TODO: 1)iOS设备类型判断  2)iOS系统版本判断
#if TARGET_OS_IPHONE 
    #if __IPHONE_OS_VERSION_MIN_REQUIRED >= 60000
        #define NEEDS_DISPATCH_RETAIN_RELEASE 0
    #else
        #define NEEDS_DISPATCH_RETAIN_RELEASE 1
    #endif
#else
#endif

/** Network Status */
typedef enum {
    NotReachible = 0,           // 网络请求不可到达
    ReachabileViaWWAn = 1,      // 网络请求通过WiFi可到达
    ReachableViaWifi = 2        // 网络请求通过使用3G/GPRS网络可到达
}NetworkStatus;

/** 回传Reachbility对象 */
typedef void (^NetworkRechable)(Reachability * rechability);
typedef void (^NetworkUnRechable)(Reachability * rechability);

@interface Reachability : NSObject

/** 当前到达主机的类型 */
@property (nonatomic, assign) NetworkStatus currentReachableStatus;

/** 与测试主机的连接对象的引用 */
@property (nonatomic, assign) SCNetworkReachabilityRef reachabilityRef;

/** 是否是通过WIFI建立与主机链接 */
@property (nonatomic, assign) BOOL isLocalWiFiRef;

/** 检测当前网络能否连上internet */
+ (Reachability *)reachableForInternet;

+ (Reachability *)reachabilityForLocalWiFi;

/** 检查网络请求是否可到达指定的，获得对主机域名的连接引用 - 主机域名,如: www.baidu.com */
+ (Reachability *)reachableWithHostName:(NSString *)hostName;

/** 检查网络请求是否可到达指定的，获得对IP地址的连接引用 - ip地址 */
+ (Reachability *)reachableWithIPAddress:(const struct sockaddr_in *)addr;

/** 根据检查到得到达主机情况创建Rechability对象  */
+ (Reachability *)getReachableIntsanceWithReachaRef:(SCNetworkReachabilityRef)reachaRef;

//获取当前Reachability的到达结果(由链接引用获取)
- (BOOL)isReachable;
- (BOOL)isReachableViaWWAN;
- (BOOL)isReachableViaWiFi;

/** 开起监听手机网络状态 */
-(BOOL)startNotifier;

/** 停止监听手机网络状态 */
-(void)stopNotifier;

/** 是否需要建立连接 */
- (BOOL)connectionRequired;
- (BOOL)isConnectionOnDemand;

/** 获取当前网络连接状态 */
- (NetworkStatus)currentReachabilityStatus;

static void convertNSStringIP(struct sockaddr_in * addr, NSString * ip);

@end
