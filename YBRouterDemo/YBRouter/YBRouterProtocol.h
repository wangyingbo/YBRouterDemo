//
//  FBRounterProtocol.h
//  FengbangB
//
//  Created by 王迎博 on 2018/6/15.
//  Copyright © 2018年 com.fengbangstore. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YBRouterProtocol <NSObject>
@optional;
- (BOOL)implementationRouter;
/**实现此协议决定当前是被present还是push出来*/
- (BOOL)routerViewControllerIsPresented;
@end

/**如果遵守YBRouterKVCProtocol协议，则所传的参数都需要有定义的成员属性或成员变量接收*/
@protocol YBRouterKVCProtocol <YBRouterProtocol>

@end
