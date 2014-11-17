//
//  NetworkEngine.h
//  MyNetworkKit
//
//  Created by xiongzenghui on 14/11/8.
//  Copyright (c) 2014年 xiong. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NetworkOperation;




typedef void (^ReachabulityChangedStatus)(NetworkStatus * status);

/*!
 *  一个 NetworkEngine 封装一个主机域名下的所有http请求
 */
@interface NetworkEngine : NSObject

//------------------------------------基本属性---------------------------------------
@property (nonatomic, assign) BOOL wifiModeOnly;    //指定只有WiFi
@property (nonatomic, copy) NSString * hostName;
@property (nonatomic, strong) NSDictionary * headersDict;
@property (nonatomic, assign) int port;
@property (nonatomic, copy)ReachabulityChangedStatus reachabulityChangedStatus;

//TODO: 使用 可变字典 缓存 operation包含的response data
@property (nonatomic, strong)NSMutableDictionary * memoryCacheDict; //指定存放response data的字典, 以operation.uniqueId为key存放


//TODO: 创建 Engine 对象
//-------------------------------创建 Engine 对象-------------------------------------
/*  
 *  1. 一个Engine代表了 主机服务器下的根域名 , 所有子路径API请求 , 都是从Engine的根路径下开始.
 *  2. Engine类 封装 所有路径API请求 的过程 , 让所有的HTTP请求的代码不散落在其他地方 , 便于维护.
 */

/**
 *  传入主机服务器root域名(www.xzh.com) , 创建NetworkEngine对象
 */
- (id)initWithHostName:(NSString *) hostName;

/**
 *  传入主机服务器root域名(www.xzh.com)  创建NetworkEngine对象 , 自定义设置请求头 , 创建NetworkEngine对象
 */
- (id)initWithHostName:(NSString *) hostName
    CustomHeaderFileds:(NSDictionary *) headersDict;

/**
 *  传入主机服务器root域名(www.xzh.com)  , 服务器端口号 , API的子路径  , 自定义设置请求头 , 创建NetworkEngine对象
 */
- (id)initWithHostName:(NSString *) hostName
    CustomHeaderFileds:(NSDictionary *) headersDict
                  Port:(int) port;


//TODO:  Engine对象 创建  Operation对象
//---------------------------------创建 属于某个主机root域名下的Operation 对象-----------------------------------
/**
 * 层级结构:
 *      Engine -- 代表主机root域名 = api.dianping.com , 将所有的API请求封装成一个Operation对象
 *          
 *      Engine下的每一个getXxxOperation()方法 , 都是获取某一个包装了要执行的API请求的Operation对象
 *
 *          > 主机服务器下的 团购类 的所有子API
 *              > getDealAllListOp()   -- API路径: deal/get_all_id_list
 *              > getDailyNewOp()      -- API路径: deal/get_daily_new_id_list
 *              > getSingleDealOp()    -- API路径: deal/get_single_deal
 *              > getFindDealsOp()     -- API路径: deal/find_deals
 *
 *          > 主机服务器下的 优惠券类 的所有子API
 *              > getFindCouponsOp()   -- API路径: coupon/find_coupons
 *              > getSingleCouponOp()  -- API路径: coupon/get_single_coupon
 */

/**
 *  由Engine对象 创建 Operation对象 , 传入API的子路径(news/searchAll , 没有请求参数的) , GET
 */
- (NetworkOperation *)operationWithApiPath:(NSString *) apiPath;

/**
 *  由Engine对象 创建 Operation对象 , 传入API的子路径(news/searchAll?name=zs&age=19) , GET
 */
- (NetworkOperation *)operationWithApiPath:(NSString *) apiPath
                                ParamsDict:(NSDictionary *) dict;

/**
 *  由Engine对象 创建 Operation对象 , 传入API的子路径(news/searchAll?name=zs&age=19) , 指定 GET或POST
 */
- (NetworkOperation *)operationWithApiPath:(NSString *) apiPath
                                ParamsDict:(NSDictionary *) dict
                             HttpReqMethod:(NSString *) method;

/**
 *  由Engine对象 创建 Operation对象 , 传入API的子路径(news/searchAll?name=zs&age=19) , 指定 GET或POST , 是否使用HTTPS
 */
- (NetworkOperation *)operationWithApiPath:(NSString *) apiPath
                                ParamsDict:(NSDictionary *) dict
                             HttpReqMethod:(NSString *) method
                                     IsSSL:(BOOL) ssl;


