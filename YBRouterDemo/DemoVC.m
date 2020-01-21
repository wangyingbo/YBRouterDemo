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
@property (nonatomic, copy) NSString *session;
@end

@implementation DemoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self configRouterParameters];
    
    [self configModuleRouter];
}

- (void)dealloc {
    NSLog(@"%@", [NSString stringWithFormat:@"<class:%@> dealloc !!!",NSStringFromClass(self.class)]);
}

#pragma mark - configData

/**
 controller之间跳转与传值
 */
- (void)configRouterParameters {
    
    NSLog(@"****************************************");
    NSLog(@"遵守YBRouterKVCProtocol协议则KVC自动赋值");
    NSLog(@"appCode:%@",self.appCode);
    //name实现了协议里的routerIgnoredKeys方法后，不会自动赋值了
    NSLog(@"name:%@",self.name);
    
    NSLog(@"****************************************");
    NSLog(@"也可以遵守普通YBRouterProtocol协议，手动获取参数值");
    NSDictionary *parameters = [self getRouterParameter];
    NSString *appCode = parameters[@"appCode"];
    NSString *name = parameters[@"name"];
    NSLog(@"appCode:%@",appCode);
    NSLog(@"name:%@",name);
    
    NSLog(@"****************************************");
    NSLog(@"总的参数字典:%@",parameters);
    NSLog(@"****************************************");
}

/**
 测试模块间的通信与传值
 */
- (void)configModuleRouter {
    
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
        NSLog(@"error:当前找不到target");
    }
    if (e.code == -2) { // mo method
        NSLog(@"error:当前找不到method");
    }
    
    //6、router_msgSend方法
    id data = router_msgSend([ModuleA class], @selector(callClassSelector:array:dictionary:), @"testX",@[@(1),@"ahah"],@{@"name":@"Peny"});
    NSLog(@"返回值：%@",data);
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.routerCompletion(nil);
}

#pragma mark - YBRouterProtocol
- (BOOL)routerViewControllerIsPresented {
    return NO;
}

#pragma mark - YBRouterKVCProtocol
- (NSArray<NSString *> *)routerIgnoredKeys {
    return @[@"name"];
}



@end
