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

//TODO: extern 声明全局变量
extern NSString * const kReachabilityChangedNotification;

/** Network Status */
typedef enum {
    NotReachible = 0,           // 网络请求不可到达
    ReachabileViaWWAn = 1,      // 网络请求通过WiFi可到达
    ReachableViaWifi = 2        // 网络请求通过使用3G/GPRS网络可到达
}NetworkStatus;

/** 回传Reachbility对象 */
typedef void (^ReachableBlock)(Reachability * rechability);
typedef void (^UnReachableBlock)(Reachability * rechability);

@interface Reachability : NSObject

@property (nonatomic, copy) ReachableBlock reachableBlock;
@property (nonatomic, copy) UnReachableBlock notReachableBlock;


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

//获取当前Reachability的到达结果(由链接引用获取)
- (BOOL)isReachable;
- (BOOL)isReachableViaWWAN;
- (BOOL)isReachableViaWiFi;

/** 开起监听手机网络状态 （需要先得到一个网络连接 --> Reachability对象 --> SCNetworkReachabilityRef网络连接的引用）*/
-(BOOL)startNotifier;

/** 停止监听手机网络状态 (对当前Reachability对象保存的SCNetworkReachabilityRef网络连接引用进行关闭) */
-(void)stopNotifier;

/** 是否需要建立连接 */
- (BOOL)connectionRequired;
- (BOOL)isConnectionOnDemand;

/** 获取当前网络连接状态 */
- (NetworkStatus)currentReachabilityStatus;

/** 创建一个并行队列 ， 指定并发数 */
void createConcurrentQueue(const char * queueName, int queueSize, dispatch_group_t * group, dispatch_queue_t * queue);

- (void)reachabilityChanged:(SCNetworkConnectionFlags)flags;

@end
