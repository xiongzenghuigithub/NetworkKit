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
#import "NetworkOperation.h"


@interface ViewController () {
    NSString * _name;
    NetworkEngine * engine;
    NetworkOperation * op;
    UIBackgroundTaskIdentifier backgroudTaskId;
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
    
    //1. Engine (NSOperationQueue)
    engine = [[NetworkEngine alloc] initWithHostName:HostName CustomHeaderFileds:nil Port:nil];
    [engine useCache];
    
    //2. NSOperation
    op = [engine operationWithApiPath:@"v1/deal/get_all_id_list" ParamsDict:nil HttpReqMethod:@"GET"];
    
    //3. NSOperation setFreezeble
    [op setFreezable:YES];
    
    //4. add call back
    [op addCompletBlock:^(NetworkOperation *completCachedOpeation) {
        NSLog(@"completCachedOpeation = %@ " , completCachedOpeation);
    } ErrorBlock:^(NetworkOperation *completOperation, NSError *err) {
        NSLog(@"err = %@ " , err);
    }];
    
    //5. engine enQueue operation
    [engine enqueueOperation:op];

}

- (void)backgroudTaskMudule {
    
    //1. applay
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //2. begin task
        backgroudTaskId =[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^(void) {
            
            //3. do some things ..
            
            //4. end task
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if (backgroudTaskId != UIBackgroundTaskInvalid) {
                    [[UIApplication sharedApplication] endBackgroundTask:backgroudTaskId];
                    backgroudTaskId = UIBackgroundTaskInvalid;
                    NSLog(@"\n1\n");
                }
            });
        }];
    });

}


@end
