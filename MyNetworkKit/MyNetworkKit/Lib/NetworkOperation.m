//
//  NeworkOperation.m
//  MyNetworkKit
//
//  Created by xiongzenghui on 14/11/8.
//  Copyright (c) 2014年 xiong. All rights reserved.
//

#import "NetworkOperation.h"

#define kNetworkKitRequestTimeOutInSeconds 30

//TODO: Operation对象实现NSURLConnectionDelegate (1. 请求服务器  2. 接受服务器回调数据)
@interface NetworkOperation () <NSCoding , NSCopying , NSURLConnectionDelegate>

//TODO: Operation对象的所有的私密属性
@property (nonatomic, copy) NSString * uniqueStr;                                                 //返回NSString分类创建的唯一字符串

@property (nonatomic, strong) NSMutableArray * downloadStreams;                                   //保存所有的下载流
                                               

@end

@implementation NetworkOperation

#pragma mark - NSCoding代理 - encodeWithCoder: 编码
- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:self.customHeader forKey:@"customHeader"];
    [aCoder encodeBool:self.shouldSendAcceptLanguageHeader forKey:@"shouldSendAcceptLanguageHeader"];
    [aCoder encodeObject:self.cacheHeaders forKey:@"cacheHeaders"];
    [aCoder encodeObject:self.paramDict forKey:@"paramDict"];
    [aCoder encodeInteger:self.postDataEncoding forKey:@"postDataEncoding"];
    [aCoder encodeObject:self.request forKey:@"request"];
    [aCoder encodeInteger:self.stringEncoding forKey:@"stringEncoding"];
    [aCoder encodeBool:self.freezable forKey:@"freezable"];
    [aCoder encodeObject:self.uniqueIdentifier forKey:@"uniqueIdentifier"];
    [aCoder encodeObject:self.responseData forKey:@"responseData"];
    [aCoder encodeBool:self.shouldNotCacheResponse forKey:@"shouldNotCacheResponse"];
    [aCoder encodeBool:self.shouldCacheResponseViaHTTPS forKey:@"shouldCacheResponseViaHTTPS"];
    [aCoder encodeInteger:self.state forKey:@"state"];
    [aCoder encodeObject:self.cacheHandler forKey:@"cacheHandler"];
    [aCoder encodeObject:self.responseBlockList forKey:@"responseBlockList"];
    [aCoder encodeObject:self.uploadBlockList forKey:@"uploadBlockList"];
    [aCoder encodeObject:self.downloadBlockList forKey:@"downloadBlockList"];
    [aCoder encodeObject:self.imageBlockList forKey:@"imageBlockList"];
    [aCoder encodeObject:self.responseErrorBlockList forKey:@"responseErrorBlockList"];
    [aCoder encodeObject:self.errorBlockList forKey:@"errorBlockList"];
    [aCoder encodeObject:self.downloadStreams forKey:@"downloadStreams"];
}

