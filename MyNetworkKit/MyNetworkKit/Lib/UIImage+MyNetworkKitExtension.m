//
//  UIImage+MyNetworkKitExtension.m
//  MyNetworkKit
//
//  Created by wadexiong on 14/11/7.
//  Copyright (c) 2014年 xiong. All rights reserved.
//

#import "UIImage+MyNetworkKitExtension.h"

@implementation UIImage (MyNetworkKitExtension)

+ (UIImage *)createImageWithName:(NSString *)name {
    @autoreleasepool {
        NSString * path = [[NSBundle mainBundle] pathForResource:name ofType:nil];
        NSLog(@"path = %@" ,path);
        UIImage * img = [[UIImage alloc] initWithContentsOfFile:path];
        return img;
    }
}

- (NSString *)base64 {
    //base64是NSData的方法
    NSData * data = UIImageJPEGRepresentation(self, 1.0f);
    return [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}

- (UIImage *)getStrechableImage {
    return [self resizableImageWithCapInsets:UIEdgeInsetsMake(1, 1, 1, 1) resizingMode:UIImageResizingModeStretch];
}

@end
