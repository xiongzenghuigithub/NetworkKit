//
//  NetworkEngine.m
//  MyNetworkKit
//
//  Created by xiongzenghui on 14/11/8.
//  Copyright (c) 2014年 xiong. All rights reserved.
//

#import "NetworkEngine.h"

#import "MyNetworkKit.h"
#import "NetworkOperation.h"

@interface NetworkEngine ()

@property (nonatomic, strong) Reachability * reachability;              //与主机的连接引用
@property (nonatomic, assign) BOOL shouldSendAcceptLanguageHeader;      //本地语言化
@property (nonatomic, assign) Class customOperationSubclass;            //注册自定义继承自NetworkOperation的子类为使用的operation类

#if NEEDS_DISPATCH_RETAIN_RELEASE 
@property (nonatomic, assign) dispatch_queue_t backgroudQueue;
@property (nonatomic, assign) dispatch_queue_t operationQueue;
#else
@property (nonatomic, strong) dispatch_queue_t backgroudQueue;
@property (nonatomic, strong) dispatch_queue_t operationQueue;
#endif

@end


static NSOperationQueue * _sharedNetworkQueue;


@implementation NetworkEngine

//TODO: initialize 1)初始化队列  2)给队列注册KVO观察者
+(void)initialize {
    if (!_sharedNetworkQueue) {
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            _sharedNetworkQueue = [[NSOperationQueue alloc] init];
            
            //TODO: 1)使用当前类的NSObject 观察 _sharedNetworkQueue值变化
            //2)在 +方法中, [self self] --> 获取当前类的NSObject
            [_sharedNetworkQueue addObserver:[self self] forKeyPath:@"operationCount" options:0 context:NULL];
            [_sharedNetworkQueue setMaxConcurrentOperationCount:6];
        });
    }
}

//TODO: 当_sharedNetworkQueue值变化时，回调当前类的NSObject的 +(void)observeValueForKeyPath:ofObject:change:context: 方法
+ (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                         change:(NSDictionary *)change context:(void *)context {
    
}


- (id)init {
    return [self initWithHostName:nil];
}

- (id)initWithHostName:(NSString *)hostName {
    return [self initWithHostName:hostName CustomHeaderFileds:nil];
}

- (id)initWithHostName:(NSString *)hostName CustomHeaderFileds:(NSDictionary *)headersDict {
    return [self initWithHostName:hostName Port:0 CustomHeaderFileds:headersDict];
}

//TODO: 所有的 initWithHostName函数 都在这个函数处理
- (id)initWithHostName:(NSString *)hostName Port:(int)port CustomHeaderFileds:(NSDictionary *)headersDict {
    
    /**
     *     创建Engine时要做的事:
     *
     *          1. 实例化Engine对象
     *          2. 创建Engine对象所持有的队列
     *          3. 注册接收到Reachability类发出的与主机连接变化的通知 (初始化时没有连接，只是准备)
     *                  3.1 通知回调处理函数中要做:
     *          4. 开始监听Engine持有的主机hostName
     *                  4.1 调用Reachability类获取与主机的网络连接引用
     *                  4.2 调用Reachability类对自己持有的与主机网络连接引用 进行异步监听状态变化
     *          5. 补充请求头的 request.header["User-Agent"]
     *          6. 默认设置
     *                  6.1 * 指定当前Engine使用的operation的类型 (如果不手动设置，默认为NetworkOperation基类类型)
     *                  6.2 默认使用语言国际化
     */
    
    //1. 调用 [super init]
    if ((self = [super init]) == nil) {
        
        self.port = port;      //保存服务器端口
        
        //2. 创建队列
        self.backgroudQueue = dispatch_queue_create("com.cn.xzn.backgroudQueue", NULL);
        self.operationQueue = dispatch_queue_create("com.cn.xzh.oeprationQueue", NULL);
        
        //3. 检测HostName是否可达 , 并监听连接状态
        if (hostName != nil) {
            
            self.hostName = hostName;
            
            //1) 注册与主机连接的状态变化的通知 , 等待接收到Reachability对象完成对HostName网络连接状态变化监听的结果
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(didReceiveReachabilityWithHostStatusChanged:) name:kReachabilityChangedNotification         //通知key 定义在 Reachability中
                                                       object:nil];
            
            //2) 获取与指定主机名的连接引用: SCNetworkReachabilityRef
            self.reachability = [Reachability reachableWithHostName:self.hostName];
            
            //3) 开始监听得到的与主机的连接
            if (self.reachability != nil) {
                
                //异步开始监听网络连接
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [self.reachability startNotifier];
                });
            }
        }
        
        //4. 补充请求头的 request.header["User-Agent"] 设置
        /**
         *     使得服务器能够识别客户使用的操作系统及版本、CPU 类型、浏览器及版本、浏览器渲染引擎、浏览器语言、浏览器插件
         */
        if (headersDict[@"User-Agent"] == nil) {//没有设置User-Agant , 框架补上
            
            //将用户传入的字典拷贝为一个可变的字典
            NSMutableDictionary * copyDict = [headersDict mutableCopy];     //使用mutableCopy拷贝出一个新的、可变的字典
            
            //让可变字典添加 User-Agent字段
            NSString * userAgantValue = [NSString stringWithFormat:@"%@/%@",
                                         [NSString getMainBundleName],
                                         [NSString getVersionForMainBundle]];
            copyDict[@"User-Agent"] = userAgantValue;
            
            //保存添加User-Agent后的请求头
            self.headersDict = copyDict;
        }
        else {
            self.headersDict = headersDict;
        }
    }
    
    //5. 默认设置
    self.customOperationSubclass = [NetworkEngine class];       //指定当前Engine使用的operation的类型(1.基类  2.框架使用者自定义的)
    self.shouldSendAcceptLanguageHeader = YES;                  //默认使用语言国际化
    
    return self;
}

