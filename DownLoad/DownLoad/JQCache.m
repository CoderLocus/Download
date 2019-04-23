//
//  JQCache.m
//  DownLoad
//
//  Created by Jing on 2019/4/23.
//  Copyright © 2019 Jing. All rights reserved.
//

#import "JQCache.h"

static JQCache *_cache;

@implementation JQCache

+ (void)initialize {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _cache = [[JQCache alloc] initWithName:@"JQCache"];
    });
}

+ (id)fetchObjectAtDocumentPathWithkey:(NSString *)key {
    NSAssert([self cacheIsNonEmpty:key], @"key不能为空");
    if (![self cacheIsNonEmpty:key]) {
        return nil;
    }
    
    return [_cache objectForKey:key];
}

+ (void)storeObjectAtDocumentPathWithkey:(NSString *)key object:(id <NSCoding>)object {
    NSAssert([self cacheIsNonEmpty:key], @"key不能为空");
    if ([self cacheIsNonEmpty:key]) {
        [_cache setObject:object forKey:key];
    }
}

+ (BOOL)cacheIsNonEmpty:(NSString *)key {
    NSMutableCharacterSet *emptyStringSet = [[NSMutableCharacterSet alloc] init];
    [emptyStringSet formUnionWithCharacterSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [emptyStringSet formUnionWithCharacterSet: [NSCharacterSet characterSetWithCharactersInString: @"　"]];
    if ([key length] == 0) {
        return NO;
    }
    NSString* str = [key stringByTrimmingCharactersInSet:emptyStringSet];
    return [str length] > 0;
}
@end
