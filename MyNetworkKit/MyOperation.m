//
//  MyOperation.m
//  MyNetworkKit
//
//  Created by wadexiong on 14/11/6.
//  Copyright (c) 2014年 xiong. All rights reserved.
//

#import "MyOperation.h"

@interface MyOperation () {
    id _target;
    BOOL executing;
    BOOL finished;
}

@end

@implementation MyOperation

- (id)initWithTarget:(id)target {
    if (self = [super init]) {
        _target = target;
    }
    return self;
}

- (id)initWithBlock:(CompletionBlock)complet {
    if (self = [super init]) {
        _complet = [complet copy];
    }
    return  self;
}

- (void)dealloc {
    _target = nil;
    _complet = nil;
}

- (void)main {
    
    @try {
    
        @autoreleasepool {
      
            NSLog(@"当前Operation要执行的任务代码");
            //1. 执行operation包装的任务
            [self executeOperation];
        
            //2. 完成opeation后更改oepration的状态
            [self completOperation];
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
}

- (BOOL)isConcurrent {
    return YES;
}

- (BOOL)isExecuting {
    return executing;
}

- (BOOL)isFinished {
    return finished;
}

- (void)start {
    
    //判断当前operation是否已经取消执行
    if([self isCancelled]) {
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }
    
    //表示当前operation没有取消，那么执行oepration
    [self willChangeValueForKey:@"isExecuting"];
    
    //创建新的 后台匿名线程 执行operation的main函数(封装了当前oepration需要做的事情)
    [NSThread detachNewThreadSelector:@selector(main) toTarget:self withObject:nil];
    executing = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
}

//执行当前operation包装的任务代码
- (void)executeOperation {
    
    //1. 执行传入的target的某个方法
    if (_target != nil) {
        [_target performSelector:@selector(test) withObject:nil];
    }
    //2. 执行传入地Block
    if (_complet != nil) {
        _complet(@"传出的参数");
    }
}

//执行当前operation完毕后，修改状态
- (void)completOperation {
    
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];
    
    finished = YES;
    executing = NO;
    
    [self didChangeValueForKey:@"isFinished"];
    [self didChangeValueForKey:@"isExecuting"];
    
}

- (BOOL)isReady {
    NSLog(@"operation is ready");
    return YES;
}

@end