//TODO: 内存释放掉持有的对象
- (void)dealloc {
    
    //释放的队列
#if NEEDS_DISPATCH_RETAIN_RELEASE
    dispatch_release(self.backgroudQueue);
    dispatch_release(self.operationQueue);
#else
    self.backgroudQueue = nil;
    self.operationQueue = nil;
#endif
    
    //释放成员变量指针指向的对象
    self.reachability = nil;
    self.hostName = nil;
    self.headersDict = nil;
    
    //移除当前Engine对象关注的通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
    
#if TARGET_OS_IPHONE
    //移除关注 - 接收内存警告的通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    //移除关注 - app进入后台的通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    //移除关注 - app即将退出的通知
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
#endif
    
}


//TODO: 接受到网络连接改变的通知
- (void)didReceiveReachabilityWithHostStatusChanged:(NSNotification *)notify {
    if ([self.reachability isReachable] == YES) {
        
        if ([self.reachability isReachableViaWiFi]) {
            [_sharedNetworkQueue setMaxConcurrentOperationCount:6];                              //WiFi网络下的队列大小
        }
        else if ([self.reachability isReachableViaWWAN]) {
            
            if (self.wifiModeOnly) {                                                             //虽然3G网可达，但是指定只在WiFi网络有效
                [_sharedNetworkQueue setMaxConcurrentOperationCount:0];
            }
            
            [_sharedNetworkQueue setMaxConcurrentOperationCount:2];                               //3G网络下的队列大小
        }
    }
    else {
        
    }
}



//TODO: 只指定子路径API路径的init函数层次
- (NetworkOperation *)operationWithApiPath:(NSString *) apiPath {
    return [self operationWithApiPath:apiPath ParamsDict:nil]; //默认是GET
}

- (NetworkOperation *)operationWithApiPath:(NSString *)apiPath
                                ParamsDict:(NSDictionary *)dict {
    
    return [self operationWithApiPath:apiPath ParamsDict:dict HttpReqMethod:@"get"];   //默认是GET
}

- (NetworkOperation *)operationWithApiPath:(NSString *)apiPath
                                ParamsDict:(NSDictionary *)dict
                             HttpReqMethod:(NSString *)method {
    
    return [self operationWithApiPath:apiPath ParamsDict:dict HttpReqMethod:method IsSSL:NO]; //默认不使用https
}

- (NetworkOperation *)operationWithApiPath:(NSString *)apiPath
                                ParamsDict:(NSDictionary *)dict
                             HttpReqMethod:(NSString *)method
                                     IsSSL:(BOOL)ssl {
    
    //1. Engine对象没有持有hostName
    if ([self hostName] == nil || [[[self hostName] stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        NSLog(@"创建Engine对象时，必须指定这个Engine的root主机域名!");
        return nil;
    }
    
    //2. 完成拼接除开参数的完整 api请求URL
    NSMutableString * fullApiPath = [NSMutableString string];
    NSString * api = @"";
    
    //去掉API路径包含的 "/"
    if ([apiPath hasPrefix:@"/"]) {
        api = [apiPath substringFromIndex:1];
    }
    
    //确定使用http or https
    [fullApiPath appendString:((ssl) ? @"https://" : @"http://")];
    
    //URL = http://www.baidu.com/news/search 或 https://www.baidu.com/news/search
    [fullApiPath appendString:[NSString stringWithFormat:@"%@/%@", [self hostName] , api]];
    
    return [self operationWithCompletURLString:fullApiPath params:dict HttpMethod:method];
}

//TODO: 得到完整URL路径的init函数层次
- (NetworkOperation *)operationWithCompletURLString:(NSString *)URLString
                                             params:(NSDictionary *)dict
                                         HttpMethod:(NSString *)method
{
    //1. 创建当前Engine 持有的operation类型 的对象
    NetworkOperation * op = [[self.customOperationSubclass alloc] initWithURL:URLString ParamDict:dict ReqMethod:method];
    
    //2. 给operation添加请求头
    [self prepareHeaders:op];
    
    //3. 是否多语言
    op.shouldSendAcceptLanguageHeader = self.shouldSendAcceptLanguageHeader;
    
    return op;
}



- (void)setCustomOperationSubclass:(Class)cls {
    self.customOperationSubclass = cls;
}


-(void) prepareHeaders:(NetworkOperation *) operation {
    operation.customHeader = self.headersDict;
}

//TODO: 将operation放入队列
- (void)enqueueOperation:(NetworkOperation *) operation {
    [self enqueueOperation:operation forceReload:NO];
}

- (void) enqueueOperation:(NetworkOperation *) operation forceReload:(BOOL) forceReload {
    
    if (operation == nil)
        return;
    
    __weak NetworkEngine * weakSelf = self;
    
    //1. 先放入全局并发队列
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //2. 先设置如果有缓存数据时如何处理
        [operation setCacheBlock:^(NetworkOperation *completCachedOpeation) {
            
        }];
        
        //3. 判断当前operation封装的请求是否有缓存数据
        if ([operation isCached])
        {
            //有缓存
        }
        else
        {
            //无缓存
        }
        
    });
    
}



@end
