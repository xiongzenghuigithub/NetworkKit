//
//  ViewController.m
//  MyNetworkKit
//
//  Created by wadexiong on 14/11/4.
//  Copyright (c) 2014年 xiong. All rights reserved.
//

#import "ViewController.h"

#import "MyOperation.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    

    Reachability * r1 = [Reachability reachableWithHostName:@"www.baidu.com"];
    
    [r1 startNotifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotifier:) name:kReachabilityChangedNotification object:nil];
    
    NSString * unique = [NSString uniqueString];
    NSString * md5 = [@"xzh" md5];
    UIImage * img = [UIImage createImageWithName:@"test.png"];
    NSString * urlEncode = [@"www.我的hiohoop哈哈哈?id=他的.com" my_urlEncodedString];
    NSLog(@"urlEncode = %@\n" ,urlEncode);
    NSString * urlDecode = [urlEncode my_urlDecodedString];
    NSLog(@"urlDecode = %@\n",urlDecode );
    
//    Reachability * r2 = [Reachability reachabilityForLocalWiFi];
//    Reachability * r3 = [Reachability reachableForInternet];
/*
    
    //1.
    dispatch_group_t group = dispatch_group_create();
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(10);
    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT);
    
    for (int i = 0; i < 100; i++) {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_group_async(group, queue, ^{
           
            NSLog(@"当前Block在新创建的第 %d 号新线程上执行", i);
            sleep(2);
            dispatch_semaphore_signal(semaphore);
        });
    }
    
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);

#if __has_feature(objc_arc)
    group = nil;
    queue = nil;
    semaphore = nil;
#else
    dispatch_release(queue);
    dispatch_release(semaphore);
    dispatch_release(group);
#endif
 
 */
    
//    NSOperationQueue * queue = [[NSOperationQueue alloc] init];
//    MyOperation * operation1 = [[MyOperation alloc] initWithTarget:r1];
//    MyOperation * operation2 = [[MyOperation alloc] initWithBlock:^(id args) {
//        NSLog(@"取得参数atgs = %@" , args);
//    }];
//    
//    //设置operations之间的依赖
//    [operation2 addDependency:operation1];
//    
//    //设置operation的优先级
//    [operation2 setQueuePriority:NSOperationQueuePriorityHigh];
//    
//    [queue addOperation:operation1];
//    [queue addOperation:operation2];
//    
//    //queue的释放
//    //operations的释放
    
    
}

- (void)receiveNotifier:(NSNotification *)notify {
    id obj = [notify object];
    NSLog(@"notify = %@" , notify);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
