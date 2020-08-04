//
//  FBRouter.h
//  FengbangB
//
//  Created by fengbang on 2018/7/16.
//  Copyright © 2018年 com.fengbangstore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YBRouterMacro.h"


#ifndef GET_CLASS
//做(NSString*)(args *)转换是为了保证args是类名
#define GET_CLASS(args) NSClassFromString((NSString*)(args *)[NSString stringWithCString:#args encoding:NSUTF8StringEncoding])
#endif

#ifndef YBCLASS
#define YBCLASS(args) GET_CLASS(args)
#endif


@interface YBRouterFunctions : NSObject

SingletonH(Router)

/**
 往路由表中注册一个class

 @param cla class
 @param router 路由名称
 @return 结果
 */
extern bool routerRegisterClass(Class cla,NSString *router);

/**
 往路由表中注册一个class
 
 @param cla class
 @param router 路由名称
 @return 结果
 */
+ (BOOL)registerClass:(Class)cla withRouter:(NSString *)router;

/**
 通过路由名称拿到controller

 @param router 路由路径名称
 @return controller
 */
extern id getController(NSString *router);

/**
 通过路由名称拿到controller
 
 @param router 路由路径名称
 @return controller
 */
+ (id)getControllerWithRouter:(NSString *)router;

/// 是否已经注册过路由了
/// @param router router description
+ (BOOL)isContainedWithRouter:(NSString *)router;

@end
