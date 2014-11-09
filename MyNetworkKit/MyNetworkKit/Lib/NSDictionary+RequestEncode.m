//
//  NSDictionary+RequestEncode.m
//  MyNetworkKit
//
//  Created by xiongzenghui on 14/11/8.
//  Copyright (c) 2014年 xiong. All rights reserved.
//

#import "NSDictionary+RequestEncode.h"
#import "NSString+MyNetworkKitExtension.h"

@implementation NSDictionary (RequestEncode)

-(NSString*) urlEncodedKeyValueString {
    
    NSMutableString *string = [NSMutableString string];
    for (NSString *key in self) {
        
        NSObject *value = [self valueForKey:key];
        if([value isKindOfClass:[NSString class]])
            [string appendFormat:@"%@=%@&", [key my_urlEncodedString], [((NSString*)value) my_urlEncodedString]];
        else
            [string appendFormat:@"%@=%@&", [key my_urlEncodedString], value];
    }
    
    if([string length] > 0)
        [string deleteCharactersInRange:NSMakeRange([string length] - 1, 1)];
    
    return string;
}

-(NSString*) jsonEncodedKeyValueString {//json --> NSDictionary
    NSError * error = nil;
    NSData * data = [NSJSONSerialization dataWithJSONObject:self
                                                    options:0 //0:no print , 1:print
                                                      error:&error];
    if (error) {
        NSLog(@"JSON Dict 解析错误: %@", error);
    }
    
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

-(NSString*) plistEncodedKeyValueString {//plist --> NSDictionary
    
    NSError * error = nil;
    NSData * data = [NSPropertyListSerialization dataWithPropertyList:self format:NSPropertyListXMLFormat_v1_0 options:0 error:&error];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