#pragma mark - NSCoding代理 - initWithCoder: 解码
- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self.customHeader = [aDecoder decodeObjectForKey:@"customHeader"];
    self.shouldSendAcceptLanguageHeader = [aDecoder decodeBoolForKey:@"shouldSendAcceptLanguageHeader"];
    self.cacheHeaders = [aDecoder decodeObjectForKey:@"cacheHeaders"];
    self.paramDict = [aDecoder decodeObjectForKey:@"paramDict"];
    self.postDataEncoding = [aDecoder decodeIntForKey:@"postDataEncoding"];
    self.request = [aDecoder decodeObjectForKey:@"request"];
    self.stringEncoding = [aDecoder decodeIntForKey:@"stringEncoding"];
    self.freezable = [aDecoder decodeBoolForKey:@"freezable"];
    self.uniqueIdentifier = [aDecoder decodeObjectForKey:@"uniqueIdentifier"];
    self.responseData = [aDecoder decodeObjectForKey:@"responseData"];
    self.shouldNotCacheResponse = [aDecoder decodeBoolForKey:@"shouldNotCacheResponse"];
    self.shouldCacheResponseViaHTTPS = [aDecoder decodeBoolForKey:@"shouldCacheResponseViaHTTPS"];
    self.state = [aDecoder decodeIntForKey:@"state"];
    self.cacheHandler = [aDecoder decodeObjectForKey:@"cacheHandler"];
    self.responseBlockList = [aDecoder decodeObjectForKey:@"responseBlockList"];
    self.uploadBlockList = [aDecoder decodeObjectForKey:@"uploadBlockList"];
    self.downloadBlockList = [aDecoder decodeObjectForKey:@"downloadBlockList"];
    self.imageBlockList = [aDecoder decodeObjectForKey:@"imageBlockList"];
    self.responseErrorBlockList = [aDecoder decodeObjectForKey:@"responseErrorBlockList"];
    self.errorBlockList = [aDecoder decodeObjectForKey:@"errorBlockList"];
    self.downloadStreams = [aDecoder decodeObjectForKey:@"downloadStreams"];
    
    
    return self;
}

//TODO:  NSCoping协议
#pragma mark - NSCoping协议 - copyWithZone - 使用 copy 拷贝一个新的对象
- (id)copyWithZone:(NSZone *)zone {
    NetworkOperation * theCopy = [[self.class allocWithZone:zone] init];
    
    [theCopy setCustomHeader:[self.customHeader copy]];
    theCopy.shouldSendAcceptLanguageHeader = self.shouldSendAcceptLanguageHeader;
    theCopy.postDataEncoding = self.postDataEncoding;
    theCopy.stringEncoding = self.stringEncoding;
    theCopy.freezable = self.freezable;
    theCopy.shouldNotCacheResponse = self.shouldNotCacheResponse;
    theCopy.shouldCacheResponseViaHTTPS = self.shouldCacheResponseViaHTTPS;
    theCopy.state = self.state;
    [theCopy setCacheHeaders:[self.cacheHeaders copy]];
    [theCopy setParamDict:[self.paramDict copy]];
    [theCopy setRequest:[self.request copy]];
    [theCopy setUniqueIdentifier:[self.uniqueIdentifier copy]];
    [theCopy setResponseData:[self.responseData copy]];
    [theCopy setCacheHandler:[self.cacheHandler copy]];
    [theCopy setResponseBlockList:[self.responseBlockList copy]];
    [theCopy setUploadBlockList:[self.uploadBlockList copy]];
    [theCopy setDownloadStreams:[self.downloadBlockList copy]];
    [theCopy setResponseErrorBlockList:[self.responseErrorBlockList copy]];
    [theCopy setErrorBlockList:[self.errorBlockList copy]];
    [theCopy setDownloadStreams:[self.downloadStreams copy]];
    
    return theCopy;
}

#pragma mark - NSCoping协议 - copyWithZone - 使用 mutableCopy 拷贝一个新的对象
- (id)mutableCopy {
    NetworkOperation * theMutableCopy = [[self.class alloc] init];
    
    [theMutableCopy setCustomHeader:[self.customHeader mutableCopy]];
    theMutableCopy.shouldSendAcceptLanguageHeader = self.shouldSendAcceptLanguageHeader;
    theMutableCopy.postDataEncoding = self.postDataEncoding;
    theMutableCopy.stringEncoding = self.stringEncoding;
    theMutableCopy.freezable = self.freezable;
    theMutableCopy.shouldNotCacheResponse = self.shouldNotCacheResponse;
    theMutableCopy.shouldCacheResponseViaHTTPS = self.shouldCacheResponseViaHTTPS;
    theMutableCopy.state = self.state;
    [theMutableCopy setCacheHeaders:[self.cacheHeaders mutableCopy]];
    [theMutableCopy setParamDict:[self.paramDict mutableCopy]];
    [theMutableCopy setRequest:[self.request mutableCopy]];
    [theMutableCopy setUniqueIdentifier:[self.uniqueIdentifier copy]];  //uniqueid不能使用mutableCopy
    [theMutableCopy setResponseData:[self.responseData mutableCopy]];
    [theMutableCopy setCacheHandler:[self.cacheHandler mutableCopy]];
    [theMutableCopy setResponseBlockList:[self.responseBlockList mutableCopy]];
    [theMutableCopy setUploadBlockList:[self.uploadBlockList mutableCopy]];
    [theMutableCopy setDownloadStreams:[self.downloadBlockList mutableCopy]];
    [theMutableCopy setResponseErrorBlockList:[self.responseErrorBlockList mutableCopy]];
    [theMutableCopy setErrorBlockList:[self.errorBlockList mutableCopy]];
    [theMutableCopy setDownloadStreams:[self.downloadStreams mutableCopy]];
    
    return theMutableCopy;
}

