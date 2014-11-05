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


/** 隐藏类 */
@interface Reachability ()


#if NEEDS_DISPATCH_RETAIN_RELEASE == 1  //非ARC环境
    @property (nonatomic, assign) dispatch_queue_t reachabilitySerialQueue; //保存要监听的网络连接(SCNetworkReachabilityRef) 队列
#else
    @property (nonatomic, strong) dispatch_queue_t reachabilitySerialQueue;
#endif

@property (nonatomic, strong) id reachabilityObject;

@end


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
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    return [self reachableWithIPAddress:&zeroAddress];
}

+ (Reachability *)reachabilityForLocalWiFi {
    struct sockaddr_in localWifiAddress;
    bzero(&localWifiAddress, sizeof(localWifiAddress));
    localWifiAddress.sin_len            = sizeof(localWifiAddress);
    localWifiAddress.sin_family         = AF_INET;
    localWifiAddress.sin_addr.s_addr    = htonl(IN_LINKLOCALNETNUM);
    return [self reachableWithIPAddress:&localWifiAddress];
}

+ (Reachability *)reachableWithIPAddress:(const struct sockaddr_in *)addr {
    //获取与所给IP地址连接的引用
    SCNetworkReachabilityRef reachaRef = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr *)addr);
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

#define testcase (kSCNetworkReachabilityFlagsConnectionRequired | kSCNetworkReachabilityFlagsTransientConnection)
-(BOOL)isReachableWithFlags:(SCNetworkReachabilityFlags)flags
{
    BOOL connectionUP = YES;
    
    if(!(flags & kSCNetworkReachabilityFlagsReachable))
        connectionUP = NO;
    
    if( (flags & testcase) == testcase )
        connectionUP = NO;
    
#if	TARGET_OS_IPHONE
    if(flags & kSCNetworkReachabilityFlagsIsWWAN)
    {
        // we're on 3G
        if(!self.isReachableViaWWAN)
        {
            // we dont want to connect when on 3G
            connectionUP = NO;
        }
    }
#endif
    
    return connectionUP;
}

- (BOOL)isReachable {
    SCNetworkConnectionFlags flags = 0;
    //获取链接状态，是否可到达
    if(!SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags)) {
        return NO;
    }
    return [self isReachableWithFlags:flags];
}
- (BOOL)isReachableViaWWAN {
#if TARGET_OS_IPHONE
    SCNetworkConnectionFlags flags = 0;
    //获取链接状态
    if (SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags)) {
        //是否可以到达
        if (flags & kSCNetworkReachabilityFlagsReachable) {
            //是否是启用的WWAN
            if (flags & kSCNetworkReachabilityFlagsIsWWAN) {
                return YES;
            }
        }
    }
#endif
    return NO;
}
- (BOOL)isReachableViaWiFi {
#if TARGET_OS_IPHONE
    SCNetworkConnectionFlags flags = 0;
    //获取链接状态
    if (SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags)) {
        //是否可到达
        if (flags & kSCNetworkReachabilityFlagsReachable) {
            //是否是启用的WiFi
            if (flags & kSCNetworkReachabilityFlagsIsWWAN) {
                return YES;
            }
            //表示使用的3G网
            else  if (flags & kSCNetworkReachabilityFlagsIsWWAN) {
                return NO;
            }
        }
    }
#endif
    return NO;
}
- (BOOL)connectionRequired {
    SCNetworkReachabilityFlags flags = 0;
    if (SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags)) {
        return (flags & kSCNetworkReachabilityFlagsConnectionRequired);
    }
    return NO;
}

-(BOOL)isConnectionOnDemand
{
	SCNetworkReachabilityFlags flags;
	
	if (SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags))
    {
		return ((flags & kSCNetworkReachabilityFlagsConnectionRequired) &&
				(flags & (kSCNetworkReachabilityFlagsConnectionOnTraffic | kSCNetworkReachabilityFlagsConnectionOnDemand)));
	}
	
	return NO;
}

- (NetworkStatus)currentReachabilityStatus {
    if ([self isReachable]) {
        if ([self isReachableViaWiFi]) {
            return ReachableViaWifi;
        }
#if TARGET_OS_IPHONE
        //只有手机才有3G网
        if ([self isReachableViaWWAN]) {
            return ReachabileViaWWAn;
        }
#endif
    }
    return NotReachible;
}

