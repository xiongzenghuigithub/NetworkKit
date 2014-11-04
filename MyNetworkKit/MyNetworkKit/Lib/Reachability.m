//
//  Reachability.m
//  MyNetworkKit
//
//  Created by wadexiong on 14/11/4.
//  Copyright (c) 2014年 xiong. All rights reserved.
//

#import "Reachability.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>



@implementation Reachability


static void convertNSStringIP(struct sockaddr_in * addr, NSString * ip) {
    const char * c_ip = [ip UTF8String];
    bzero(addr, sizeof(addr));
    addr->sin_len = sizeof(addr);
    addr->sin_family = AF_INET;
    if (c_ip != NULL) {
        addr->sin_addr.s_addr = inet_addr(c_ip);
//        addr->sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM);//同上一样的效果
    }
    bzero(&(addr->sin_zero), 8);
    
    //不适用端口
}


/** 输出当前链接主机的所有信息 */
static void PrintReachabilityFlags(SCNetworkReachabilityFlags flags, const char* comment) {
#if kShouldPrintReachabilityFlags == 1
    NSLog(@"Reachability Flag Status: %c%c %c%c%c%c%c%c%c %s\n",
          (flags & kSCNetworkReachabilityFlagsIsWWAN)               ? 'W' : '-',//当前网络为蜂窝网络，即3G或者GPRS
          (flags & kSCNetworkReachabilityFlagsReachable)            ? 'R' : '-',//网络请求地址可达
          
          (flags & kSCNetworkReachabilityFlagsTransientConnection)  ? 't' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionRequired)   ? 'c' : '-',//需要建立链接
          (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)  ? 'C' : '-',
          (flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionOnDemand)   ? 'D' : '-',
          (flags & kSCNetworkReachabilityFlagsIsLocalAddress)       ? 'l' : '-',//该值为一个本地地址
          (flags & kSCNetworkReachabilityFlagsIsDirect)             ? 'd' : '-',
          
          comment
          );
#endif
}

+ (Reachability *)reachableForInternet {
    struct sockaddr_in zeroAddr;
    convertNSStringIP(&zeroAddr, nil);
    return [self reachableWithIPAddress:&zeroAddr];
}

+ (Reachability *)reachabilityForLocalWiFi {
    struct sockaddr_in zeroAddr;
    convertNSStringIP(&zeroAddr, @"169.254.0.0");//htonl(IN_LINKLOCALNETNUM)
    return [self reachableWithIPAddress:&zeroAddr];
}

+ (Reachability *)reachableWithIPAddress:(struct sockaddr_in *)addr {
    
    SCNetworkReachabilityRef reachaRef = SCNetworkReachabilityCreateWithName(kCFAllocatorDefault, (const struct sockaddr *)addr);
    if (reachaRef != NULL) {
        return [self getReachableIntsanceWithReachaRef:reachaRef];
    }
    return nil;
}

+ (Reachability *)reachableWithHostName:(NSString *)hostName {
    
    //获取与所给主机连接的引用
    SCNetworkReachabilityRef reachaRef = SCNetworkReachabilityCreateWithName(NULL, [hostName UTF8String]);//NULL: 域名
    if (reachaRef != NULL) {
        return [self getReachableIntsanceWithReachaRef:reachaRef];
    }
    return nil;
}

+ (Reachability *)getReachableIntsanceWithReachaRef:(SCNetworkReachabilityRef)reachaRef {
    Reachability * reachable = [[Reachability alloc] init];
    reachable.reachabilityRef = reachaRef;
    reachable.isLocalWiFiRef = NO;
#if __has_feature(objc_arc)
    return reachable;
#else
    return [reachable autorelease];
#endif
}


#pragma mark - dealloc
- (void)dealloc {
    
    if (self.reachabilityRef != NULL) {
        CFRelease(self.reachabilityRef);
    }
    self.reachabilityRef = NULL;
    
#if !(__has_feature(objc_arc))
    [super dealloc];
#endif
}

@end
