//
//  ViewController.m
//  MyNetworkKit
//
//  Created by wadexiong on 14/11/4.
//  Copyright (c) 2014年 xiong. All rights reserved.
//

#import "ViewController.h"
#import "Reachability.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [Reachability rechableWithHostName:@"localhost"];
//    Reachability * r1 = [Reachability reachableWithHostName:@"www.baidu.com"];//不要加http://
    [Reachability reachabilityForLocalWiFi];
//    Reachability * r2 = [Reachability reachableForInternet];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
