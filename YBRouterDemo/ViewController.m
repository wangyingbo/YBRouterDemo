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

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    NSString *uri = [NSString stringWithCString:_DemoVC_DemoVC_ encoding:NSUTF8StringEncoding];
    NSLog(@"默认类名作为url：%@",uri);
    
    NSString *customUrl = [NSString stringWithCString:_DemoVC_URL_ encoding:NSUTF8StringEncoding];
    NSLog(@"自定义controller的url：%@",customUrl);
    
    NSMutableDictionary *mutDic = [NSMutableDictionary dictionary];
    [mutDic setObject:@"123456" forKey:@"appCode"];
    [mutDic setObject:@"JackMa" forKey:@"name"];
    [YBRouter routerControllerURI:_DemoVC_URL_ parameter:mutDic.copy handler:nil];
}

@end
