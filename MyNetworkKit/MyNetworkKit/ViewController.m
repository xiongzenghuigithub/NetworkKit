//
//  ViewController.m
//  MyNetworkKit
//
//  Created by wadexiong on 14/11/4.
//  Copyright (c) 2014年 xiong. All rights reserved.
//

#import "ViewController.h"

#import "MyOperation.h"

#import "NetworkEngine.h"


@interface ViewController () {
    NSString * _name;
}

@end

@implementation ViewController

- (NSString *)name {
    return _name;
}

- (void)setName:(NSString *)name {
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];


//    Reachability * r1 = [Reachability reachableWithHostName:@"www.baidu.com"];
//    
//    [r1 startNotifier];
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotifier:) name:kReachabilityChangedNotification object:nil];
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(20, 100, 100, 50);
    [btn addTarget:self action:@selector(test) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = [UIColor redColor];
    [self.view addSubview:btn];
    
    
    
    NSString * url = @"http://dawdawdawdw";
    
    NSString * api = @"";
    if ([url hasPrefix:@"http://"]) {
        api = [url substringFromIndex:6];
    }else if ([url hasPrefix:@"https://"]){
        api = [url substringFromIndex:7];
    }
    
    
    
    
    
}

#pragma mark - 接收到网络状态发生改变后的通知 , 并从通知中取出Reachability对象
- (void)receiveNotifier:(NSNotification *)notify {
    id obj = [notify object];
    NSLog(@"notify = %@" , notify);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
//    if (object == _name && [keyPath isEqualToString:@"name"]) {
        NSLog(@"----------name变量值发生改变------------");
//    }
}

    
    

@end
