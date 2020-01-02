//
//  UIViewController+YBExtension.h
//  FengbangB
//
//  Created by 王迎博 on 2018/6/15.
//  Copyright © 2018年 com.fengbangstore. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^FBRouterHandlerCompletion)(id obj);

@interface UIViewController (YBExtension)
/**路由跳转的urLString*/
@property (nonatomic, copy, readonly) NSString *routerString;
/**回调*/
@property (nonatomic, copy) FBRouterHandlerCompletion routerCompletion;

/**
 工厂方法生成实例
 
 @return 返回初始化对象
 */
+ (instancetype)factoryInstance;

/**
 初始化 controller

 @param cla  类class
 @return instance 实例
 */
id controllerInstance(Class cla);

/**
 获取路由string

 @return return value description
 */
- (NSString *)getRouterString;

/**
 获取总的参数（同时获得路由里的参数和自定义的参数）
 1、若同时有值，则调用：
    NSDictionary *obj = [self getRounterParameter];
    用obj[kFBRounterCustomParameterKey]取得路由参数；
    用obj[kFBRounterCustomParameterKey]取得自定义的参数；

 @return return value description
 */
- (id)getRouterParameter;

/**
 获取路由string里的参数

 @return return value description
 */
- (id)getRouterUrlParameter;

/**
 获取自定义传参里的参数

 @return return value description
 */
- (id)getRouterCustomParameter;

/**
 路由参数通过kvc赋值，只在路由跳转时使用

 @param ignoredArr 需要被忽略赋值的key
 */
- (void)setValueByKeyWithIgnoredKeys:(NSArray<NSString *> *)ignoredArr;

/**
 给只读变量赋值的方法，禁止调用此方法

 @param string string description
 */
- (void)configRouterString:(NSString *)string;

- (void)configRouterParameter:(id)routerParameter;

@end
