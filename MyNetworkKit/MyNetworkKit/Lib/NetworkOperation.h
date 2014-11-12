//
//  ;
//  MyNetworkKit
//
//  Created by xiongzenghui on 14/11/8.
//  Copyright (c) 2014年 xiong. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NetworkOperation;

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

    
}


@property (nonatomic, strong) NSDictionary * customHeader;              //请求头
@property (nonatomic, assign) BOOL shouldSendAcceptLanguageHeader;      //语言化

@property (nonatomic, strong) NSMutableDictionary * cacheHeader;        //缓存设置列表
@property (nonatomic, strong) NSMutableDictionary * paramDict;          //请求参数
@property (nonatomic, assign) NSStringEncoding stringEncoding;          //文字内容的编码格式 (如: 中文显示需要GBK编码格式)

@property (nonatomic, strong) NSMutableURLRequest * request;            //当前Operation封装的请求对象

//TODO: 缓存数据回调处理
@property (nonatomic , copy) NKResponseBlock cacheBlock;

//TODO: 各种回传值Block数组
@property (nonatomic, strong) NSMutableArray * responseBlockList;
@property (nonatomic, strong) NSMutableArray * uploadBlockList;
@property (nonatomic, strong) NSMutableArray * downloadBlockList;
@property (nonatomic, strong) NSMutableArray * imageBlockList;
@property (nonatomic, strong) NSMutableArray * responseErrorBlockList;
@property (nonatomic, strong) NSMutableArray * errorBlockList;






- (id)initWithURL:(NSString *) reqURL
        ParamDict:(NSDictionary *) dict
        ReqMethod:(NSString *)method;

/**
 *  接收处理缓存数据Block
 */
- (void)setCacheBlock:(NKResponseBlock)_cacheBlock;

/**
 *  判断当前Operation执行的请求是否有缓存数据
 */
- (BOOL)isCached;


@end
