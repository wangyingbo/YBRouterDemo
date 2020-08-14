//
//  FBRouterProtocol.h
//  FengbangB
//
//  Created by 王迎博 on 2018/6/15.
//  Copyright © 2018年 com.fengbangstore. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YBRouterProtocol <NSObject>
@optional;
/**暂无实义用处待定*/
- (BOOL)implementationRouter;
/**实现此协议决定当前是被present还是push出来*/
- (BOOL)routerViewControllerIsPresented;
/**通过代理方法传参*/
- (void)routerParameters:(id)parameters;
/***/
//- (NSDictionary *)routerRegisterClass:(id)sender;
@end

/**如果遵守YBRouterKVCProtocol协议，则所传的参数都需要有定义的成员属性或成员变量接收*/
@protocol YBRouterKVCProtocol <YBRouterProtocol>
@optional;
/**KVC默认赋值时，需要被忽略的key*/
- (NSArray<NSString *> *)routerIgnoredKeys;
@end
