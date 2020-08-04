//
//  YBRouter.m
//  YBRouterDemo
//
//  Created by fengbang on 2019/10/11.
//  Copyright © 2019 王颖博. All rights reserved.
//   

#import "YBRouter.h"
#import <objc/runtime.h>
#import <objc/message.h>
#include <mach-o/getsect.h>
#include <mach-o/loader.h>
#include <mach-o/dyld.h>
#include <dlfcn.h>
#include <mach-o/ldsyms.h>

#import "YBRouterFunctions.h"
#import "YBRouterTool.h"
#import "YBRouterProtocol.h"



const NSErrorDomain YBRouterPerformError = @"KSRouterPerformError";
const NSErrorUserInfoKey YBRouterReasonKey = @"reason";

NSArray<NSString *>* KSReadConfiguration(char *sectionName,const struct mach_header *mhp) {
    NSMutableArray *configs = [NSMutableArray array];
    unsigned long size = 0;
#ifndef __LP64__
    uintptr_t *memory = (uintptr_t*)getsectiondata(mhp, SEG_DATA, sectionName, &size);
#else
    const struct mach_header_64 *mhp64 = (const struct mach_header_64 *)mhp;
    uintptr_t *memory = (uintptr_t*)getsectiondata(mhp64, SEG_DATA, sectionName, &size);
#endif
    
    unsigned long counter = size/sizeof(void*);
    for(int i = 0; i < counter; ++i){
        char *string = (char*)memory[i];
        NSString *str = [NSString stringWithUTF8String:string];
        if(!str)continue;
        
        if(str) [configs addObject:str];
    }
    
    return configs;
}

BOOL is_method_callable(NSString *targetName, NSString *actionName) {
    NSObject *target = [NSClassFromString(targetName) new];
    SEL action = NSSelectorFromString([actionName stringByAppendingString:@":"]);
    if (!target || !action) {
        return NO;
    }
    return [target respondsToSelector:action];
}

static void dyld_callback(const struct mach_header *mhp, intptr_t vmaddr_slide) {
    NSArray<NSString *> *invocations = KSReadConfiguration(YBInvocatations,mhp);
    for (NSString *map in invocations) {
        NSData *jsonData =  [map dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        id json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
        if (!error) {
            if ([json isKindOfClass:[NSDictionary class]] && [json allKeys].count) {
                NSString *target = [json allKeys][0];
                NSString *action  = [json allValues][0];
                if (target && action) {
                    if (!is_method_callable(target, action)) {
                        NSLog(@"KSRouter: The following method is not callable: -[%@ %@:]", target, action);
#ifdef DEBUG
                        abort();
#endif
                    }
                }
            }
        }
    }
}

__attribute__((constructor))
void _init() {
    _dyld_register_func_for_add_image(dyld_callback);
}

inline id router_msgSend(id target, SEL aSelector,id firstParameter, ...) {
    NSCAssert(target, @"target is nil");
    NSCAssert(aSelector, @"aSelector is nil");
    if (!target || !aSelector) {
        NSLog(@"target and aSelector is could not be nil");
        return nil;
    }
    NSMethodSignature *signature = [target methodSignatureForSelector:aSelector];
    NSCAssert(signature, @"the method is not correct");
    if (!signature) {
        NSLog(@"the method is not correct");
        return nil;
    }
    NSUInteger length = [signature numberOfArguments];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setTarget:target];
    [invocation setSelector:aSelector];
    
    [invocation setArgument:&firstParameter atIndex:2];
    va_list arg_ptr;
    va_start(arg_ptr, firstParameter);
    for (NSUInteger i = 3; i < length; ++i) {
        void *parameter = va_arg(arg_ptr, void *);
        [invocation setArgument:&parameter atIndex:i];
    }
    va_end(arg_ptr);
    
    [invocation invoke];
    if ([signature methodReturnLength]) {
        id data;
        [invocation getReturnValue:&data];
        return data;
    }
    return nil;
}


@implementation YBRouter

+ (id)routerToURI:(NSString *)URI args:(NSDictionary *)args {
    id json = [YBRouter getRouterUrlWithURI:URI];
    if ([json isKindOfClass:[NSDictionary class]] && [json allKeys].count) {
        NSString *target = [json allKeys][0];
        NSString *action  = [json allValues][0];
        if (target && action) {
            return [self performTarget:target action:action args:args];
        }
    }
    return nil;
}

+ (id)performTarget:(NSString *)targetName action:(NSString *)actionName args:(NSDictionary *)args {
    return [self performTarget:targetName action:actionName args:args error:nil];
}


+ (id)performTarget:(NSString *)targetName action:(NSString *)actionName args:(NSDictionary *)args error:(NSError *__autoreleasing *)error {
    SEL action = NSSelectorFromString([actionName stringByAppendingString:@":"]);
    NSObject *target = [NSClassFromString(targetName) new];
    return [self performTarget:target selector:action args:args error:error];
}