//TODO: 接受网络状态变化的回调处理函数
static void ReceiveNetworkStatusUpdateHandle(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info) {
    
}


-(BOOL)startNotifier {
    
    //1. context指定异步监听网络连接回调时 ，调用哪个对象(需要retain一次) ，哪个方法(必须是c语言函数)
    SCNetworkReachabilityContext  context = { 0, NULL, NULL, NULL, NULL };
    
    //需要对当前Reachability对象retain一次 ==> 加一个强指针引用, 方法执行完毕后一定要清空这个强引用（进行release一次）
    self.reachabilityObject = self;
    
    //TODO:  使用 __bridge 关键字来实现 id类型 与 void* 类型的相互转换
    context.info = (__bridge void *)self;//__bridge把void*转换为id类型
    
    //2. 创建保存要监听的网络连接的队列
    self.reachabilitySerialQueue = dispatch_queue_create("com.xzh.network.reachabilityQueue", NULL);//创建串行队列
    if (self.reachabilitySerialQueue == nil) {
        return NO;
    }
    
    //3. 设置 接收到监听的网络连接的 网络状态发送变化后，回调context指定的 指定对象的指定函数
    if (SCNetworkReachabilitySetCallback(self.reachabilityRef, ReceiveNetworkStatusUpdateHandle, &context) == false) {//开启监听失败
        
#ifdef DEBUG
        NSLog(@"SCNetworkReachabilitySetCallback() failed: %s", SCErrorString(SCError()));
#endif
        //设置监听回调函数失败
        
        //3.1 release一次队列(因为SCNetworkReachabilitySetCallback里面会进行retain操作)
#if NEEDS_DISPATCH_RETAIN_RELEASE == 1 //非ARC
        dispatch_release(self.reachabilitySerialQueue); //非ARC下 ，release释放
#else
        self.reachabilitySerialQueue = nil;             //ARC ，指针为nil
#endif
        //3.2 release一次self.reachabilityObject(因为SCNetworkReachabilitySetCallback里面会进行retain操作)
        self.reachabilityObject = nil;                  //减少强引用一次
        
        return NO;
    }
    
    //4. 开启网络监听 1)监听哪一个网络连接  2)先暂时保存在队列（因为都是异步等待到某一个时刻才真正发起网络监听）
    if (SCNetworkReachabilitySetDispatchQueue(self.reachabilityRef, self.reachabilitySerialQueue) == false) {//发起监听失败
        
        //注: SCNetworkReachabilitySetDispatchQueue()方法内部会对传入的参数进行retain，所以改方法执行完毕，需要对传入的参数进行release
        
        //开启监听失败
        
        //对传入的参数进都release一次，保持计数器平衡
#if NEEDS_DISPATCH_RETAIN_RELEASE == 1
        dispatch_release(self.reachabilitySerialQueue);
#else
        self.reachabilitySerialQueue = nil;
#endif
    }
    
    //5. 所有操作成功执行完毕后，要对self.reachabilityObject进行release一次，上面只在失败的时候进行release，保持平衡
    self.reachabilityObject = nil;
    
    return YES;//成功开启网络状态监听
}

-(void)stopNotifier {
    
    //1. 设置停止 某一个网络连接监听 的回调函数
    SCNetworkReachabilitySetCallback(self.reachabilityRef, NULL, NULL);//不需要回调函数执行什么
    
    //2. 创建队列
    if (self.reachabilitySerialQueue == nil) {
        self.reachabilitySerialQueue = dispatch_queue_create("com.xzh.network.reachabilityQueue", NULL);
    }
    
    //3. 停止监听 ==》把要停止监听的网络连接，保存到队列，等待某一个时刻执行
    SCNetworkReachabilitySetDispatchQueue(self.reachabilityRef, self.reachabilitySerialQueue);
    
    //4. 操作完毕后release一次之前进行retain了得参数
#if NEEDS_DISPATCH_RETAIN_RELEASE == 1
    dispatch_release(self.reachabilitySerialQueue);
#else
    self.reachabilitySerialQueue = nil;
#endif
    
    //5. release一次reachabilityObject指针，让其释放(都停止监听连接了，就需要这个参数值了)
    self.reachabilityObject = nil;
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