/**
 *  重写一个NSOperation子类的基本结构
 */

#import <Foundation/Foundation.h>

typedef void (^CompletionBlock)(id args);

@interface MyOperation : NSOperation

@property (nonatomic, copy, readonly)CompletionBlock complet;

- (id)initWithTarget:(id)target;
- (id)initWithBlock:(CompletionBlock)complet;

@end
