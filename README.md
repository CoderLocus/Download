# Download
断点下载Demo，支持杀死APP，重启后继续下载，支持多次请求同一url，只下载一次

简书：https://www.jianshu.com/p/af6700ff91e5

使用方法：

 [JQDownloadManager downloadTaskWithURL:url path:path completionHandler:^(NSURLResponse * _Nullable response, NSURL * _Nullable filePath, NSError * _Nullable error) {}];
 
[JQDownloadManager downloadTaskWithURL:url path:path fileName:@"" progress:^(NSProgress * _Nonnull downloadProgress) {
    } completionHandler:^(NSURLResponse * _Nullable response, NSURL * _Nullable filePath, NSError * _Nullable error) { }];

一、 AFN3.0 下载过程

1. 第一步肯定是创建`AFURLSessionManager`，配置一些`NSURLSessionConfiguration`，这一步我就不做多的叙述了。
  
> 不过因为我们是断点下载，可以在不同的地方都调用，而且为了调用方便，我们直接提供类(+)方法，但有一些成员变量可以重复使用，例如`AFURLSessionManager`，综合考虑，将折现成员变量声明称静态变量，并在+initialize方法里使用dispatch_once初始化。

2. 创建NSURLSessionDownloadTask：

       - (NSURLSessionDownloadTask *)downloadTaskWithRequest:(NSURLRequest *)request
                                             progress:(void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                                          destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                    completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler {}

       - (NSURLSessionDownloadTask *)downloadTaskWithResumeData:(NSData *)resumeData
                                                progress:(void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                                             destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                       completionHandler:(void (^)(NSURLResponse *response, NSURL *filePath, NSError *error))completionHandler {}

我们可以看到AFN给我们提供了两个创建NSURLSessionDownloadTask的方法，第一种方式是通过NSURLRequest创建，第二种方式是通过NSData创建。通过参数我们也能看出来，第一种是为了第一次下载提供的，第二种是为了我们做断点下载提供的。

3. 开始下载

       [task resume];
       下载时，会在tmp文件中生成下载的临时文件，
       文件名是CFNetworkDownload_XXXXXX.tmp，后缀由系统随机生成
       下载完将临时文件移动到目的路径，路径为创建DownloadTask时传入的destination参数

4. 暂停下载

       [task suspend]
       暂停后task依然有效，通过resume又可以恢复下载

5. 取消下载任务，取消下载任务，当前的task会失效，如果想继续下载，需要重新创建下载任务

       [task cancel]
       [task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {}]
       1. 第二种手动取消任务，会返回一个resumeData，这个参数是我们做断点下载所必须的，我们可以直接通过resumeData开启一个新的下载任务，发起下载请求
       2. 取消任务时，只有满足以下的各条件，才会产生resumeData
           1. 自从资源开始请求后，资源未更改过
           2. 任务必须是 HTTP 或 HTTPS 的 GET 请求
           3. 服务器在response信息汇总提供了 ETag 或 Last-Modified头部信息
           4. 服务器支持 byte-range 请求
           5. 下载的临时文件未被删除


二、断点下载的实现

![源自网络：下载交互过程顺序图](https://upload-images.jianshu.io/upload_images/1546611-b57da218253f79fb.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

1. 为什么会出现断点下载，我分了三种情况
    1. 手动取消，也就是我们提供给用户或我们项目内部调用了1.5中的`cancel`方法
    2. 网络、服务器异常，导致下载失败
    3. 用户手动kill掉APP

2. 第二情况的断点下载实现(部分网络错误)：

        JQDownloadManagerCompletion completeBlock = ^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            if (!error) { // 任务完成或暂停下载
                [self removeResumeDataWithUrl:url];
                [self removeTaskWithUrl:url];
            } else  { // 部分网络出错，会返回resumeData
                NSData *resumeData = error.userInfo[NSURLSessionDownloadTaskResumeData];
                if (resumeData) [self saveResumeData:resumeData url:url];
            }
        }

> 部分网络错误，在error.userInfo中我们是可以获取到resumeData，可以直接用于断点下载。

3. 第三种情况最复杂
      1. 尝试在网络失败时获取resumeData，由于时间太短，不可行
      2. 尝试通过监听UIApplicationWillTerminateNotification的通知，在app要结束的时候获取resumeData并保存，但现实还是比较残酷，由于时间太短还是无法获取resumeData，不可行
    3. 从resumeData入手，进行解析

           <?xml version="1.0" encoding="UTF-8"?>
           <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
           <plist version="1.0">
           <dict>
                <key>NSURLSessionDownloadURL</key>
                    <string>http://downloadUrl</string>
                <key>NSURLSessionResumeBytesReceived</key>
                    <integer>1474327</integer>
                <key>NSURLSessionResumeCurrentRequest</key>
                    <data>
                     ......
                    </data>
                <key>NSURLSessionResumeEntityTag</key>
                    <string>"XXXXXXXXXX"</string>
                <key>NSURLSessionResumeInfoTempFileName</key>
                    <string>CFNetworkDownload_XXXXX.tmp</string>
                <key>NSURLSessionResumeInfoVersion</key>
                    <integer>2</integer>
                <key>NSURLSessionResumeOriginalRequest</key>
                    <data>
                     .....
                    </data>
                <key>NSURLSessionResumeServerDownloadDate</key>
                     <string>week, dd MM yyyy hh:mm:ss </string>
           </dict></plist>

        1. 上面就是解析resumeData之后的数据，其实就是一个plist文件，里面信息包括了下载URL、已接收字节数、临时的下载文件名(文件默认存在tmp文件夹中)、当前请求、原始请求、下载事件、resumeInfo版本、EntityTag这些数据
        2. iOS8生成的resumeData稍有不同，没有`NSURLSessionResumeInfoTempFileName`字段，有`NSURLSessionResumeInfoLocalPath`，记录了完整的tmp文件地址

4. 主要需要几个参数：**下载URL、当前请求、已接收字节数、临时的下载文件名(文件默认存在tmp文件夹中)**这四个数据
    1. 下载URL：已知
    2. 当前请求：需要通过已经下载的大小和URL创建
    3. 已接收字节数：需要通过临时文件来获取大小
    4. 临时文件：存放在本地tmp文件夹下，但由于文件名CFNetworkDownload_XXXXXX.tmp，是系统随机生成的，我们无法将tmp文件和URL对应。

5. 获取tmp文件路径
     1. 手动cancel，在继续任务，在cancel回调中可以获取到resumeData，里面直接包含所有信息，我们只需要把数据中的字节数和当前请求更换就可以。
    2. 上一种方法，有显而易见的缺点，性能时间都会浪费，后来通过调试，查看信息，发现`NSURLSessionDownloadTask`中有个数据`downloadFile`存放了一些关于下载的信息，其中一个信息`path`就是存放临时文件路径的，通过`lastPathComponent`就可以直接取到相应的临时文件名。
    3. 通过tmp文件名获取tmp文件路径，这样做是因为本地文件路径会变，所以不能直接存task中的文件路径，需要获取到文件名，通过tmp的路径获取到tmp文件路径

6. 生成resumeData

        NSData *resumeData;
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        if ([fileMgr fileExistsAtPath:tempFilePath]) {
            NSDictionary *tempFileAttr = [[NSFileManager defaultManager] attributesOfItemAtPath:tempFilePath error:nil ];
            unsigned long long fileSize = [tempFileAttr[NSFileSize] unsignedLongLongValue];
        
            if (fileSize > 0) {
                NSMutableDictionary *fakeResumeData = [NSMutableDictionary dictionary];
            
                NSMutableURLRequest *newResumeRequest =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
                NSString *bytesStr =[NSString stringWithFormat:@"bytes=%ld-",fileSize];
                [newResumeRequest addValue:bytesStr forHTTPHeaderField:@"Range"];
            
                NSData *newResumeData =[NSKeyedArchiver archivedDataWithRootObject:newResumeRequest];
                [fakeResumeData setObject:newResumeData forKey:@"NSURLSessionResumeCurrentRequest"];
                [fakeResumeData setObject:url forKey:@"NSURLSessionDownloadURL"];
                [fakeResumeData setObject:@(fileSize) forKey:@"NSURLSessionResumeBytesReceived"];
                [fakeResumeData setObject:[tempFilePath lastPathComponent] forKey:@"NSURLSessionResumeInfoTempFileName"]; // iOS9以下 需要路径

                resumeData = [NSPropertyListSerialization dataWithPropertyList:fakeResumeData format:NSPropertyListXMLFormat_v1_0 options:0 error:nil];
            }
        }

7. 大功告成，如果获取到resumeData，可以直接通过resumeData创建task，进行断点下载了。

8. 下载完成，删除相应的数据

三、断点下载中涉及其他的知识点
1. 数据缓存： 
    1. 正在下载的URL
    2. 正在下载的URL的回调函数
    3. 下载的URL对应的resumeData
    4. 下载的URL对应的tmp文件名

    1 2 因为肯定是APP本次启动之后才存在的数据，所以直接使用静态变量存储就可以。
    3 4 则需要本地化，使用了JQCache存放在Document目录下

2. 数据安全问题：
    1. 创建一个`dispatch_queue`
    2. 使用读写锁来保障数据安全
          1. dispatch_barrier_async
          2. dispatch_sync
    3. 还有互斥锁和自旋锁
    4. 信号量，如果有大量下载同时访问，需要控制并发数量，这里我采用了信号量的方式去控制。

3. 同一URL处理
    1. 针对同一URL的网络请求，如果有下载任务，则不在此下载，判断方式通过参考SD的原理，考虑如果URL过长，全部对URL进行MD5处理，在进行判断和存储
    2. 不进行下载，但需要保存当前请求的回调函数，参考了关联对象的实现逻辑，对URL的回调函数做处理