//TODO: 完整URL访问的Operation
//----------------------------------直接指定完整URL访问的Operation---------------------------------
/**
 *  指定一个完整的URL创建Operation , 默认GET
 */
- (NetworkOperation *)operationWithCompletURL:(NSString *) URLString;

/**
 *  指定一个完整的URL创建Operation , 传入请求参数 , 默认GET
 */
- (NetworkOperation *)operationWithCompletURLString:(NSString *) URLString
                                             params:(NSDictionary *) dict;

/**
 *  指定一个完整的URL创建Operation , 传入请求参数 , 指定GET或PST
 */
- (NetworkOperation *)operationWithCompletURLString:(NSString *) URLString
                                             params:(NSDictionary *) dict
                                         HttpMethod:(NSString *) method;


/**
 *  给Operation添加请求头
 */
-(void) prepareHeaders:(NetworkOperation *) operation;



//TODO: 异步在Block中访问网络图片
#if TARGET_OS_IPHONE

/**
 *  访问网络图片 , 在Block中异步获取UIImage对象
 */
- (void)imageWithURL:(NSURL *) imageURL
    FetchImageBlock:(void (^)(UIImage * image , NSURL * url , BOOL isInCache)) complet
    DEPRECATED_ATTRIBUTE;   //TODO: 使用宏 DEPRECATED_ATTRIBUTE 废弃使用某个方法

/**
 *  访问网络图片 , 在Block中异步获取UIImage对象 , 并且是拉伸到指定大小的UIImage对象
 */
- (void)imageWithURL:(NSURL *) imageURL
              Resize:(CGSize) size
    FetchImageBlock:(void (^)(UIImage * resizedImage , NSURL * url , BOOL isInCache)) complet
    DEPRECATED_ATTRIBUTE;

/**
 *  访问网络图片 , 在Block中异步获取UIImage对象 , 传入错误Block
 */
- (void)imageWithURL:(NSURL *) imageURL
     FetchImageBlock:(void (^)(UIImage * image, NSURL * url, BOOL isInCache )) complet
          ErrorBlock:(void (^)(NetworkOperation * op , NSError * error)) error;

/**
 *  访问网络图片 , 在Block中异步获取 resize的 UIImage对象 , 传入错误Block
 */
- (void)imageWithURL:(NSURL *) imageURL
              Resize:(CGSize) size
     FetchImageBlock:(void (^)(UIImage * resizeImage , NSURL * url , BOOL isInCache)) complet
          ErrorBlock:(void (^)(NetworkOperation * op, NSError * error)) error;

#endif

/**
 *  将 NetOperation对象放入Engine对象的队列 , 异步等待执行
 */
- (void)enqueueOperation:(NetworkOperation *) operation;

/**
 *  将 NetOperation对象放入Engine对象的队列 , 异步等待执行 , 如果forceReload=YES-->及时有缓存也重新发起请求新数据
 */
- (void) enqueueOperation:(NetworkOperation *) operation forceReload:(BOOL) forceReload;

/**
 *  取消执行包含指定URL的 NetOperation对象
 */
- (void)cancelOperstionsContainingURLString:(NSString *) url;

/**
 *  取消所有的NetOperation执行
 */
- (void) cancelAllOperations;

/**
 *  获取缓存目录
 */
-(NSString*) cacheDirectoryName;

/**
 *  在内存 - 能够缓存response data 的最大个数
 */
- (int)cacheMemerySize;

/**
 *  使用缓存请求数据 , 不使用该方法时不会缓存请求数据
 */
- (void)useCache;

/**
 *  清空缓存
 */
- (void)emptyCache;

/**
 *  设置当前Engine所持有的Operation的类型Class
 */
- (void)setCustomOperationSubclass:(Class)cls;

/**
 *  将当前operation(request对应的response数据)保存起来 --> 缓存相同的请求数据
 */
- (void)saveOperation:(NSData *)responseData forKey:(NSString *)key;

/**
 *  获取operation中包含的response data
 */
- (NSData *)cachedResponseWithOperation:(NetworkOperation *)operation;

/**
 *  是否已经开启使用缓存功能
 */
- (BOOL)isCacheEnabled;

/**
 *  将与cache相关的3个字典对象从内存中，保存到本地
 */
- (void)saveCache;

/**
 *  创建request header 标示当前请求服务器的客户端类型(iOS , Android ...)
 */
- (NSMutableDictionary *)createRequestHeader;

@end
