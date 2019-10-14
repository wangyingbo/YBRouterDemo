//
//  ModuleA.m
//  YBRouterDemo
//
//  Created by fengbang on 2019/10/11.
//  Copyright © 2019 王颖博. All rights reserved.
//

#import "ModuleA.h"

@implementation ModuleA

- (void)runDirectly:(NSDictionary *)arg {
    NSLog(@"直接调用");
}

- (Class)getSomeValue:(NSDictionary *)arg {
    NSLog(@"带返回值的调用方式");
    
    return [NSObject class];
}

- (void)runWithCallBack:(NSDictionary *)arg {
    NSLog(@"带回调的调用方式");
    
    if (arg[@"callback"]) {
        void(^callback)(BOOL result) = arg[@"callback"];
        callback(YES);
    }
}

- (void)callOtherModule:(NSDictionary *)arg {
    NSLog(@"调用其他组件");
    
    [YBRouter routerToURI:_ModuleB_run_ args:nil];
}

+ (NSNumber *)callClassSelector:(NSString *)string array:(NSArray *)array dictionary:(NSDictionary *)dictionary {
    NSLog(@"当前类方法的参数\n参数1：%@\n参数2：%@\n参数3：%@",string,array,dictionary);
    NSLog(@"调用类方法");
    return @(1);
}

@end
