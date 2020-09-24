//
//  DemoDefine.h
//  YBRouterDemo
//
//  Created by fengbang on 2020/1/21.
//  Copyright © 2020 王颖博. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YBRouterHeader.h"
@class DemoVC;
@class TestFirstVC;
@class TestSecondVC;

#pragma GCC diagnostic ignored "-Wmacro-redefined"

NS_ASSUME_NONNULL_BEGIN


/**可由服务器控制跳转*/
extern NSString * const kRouterServerDemoVC;
/**注册testVC*/
extern NSString * const kRouterServerTestVC;
/**注册TestSecondVC*/
extern NSString * const kRouterServerTestSecondVC;




//可自定义前缀，需要多个前缀的话可参考YBRouter.h自己定义宏
#ifndef ROUTER_PREFIX
#define ROUTER_PREFIX "open://"
#endif


//自定义模块间跳转的常量路由路径uri
@YBRouterRegister(ModuleA, runDirectly)
@YBRouterRegister(ModuleA, getSomeValue)
@YBRouterRegister(ModuleA, runWithCallBack)
@YBRouterRegister(ModuleA, callOtherModule)
@YBRouterRegister(ModuleB, run)


//自定义controller的常量路由路径uri
/**
 1、可调用routerRegisterClass(Class cla,NSString *router)方法手动注册路由；
 2、也可以使用下面的宏自动生成常量名，在路由跳转routerControllerURI:parameter:handler:的时候会自动注册；
    a) @YBControllerRegisterClass(args) 自动生成映射；
    b) @YBControllerRegisterClassRouter(args,string) 自定义映射；
 */
@YBControllerRegisterClass(DemoVC)
@YBControllerRegisterClassRouter(DemoVC, "alipay://bapp/demo?userId=123&token=xxxx")
@YBControllerRegisterClass(TestFirstVC)
@YBControllerRegisterClassRouter(TestSecondVC, @"alipay://bapp/second?id=123")



@interface DemoDefine : NSObject

@end

NS_ASSUME_NONNULL_END
