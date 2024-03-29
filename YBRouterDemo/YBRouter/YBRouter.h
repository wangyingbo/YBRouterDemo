//
//  YBRouter.h
//  YBRouter
//
//  Created by 王迎博 on 2019/10/11.
//  Copyright © 2019 王迎博. All rights reserved.
//
//  base on KSRouter

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YBRouterFunctions.h"

typedef NS_ENUM(NSInteger,RouterErrorCode) {
    /**perform selector no target*/
    RouterErrorCodeNoTarget = -1,
    /**perform selector no selector*/
    RouterErrorCodeNoSelector = -2,
};
/**注册通用的webViewController*/
static NSString * _Nonnull const kYBRouterGeneralWebViewController = @"kYBRouterGeneralWebViewController";
typedef void(^RouterCallBackHandler)(id _Nullable obj);

typedef const char * YBRouterURI;

#ifndef GET_CLASS
//做(NSString*)(args *)转换是为了保证args是类名
#define GET_CLASS(args) NSClassFromString((NSString*)(args *)[NSString stringWithCString:#args encoding:NSUTF8StringEncoding])
#endif

/**校验参数是否是类名；可在编译期校验class的合法性*/
#ifndef CHECK_CLASS
#define CHECK_CLASS(args) ({ \
id obj = NSClassFromString((NSString*)(args *)[NSString stringWithCString:#args encoding:NSUTF8StringEncoding]); \
if (!obj){ \
NSAssert(NO, @"args must be a class name"); \
@""; \
} \
obj; \
})
#endif

#ifndef YBCLASS
#define YBCLASS(args) GET_CLASS(args)
#endif

/**宏定义快捷注册路由类*/
#ifndef YBRouterRegisterClass
//#define YBRouterRegisterClass(className,url) autoreleasepool{} do { rounterRegisterClass(YBCLASS(className),url); } while (0);
#define YBRouterRegisterClass(className,url) autoreleasepool{} do { [YBRouterFunctions registerClass:YBCLASS(className) withRouter:url]; } while (0);
#endif


//校验声明controller的路由url时，传入的是否是正确的类名
#ifndef VERIFY_CLASS
#define VERIFY_CLASS(cla) extern void private_yb_router_verify_##cla(cla *a);
#endif

#define YBInvocatations "YBInvocatations"
#define KSDATA(sectname) __attribute((used, section("__DATA,"#sectname" ")))
#define YBRouterRegister(target,method) \
class _; static NSString *_##target##_##method##_ KSDATA(YBInvocatations) = @"{\""#target"\":\""#method"\"}";

//basic定义：类-前缀-路由
#define YBBaseControllerRegister(cla,Prefix,router) \
class _; static NSString *_##cla##_##router##_ = @"{\""#cla"\":\"" Prefix#router"\"}";
//定义：类-默认类名即路由
#define YBControllerRegisterClass(cla) YBBaseControllerRegister(cla,ROUTER_PREFIX,cla);VERIFY_CLASS(cla);


//basic定义：类-自定义路由
#define YBBaseControllerCustomRegister(cla,Prefix,router) \
class _; static NSString *_##cla##_URL_ = @"{\""#cla"\":\"" Prefix router"\"}";
//定义：类-自定义路由（如果需要多个前缀，可参考这个宏定义多个宏）
#define YBControllerRegisterClassRouter(cla,router) YBBaseControllerCustomRegister(cla,"",router);VERIFY_CLASS(cla);


//自定义路由url的前缀，可重新定义ROUTER_PREFIX实现自定义前缀
#ifndef ROUTER_PREFIX
#define ROUTER_PREFIX "open://"
#endif


NS_ASSUME_NONNULL_BEGIN

@interface YBRouter : NSObject

#pragma mark - mudule
+ (_Nullable id)routerToURI:(NSString *)URI args:(NSDictionary * _Nullable )args;
+ (id)performTarget:(NSString *)targetName action:(NSString *)actionName args:(NSDictionary * _Nullable )args;
+ (id)performTarget:(NSString *)targetName action:(NSString *)actionName args:(NSDictionary * _Nullable )args error:(NSError ** _Nullable )error;
+ (id)performTarget:(id)target selector:(SEL)action args:(NSDictionary * _Nullable )args error:(NSError ** _Nullable )error;
extern id router_msgSend(id target, SEL selector,id firstParameter, ...);

#pragma mark - controller类的router

+ (__kindof UIViewController *)routerControllerURI:(NSString *)URI parameter:(id _Nullable)parameter handler:(RouterCallBackHandler _Nullable)handler;

/// 使用自身controller来push或者present新的controller
/// @param selfController 当前的controller
/// @param URI 将要跳转的uri
/// @param parameter 参数
/// @param handler 回调
+ (__kindof UIViewController *)selfController:(__kindof UIViewController  * _Nullable )selfController routerControllerURI:(NSString *)URI parameter:(id _Nullable)parameter handler:(RouterCallBackHandler _Nullable)handler;

#pragma mark - 调用routerRegisterClass注册的controller可用此方法跳转
//+ (id)openControllerUrl:(NSString *)router parameter:(id _Nullable)parameter completion:(RouterCallBackHandler _Nullable)completion;

//+ (id)openControllerUrl:(NSString *)router jsonObj:(id _Nullable)jsonObj completion:(RouterCallBackHandler _Nullable)completion;


@end

NS_ASSUME_NONNULL_END
