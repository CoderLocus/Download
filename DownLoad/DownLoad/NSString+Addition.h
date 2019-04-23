//
//  NSString+Addition.h
//  DownLoad
//
//  Created by Jing on 2019/4/23.
//  Copyright © 2019 Jing. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Addition)

+ (NSString *)documentPath;
- (BOOL)isNonEmpty;
- (NSString *)stringFromMD5;

@end

NS_ASSUME_NONNULL_END
