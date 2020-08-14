
//
//  TestFirstVC.m
//  YBRouterDemo
//
//  Created by fengbang on 2020/8/14.
//  Copyright © 2020 王颖博. All rights reserved.
//

#import "TestFirstVC.h"
#import "YBRouterHeader.h"

@interface TestFirstVC ()<YBRouterProtocol>

@end

@implementation TestFirstVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self configNavigationUI];
}

#pragma mark - configUI
- (void)configNavigationUI {
    NSString *title = @"TestFirstVC";
    self.title = title;
    self.navigationController.navigationItem.title = title;
    self.view.backgroundColor = [UIColor whiteColor];
}



#pragma mark - YBRouterProtocol

- (void)routerParameters:(id)parameters {
    NSLog(@"<%@>通过代理方法传参的参数是：\n%@",NSStringFromClass([self class]),parameters);
}

@end