//- (id)copyForRetry {
//    
//    NetworkOperation * theMutableCopy = [[self.class alloc] init];
//    
//    [theMutableCopy setCustomHeader:[self.customHeader mutableCopy]];
//    //    [theCopy setShouldSendAcceptLanguageHeader:[self.shouldNotCacheResponse copy]];//注意: BOOL值不需要copy
//    [theMutableCopy setCacheHeaders:[self.cacheHeaders mutableCopy]];
//    [theMutableCopy setParamDict:[self.paramDict mutableCopy]];
//    //    theCopy setPostDataEncoding:[self.postDataEncoding cop]////注意: int值不需要copy
//    [theMutableCopy setRequest:[self.request mutableCopy]];
//    [theMutableCopy setUniqueIdentifier:[self.uniqueIdentifier mutableCopy]];
//    [theMutableCopy setResponseData:[self.responseData mutableCopy]];
//    [theMutableCopy setCacheHandler:[self.cacheHandler mutableCopy]];
//    [theMutableCopy setResponseBlockList:[self.responseBlockList mutableCopy]];
//    [theMutableCopy setUploadBlockList:[self.uploadBlockList mutableCopy]];
//    [theMutableCopy setDownloadStreams:[self.downloadBlockList mutableCopy]];
//    [theMutableCopy setResponseErrorBlockList:[self.responseErrorBlockList mutableCopy]];
//    [theMutableCopy setErrorBlockList:[self.errorBlockList mutableCopy]];
//    [theMutableCopy setDownloadStreams:[self.downloadStreams mutableCopy]];
//    
//    return theMutableCopy;
//}


//TODO: 判断当前operation能不能使用缓存功能
- (BOOL)isCachable {
    
    //1. 设置了当前operation不允许缓存resposne
    if (self.shouldNotCacheResponse) return NO;
    
    //2. 只有GET请求可以使用缓存response
    if (![[[self request] HTTPMethod] isEqualToString:@"GET"]) return NO;
    
    //3. 当GET请求使用https协议时 , 是否可以缓存response
    if ([[[[[self request] URL] scheme] lowercaseString] isEqualToString:@"https"]) return self.shouldCacheResponseViaHTTPS;
// TODO: 获取request的请求协议是http or https  :   [[self.request.URL.scheme lowercaseString] isEqualToString:@"https"]
    
    //4. GET请求中得下载操作 , 不能被缓存
    if ([self.downloadStreams count] > 0) return NO;
    
    return YES;
}

-(NSUInteger) hash {
    return  [[self uniqueIdentifier] hash];
}

- (void)setFreezable:(BOOL)freezable {
    
    // get请求不允许被冻结
    if (freezable == YES && [[_request HTTPMethod] isEqualToString:@"GET"]) return;
    
    //保存
    _freezable = freezable;
    
    //如果是冻结operation， 并且唯一字符串为空，构造一个唯一的字符串 （让operation.uniqueId多加一个唯一字符串 --> 独一无二）
    if (freezable == YES && _uniqueStr == nil) {
        _uniqueStr = [NSString my_uniqueString];
    }
}


