//
//  JQDownloadManager.h
//  DownLoad
//
//  Created by Jing on 2019/4/23.
//  Copyright © 2019 Jing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+Addition.h"

NS_ASSUME_NONNULL_BEGIN
typedef NSURL * _Nullable (^JQDownloadManagerDestination)(NSURL *targetPath, NSURLResponse *response);
typedef void (^JQDownloadmanagerProgress)(NSProgress *downloadProgress);
typedef void(^JQDownloadManagerCompletion)(NSURLResponse * _Nullable response, NSURL * _Nullable filePath, NSError * _Nullable error);

@interface JQDownloadManager : NSObject

+ (void)downloadTaskWithURL:(NSString *)url path:(NSString *)path completionHandler:(JQDownloadManagerCompletion)completionHandler;
+ (void)downloadTaskWithURL:(NSString *)url path:(NSString *)path fileName:(nullable NSString *)fileName completionHandler:(JQDownloadManagerCompletion)completionHandler;
+ (void)downloadTaskWithURL:(NSString *)url path:(NSString *)path fileName:(nullable NSString *)fileName progress:(JQDownloadmanagerProgress)progress completionHandler:(JQDownloadManagerCompletion)completionHandler;

@end

NS_ASSUME_NONNULL_END
