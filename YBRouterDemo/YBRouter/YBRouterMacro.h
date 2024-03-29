
//
//  YBRouterMacro.h
//  YBRouter
//
//  Created by 王迎博 on 2019/10/11.
//  Copyright © 2019 王迎博. All rights reserved.
//

#ifndef YBRouterMacro_h
#define YBRouterMacro_h


/**performSelector引起的警告解决办法*/
#ifndef SafePerformSelector
#define SafePerformSelector(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)
#endif

/**单例的宏*/
#ifndef SingletonH
#define SingletonH(name) + (instancetype)shared##name;
#endif

#ifndef SingletonM
#define SingletonM(name) \
static id _instance; \
\
+ (instancetype)allocWithZone:(struct _NSZone *)zone \
{ \
    static dispatch_once_t onceToken; \
    dispatch_once(&onceToken, ^{ \
        _instance = [super allocWithZone:zone]; \
    }); \
    return _instance; \
} \
\
+ (instancetype)shared##name \
{ \
    static dispatch_once_t onceToken; \
    dispatch_once(&onceToken, ^{ \
        _instance = [[self alloc] init]; \
    }); \
    return _instance; \
} \
\
- (id)copyWithZone:(NSZone *)zone \
{ \
    return _instance; \
}\
\
- (id)mutableCopyWithZone:(NSZone *)zone { \
    return _instance; \
}
#endif




#endif /* YBRouterMacro_h */