//TODO: 为每一个operation创建一个唯一id值
/**
 *  每一个operation的唯一identify值组成:
 *
 *      情形1: 当前operation没有设置可以被冻结
 *                 identify = 请求方法(GET或POST) + request.url
 *
 *      情形2: 当前operation设置了可以被冻结
 *                 idenfity = 请求方法(POST、PUT...) + request.url + NSString生成的唯一字符串(因为要保存到本地, 必须保证operation的唯一性)
 *                 (注意:  GET请求不能被冻结)
 */
- (NSString *)uniqueIdentifier {
    
    NSMutableString * uniqueIdForOperation = [NSMutableString string];
    
    //1. 每一个operation的id =  get/post + request.url
    [uniqueIdForOperation appendString:[NSString stringWithFormat:@"%@ %@" , self.request.HTTPMethod , self.url]];
    
    //2. 如果当前operation需要被冻结, 每一个operation的id = (get/post + request.url) + 字符串唯一值(self.uniqueStr)
    if (self.freezable) {
        [uniqueIdForOperation appendString:[self uniqueStr]];
    }
    
    //3. 返回唯一id值得 md5加密值
    return [uniqueIdForOperation my_md5];
}

//TODO: 设置手动发出KVO
+ (BOOL)automaticallyNotifiesObserversForKey: (NSString *)theKey {
    
    BOOL isAutomic;
    
    //取消postDataEncoding属性的变化后，自动通知改成手动 (willChange.. / didChange...)
    if ([theKey isEqualToString:@"postDataEncoding"]) {
        isAutomic = NO;
    }else{
        isAutomic = [super automaticallyNotifiesObserversForKey:theKey];
    }
    
    return isAutomic;
}


//TODO: 对要post到服务器的数据设置编码
- (void)setPostDataEncoding:(NKPostDataEncodingType)postDataEncoding {
    
    //要post的数据 类型
    _postDataEncoding = postDataEncoding;
    
    //TODO: post的数据使用哪一种文字编码 (如: GBK , GB1312 , UTF8 ...)
    NSString * charset = (__bridge NSString*)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(self.stringEncoding));
    
    //TODO: 根据post的数据类型 , 设置文件内容的编码格式
    switch(_postDataEncoding) {
            
            //结构:  application/文件类型表示; charset=文字编码格式    (不同的编码格式，显示不同国家地区的文字)
            
        case NKPostDataEncodingTypeURL:
            [self.request setValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", charset]
                forHTTPHeaderField:@"Content-Type"];
            break;
            
        case NKPostDataEncodingTypeJSON:
            [self.request setValue:[NSString stringWithFormat:@"application/json; charset=%@", charset]
                forHTTPHeaderField:@"Content-Type"];
            break;
            
        case NKPostDataEncodingTypePlist:
            [self.request setValue:[NSString stringWithFormat:@"application/x-plist; charset=%@", charset]
                forHTTPHeaderField:@"Content-Type"];
            break;
            
            //TODO: post自定义的文件类型 (1.客户端 2.服务端 Content-Type一致)
        case NKPostDataEncodingTypeCustom:
            [self.request setValue:[NSString stringWithFormat:@"自定义post文件格式和服务器协商; charset=%@", charset]
                forHTTPHeaderField:@"Content-Type"];
            break;
    }

}


