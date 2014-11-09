//
//  NetworkEngine.m
//  MyNetworkKit
//
//  Created by xiongzenghui on 14/11/8.
//  Copyright (c) 2014年 xiong. All rights reserved.
//

#import "NetworkEngine.h"
#import "MyNetworkKit.h"

@interface NetworkEngine ()

@property (nonatomic, strong) Reachability * reachability;              //与主机的连接引用
@property (nonatomic, assign) BOOL shouldSendAcceptLanguageHeader;      //本地语言化
@property (nonatomic, assign) Class customOperationSubclass;            //注册NetworkOperation的子类为使用的operation类

#if NEEDS_DISPATCH_RETAIN_RELEASE 
@property (nonatomic, assign) dispatch_queue_t backgroudQueue;
@property (nonatomic, assign) dispatch_queue_t operationQueue;
#else
@property (nonatomic, strong) dispatch_queue_t backgroudQueue;
@property (nonatomic, strong) dispatch_queue_t operationQueue;
#endif

@end

@implementation NetworkEngine



- (id)init {
    return [self initWithHostName:nil];
}

- (id)initWithHostName:(NSString *)hostName {
    return [self initWithHostName:hostName CustomHeaderFileds:nil];
}

- (id)initWithHostName:(NSString *)hostName CustomHeaderFileds:(NSDictionary *)headersDict {
    return [self initWithHostName:hostName Port:0 CustomHeaderFileds:headersDict];
}

- (id)initWithHostName:(NSString *)hostName Port:(int)port CustomHeaderFileds:(NSDictionary *)headersDict {
    
    //调用 [super init]
    if ((self = [super init]) == nil) {
        
        self.port = port;
        
        //1. 创建队列
        self.backgroudQueue = dispatch_queue_create("com.cn.xzn.backgroudQueue", NULL);
        self.operationQueue = dispatch_queue_create("com.cn.xzh.oeprationQueue", NULL);
        
        //2. 检测HostName是否可达 , 并监听连接状态
        if (hostName != nil) {
            
            self.hostName = hostName;
            
            //1) 注册与主机连接的状态变化的通知
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(didReceiveReachabilityWithHostStatusChanged:) name:kReachabilityChangedNotification
                                                       object:nil];
            
            //2) 获取与指定主机名的连接引用: SCNetworkReachabilityRef
            self.reachability = [Reachability reachableWithHostName:self.hostName];
            
            //3) 开始监听得到的与主机的连接
            if (self.reachability != nil) {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self.reachability startNotifier];
                });
            }
        }
        
        //3. request.header["User-Agent"] 的设置
        /**
         *     使得服务器能够识别客户使用的操作系统及版本、CPU 类型、浏览器及版本、浏览器渲染引擎、浏览器语言、浏览器插件
         */
//        if (headersDict[@"User-Agent"] == nil) {//没有设置User-Agant , 代码代替补上
//            NSDictionary * userAgant = [headersDict mutableCopy];
//            userAgant setValue:<#(id)#> forKey:<#(NSString *)#>
//        }
        
    }
    
    return self;
}

- (void)dealloc {
#if NEEDS_DISPATCH_RETAIN_RELEASE
    dispatch_release(self.backgroudQueue);
    dispatch_release(self.operationQueue);
#else
    self.backgroudQueue = nil;
    self.operationQueue = nil;
#endif
    
    self.reachability = nil;
    self.hostName = nil;
    self.headersDict = nil;
}
















@end
