//
//  FBRounter.m
//  FengbangB
//
//  Created by fengbang on 2018/7/16.
//  Copyright © 2018年 com.fengbangstore. All rights reserved.
//
//  KSRouter

#import "YBRouterFunctions.h"
#import "YBRouterTool.h"
#import "UIViewController+YBExtension.h"

@interface YBRouterFunctions ()
@property (nonatomic, strong) NSMutableDictionary *rounterClassMutDic;
@end

@implementation YBRouterFunctions

SingletonM(Router)

- (NSMutableDictionary *)rounterClassMutDic {
    if (!_rounterClassMutDic) {
        NSMutableDictionary *mutDic = [NSMutableDictionary dictionary];
        _rounterClassMutDic = mutDic;
    }
    return _rounterClassMutDic;
}

inline bool routerRegisterClass(Class cla,NSString *router) {
    NSCAssert(cla, @"class is could not be nil");
    NSCAssert(router, @"router url is could not be nil");
    if (!router) { return false; }
    if (!cla) { return false; }
    
    NSArray *urlArr = [router componentsSeparatedByString:kYBRouterSpecialSymbol];
    if (urlArr.count<1) { return NO; }
    NSString *fb_preUrlStr = [urlArr firstObject];
    [[YBRouterFunctions sharedRouter].rounterClassMutDic setObject:NSStringFromClass(cla) forKey:fb_preUrlStr];
    
    return true;
}

+ (BOOL)registerClass:(Class)cla withRouter:(NSString *)router {
    if (!router) { return NO; }
    
    NSArray *urlArr = [router componentsSeparatedByString:kYBRouterSpecialSymbol];
    if (urlArr.count<1) { return NO; }
    NSString *fb_preUrlStr = [urlArr firstObject];
    
    [[YBRouterFunctions sharedRouter].rounterClassMutDic setObject:NSStringFromClass(cla) forKey:fb_preUrlStr];
    
    return YES;
}

inline id getController(NSString *router) {
    if (!router) { return nil; }
    
    NSString *claStr = [YBRouterFunctions getClassWithRounter:router];
    if (!claStr) { return nil; }
    
    return controllerInstance(NSClassFromString(claStr));
}

+ (id)getControllerWithRouter:(NSString *)router {
    if (!router) { return nil; }
    
    NSString *claStr = [self getClassWithRounter:router];
    if (!claStr) { return nil; }
    
    return controllerInstance(NSClassFromString(claStr));
}


/**
 获取路由对应的class

 @param rounter 路由
 @return 类名
 */
+ (id)getClassWithRounter:(NSString *)rounter {
    id obj;
    if (!rounter) { return obj; }
    
    NSArray *urlArr = [rounter componentsSeparatedByString:kYBRouterSpecialSymbol];
    if (urlArr.count<1) { return obj; }
    NSString *fb_preUrlStr = [urlArr firstObject];
    
    obj = [[YBRouterFunctions sharedRouter].rounterClassMutDic objectForKey:fb_preUrlStr];
    
    return obj;
}
@end
