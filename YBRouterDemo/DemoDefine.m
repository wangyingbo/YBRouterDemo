//
//  DemoDefine.m
//  YBRouterDemo
//
//  Created by fengbang on 2020/1/21.
//  Copyright © 2020 王颖博. All rights reserved.
//

#import "DemoDefine.h"
#import "DemoVC.h"
@class TestVC;


/**可由服务器控制跳转-需手动注册*/
NSString * const kRouterServerDemoVC = @"wechat://bapp/userInfo?userId=123&session=zzz";
/**注册testVC*/
NSString * const kRouterServerTestVC = @"wechat://bapp/detailList?name=wyb";


@implementation DemoDefine

+ (void)load {
    /**可由服务器控制跳转*/
    routerRegisterClass(DemoVC.class, kRouterServerDemoVC);
    /**注册testVC*/
    routerRegisterClass(GET_CLASS(TestVC), kRouterServerTestVC);
}


@end
