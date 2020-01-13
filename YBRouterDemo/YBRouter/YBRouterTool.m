//
//  FBRouterTool.m
//  FengbangB
//
//  Created by 王迎博 on 2018/6/15.
//  Copyright © 2018年 com.fengbangstore. All rights reserved.
//

#import "YBRouterTool.h"
#import "NSString+JSON.h"

NSString * const kSeparareMiddleSymbol = @"?param=";
NSString * const kYBRouterCustomParameterKey = @"kYBRouterCustomParameterKey";
NSString * const kYBRouterUrlParameterKey = @"kYBRouterUrlParameterKey";
NSString * const kYBRouterSpecialSymbol = @"?";

@implementation YBRouterTool

#pragma mark - public
+ (NSString *)encodeRouterWithPreRouter:(NSString *)preRouter param:(id)param {
    NSString *result;
    NSAssert((preRouter), @"路由前缀字符不能为空");
    if (!preRouter) { preRouter = @""; }
    if (!param) { return preRouter; }
    NSString *json = [NSString jsonStringWithObject:param];
    result = [NSString stringWithFormat:@"%@%@%@",preRouter,(json?kSeparareMiddleSymbol:@""),(json?json:@"")];
    return result;
}

+ (id)decodeRouterWithRouter:(NSString *)router {
    NSAssert(router, @"解析参数router不能为空");
    if (!router) { router = @""; }
    NSArray *array = [router componentsSeparatedByString:kSeparareMiddleSymbol];
    if (array.count<2) {
        NSMutableDictionary *mutRouterDic = [self getURLParameters:router];
        return mutRouterDic.copy;
    }
    
    NSString *preRouter = [array firstObject];
    NSMutableDictionary *mutRouterDic = [self getURLParameters:preRouter];
    NSMutableArray *mutArr = [NSMutableArray arrayWithArray:array];
    [mutArr removeObjectAtIndex:0];
    NSString *json = [mutArr componentsJoinedByString:kSeparareMiddleSymbol];
    id customResultParam = [NSString jsonParseJSONStringToObj:json];
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    if (mutRouterDic) {
        [result setObject:mutRouterDic forKey:kYBRouterUrlParameterKey];
    }
    if (customResultParam) {
        [result setObject:customResultParam forKey:kYBRouterCustomParameterKey];
    }
    
    //如果自定义参数为字典的话，合并两个字典
    if ([customResultParam isKindOfClass:[NSDictionary class]]) {
        [result addEntriesFromDictionary:customResultParam];
    }
    if (mutRouterDic) {
        [result addEntriesFromDictionary:mutRouterDic];
    }
    
    return result.copy;
}

#pragma mark - private
+ (NSMutableDictionary *)getURLParameters:(NSString *)urlStr {
    
    // 查找参数
    NSRange range = [urlStr rangeOfString:kYBRouterSpecialSymbol];
    if (range.location == NSNotFound) {
        return nil;
    }
    
    // 以字典形式将参数返回
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    // 截取参数
    NSString *parametersString = [urlStr substringFromIndex:range.location + 1];
    
    // 判断参数是单个参数还是多个参数
    if ([parametersString containsString:@"&"]) {
        
        // 多个参数，分割参数
        NSArray *urlComponents = [parametersString componentsSeparatedByString:@"&"];
        
        for (NSString *keyValuePair in urlComponents) {
            // 生成Key/Value
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
//            NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
//            NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];
            NSString *key = pairComponents.firstObject;
            NSString *value = pairComponents.lastObject;
            
            // Key不能为nil
            if (key == nil || value == nil) { continue; }
            
            id existValue = [params valueForKey:key];
            if (existValue != nil) {
                // 已存在的值，生成数组
                if ([existValue isKindOfClass:[NSArray class]]) {
                    // 已存在的值生成数组
                    NSMutableArray *items = [NSMutableArray arrayWithArray:existValue];
                    [items addObject:value];
                    
                    [params setValue:items forKey:key];
                } else {
                    // 非数组
                    [params setValue:@[existValue, value] forKey:key];
                }
            } else {
                // 设置值
                [params setValue:value forKey:key];
            }
        }
    } else { // 单个参数
        
        // 生成Key/Value
        NSArray *pairComponents = [parametersString componentsSeparatedByString:@"="];
        
        // 只有一个参数，没有值
        if (pairComponents.count == 1) { return nil; }
        
        // 分隔值
        NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
        NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];
        
        // Key不能为nil
        if (key == nil || value == nil) { return nil; }
        
        // 设置值
        [params setValue:value forKey:key];
    }
    
    return params;
}

@end
