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
#import "MyFileManager.h"

#import <SystemConfiguration/SystemConfiguration.h>

//TODO: NetworkEngine 的所有私密属性
@interface NetworkEngine () 

@property (nonatomic, strong) Reachability * reachability;              //与主机的连接引用
@property (nonatomic, assign) BOOL shouldSendAcceptLanguageHeader;      //本地语言化
@property (nonatomic, assign) Class customOperationSubclass;            //注册自定义继承自NetworkOperation的子类为使用的operation类

#if NEEDS_DISPATCH_RETAIN_RELEASE 
@property (nonatomic, assign) dispatch_queue_t backgroudQueue;          //保存其他操作的队列
@property (nonatomic, assign) dispatch_queue_t operationQueue;
#else
@property (nonatomic, strong) dispatch_queue_t backgroudQueue;
@property (nonatomic, strong) dispatch_queue_t operationQueue;
#endif

//TODO: 可变字典 统计保存到memory dict 中得所有response data 的key
@property (nonatomic, strong) NSMutableArray * memoryCacheKeysArray;    //保存被缓存到memrory字典中的response data的id值(key)

//保存当前operation的所有的不合法参数值 , 其中每一个参数值都是一个字典 (key:cacheHeaders , value:cache的参数字典)
@property(nonatomic, strong) NSMutableDictionary * cacheValidParams;

@end


static NSOperationQueue * _sharedNetworkQueue;                          //保存网络请求operation的队列


@implementation NetworkEngine



