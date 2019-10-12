//
//  FBRounterTool.h
//  FengbangB
//
//  Created by 王迎博 on 2018/6/15.
//  Copyright © 2018年 com.fengbangstore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YBRouterProtocol.h"

extern NSString * const kYBRouterCustomParameterKey;
extern NSString * const kYBRouterUrlParameterKey;
extern NSString * const kYBRouterSpecialSymbol;

@interface YBRouterTool : NSObject

/**
 生成拼接带参数的路由url

 @param preRounter 路由url的前缀
 @param param 参数
 @return 拼接好的路由url
 */
+ (NSString *)encodeRounterWithPreRounter:(NSString *)preRounter param:(id)param;

/**
 解码路由url带的参数

 @param rounter 路由url
 @return 参数
 */
+ (id)decodeRounterWithRounter:(NSString *)rounter;

@end
