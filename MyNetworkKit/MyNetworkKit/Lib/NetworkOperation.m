//
//  NeworkOperation.m
//  MyNetworkKit
//
//  Created by xiongzenghui on 14/11/8.
//  Copyright (c) 2014年 xiong. All rights reserved.
//

#import "NetworkOperation.h"

#define kNetworkKitRequestTimeOutInSeconds 30

@interface NetworkOperation () {
    
    NKPostDataEncodingType _postDataEncoding;
    NSString * _name;
}

@end

@implementation NetworkOperation

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

- (NKPostDataEncodingType)postDataEncoding {
    return _postDataEncoding;
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
            method = @"get";
        }
        
        if ([method isEqualToString:@"get"]) {  //如果是get请求，设置如何缓存请求数据
            self.cacheHeader = [NSMutableDictionary dictionary];
        }
        
        //取出字典保存的请求参数，拼接在 api? 后
        if ([method isEqualToString:@"get"] && [dict count] > 0) {
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
        
        if ([method isEqualToString:@"post"] /*|| [method isEqualToString:@"put"]*/) {
            self.postDataEncoding = NKPostDataEncodingTypeURL;  //默认post数据类型
        }
        
        
//---------------------------------------------------------------------------------
        
        [self.request setHTTPMethod:method];
        
    }
    
    return self;
}

@end