//TODO: initialize 1)初始化队列  2)给队列注册KVO观察者
+(void)initialize {
    if (!_sharedNetworkQueue) {
        static dispatch_once_t oncePredicate;
        dispatch_once(&oncePredicate, ^{
            _sharedNetworkQueue = [[NSOperationQueue alloc] init];
            
            //TODO: 1)使用当前类的NSObject 观察 _sharedNetworkQueue值变化
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
    return [self initWithHostName:hostName CustomHeaderFileds:headersDict Port:0];
}

//TODO: 所有的 initWithHostName函数 都在这个函数处理
- (id)initWithHostName:(NSString *) hostName
    CustomHeaderFileds:(NSDictionary *) headersDict
                  Port:(int) port {
    
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
    if ((self = [super init]) != nil) {
        
        self.port = port;      //保存服务器端口
        
        //2. 创建队列
        self.backgroudQueue = dispatch_queue_create("com.cn.xzn.backgroudQueue", NULL);
        self.operationQueue = dispatch_queue_create("com.cn.xzh.oeprationQueue", NULL);
        
        //3. 检测HostName是否可达 , 并监听连接状态
        if (hostName != nil) {
            
            self.hostName = hostName;
            
            //1) 注册与主机连接的状态变化的通知 , 等待接收到Reachability对象完成对HostName网络连接状态变化监听的结果
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(didReceiveReachabilityWithHostStatusChanged:)
                                                         name:kReachabilityChangedNotification
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
    self.customOperationSubclass = [NetworkOperation class];       //指定当前Engine使用的operation的类型(1.基类  2.框架使用者自定义的)
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
    
    return [self operationWithApiPath:apiPath ParamsDict:dict HttpReqMethod:@"GET"];   //默认是GET
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
    
    //去掉API路径包含的 "/"
    if ([apiPath hasPrefix:@"/"]) {
        apiPath = [apiPath substringWithRange:NSMakeRange(1, [apiPath length])];
    }
    
    //确定使用http or https
    [fullApiPath appendString:((ssl) ? @"https://" : @"http://")];
    
    //URL = http://www.baidu.com/news/search 或 https://www.baidu.com/news/search
    [fullApiPath appendString:[NSString stringWithFormat:@"%@/%@", [self hostName] , apiPath]];
    
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


-(void) prepareHeaders:(NetworkOperation *) operation {
    operation.customHeader = self.headersDict;
}

//TODO: enqueueOperation
- (void)enqueueOperation:(NetworkOperation *) operation {
    [self enqueueOperation:operation forceReload:NO];
}

//TODO: 冻结(归档)operation对象到本地 ( 当hostName不可达时调用该方法 )
- (void)freezeOperations {
    
    //当缓存功能不能使用的时候, 默认不能归档operation
    if (![self isCacheEnabled]) return;
    
    if (self.hostName == nil) return;
    
    //归档当前engine.sharedOperationQueue中的所有operation
    for (NetworkOperation * op in [_sharedNetworkQueue operations]) {
        
        //判断operation是否可以被归档
        if (![op freezable]) return;
        
        //只有属于当前engine.hostNeme 下的 operation.request.url 的opertion 才可以被归档
        if ([[op url] rangeOfString:[self hostName]].location  == NSNotFound) continue;
        
        //归档当前operation到本地缓存目录, 文件名是operation.uniqueId
        NSString * archivePath = [[self cacheDirectoryName] stringByAppendingPathComponent:[op uniqueIdentifier]];
        [NSKeyedArchiver archiveRootObject:op toFile:archivePath];
    }
}

- (void) enqueueOperation:(NetworkOperation *) operation forceReload:(BOOL) forceReload {
    
    if (operation == nil)
        return;
    
    __weak NetworkEngine * weakSelf = self;
    
    //TODO: dispatch_aysnc global_queue operation的各种代码组装
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // 1. 先给operation预先设置, 缓存response data的代码
        [operation setCacheHandler:^(NetworkOperation *completCachedOpeation) {
            
            NSString * uniqueId = [completCachedOpeation uniqueIdentifier];
            [weakSelf saveOperation:[completCachedOpeation responseData] forKey:uniqueId];
            [weakSelf.cacheValidParams setObject:[completCachedOpeation cacheHeaders] forKey:uniqueId];
        }];
        
        
        //以下判断是在初始化operation的时候 , 并没有执行operation (发起请求)
        /**
         *  1) 存在cache、不存在cache      2)重新请求、不重新请求
         *
         *  总的组合模式:
         *
         *      1. 存在cache + 不重新请求      ---> 直接设置cached response data
         *      2. 存在cache + 重新请求        ---> 将operation入队等待请求
         *      3. 不存在cache + 不重新请求     ---> 错误
         *      4. 不存在cache + 重新请求      ---> 将operation入队等待请求
         */
        
        
        //2. 判断当前operation能不能使用缓存功能
        if ([operation isCachable])
        {
            // 能使用缓存 --> 查找这个operation对应的缓存的response data
            
            __block double expiryTimeInSeconds = 0.0f;  //保存operation的cache数据的过期时间
            
            //从缓存字典中获取operation对应的response data
            NSData * cachedResponseData = [self cachedResponseWithOperation:operation];
            
            //2.1
            if (cachedResponseData) {
                
                //2.1.1- (void)setResponseData:(NSData *)responseData
                //TODO: dispatch_aysnc main_queue 给operation设置response data
                dispatch_async(dispatch_get_main_queue(), ^{
                    [operation setResponseData:cachedResponseData];
                });
                
                /* (注: 因为Block异步执行， 其实没有执行， 直接到了下面的代码) */
                
                //2.1.2
                //如果不指定强制重新请求服务器
                if (forceReload == NO) {
                    
                    //operation的缓存时间限制是否超时
                    
                    //1. 取出oepration的 所有非法参数集合中 的 关于cache的非法参数结合
                    NSMutableDictionary * cacheHeadersDict = (self.cacheValidParams)[[operation uniqueIdentifier]];
                    if (cacheHeadersDict) {
                        NSString * cacheExpires = cacheHeadersDict[@"Expires"];
                        
                        //TODO: dispatch_aysnc operationQueue 将获取的字符串过期时间 转换成 doudle类型的值(秒)
                        dispatch_async(self.operationQueue, ^{  //与主线程无关
                            
                            //重新计算缓存的过期时间: 改为从现在算起 (减少过期时间)
                            NSDate *expiresOnDate = [NSDate dateFromRFC1123:cacheExpires];
                            expiryTimeInSeconds = [expiresOnDate timeIntervalSinceNow];
                        });
                        
                        //TODO: dispatch_async main_queue 更新operation缓存的参数字典
                        dispatch_async(dispatch_get_main_queue(), ^{
                            //修改operation的值, 因为operation对象是在主线程上创建的 ,所以必须丢到dispatch 到 main queue
                            [operation updateOperationBasedOnPreviousHeaders:cacheHeadersDict];
                        });
                    }
                }
                
                //2.1.3 对要入队的operation做最后的处理.
                
                //需要得到在operationQueue的block执行后修改的expiryTimeInSeconds ,所以如下block要dispatch到oeprationQueue
                
                //TODO: dispatch_async operationQueue
                dispatch_async(self.operationQueue, ^{
                    
                    BOOL operationFinished = NO;
                    NSArray * operations = [_sharedNetworkQueue operations];
                    NSUInteger index = [operations indexOfObject:operation];  //找到当前operation是否已经存在于队列
                    if (index != NSNotFound) {  //当前创建的operation已经存在于队列
                        
                        //1. 对于已经存在于 _sharedOperationQueue 的operation , 进行属性更新
                        NetworkOperation * queueOperation = [operations objectAtIndex:index];
                        
                        //2. 判断是否执行完毕
                        operationFinished = [queueOperation isFinished];
                        
                        //2.1 没有执行
                        if (operationFinished) { //operation没有执行
                            
                            //修改从queue中找到的queueOperation的属性
                            //a: operation: 带有新参数
                            //b: queueOperation: 之前就已经加入队列的
                            
                            [queueOperation updateHandlersFromOperatio:operation];
                        }
                        
                        //2.2 已经执行完毕
                        //else operation 已经执行完毕, 什么都不做
                    }
                    
                    //将准备完毕的operation dispatch 到 _sharedOperationQueue 等待执行
                    if (expiryTimeInSeconds <= 0 || forceReload == YES || operationFinished == YES) {
                        [_sharedNetworkQueue addOperation:operation];
                    }
                    
                });
            }
            
        } else {
            
            // 不能使用缓存  --> 直接发起请求
            [_sharedNetworkQueue addOperation:operation];
        }
        
        //dispatch block to main queue 后的执行代码
        if ([self.reachability currentReachabilityStatus] == NotReachible) {
            
            //TODO: 当与主机网络连接不可达时，冻结当前的operation (序列化Operation对象 到本地文件)
            [self freezeOperations];
        }
    });


}

//TODO: 将operation(包含的response数据)保存起来作为缓存数据
/**
 *  将oepration包含的response数据作为缓存数据保存
 *
 *      需要2部分:
 *
 *          1. memory dict :
 *                          (operation.uniqueIdeifty为key , operation.responseData为value)
 *
 *          2. memory keys array:
 *                          (依次保存加入内存缓存的response data 所在的 operation uniqueId)
 *
 */
- (void)saveOperation:(NSData *)responseData forKey:(NSString *)key {
    
    //TODO: dispatch_async backgroud_queue 异步完成保存reponse data
    dispatch_async(self.backgroudQueue , ^{
        
        //1. 保存response data    --- value
        (self.memoryCacheDict)[key] = responseData;
        
        //2. 保存response data 所在的 operation的 uniqueId --- key
        NSUInteger index = [self.memoryCacheKeysArray indexOfObject:key];    //先找到key的现在所在位置
        if (index != NSNotFound) {                                           //先从memory key array删除
            [self.memoryCacheKeysArray removeObjectAtIndex:index];
        }
        [self.memoryCacheKeysArray insertObject:key atIndex:0];              //再将key放入到memory key array的第一个位置
        
        //3. 判断当前插入后的 memoryCacheKeysArray 总个数 是否大于 规定的 内存能够保存response data的总个数 (memoryCacheKeysArray是可变数组)
        if ([self.memoryCacheKeysArray count] >= [self cacheMemerySize]) {
         
            //如果当前内存缓存可变字典存放的response data总个数 == 规定的个数， 将末尾的response data 写入本地缓存目录的文件
            
            //3.1 找到keys数组中最后的key和对应的response data
            NSString * lastKey = [self.memoryCacheKeysArray lastObject];            //最后一个key
            NSData * lastData = [self.memoryCacheDict objectForKey:lastKey];        //最后一个key对应的response data
            
            //3.2 将最后的response data 写入到本地缓存目录的文件 , 以key为文件名
            NSString * responseFilePath = [NSString stringWithFormat:@"%@/%@" , [self cacheDirectoryName] , lastKey];
            [MyFileManager writeResponseDataTo:responseFilePath Data:responseData];
            
            //3.3 删除最后的key和对应的data
            [self.memoryCacheDict removeObjectForKey:lastKey];                      //删除内存缓存中， 最后一个key对应的response data
            [self.memoryCacheKeysArray removeLastObject];                           //删除保存的最有一个key
        }
    });
}

- (int)cacheMemerySize {
    return kMyNetworkKitDefaultCacheSize;
}

-(NSString*) cacheDirectoryName {
    
    static NSString * cacheDirName = nil;
    
    //TODO: 使用dispatch_once 保证代码只执行一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString * systemCacheDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        cacheDirName = [systemCacheDir stringByAppendingPathComponent:kMyNetworkKitDefualtDirectory];
    });
    
    return [NSString getCachesPath];
}

//TODO: 查找可以使用缓存的operation的reseponse data
/**
 *  查找可以使用缓存功能的operation的response data 的途径:
 *
 *      1. Engine对象.memoryDict :  以当前operation.uniqueId查找
 *
 *      2. 本地缓存目录下的文件 : 路径为 [[Engine对象 cacheDirectoryName] stringByAppendingPathComponent:operation.uniqueIdentifier]
 */
- (NSData *)cachedResponseWithOperation:(NetworkOperation *)operation {
    
    //1. 在内存字典中查找 - 用当前operation.uniqueId查询 memory dict , 看是否有该opeation对应的response data
    NSData * cachedResponseData = (self.memoryCacheDict)[[operation uniqueIdentifier]];
    if (cachedResponseData) return cachedResponseData;
    
    //2. 在本地缓存目录文件查找
    NSString * responseDataFilePath = [[self cacheDirectoryName] stringByAppendingPathComponent:[operation uniqueIdentifier]];
    cachedResponseData = [MyFileManager responseDataFromPath:responseDataFilePath];
    if (cachedResponseData) return cachedResponseData;
    
    return  nil;
    
}

//直接判断手机本地的缓存目录下是否存在框架声明的名字的文件夹
- (BOOL)isCacheEnabled {
    BOOL isDir = NO;
    BOOL hasNetworkKitCacheDir = [[NSFileManager defaultManager] fileExistsAtPath:[self cacheDirectoryName] isDirectory:&isDir];
    return hasNetworkKitCacheDir;
}

//TODO: 开启缓存功能
- (void)useCache {
    
    //保存缓存的operation.responseData
    self.memoryCacheDict = [NSMutableDictionary dictionaryWithCapacity:kMyNetworkKitDefaultCacheSize];
    
    //保存operation.uniqueId
    self.memoryCacheKeysArray = [NSMutableArray arrayWithCapacity:kMyNetworkKitDefaultCacheSize];
    
    //保存oepration的各种缓存参数
    self.cacheValidParams = [NSMutableDictionary dictionary];
    
    //如果不存在框架创建的自己的缓存根目录 , 创建缓存根目录
    NSString * cacheRootDir = [[self cacheDirectoryName] stringByAppendingPathComponent:kMyNetworkKitDefualtDirectory];
    BOOL isFileExists = [[NSFileManager defaultManager] fileExistsAtPath:cacheRootDir isDirectory:nil];
    if (isFileExists == NO) {
        [[NSFileManager defaultManager] createDirectoryAtPath:cacheRootDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    //如果说缓存目录下存在 self.cacheValidParams 对应的文件 ， 从本地文件创建字典
    BOOL isFile = YES;
    NSString * cacheValidParamsPath = [cacheRootDir stringByAppendingPathComponent:@"plist"];
    isFileExists = [[NSFileManager defaultManager] fileExistsAtPath:cacheValidParamsPath isDirectory:&isFile];
    
    if (isFile && isFileExists) {
        self.cacheValidParams = [NSMutableDictionary dictionaryWithContentsOfFile:cacheValidParamsPath];
    }
    
    //TODO:  设置缓存时，同时监听通知 .  当接收到如下通知，马上将数据保存为缓存数据
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveCache)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification  //接收到内存警告
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveCache)
                                                 name:UIApplicationDidEnterBackgroundNotification       //app将要进入后台
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveCache)
                                                 name:UIApplicationWillTerminateNotification            //app将要退出
                                               object:nil];
}

