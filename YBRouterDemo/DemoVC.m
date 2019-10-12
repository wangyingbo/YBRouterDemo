//
//  DemoVC.m
//  YBRouterDemo
//
//  Created by fengbang on 2019/10/11.
//  Copyright © 2019 王颖博. All rights reserved.
//

#import "DemoVC.h"
#import "YBRouterHeader.h"
#import "ModuleA.h"


@interface DemoVC ()<YBRouterKVCProtocol>
@property (nonatomic, copy) NSString *appCode;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *token;
@property (nonatomic, copy) NSString *userId;
@end

@implementation DemoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self configRouterParameters];
    
    [self testRouter];
}

#pragma mark - configData
- (void)configRouterParameters {
    
    NSLog(@"****************************************");
    NSLog(@"遵守YBRouterKVCProtocol协议则KVC自动赋值");
    NSLog(@"appCode:%@",self.appCode);
    NSLog(@"name:%@",self.name);
    
    NSLog(@"****************************************");
    NSLog(@"也可以遵守普通YBRouterProtocol协议，手动获取参数值");
    NSDictionary *parameters = [self getRounterParameter];
    NSString *appCode = parameters[@"appCode"];
    NSString *name = parameters[@"name"];
    NSLog(@"appCode:%@",appCode);
    NSLog(@"name:%@",name);
    
    NSLog(@"****************************************");
    NSLog(@"总的参数字典:%@",parameters);
    
    NSLog(@"****************************************");
}

- (void)testRouter {
    
    //1、直接调用
    [YBRouter routerToURI:_ModuleA_runDirectly_ args:nil];
    
    //2、带返回值的调用方式
    __unused id result = [YBRouter routerToURI:_ModuleA_getSomeValue_ args:nil];
    
    //3、带回调的调用方式
    void(^callback)(BOOL result) = ^(BOOL result){
        
    };
    [YBRouter routerToURI:_ModuleA_runWithCallBack_ args:@{@"callback": callback}];
    
    //4、调用其他组件
    [YBRouter routerToURI:_ModuleA_callOtherModule_ args:nil];
    
    //5、执行方法
    NSError *e = nil;
    [YBRouter performTarget:@"ModuleA" action:@"b" args:nil error:&e];
    if (e.code == -1) { // no target
        
    }
    if (e.code == -2) { // mo method
        
    }
}

#pragma mark - YBRouterProtocol
- (BOOL)routerViewControllerIsPresented {
    return NO;
}

@end