//TODO: Operation create instance
- (id)initWithURL:(NSString *)reqURL ParamDict:(NSDictionary *)dict ReqMethod:(NSString *)method {
    
    if ((self = [super init])) {
    
        //初始化各种Block数组
        self.responseBlockList = [NSMutableArray array];
        self.uploadBlockList = [NSMutableArray array];
        self.downloadBlockList = [NSMutableArray array];
        self.imageBlockList = [NSMutableArray array];
        self.responseErrorBlockList = [NSMutableArray array];
        self.errorBlockList = [NSMutableArray array];
    
        //初始化post数据的编码
        self.stringEncoding = NSUTF8StringEncoding;
        
//----------------------------------get request-----------------------------------
        
        NSURL * finalURL = nil;
        
        if (method == nil) {    //默认是get请求
            method = @"GET";
        }
        
        if ([method isEqualToString:@"GET"]) {  //如果是get请求，设置如何缓存请求数据
            self.cacheHeaders = [NSMutableDictionary dictionary];
        }
        
        //取出字典保存的请求参数，拼接在 api? 后
        if ([method isEqualToString:@"GET"] && [dict count] > 0) {
            self.paramDict = [dict mutableCopy];
            NSString * url = [NSString stringWithFormat:@"%@?%@" , reqURL , [self.paramDict urlEncodedKeyValueString]];
            finalURL = [NSURL URLWithString:url];
        }else {
            finalURL = [NSURL URLWithString:reqURL];
        }
        
        if (finalURL == nil) {
            NSLog(@"APi请求路径 或 请求参数错误!");
            return nil;
        }
        
        //1. get请求的URL  2.post请求的URL
        self.request = [NSMutableURLRequest requestWithURL:finalURL
                                               cachePolicy:NSURLRequestReloadIgnoringLocalCacheData         //忽略本地缓存
                                           timeoutInterval:kNetworkKitRequestTimeOutInSeconds];
        
        
//----------------------------------post request-----------------------------------
        
        if ([method isEqualToString:@"POST"] /*|| [method isEqualToString:@"put"]*/) {
            self.postDataEncoding = NKPostDataEncodingTypeURL;  //默认post数据类型
        }
        
        
//---------------------------------------------------------------------------------
        
        [self.request setHTTPMethod:method];
        
    }
    
    return self;
}

//TODO: 返回operation.request.URL.absoluteString
- (NSString *)url {
    return [[[self request] URL] absoluteString];
}

- (void)setCacheHanler:(NKResponseBlock)_handler {
    self.cacheHandler = _handler;
}

- (void)setResponseData:(NSData *)responseData {
    
    //1. 接受传入的response data
    _responseData = responseData;
    
    //2. 结束操作当前operation
    [self operationDidCompletWithSuccess];
}

- (void)operationDidCompletWithSuccess {
    
    //一个operation == 一个 http request
    //一个operation 可以包含多个 对相同request的response data的多个业务逻辑 回调block块
    for (NKResponseBlock responseBlock in self.responseBlockList) {
        responseBlock(self);                        //将当前operation作为代码块的参数值 (operation 包含了 response data)
    }
}

-(void) updateOperationBasedOnPreviousHeaders:(NSMutableDictionary*) headers {
    
    NSString * lastModify = headers[@"Last-Modified"];
    NSString * eTag = headers[@"ETag"];
    
    if (lastModify) {
        [self.request setValue:lastModify forKey:@"IF-MODIFIED-SINCE"];
    }
    
    if (eTag) {
        [self.request setValue:eTag forKey:@"IF-NONE-MATCH"];
    }
}

-(void) updateHandlersFromOperatio:(NetworkOperation *)operation {
    
    [self.responseBlockList addObjectsFromArray:operation.responseBlockList];
    [self.responseErrorBlockList addObjectsFromArray:operation.responseErrorBlockList];
    [self.uploadBlockList addObjectsFromArray:operation.uploadBlockList];
    [self.downloadBlockList addObjectsFromArray:operation.downloadBlockList];
    [self.downloadStreams addObjectsFromArray:operation.downloadStreams];
    [self.errorBlockList addObjectsFromArray:operation.errorBlockList];
}

- (BOOL)isFinished {
    return (self.state == NetworkOperationStateFinished);
}

@end
