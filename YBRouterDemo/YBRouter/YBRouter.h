//
//  YBRouter.h
//  YBRouterDemo
//
//  Created by fengbang on 2019/10/11.
//  Copyright © 2019 王颖博. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

typedef void(^RouterCallBackHandler)(id obj);

typedef char * YBRouterURI;

//校验声明controller的路由url时，传入的是否是正确的类名
#ifndef VERIFY_CLASS
#define VERIFY_CLASS(cla) extern cla *YBRouterVerifyClassObj;
#endif

#define YBInvocatations "YBInvocatations"
#define KSDATA(sectname) __attribute((used, section("__DATA,"#sectname" ")))
#define YBRouterRegister(target,method) \
class _; static char *_##target##_##method##_ KSDATA(YBInvocatations) = "{\""#target"\":\""#method"\"}";

//basic定义：类-前缀-路由
#define YBControllerRegister(cla,Prefix,router) \
class _; static char *_##cla##_##router##_ = "{\""#cla"\":\""Prefix#router"\"}";
//定义：类-默认类名即路由
#define YBControllerRegisterClass(cla) YBControllerRegister(cla,ROUTER_PREFIX,cla);VERIFY_CLASS(cla);


//basic定义：类-自定义路由
#define YBControllerCustomRegister(cla,Prefix,router) \
class _; static char *_##cla##_URL_ = "{\""#cla"\":\""Prefix router"\"}";
//定义：类-自定义路由（如果需要多个前缀，可参考这个宏定义多个宏）
#define YBControllerRegisterClassRouter(cla,router) YBControllerCustomRegister(cla,"",router);VERIFY_CLASS(cla);


//自定义路由url的前缀，可重新定义ROUTER_PREFIX实现自定义前缀
#ifndef ROUTER_PREFIX
#define ROUTER_PREFIX "open://"
#endif



@interface YBRouter : NSObject

#pragma mark - mudule
+ (_Nullable id)routerToURI:(YBRouterURI)URI args:(NSDictionary * _Nullable )args;
+ (id)performTarget:(NSString *)targetName action:(NSString  *)actionName args:(NSDictionary * _Nullable )args;
+ (id)performTarget:(NSString *)targetName action:(NSString *)actionName args:(NSDictionary * _Nullable )args error:(NSError ** _Nullable )error;
extern id router_msgSend(id target, SEL selector,id firstParameter, ...);

#pragma mark - controller类的router
+ (__kindof UIViewController *)routerControllerURI:(YBRouterURI)URI parameter:(id _Nullable)parameter handler:(RouterCallBackHandler _Nullable)handler;

#pragma mark - 调用routerRegisterClass注册的controller可用此方法跳转
+ (id)openControllerUrl:(NSString *)router parameter:(id _Nullable)parameter completion:(RouterCallBackHandler _Nullable)completion;

+ (id)openControllerUrl:(NSString *)router jsonObj:(id _Nullable)jsonObj completion:(RouterCallBackHandler _Nullable)completion;


@end

NS_ASSUME_NONNULL_END
