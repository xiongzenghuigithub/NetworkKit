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


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];


    Reachability * r1 = [Reachability reachableWithHostName:@"www.baidu.com"];
    
    [r1 startNotifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotifier:) name:kReachabilityChangedNotification object:nil];
    
    NSString * unique = [NSString my_uniqueString];
    NSString * md5 = [@"xzh" my_md5];
    UIImage * img = [UIImage createImageWithName:@"test.png"];
    NSString * urlEncode = [@"www.我的hiohoop哈哈哈?id=他的.com" my_urlEncodedString];
    NSLog(@"urlEncode = %@\n" ,urlEncode);
    NSString * urlDecode = [urlEncode my_urlDecodedString];
    NSLog(@"urlDecode = %@\n",urlDecode );
    [NSString getTmpPath];
    [NSString getCachesPath];
    [NSString getHomePath];
    [NSString getDocumentsPath];
    
    NSDictionary * d = @{
                         @"name":@"zhangsan",
                         @"age":@"19",
                         @"address":@"湖南"
                         };
    NSString * d_str = [d urlEncodedKeyValueString];
    NSString * D_str2 = [d jsonEncodedKeyValueString];

    
    NSString * bundleName = [NSString getMainBundleName];
    NSString * version = [NSString getVersionForMainBundle];
    
}

#pragma mark - 接收到网络状态发生改变后的通知 , 并从通知中取出Reachability对象
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
