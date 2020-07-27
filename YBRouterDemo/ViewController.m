//
//  ViewController.m
//  YBRouterDemo
//
//  Created by fengbang on 2019/10/11.
//  Copyright © 2019 王颖博. All rights reserved.
//

#import "ViewController.h"
#import "DemoVC.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

/**
 调用路由的三种方式
 */
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    //第一种：默认类名即路由，由@YBControllerRegisterClass注册的路由，路由名为_classVC_classVC_
    NSString *uri = [NSString stringWithCString:_DemoVC_DemoVC_ encoding:NSUTF8StringEncoding];
    NSLog(@"默认类名作为url：%@",uri);
    
    //第二种：自定义的路由，由@YBControllerRegisterClassRouter注册的路由，路由名为_classVC_URL_
    NSString *customUrl = [NSString stringWithCString:_DemoVC_URL_ encoding:NSUTF8StringEncoding];
    NSLog(@"自定义controller的url：%@",customUrl);
    
    //第三种：手动注册路由，由routerRegisterClass方法注册的路由，路由名为自定义的字符串
    NSMutableDictionary *mutDic = [NSMutableDictionary dictionary];
    [mutDic setObject:@"123456" forKey:@"appCode"];
    [mutDic setObject:@"JackMa" forKey:@"name"];
    //[YBRouter routerControllerURI:_DemoVC_DemoVC_ parameter:mutDic.copy handler:nil];
    //[YBRouter routerControllerURI:_DemoVC_URL_ parameter:mutDic.copy handler:nil];
    [YBRouter routerControllerURI:kRouterServerDemoVC.UTF8String parameter:mutDic.copy handler:nil];
}

@end
