//
//  NSString+JSON.h
//  edianzu
//
//  Created by EDZ on 2017/1/18.
//  Copyright © 2017年 edianzu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (JSON)


+ (id)jsonParseJSONStringToObj:(NSString *)JSONString;

+ (NSString *)jsonStringWithObject:(id)jsonObject;


+ (NSString*)dictionaryToJson:(NSDictionary *)dic;

+ (NSString *)arrayToJSONString:(NSArray *)array;

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;

+ (NSDictionary *)parseJSONStringToNSDictionary:(NSString *)JSONString;


@end