+ (id)performTarget:(id)target selector:(SEL)selector args:(NSDictionary *)args error:(NSError *__autoreleasing  _Nullable *)error {
    
    if (!target) {
        if (error) {
            *error = [NSError errorWithDomain:YBRouterPerformError code:-1 userInfo:@{YBRouterReasonKey: @"target not exists"}];
        }
        return nil;
    }
    
    SEL action = selector;
    if (![target respondsToSelector:action]) {
        if (error) {
            *error = [NSError errorWithDomain:YBRouterPerformError code:-2 userInfo:@{YBRouterReasonKey: @"method not exists"}];
        }
        return nil;
    }
    
    NSMethodSignature *methodSignature = [target methodSignatureForSelector:action];
    if (!methodSignature) {
        
        return nil;
    }
    
    const char * returnType = [methodSignature methodReturnType];
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    [invocation setArgument:&args atIndex:2];
    [invocation setSelector:action];
    [invocation setTarget:target];
    [invocation invoke];
    
    id returnValue;
    switch (returnType[0] == _C_CONST ? returnType[1] : returnType[0]) {
#define KSROUTER_RET_OBJECT \
void *value; \
[invocation getReturnValue:&value]; \
id object = (__bridge id)value; \
returnValue = object; \
break;
        case _C_ID: {
            KSROUTER_RET_OBJECT
        }
            
#define KSROUTER_RET_CASE(typeString, type) \
case typeString: {                      \
type value;                         \
[invocation getReturnValue:&value];  \
returnValue = @(value); \
break; \
}
            KSROUTER_RET_CASE(_C_CHR, char)
            KSROUTER_RET_CASE(_C_UCHR, unsigned char)
            KSROUTER_RET_CASE(_C_SHT, short)
            KSROUTER_RET_CASE(_C_USHT, unsigned short)
            KSROUTER_RET_CASE(_C_INT, int)
            KSROUTER_RET_CASE(_C_UINT, unsigned int)
            KSROUTER_RET_CASE(_C_LNG, long)
            KSROUTER_RET_CASE(_C_ULNG, unsigned long)
            KSROUTER_RET_CASE(_C_LNG_LNG, long long)
            KSROUTER_RET_CASE(_C_ULNG_LNG, unsigned long long)
            KSROUTER_RET_CASE(_C_FLT, float)
            KSROUTER_RET_CASE(_C_DBL, double)
            KSROUTER_RET_CASE(_C_BOOL, BOOL)
            
        case _C_STRUCT_B: {
            NSString *typeString = [NSString stringWithUTF8String:returnType];
            
#define KSROUTER_RET_STRUCT(_type, _methodName)                             \
if ([typeString rangeOfString:@#_type].location != NSNotFound) {   \
_type value;                                                   \
[invocation getReturnValue:&value];                            \
returnValue = [NSValue _methodName:value]; \
break;                                                         \
}
            KSROUTER_RET_STRUCT(CGRect, valueWithCGRect)
            KSROUTER_RET_STRUCT(CGPoint, valueWithCGPoint)
            KSROUTER_RET_STRUCT(CGSize, valueWithCGSize)
            KSROUTER_RET_STRUCT(NSRange, valueWithRange)
            KSROUTER_RET_STRUCT(CGVector, valueWithCGVector)
            KSROUTER_RET_STRUCT(UIOffset, valueWithUIOffset)
            KSROUTER_RET_STRUCT(CATransform3D, valueWithCATransform3D)
            KSROUTER_RET_STRUCT(UIEdgeInsets, valueWithUIEdgeInsets)
            KSROUTER_RET_STRUCT(CGAffineTransform, valueWithCGAffineTransform)
        }
        case _C_CHARPTR:
        case _C_PTR:
        case _C_CLASS:{
            KSROUTER_RET_OBJECT
        }
        case _C_VOID:
        default:{
            returnValue = nil;
        }
    }
    
    return returnValue;
}

id getJsonObjWithURI(NSString *URI) {
    NSString *uri = URI;//[NSString stringWithCString:URI encoding:NSUTF8StringEncoding]
    NSData *jsonData =  [uri dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id json = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&error];
    if (!error) {
        if ([json isKindOfClass:[NSDictionary class]] && [json allKeys].count) {
            return json;
        }
    }
    return json;
}

+ (id)getRouterUrlWithURI:(NSString *)URI {
    return getJsonObjWithURI(URI);
}

#pragma mark -
+ (UIViewController *)routerControllerURI:(NSString *)URI parameter:(id)parameter handler:(RouterCallBackHandler)handler {
    UIViewController *controller = nil;
    NSDictionary *jsonDic = [YBRouter getRouterUrlWithURI:URI];
    NSString *urlString = [jsonDic allValues][0];//拿到注册的url
    NSString *claString = [jsonDic allKeys][0];
    if (!urlString || !claString) {
        return [YBRouter openControllerUrl:URI parameter:parameter completion:handler];
    }else {
        Class cla = NSClassFromString(claString);
        NSAssert(cla, @"is not a class");
        if (cla && ([cla isKindOfClass:[NSObject class]] || [cla isKindOfClass:[NSProxy class]])) {
            if (![YBRouterFunctions isContainedWithRouter:urlString]) {
                routerRegisterClass(cla, urlString);
            }
            return [YBRouter openControllerUrl:urlString parameter:parameter completion:handler];
        }
    }
    
    return controller;
}


#pragma mark -
+ (id)openControllerUrl:(NSString *)router parameter:(id)parameter completion:(RouterCallBackHandler)completion {
    NSAssert((router), @"router不能为空");
    if (!router) { return nil; }
    return [self openUrl:router parameter:parameter routerCompletion:completion];
}

+ (id)openControllerUrl:(NSString *)router jsonObj:(id)jsonObj completion:(RouterCallBackHandler)completion {
    NSAssert((router), @"router不能为空");
    if (!router) { return nil; }
    NSString *urlStr = jsonObj?[YBRouterTool encodeRouterWithPreRouter:router param:jsonObj]:router;
    return [self openUrl:urlStr parameter:nil routerCompletion:completion];
}

+ (id)openUrl:(NSString *)urlStr parameter:(id)parameter routerCompletion:(void (^)(id))routerCompletion {
    UIViewController *viewController;
    
    if ([urlStr hasPrefix:@"http://"] || [urlStr hasPrefix:@"https://"]) {
        //webView跳转
        
    }else {
        viewController = getController(urlStr);
    }
    
    // [viewController respondsToSelector:@selector(implementationRouter)]
    if (viewController && [viewController isKindOfClass:[UIViewController class]]) {
        //判断是否遵守FBRouterProtocol协议
        if ([viewController conformsToProtocol:@protocol(YBRouterProtocol)]) {
            //传参
            [viewController configRouterString:urlStr];
            if (parameter) { [viewController configRouterParameter:parameter]; }
            //回调
            if (!routerCompletion) { routerCompletion = ^(id obj){}; }
            viewController.routerCompletion = routerCompletion;
            //遵守FBRouterKVCProtocol协议则KVC赋值
            if ([viewController conformsToProtocol:@protocol(YBRouterKVCProtocol)]) {
                NSArray *ignoredArr = @[];
                if ([viewController respondsToSelector:@selector(routerIgnoredKeys)]) {
                    ignoredArr = [viewController performSelector:@selector(routerIgnoredKeys)];
                }
                [viewController setValueByKeyWithIgnoredKeys:ignoredArr];
            }
        }
        
        //弹出视图方式选择
        BOOL isPresent = NO;
        if ([viewController respondsToSelector:@selector(routerViewControllerIsPresented)]) {
            isPresent = [viewController performSelector:@selector(routerViewControllerIsPresented)];
        }
        if (![YBRouter getCurrentVC].navigationController) {
            isPresent = YES;
        }
        if (isPresent) {
            [[YBRouter getCurrentVC] presentViewController:viewController animated:YES completion:nil];
        }else {
            [[YBRouter getCurrentVC].navigationController pushViewController:viewController animated:YES];
        }
        
        return viewController;
    }
    
    return nil;
}


//获取当前屏幕显示的viewcontroller
+ (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows) {
            if (tmpWin.windowLevel == UIWindowLevelNormal) {
                window = tmpWin;
                break;
            }
        }
    }
    
    id  nextResponder = nil;
    UIViewController *appRootVC=window.rootViewController;
    
    nextResponder = appRootVC;
    
    if ([nextResponder isKindOfClass:[UITabBarController class]]){
        UITabBarController * tabbar = (UITabBarController *)nextResponder;
        //UINavigationController * nav = (UINavigationController *)tabbar.viewControllers[tabbar.selectedIndex];
        id nav = tabbar.selectedViewController ; //上下两种写法都行
        if ([nav isKindOfClass:[UINavigationController class]]) {
            result = ((UINavigationController *)nav).childViewControllers.lastObject;
        }else if ([nav isKindOfClass:[UIViewController class]]) {
            result = nav;
        }
        
    }else if ([nextResponder isKindOfClass:[UINavigationController class]]){
        UINavigationController * nav = (UINavigationController *)nextResponder;
        result = nav.childViewControllers.lastObject;
    }else if ([nextResponder isKindOfClass:[UIViewController class]]){
        UIViewController *currentViewController = (UIViewController *)nextResponder;
        NSUInteger childViewControllerCount = currentViewController.childViewControllers.count;
        if (childViewControllerCount > 0) {
            result = currentViewController.childViewControllers.lastObject;
        } else {
            result = currentViewController;
        }
    }
    
    if (![result isKindOfClass:[UIViewController class]]) {
        result = nil;
    }
    
    return result;
}

@end
