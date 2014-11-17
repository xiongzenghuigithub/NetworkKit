/**
 *  一个NetworkOperation:
 *          
 *    1.  包含了 GET/POST/DELETE/PUT + hostName + apiPath + paramDict , 完整的http request 操作
 *    2.  已经request对应的服务器response data
 *    3.  所有与request、response相关的属性和方法
 *              > 缓存response、缓存设置 ...
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
typedef void (^NKOperationStateChangedBlock)(NetworkOperation * changedOperation);          //当operation的执行状态改变

@interface NetworkOperation : NSBlockOperation {
    
    
    NSData * _responseData;                                            //operation保存的服务器response数据
    
//TODO: 私有变量
@private

//    BOOL _freezable;                                                 //当前operation是否可以冻结
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
@property (nonatomic, assign) BOOL shouldNotCacheResponse;              //设置是够可以缓存response data 数据
@property (nonatomic, assign) BOOL shouldCacheResponseViaHTTPS;         //设置当get请求是 https:// 的时候, 是否可以缓存response
@property (nonatomic, assign) NetworkOperationState state;              //当前operation的执行状态

//TODO: 缓存数据回调处理
@property (nonatomic, copy) NKResponseBlock cacheHandler;
@property (nonatomic, copy) NKOperationStateChangedBlock operationStateChanegedHandler;

//TODO: 各种回传值Block数组
@property (nonatomic, strong) NSMutableArray * responseBlockList;       //保存多个对 同一个URL+相同参数的GET请求 的回调block
@property (nonatomic, strong) NSMutableArray * uploadBlockList;
@property (nonatomic, strong) NSMutableArray * downloadBlockList;
@property (nonatomic, strong) NSMutableArray * imageBlockList;
@property (nonatomic, strong) NSMutableArray * responseErrorBlockList;
@property (nonatomic, strong) NSMutableArray * errorBlockList;
@property (nonatomic, strong) NSMutableArray * notModifiedHandlerList;






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

/**
 *  当前operation执行失败
 */
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
 *  给当前operation设置对response data的回调处理代码
 */
-(void) onCompletion:(NKResponseBlock) response onError:(NKErrorBlock) error DEPRECATED_ATTRIBUTE;

/**
 *  给当前operation设置, 对response data的回调处理代码
 */
- (void) addCompletBlock:(NKResponseBlock) complet ErrorBlock:(NKResponseErrorBlock) error;

/**
 *  给当前operation设置, 当operation 的执行状态改变时的回调代码
 */
- (void) addOperaitonStateChangedBlock:(NKOperationStateChangedBlock) complet;

/**
 *  给当前operation设置, 当服务器返码==304 时候的回调处理代码
 */
- (void) onNotModified:(NKVoidBlock) complet;

/**
 *  给当前operation设置, 下载时候的回调处理代码 , 返回时时下载的进度
 */
- (void) onDownloadProgressChanged:(NKProgressBlock) downloadProgressBlock;

/**
 *  NSOutputStream可以将网络请求的资源回来的数据保存到本地文件
 */
-(void) addDownloadStream:(NSOutputStream*) outputStream;

/**
 *  判断当前operation的response data 是否已经被缓存
 */
- (BOOL) isCachedResponse;

/**
 *  返回当前oepration的response data 服务器响应数据
 */
- (NSData *) responseData;

/**
 *  返回operation.response data 转换后的 JSON Dictionary
 */
- (id) responseJSON;

- (void) setResponseData:(NSData *)responseData;

//TOOD: 当前operation执行状态
- (BOOL) isFinished;
- (BOOL) isReady;
- (BOOL) isExecuting;

/**
 *  返回当前operation.request.url.absoluteString
 */
- (NSString *)url;

/**
 *  当前operation.request.method
 */
- (NSString *)httpMethod;

@end