//TODO: 接收到系统通知后，将3个关于缓存先关的字典对象从内存中保存到本地缓存目录下的文件
- (void)saveCache {
    
    //1. Engine对象持有的所有operation对象.responseData写入文件
    for (NSString * operationUniqueId in [self.memoryCacheDict allKeys]) {
        
        NSString * cacheFilePath = [[self cacheDirectoryName] stringByAppendingPathComponent:operationUniqueId];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:cacheFilePath]) {
            [[NSFileManager defaultManager] removeItemAtPath:cacheFilePath error:nil];
        }

        [self.memoryCacheDict[operationUniqueId] writeToFile:cacheFilePath atomically:YES];
    }
    
    //2. 清空缓存字典
    [self.memoryCacheDict removeAllObjects];
    [self.memoryCacheKeysArray removeAllObjects];
    
    //3. 将oepration的缓存设置参数列表写入本地
    NSString * cacheValidParamsPath = [[self cacheDirectoryName] stringByAppendingPathComponent:@"plist"];
    [self.cacheValidParams writeToFile:cacheValidParamsPath atomically:YES];
}

- (NSMutableDictionary *)createRequestHeader {
    
    NSMutableDictionary * headers = [NSMutableDictionary dictionary];
    headers[@"x-client-identifier"] = @"iOS";
    //do other settings
    
    return headers;
}

@end
