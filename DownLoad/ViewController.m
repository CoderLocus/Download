//
//  ViewController.m
//  DownLoad
//
//  Created by Jing on 2019/4/23.
//  Copyright © 2019 Jing. All rights reserved.
//

#import "ViewController.h"
#import "JQDownloadManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSString *url = @"https://ss0.bdstatic.com/94oJfD_bAAcT8t7mm9GUKT-xh_/timg?image&quality=100&size=b4000_4000&sec=1556013089&di=8e3bb21e0e7b9ff9acfcd23609b10817&src=http://pic.90sjimg.com/back_pic/qk/back_origin_pic/00/03/46/6e9930b1b0af90f162d7339028d2ca29.jpg";
    NSString *url2 = @"https://www.apple.com/105/media/cn/iphone-x/2017/01df5b43-28e4-4848-bf20-490c34a926a7/films/feature/iphone-x-feature-cn-20170912_1280x720h.mp4";
    NSString *path = [NSString documentPath];
    
    [JQDownloadManager downloadTaskWithURL:url path:path completionHandler:^(NSURLResponse * _Nullable response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (filePath) NSLog(@"url1-1 下载完成");
    }];
    
    [JQDownloadManager downloadTaskWithURL:url path:path fileName:@"" progress:^(NSProgress * _Nonnull downloadProgress) {
    } completionHandler:^(NSURLResponse * _Nullable response, NSURL * _Nullable filePath, NSError * _Nullable error) { }];
    
    [JQDownloadManager downloadTaskWithURL:url path:path completionHandler:^(NSURLResponse * _Nullable response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (filePath) NSLog(@"url1-2 下载完成");
    }];
    
    [JQDownloadManager downloadTaskWithURL:url path:path completionHandler:^(NSURLResponse * _Nullable response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (filePath) NSLog(@"url1-3 下载完成");
    }];
    
    [JQDownloadManager downloadTaskWithURL:url path:path completionHandler:^(NSURLResponse * _Nullable response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (filePath) NSLog(@"url1-4 下载完成");
    }];
    
    [JQDownloadManager downloadTaskWithURL:url path:path completionHandler:^(NSURLResponse * _Nullable response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (filePath) NSLog(@"url1-5 下载完成");
    }];
    
    [JQDownloadManager downloadTaskWithURL:url path:path completionHandler:^(NSURLResponse * _Nullable response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (filePath) NSLog(@"url1-6 下载完成");
    }];
    
    [JQDownloadManager downloadTaskWithURL:url2 path:path completionHandler:^(NSURLResponse * _Nullable response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        if (filePath) {
            NSLog(@"url2 下载完成");
        }
    }];
}


@end
