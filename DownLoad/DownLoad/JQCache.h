//
//  JQCache.h
//  DownLoad
//
//  Created by Jing on 2019/4/23.
//  Copyright © 2019 Jing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TMCache.h"

NS_ASSUME_NONNULL_BEGIN

@interface JQCache : TMCache

+ (id)fetchObjectAtDocumentPathWithkey:(NSString *)key;
+ (void)storeObjectAtDocumentPathWithkey:(NSString *)key object:(id <NSCoding>)object;
@end

NS_ASSUME_NONNULL_END
