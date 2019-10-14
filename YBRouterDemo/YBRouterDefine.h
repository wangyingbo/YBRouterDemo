
//
//  YBRouterDefine.h
//  YBRouterDemo
//
//  Created by fengbang on 2019/10/11.
//  Copyright © 2019 王颖博. All rights reserved.
//

#ifndef YBRouterDefine_h
#define YBRouterDefine_h


#import "YBRouterHeader.h"
@class DemoVC;


#pragma GCC diagnostic ignored "-Wmacro-redefined"
#define ROUTER_PREFIX "weChat://" //可自定义前缀，需要多个前缀的话可参考YBRouter.h自己定义宏


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
 */
@YBControllerRegisterClass(DemoVC)
@YBControllerRegisterClassRouter(DemoVC, "bapp/userInfo?userId=123&token=xxxx")


#endif /* YBRouterDefine_h */
