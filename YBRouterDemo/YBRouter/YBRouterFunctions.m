//
//  YBRouterFunctions.m
//  YBRouter
//
//  Created by 王迎博 on 2018/7/16.
//  Copyright © 2018年 王迎博. All rights reserved.
//
//  KSRouter

#import "YBRouterFunctions.h"
#import "YBRouterTool.h"

@interface YBRouterFunctions ()
@property (nonatomic, strong) NSMutableDictionary *routerClassMutDic;
@end

@implementation YBRouterFunctions

SingletonM(Router)

- (NSMutableDictionary *)routerClassMutDic {
    if (!_routerClassMutDic) {
        NSMutableDictionary *mutDic = [NSMutableDictionary dictionary];
        _routerClassMutDic = mutDic;
    }
    return _routerClassMutDic;
}

inline bool routerRegisterClass(Class cla,NSString *router) {
    NSCAssert(cla, @"class is could not be nil");
    NSCAssert(router, @"router url is could not be nil");
    if (!router) { return false; }
    if (!cla) { return false; }
    
    NSArray *urlArr = [router componentsSeparatedByString:kYBRouterSpecialSymbol];
    if (urlArr.count<1) { return NO; }
    NSString *fb_preUrlStr = [urlArr firstObject];
    
    NSString *errorString = [NSString stringWithFormat:@"路由前缀%@重复了!",fb_preUrlStr];
    NSCAssert(![[YBRouterFunctions sharedRouter].routerClassMutDic objectForKey:fb_preUrlStr], errorString);
    
    [[YBRouterFunctions sharedRouter].routerClassMutDic setObject:NSStringFromClass(cla) forKey:fb_preUrlStr];
    
    return true;
}

+ (BOOL)registerClass:(Class)cla withRouter:(NSString *)router {
    return routerRegisterClass(cla, router);
}

inline id getController(NSString *router) {
    if (!router) { return nil; }
    
    NSString *claStr = [YBRouterFunctions getClassWithRouter:router];
    if (!claStr) { return nil; }
    
    return objectInstance(NSClassFromString(claStr));
}

+ (id)getControllerWithRouter:(NSString *)router {
    if (!router) { return nil; }
    
    NSString *claStr = [self getClassWithRouter:router];
    if (!claStr) { return nil; }
    
    return objectInstance(NSClassFromString(claStr));
}


/**
 获取路由对应的class

 @param router 路由
 @return 类名
 */
+ (id)getClassWithRouter:(NSString *)router {
    id obj;
    if (!router) { return obj; }
    
    NSArray *urlArr = [router componentsSeparatedByString:kYBRouterSpecialSymbol];
    if (urlArr.count<1) { return obj; }
    NSString *fb_preUrlStr = [urlArr firstObject];
    
    obj = [[YBRouterFunctions sharedRouter].routerClassMutDic objectForKey:fb_preUrlStr];
    
    return obj;
}

+ (BOOL)isContainedWithRouter:(NSString *)router {
    BOOL _contain = NO;
    if (!router) { return _contain; }
    
    NSArray *urlArr = [router componentsSeparatedByString:kYBRouterSpecialSymbol];
    if (urlArr.count<1) { return _contain; }
    NSString *fb_preUrlStr = [urlArr firstObject];
    
    id obj = [[YBRouterFunctions sharedRouter].routerClassMutDic objectForKey:fb_preUrlStr];
    if (obj) {
        _contain = YES;
    }
    return _contain;
}

@end
