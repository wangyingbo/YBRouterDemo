//
//  UIViewController+YBExtension.m
//  FengbangB
//
//  Created by 王迎博 on 2018/6/15.
//  Copyright © 2018年 com.fengbangstore. All rights reserved.
//

#import "UIViewController+YBExtension.h"
#import <objc/runtime.h>
#import "YBRouterTool.h"
#import "YBRouterProtocol.h"

extern NSString * const kSeparareMiddleSymbol;
static const void *rounterCompletionKey = &rounterCompletionKey;
static const void *rounterParameterKey = &rounterParameterKey;

@interface UIViewController ()
@property (nonatomic, strong) id rounterParameter;
@end

@implementation UIViewController (YBExtension)
@dynamic rounterCompletion;

#pragma mark - rounterString
static char rounterStringKey;
- (NSString *)rounterString
{
    return objc_getAssociatedObject(self, &rounterStringKey);
}

- (void)setRounterString:(NSString *)rounterString {
    objc_setAssociatedObject(self, &rounterStringKey, rounterString, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

#pragma mark - rounterParameter
- (id)rounterParameter {
    return objc_getAssociatedObject(self, &rounterParameterKey);
}

- (void)setRounterParameter:(id)rounterParameter {
    objc_setAssociatedObject(self, &rounterParameterKey, rounterParameter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - rounterCompletion
- (FBRounterHandlerCompletion)rounterCompletion {
    return objc_getAssociatedObject(self, rounterCompletionKey);
}

- (void)setRounterCompletion:(FBRounterHandlerCompletion)rounterCompletion {
    objc_setAssociatedObject(self, rounterCompletionKey, rounterCompletion, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

#pragma mark - factory
+ (instancetype)factoryInstance {
    Class class = [self class];
    return [[class alloc] init];
}

id controllerInstance(Class class) {
    return [[class alloc] init];
}

#pragma mark - public

- (NSString *)getRounterString {
    NSArray *array = [self.rounterString componentsSeparatedByString:kSeparareMiddleSymbol];
    NSString *rounter = @"";
    if (array.count < 2) {
        rounter = self.rounterString;
    }else {
        rounter = [array firstObject];
    }
    
    return rounter;
}

- (id)getRounterParameter {
    NSAssert([self conformsToProtocol:@protocol(YBRouterProtocol)] || [self conformsToProtocol:@protocol(YBRouterKVCProtocol)], @"没有遵守路由协议");
    id obj = [YBRouterTool decodeRounterWithRounter:self.rounterString];
    
    NSMutableDictionary *mutDic = [NSMutableDictionary dictionaryWithDictionary:obj];
    if (self.rounterParameter) {
        if ([self.rounterParameter isKindOfClass:[NSDictionary class]]) {
            [mutDic addEntriesFromDictionary:self.rounterParameter];
        }else {
            [mutDic setObject:self.rounterParameter forKey:kYBRouterCustomParameterKey];
        }
    }
    return mutDic.copy;
}

- (id)getRounterUrlParameter {
    if (![self getRounterParameter]) {
        return nil;
    }
    return [self getRounterParameter][kYBRouterUrlParameterKey];
}

- (id)getRounterCustomParameter {
    if (self.rounterParameter) {
        return self.rounterParameter;
    }
    if (![self getRounterParameter]) {
        return nil;
    }
    return [self getRounterParameter][kYBRouterCustomParameterKey];
}

- (void)configRounterString:(NSString *)string {
    self.rounterString = string;
}

- (void)configRounterParameter:(id)rounterParameter {
    self.rounterParameter = rounterParameter;
}

- (void)setValueByKey {
    NSDictionary *dic = [self getRounterParameter];
    if (!dic){ return; }
    [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (key && obj) {//[self respondsToSelector:NSSelectorFromString(key)]
            [self setValue:obj forKey:key];
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
