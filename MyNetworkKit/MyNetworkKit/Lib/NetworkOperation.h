/**
 *  一个NetworkOperation:
 *          
 *    1.  包含了 GET/POST/DELETE/PUT + hostName + apiPath + paramDict , 完整的http request 操作
 *    2.  已经request对应的服务器response data
 */

#import <Foundation/Foundation.h>

@class NetworkOperation;

//TODO: NetworkOperation的状态
typedef enum {
    NetworkOperationStateReady = 1,
    NetworkOperationStateExecuting = 2,
    NetworkOperationStateFinished = 3,
}NetworkOperationState;

//TODO: post到服务器的数据类型定义
typedef enum {
    NKPostDataEncodingTypeURL = 0, // default
    NKPostDataEncodingTypeJSON,
    NKPostDataEncodingTypePlist,
    NKPostDataEncodingTypeCustom
} NKPostDataEncodingType;

//TODO: 定义各种回传值Block
typedef void (^NKVoidBlock)(void);
typedef void (^NKProgressBlock)(double progress);                                           //回传 进度值
typedef void (^NKResponseBlock)(NetworkOperation * completCachedOpeation);                  //回传 response数据(1.缓存 2.服务器json)
typedef void (^NKImageBlock)(UIImage * loadedImage , NSURL * url , BOOL isInCache);         //回传 网路URL指向的图片文件
typedef void (^NKResponseErrorBlock)(NetworkOperation * completOperation, NSError * err);   //回传 response错误
typedef void (^NKErrorBlock)(NSError * error);                                              //回传 普通错误


@interface NetworkOperation : NSOperation {
    
//TODO: 私有变量
@private

//    BOOL _freezable;                                                    //当前operation是否可以冻结
}


//TODO: Operation对象的所有的公开可以设置的属性
@property (nonatomic, strong) NSDictionary * customHeader;              //请求头
@property (nonatomic, assign) BOOL shouldSendAcceptLanguageHeader;      //语言化

@property (nonatomic, strong) NSMutableDictionary * cacheHeaders;        //缓存设置列表
@property (nonatomic, strong) NSMutableDictionary * paramDict;          //请求参数

@property (nonatomic, assign) NKPostDataEncodingType postDataEncoding;  //post到服务器的数据的类型
@property (nonatomic, assign) NSStringEncoding stringEncoding;          //文字内容的编码格式 (如: 中文显示需要GBK编码格式)

@property (nonatomic, strong) NSMutableURLRequest * request;            //当前Operation封装的请求对象
@property (nonatomic, strong) NSString * url;                           //request-->url

@property (nonatomic, assign) BOOL freezable;                           //operation是否可以被归档
@property (nonatomic, copy) NSString * uniqueIdentifier;                //每一个operatin的唯一id值
@property (nonatomic, strong) NSData * responseData;                    //operation保存的服务器response数据
@property (nonatomic, assign) BOOL shouldNotCacheResponse;              //设置是够可以缓存response data 数据
@property (nonatomic, assign) BOOL shouldCacheResponseViaHTTPS;         //设置当get请求是 https:// 的时候, 是否可以缓存response
@property (nonatomic, assign) NetworkOperationState state;              //当前operation的执行状态

//TODO: 缓存数据回调处理
@property (nonatomic , copy) NKResponseBlock cacheHandler;

//TODO: 各种回传值Block数组
@property (nonatomic, strong) NSMutableArray * responseBlockList;       //保存多个对 同一个URL+相同参数的GET请求 的回调block
@property (nonatomic, strong) NSMutableArray * uploadBlockList;
@property (nonatomic, strong) NSMutableArray * downloadBlockList;
@property (nonatomic, strong) NSMutableArray * imageBlockList;
@property (nonatomic, strong) NSMutableArray * responseErrorBlockList;
@property (nonatomic, strong) NSMutableArray * errorBlockList;






- (id)initWithURL:(NSString *) reqURL
        ParamDict:(NSDictionary *) dict
        ReqMethod:(NSString *)method;

/**
 *  接收 处理缓存数据 代码块
 */
- (void)setCacheHanler:(NKResponseBlock)_handler;

/**
 *  判断当前operation包含的response data 到底能不能 被缓存
 */
- (BOOL)isCachable;


/**
 *  返回当前operation的唯一id值(字符串) 的hash值
 */
-(NSUInteger) hash;

/**
 *  当前operation正确执行完毕
 */
- (void)operationDidCompletWithSuccess;

- (void)operationDidCompletWithFail;

/**
 *  修改operation的之前拥有的用来保存cache的参数字典
 */
-(void) updateOperationBasedOnPreviousHeaders:(NSMutableDictionary*) headers;

/**
 *  当前创建的operation已经存在于队列(被多次添加) , 在原来的operation基础上修改其属性
 */
-(void) updateHandlersFromOperatio:(NetworkOperation *)operation;

/**
 *  当前operation是否执行完毕
 */
- (BOOL)isFinished;

/**
 *  返回当前operation.request.url.absoluteString
 */
- (NSString *)url;

@end
