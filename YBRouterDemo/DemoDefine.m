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
@class TestSecondVC;
@class BaseWebViewController;

/**可由服务器控制跳转-需手动注册*/
NSString * const kRouterServerDemoVC = @"wechat://bapp/userInfo?userId=123&session=zzz";
/**注册testVC*/
NSString * const kRouterServerTestVC = @"wechat://bapp/list?name=wyb";
/**注册TestSecondVC*/
NSString * const kRouterServerTestSecondVC = @"wechat://bapp/detail?id=123456";


@implementation DemoDefine

+ (void)load {
    /**可由服务器控制跳转*/
    routerRegisterClass(DemoVC.class, kRouterServerDemoVC);
    /**注册testVC*/
    routerRegisterClass(YBCLASS(TestVC), kRouterServerTestVC);
    /**用宏定义快捷注册testVC*/
    @YBRouterRegisterClass(TestSecondVC, kRouterServerTestSecondVC);
    /**定义通用的webViewController页面，其他自定义的webView可走正常逻辑*/
    @YBRouterRegisterClass(BaseWebViewController, kYBRouterGeneralWebViewController);
    
}


@end
