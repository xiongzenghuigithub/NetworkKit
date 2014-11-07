//
//  MyOperation.h
//  MyNetworkKit
//
//  Created by wadexiong on 14/11/6.
//  Copyright (c) 2014年 xiong. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CompletionBlock)(id args);

@interface MyOperation : NSOperation

@property (nonatomic, copy, readonly)CompletionBlock complet;

- (id)initWithTarget:(id)target;
- (id)initWithBlock:(CompletionBlock)complet;

@end
