//
//  NSObject+Router.m
//  YBRouter
//
//  Created by 王迎博 on 2020/1/9.
//  Copyright © 2020 王迎博. All rights reserved.
//

#import "NSObject+Router.h"
#import <objc/runtime.h>
#import "YBRouterTool.h"
#import "YBRouterProtocol.h"

extern NSString * const kSeparareMiddleSymbol;
static const void *routerCompletionKey = &routerCompletionKey;
static const void *routerParameterKey = &routerParameterKey;

@interface NSObject ()
@property (nonatomic, strong) id routerParameter;

@end

@implementation NSObject (Router)

@dynamic routerCompletion;

#pragma mark - routerString
static char routerStringKey;
- (NSString *)routerString
{
    return objc_getAssociatedObject(self, &routerStringKey);
}

- (void)setRouterString:(NSString *)routerString {
    objc_setAssociatedObject(self, &routerStringKey, routerString, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

#pragma mark - routerParameter
- (id)routerParameter {
    return objc_getAssociatedObject(self, &routerParameterKey);
}

- (void)setRouterParameter:(id)routerParameter {
    objc_setAssociatedObject(self, &routerParameterKey, routerParameter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - routerCompletion
- (FBRouterHandlerCompletion)routerCompletion {
    return objc_getAssociatedObject(self, routerCompletionKey);
}

- (void)setRouterCompletion:(FBRouterHandlerCompletion)routerCompletion {
    objc_setAssociatedObject(self, routerCompletionKey, routerCompletion, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

#pragma mark - factory
+ (instancetype)factoryInstance {
    Class class = [self class];
    return [[class alloc] init];
}

id objectInstance(Class class) {
    return [[class alloc] init];
}

#pragma mark - public

- (NSString *)getRouterString {
    NSArray *array = [self.routerString componentsSeparatedByString:kSeparareMiddleSymbol];
    NSString *router = @"";
    if (array.count < 2) {
        router = self.routerString;
    }else {
        router = [array firstObject];
    }
    
    return router;
}

- (id)getRouterParameter {
    NSAssert([self conformsToProtocol:@protocol(YBRouterProtocol)] || [self conformsToProtocol:@protocol(YBRouterKVCProtocol)], @"没有遵守路由协议");
    id obj = [YBRouterTool decodeRouterWithRouter:self.routerString];
    
    NSMutableDictionary *mutDic = [NSMutableDictionary dictionaryWithDictionary:obj];
    if (self.routerParameter) {
        if ([self.routerParameter isKindOfClass:[NSDictionary class]]) {
            [mutDic addEntriesFromDictionary:self.routerParameter];
        }else {
            [mutDic setObject:self.routerParameter forKey:kYBRouterCustomParameterKey];
        }
    }
    return mutDic.copy;
}

- (id)getRouterUrlParameter {
    if (![self getRouterParameter]) {
        return nil;
    }
    return [self getRouterParameter][kYBRouterUrlParameterKey];
}

- (id)getRouterCustomParameter {
    if (self.routerParameter) {
        return self.routerParameter;
    }
    if (![self getRouterParameter]) {
        return nil;
    }
    return [self getRouterParameter][kYBRouterCustomParameterKey];
}

- (void)configRouterString:(NSString *)string {
    self.routerString = string;
}

- (void)configRouterParameter:(id)routerParameter {
    self.routerParameter = routerParameter;
}

#pragma mark - kvc method
- (void)setValueByKeyWithIgnoredKeys:(NSArray<NSString *> *)ignoredArr {
    NSDictionary *dic = [self getRouterParameter];
    if (!dic){ return; }
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        //[self respondsToSelector:NSSelectorFromString(key)]
        if (key && obj) {
            if ([key isKindOfClass:[NSNumber class]]) {
                key = ((NSNumber *)key).stringValue;
            }
            if (ignoredArr.count>0 && [key isKindOfClass:[NSString class]]) {
                if ([ignoredArr containsObject:key] || [ignoredArr containsObject:[NSString stringWithFormat:@"_%@",key]]) {
                }else {
                    [self setValue:obj forKey:key];
                }
            }else {
                [self setValue:obj forKey:key];
            }
        }
    }];
}

/**
 返回yes，则会寻找_propertyName,propertyName,_isPropertyName,set:等成员属性或者成员变量

 @return bool值
 */
+ (BOOL)accessInstanceVariablesDirectly {
    return YES;
}

/**
 重写拦截设置value为nil的情况
 */
- (void)setNilValueForKey:(NSString *)key {
    NSString *des = [NSString stringWithFormat:@"%@ <%p> the value of key:%@ is nil",NSStringFromClass([self class]),self,key];
    NSAssert(NO, des);
}

/**
 重写拦截设置的key为空的情况或key找不到的情况
 */
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSString *des = [NSString stringWithFormat:@"%@ <%p> not exsit the key:%@",NSStringFromClass([self class]),self,key];
    NSAssert(NO, des);
}

/**
 重写拦截设置的key为空的情况key找不到的情况
 */
- (id)valueForUndefinedKey:(NSString *)key {
    NSString *des = [NSString stringWithFormat:@"%@ <%p> not exsit the key:%@",NSStringFromClass([self class]),self,key];
    NSAssert(NO, des);
    return nil;
}
@end
