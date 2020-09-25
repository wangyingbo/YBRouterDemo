//
//  TestSecondVC.m
//  YBRouterDemo
//
//  Created by fengbang on 2020/9/24.
//  Copyright © 2020 王颖博. All rights reserved.
//

#import "TestSecondVC.h"
#import "YBRouterHeader.h"

@interface TestSecondVC ()<YBRouterProtocol>
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *orderId;
@end

@implementation TestSecondVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initData];
    
    [self initUI];
}

#pragma mark - initData
- (void)initData {
    NSDictionary *parameters = [self getRouterParameter];
    NSLog(@"<%@>通过参数方法传参的参数是：\n%@",NSStringFromClass([self class]),parameters);
}

#pragma mark - initUI
- (void)initUI {
    [self configNavigationUI];
}

- (void)configNavigationUI {
    NSString *title = @"TestSecondVC";
    self.title = title;
    self.navigationController.navigationItem.title = title;
    self.view.backgroundColor = [UIColor whiteColor];
}



#pragma mark - YBRouterProtocol
- (void)routerParameters:(id)parameters {
    NSLog(@"<%@>通过代理方法传参的参数是：\n%@",NSStringFromClass([self class]),parameters);
}

- (void)routerTransitionPreController:(__kindof UIViewController *)preController nextController:(__kindof UIViewController *)nextController {
    [preController presentViewController:nextController animated:YES completion:nil];
}

#pragma mark - YBRouterKVCProtocol
- (NSArray<NSString *> *)routerIgnoredKeys {
    return @[@"name"];
}

@end
