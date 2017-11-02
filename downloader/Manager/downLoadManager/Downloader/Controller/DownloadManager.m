//
//  DownloadManager.m
//  DownLoader
//
//  Created by bfec on 17/2/14.
//  Copyright © 2017年 com. All rights reserved.
//

#import "DownloadManager.h"
#import "AppDelegate.h"
#import "RootViewController.h"
#import "DownloadManager+Helper.h"
#import "DownloadManager+Utils.h"
#import "LocalNotificationManager.h"
#import "DownloadCacher+M3U8.h"
#import "DownloadManager_M3U8.h"
#import "UserDefaultManager.h"
#import "CoreStatus.h"
#import "XYWADManager.h"
static DownloadManager *instance;

@interface DownloadManager ()<DownloadManager_M3U8_Delegate,CoreStatusProtocol>

@property (nonatomic,strong) DownloadModel *downloadingModel;
@property (nonatomic,strong) DownloadManager_M3U8 *m3u8DownloadManager;
@property (nonatomic,assign) UIBackgroundTaskIdentifier bgTask;

@end

@implementation DownloadManager

+ (id)shareInstance
{
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [[DownloadManager alloc] init];
    });
    return instance;
}

- (id)init
{
    if (self = [super init])
    {
        NSURLSessionConfiguration *scf = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"nsurlsession_download_identifier"];
        scf.discretionary = NO;
        scf.allowsCellularAccess = YES;
        self.urlSession = [[AFURLSessionManager alloc] initWithSessionConfiguration:scf];
        self.downloadCacher = [DownloadCacher shareInstance];
        [self _checkOrCreateDownloadFolder];
        [self initM3U8];
        
        [self.urlSession setDidFinishEventsForBackgroundURLSessionBlock:^(NSURLSession * _Nonnull session) {
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            if (appDelegate.backgroundSessionCompletionHandler)
            {
                appDelegate.backgroundSessionCompletionHandler();
                appDelegate.backgroundSessionCompletionHandler = nil;
            }
        }];
        [self.urlSession setSessionDidBecomeInvalidBlock:^(NSURLSession * _Nonnull session, NSError * _Nonnull error) {
            
        }];
//        [CoreStatus beginNotiNetwork:self];
    }
    return self;
}
-(void)coreNetworkChangeNoti:(NSNotification *)noti{
    DDLogInfo(@"网络变成:");
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    RootViewController* rootVC = (RootViewController*)app.window.rootViewController;
    [rootVC requestIPinfo];
    if ([CoreStatus currentNetWorkStatus] == CoreNetWorkStatusWifi) {
        DDLogInfo(@"wifi");
        [self _tryToOpenNewDownloadTask];
    }else if ([CoreStatus currentNetWorkStatus] >= CoreNetWorkStatusWWAN){
        DDLogInfo(@"wwan");
        if (![self canGoonOpenNewDownloadTask]) {
            DDLogInfo(@"不允许流量，暂停下载");
            [self wattingForNetwork];
        }
    }else if ([CoreStatus currentNetWorkStatus] == CoreNetWorkStatusNone){//无网
        DDLogInfo(@"没网");
//        if (![self canGoonOpenNewDownloadTask]) {
//            [self wattingForNetwork];
//        }
    }
    
}

/*
 self.bgTask = UIBackgroundTaskInvalid;
 
 [[NSNotificationCenter defaultCenter] addObserver:self
 selector:@selector(_onEnterForegound)
 name:UIApplicationDidBecomeActiveNotification
 object:nil];
 [[NSNotificationCenter defaultCenter] addObserver:self
 selector:@selector(_onEnterBackground)
 name:UIApplicationDidEnterBackgroundNotification
 object:nil];

- (void)_onEnterForegound
{
    if (self.bgTask != UIBackgroundTaskInvalid)
    {
        [[UIApplication sharedApplication] endBackgroundTask:self.bgTask];
    }
    self.bgTask = UIBackgroundTaskInvalid;
}

- (void)_onEnterBackground
{
    UIApplication* application = [UIApplication sharedApplication];
    
    self.bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        [application endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
    }];
}
 */

- (DownloadManager_M3U8 *)m3u8DownloadManager
{
    if (!_m3u8DownloadManager)
    {
        _m3u8DownloadManager = [DownloadManager_M3U8 shareInstance];
    }
    return _m3u8DownloadManager;
}

- (void)dealDownloadModel:(DownloadModel *)downloadModel
{
    [self initializeDownloadModelFromDBCahcher:downloadModel];
    DownloadStatus status = downloadModel.status;
    
    BOOL wifi = [CoreStatus isWifiEnable];
    BOOL onlyWifi = [UserDefaultManager isOnlyDownloadWhenWIFI];
    switch (status) {
        case DownloadNotExist:
            [self addDownloadModel:downloadModel];
            if ((!wifi) && onlyWifi) {
                return;
            }
            break;
            
        case Downloading:
        {
            [self pauseDownloadModel:downloadModel];
            break;
        }
            
        case DownloadWating:
        {
            
            downloadModel.status = DownloadPause;
            [self _changeStatusWithModel:downloadModel];
            break;
        }
            
        case DownloadPause:
        case DownloadFailed:
        {
            
            downloadModel.status = DownloadWating;
            [self _changeStatusWithModel:downloadModel];
            break;
        }
            
        case DownloadFinished:
            break;
            
        default:
            break;
    }
    [self _tryToOpenNewDownloadTask];
}
-(void)wattingForNetwork{
    if (self.downloadingModel) {
        DDLogInfo(@"暂停当前正在现在的%@",self.downloadingModel);
        [self wattingDownloadModel:_downloadingModel];
    }else{
        DDLogInfo(@"没有正在下载的任务");
    }
}

- (void)initM3U8
{
    self.m3u8DownloadManager.delegate = self;
    self.m3u8DownloadManager.downloadCacher = self.downloadCacher;
    self.m3u8DownloadManager.urlSession = self.urlSession;
}

- (void)addDownloadModel:(DownloadModel *)downloadModel
{
    downloadModel.status = DownloadWating;
    [self.downloadCacher insertDownloadModel:downloadModel];
    [DownloadManager postNotification:DownloadingUpdateNotification andObject:downloadModel];
}

- (void)pauseDownloadModel:(DownloadModel *)downloadModel
{
    if ([self.downloadCacher checkIsExistDownloading])
    {
        DDLogInfo(@"[[self.urlSession downloadTasks] count]   ===   %lu",(unsigned long)[[self.urlSession downloadTasks] count]);
        
        [[self.urlSession downloadTasks] enumerateObjectsUsingBlock:^(NSURLSessionDownloadTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSURLSessionDownloadTask *task = obj;
            if (task.state == NSURLSessionTaskStateRunning)
            {
                if (downloadModel.isM3u8Url)
                {
                    [task cancel];
                    [[self.urlSession downloadTasks] makeObjectsPerformSelector:@selector(cancel)];
                    downloadModel.status = DownloadPause;
                    [self.downloadCacher updateDownloadModel:downloadModel];
                    [self.m3u8DownloadManager pauseDownloadModel:downloadModel withResumeData:nil];
                }
                else
                {
                    
                    [task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                        NSString *resumeDataStr = [[NSString alloc] initWithData:resumeData encoding:NSUTF8StringEncoding];
                        downloadModel.resumeData = resumeDataStr;
                        downloadModel.status = DownloadPause;
                        [self.downloadCacher updateDownloadModel:downloadModel];
                    }];
                }

                *stop = YES;
            }
        }];
    }
}
-(void)wattingDownloadModel:(DownloadModel *)downloadModel
{
    if ([self.downloadCacher checkIsExistDownloading])
    {
        DDLogInfo(@"[[self.urlSession downloadTasks] count]   ===   %lu",(unsigned long)[[self.urlSession downloadTasks] count]);
        
        [[self.urlSession downloadTasks] enumerateObjectsUsingBlock:^(NSURLSessionDownloadTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSURLSessionDownloadTask *task = obj;
            if (task.state == NSURLSessionTaskStateRunning)
            {
                if (downloadModel.isM3u8Url)
                {
                    [task cancel];
                    [[self.urlSession downloadTasks] makeObjectsPerformSelector:@selector(cancel)];
                    downloadModel.status = DownloadWating;
                    [self.downloadCacher updateDownloadModel:downloadModel];
                    [self.m3u8DownloadManager pauseDownloadModel:downloadModel withResumeData:nil];
                }
                else
                {
                    DDLogInfo(@"找到了下载任务，并进行取消，设置为waiting状态");
                    [task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                        NSString *resumeDataStr = [[NSString alloc] initWithData:resumeData encoding:NSUTF8StringEncoding];
                        downloadModel.resumeData = resumeDataStr;
                        downloadModel.status = DownloadWating;
                        [self.downloadCacher updateDownloadModel:downloadModel];
                    }];
                }
                *stop = YES;
            }
        }];
    }
}
- (void)_changeStatusWithModel:(DownloadModel *)downloadModel
{
    [self.downloadCacher updateDownloadModel:downloadModel];
    [DownloadManager postNotification:DownloadingUpdateNotification andObject:downloadModel];
}

- (void)deleteDownloadModelArr:(NSArray *)downloadArr
{
    if ([downloadArr containsObject:_downloadingModel])
    {
        NSURLSessionDownloadTask *task = [[self.urlSession downloadTasks] firstObject];
        [task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            [self _deleteTmpFileWithResumeData:resumeData];
            _downloadingModel = nil;
        }];
    }
    [self.downloadCacher deleteDownloadModels:downloadArr];
    if ([self canGoonOpenNewDownloadTask]) {
        [self _tryToOpenNewDownloadTask];
    }
}

- (void)_deleteTmpFileWithResumeData:(NSData *)resumeData
{
    NSError *error = nil;
    NSPropertyListFormat format = NSPropertyListXMLFormat_v1_0;
    NSDictionary *dict = [NSPropertyListSerialization propertyListWithData:resumeData options:0 format:&format error:&error];
    if (!error)
    {
        NSString *tmpPath = [dict valueForKey:@"NSURLSessionResumeInfoTempFileName"];
        tmpPath = [NSString stringWithFormat:@"%@/tmp/%@",NSHomeDirectory(),tmpPath];
        BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:tmpPath];
        if (fileExist)
        {
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:tmpPath error:&error];
            if (!error)
            {
                DDLogInfo(@"删除无用的临时文件成功!");
            }
        }
    }
}


- (void)startAllDownload
{
    NSArray *arr = [self.downloadCacher startAllDownloadModels];
    for (DownloadModel *model in arr)
    {
        [DownloadManager postNotification:DownloadingUpdateNotification andObject:model];
    }
    [self _tryToOpenNewDownloadTask];
}

- (void)pauseAllDownload
{
    [self pauseDownloadModel:_downloadingModel];
    NSArray *arr = [self.downloadCacher pauseAllDownloadModels];
    for (DownloadModel *model in arr)
    {
        [DownloadManager postNotification:DownloadingUpdateNotification andObject:model];
    }
}
//BOOL wifi = [CoreStatus isWifiEnable];
//if (!wifi) {//不是Wi-Fi
//    BOOL onlyWifi = [UserDefaultManager isOnlyDownloadWhenWIFI];
//    if (onlyWifi) {//只有Wi-Fi下载
//        downloadModel.status = DownloadPause;
//    }else{
//        downloadModel.status = DownloadWating;
//    }
//}else{
//    downloadModel.status = DownloadWating;
//}
- (void)_tryToOpenNewDownloadTaskByUser
{
    DDLogInfo(@"尝试开启下一个等待中的任务");
    if ([self.downloadCacher checkIsExistDownloading])//存在正在下载
        return;
    DownloadModel *topWaitingModel = [self.downloadCacher queryTopWaitingDownloadModel];
    if (!topWaitingModel)
    {
        DDLogInfo(@"not find waiting model...");
    }
    else
    {
        DDLogInfo(@"开始这个任务%@",topWaitingModel);
        topWaitingModel.status = Downloading;
        [self.downloadCacher updateDownloadModel:topWaitingModel];
        _downloadingModel = topWaitingModel;
        
        if (topWaitingModel.isM3u8Url)
        {
            NSDictionary *m3u8Info = [self.downloadCacher queryM3U8Record:topWaitingModel.url];
            [self.m3u8DownloadManager m3u8Downloading:topWaitingModel withInfo:m3u8Info];
        }
        else
        {
            [self _mp4Downloading:topWaitingModel];
        }
    }
}
-(BOOL)canGoonOpenNewDownloadTask{
    
    BOOL wifi = [CoreStatus isWifiEnable];
    BOOL onlyWifi = [UserDefaultManager isOnlyDownloadWhenWIFI];
    if ((!wifi) && onlyWifi) {
        return NO;
    }
    return YES;
}
- (void)_tryToOpenNewDownloadTask
{
    if ([self.downloadCacher checkIsExistDownloading])//存在正在下载
        return;
    if (![self canGoonOpenNewDownloadTask]) {
        return;
    }
    DownloadModel *topWaitingModel = [self.downloadCacher queryTopWaitingDownloadModel];
    if (!topWaitingModel)
    {
        DDLogInfo(@"not find waiting model...");
    }
    else
    {
        topWaitingModel.status = Downloading;
        [self.downloadCacher updateDownloadModel:topWaitingModel];
        _downloadingModel = topWaitingModel;
        
        if (topWaitingModel.isM3u8Url)
        {
            NSDictionary *m3u8Info = [self.downloadCacher queryM3U8Record:topWaitingModel.url];
            [self.m3u8DownloadManager m3u8Downloading:topWaitingModel withInfo:m3u8Info];
        }
        
        else
        {
            [self _mp4Downloading:topWaitingModel];
        }
    }
}
-(void)recoverDownloading{
     DownloadModel * downloadingModel = [self.downloadCacher queryTopDownloadingDownloadModel];
    [self _mp4Downloading:downloadingModel];
}
-(void)resetDownloading{
    DownloadModel * downloadingModel = [self.downloadCacher queryTopDownloadingDownloadModel];
    downloadingModel.status = DownloadPause;
    [self.downloadCacher updateDownloadModel:downloadingModel];
}
- (void)_mp4Downloading:(DownloadModel *)downloadModel
{
    if (downloadModel.resumeData && downloadModel.resumeData.length>0)
    {
        NSData *resumeData = [downloadModel.resumeData dataUsingEncoding:NSUTF8StringEncoding];
        NSURLSessionDownloadTask *task = [self _downloadTaskWithOriginResumeData:resumeData withDownloadModel:downloadModel];
        [task resume];
    }
    else
    {
        NSURLRequest *rq = [NSURLRequest requestWithURL:[NSURL URLWithString:downloadModel.url]];
        NSURLSessionDownloadTask *task = [self.urlSession downloadTaskWithRequest:rq progress:^(NSProgress * _Nonnull downloadProgress) {
            downloadModel.videoSize = downloadProgress.totalUnitCount;
            downloadModel.downloadPercent = downloadProgress.completedUnitCount / (downloadProgress.totalUnitCount * 1.0);
            DDLogVerbose(@"videoSize = %ld",downloadModel.videoSize);
            [self.downloadCacher updateDownloadModel:downloadModel];
            [DownloadManager postNotification:DownloadingUpdateNotification andObject:downloadModel];
            
        } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
            NSURL *fileURL = [NSURL fileURLWithPath:[DownloadManager getMP4LocalUrlWithVideoName:downloadModel.name]];
            [self.downloadCacher updateDownloadModel:downloadModel];
            downloadModel.name = fileURL.lastPathComponent;
            return fileURL;
//            return [NSURL fileURLWithPath:[DownloadManager getMP4LocalUrlWithVideoUrl:downloadModel.url]];
            
        } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
            
            DDLogError(@"下载失败！%@",error.localizedDescription);
            [self dealDownloadFinishedOrFailedWithError:error andDownloadModel:downloadModel];
//            if ([self canGoonOpenNewDownloadTask]) {
//                [self _tryToOpenNewDownloadTask];
//            }
        }];
        [task resume];
    }
    [DownloadManager postNotification:DownloadBeginNotification andObject:downloadModel];
}

- (void)_checkOrCreateDownloadFolder
{
    NSString *downloadFolderPath = [NSString stringWithFormat:@"%@/download",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]];
    BOOL isDirectory = YES;
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:downloadFolderPath isDirectory:&isDirectory];
    if (!exist)
    {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:downloadFolderPath withIntermediateDirectories:NO attributes:nil error:&error];
        if (error)
        {
            DDLogInfo(@"create downloadFolderPath failed...");
        }
        else
        {
            DDLogInfo(@"create downloadFolderPath successful...");
        }
    }
}

- (void)dealDownloadFinishedOrFailedWithError:(NSError *)error andDownloadModel:(DownloadModel *)downloadModel
{
    
    if (error)
    {
        //手动暂停的
        if ([error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData])
        {
            NSData *resumeData = [error.userInfo objectForKey:NSURLSessionDownloadTaskResumeData];
            downloadModel.resumeData = [[NSString alloc] initWithData:resumeData encoding:NSUTF8StringEncoding];
            if (downloadModel.status==DownloadWating) {//已经被设置为waiting，说明是在等网络
                DDLogInfo(@"下载取消，但是是因为网络不满足，设为watting");
            }else{
                DDLogInfo(@"下载取消，但是是因为用户手动暂停，设为pause");
                downloadModel.status = DownloadPause;
            }
            
            [self.downloadCacher updateDownloadModel:downloadModel];
            
            [DownloadManager postNotification:DownloadingUpdateNotification andObject:downloadModel];
            [DownloadManager postNotification:DownloadingPauseNotification andObject:downloadModel];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [LocalNotificationManager sendNotificationNow:[[NSString alloc] initWithFormat:@"%@--下载暂停",downloadModel.name]];
//            });
        }
        //下载出现错误
        else
        {
            downloadModel.status = DownloadFailed;
            [self.downloadCacher updateDownloadModel:downloadModel];

            downloadModel.error = error;
            [DownloadManager postNotification:DownloadFailedNotification andObject:downloadModel];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [LocalNotificationManager sendNotificationNow:[[NSString alloc] initWithFormat:@"%@%@",[downloadModel.name stringByURLDecode] ,NSLocalizedString(@"download failed", nil)]];
            });
        }
        
    }
    //下载完成
    else
    {
        downloadModel.status = DownloadFinished;
        downloadModel.downloadPercent = 1.0;
        [self.downloadCacher updateDownloadModel:downloadModel];

        [DownloadManager postNotification:DownloadFinishNotification andObject:downloadModel];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([[XYWADManager shareInstance].interstitialAd isAdValid]) {
                [[XYWADManager shareInstance]showAD];
            }
            [LocalNotificationManager sendNotificationNow:[[NSString alloc] initWithFormat:@"%@%@",[downloadModel.name stringByURLDecode],NSLocalizedString(@"downloaded", nil)]];
            
        });
    }
    [self _tryToOpenNewDownloadTask];
}




- (void)initializeDownloadModelFromDBCahcher:(DownloadModel *)downloadModel
{
    [[DownloadCacher shareInstance] initializeDownloadModelFromDBCahcher:downloadModel];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceBatteryLevelDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceBatteryStateDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
}




#pragma mark - DownloadManager_M3U8_Delegate

- (void)m3u8Downloader:(DownloadManager_M3U8 *)m3u8Downloader beginDownload:(DownloadModel *)downloadModel segment:(M3U8SegmentInfo *)segment task:(NSURLSessionDownloadTask *)task
{
    self.downloadingModel = downloadModel;
    [DownloadManager postNotification:DownloadBeginNotification andObject:downloadModel];
}

- (void)m3u8Downloader:(DownloadManager_M3U8 *)m3u8Downloader updateDownload:(DownloadModel *)downloadModel progress:(CGFloat)progress
{
    downloadModel.downloadPercent = progress;
    [self.downloadCacher updateDownloadModel:downloadModel];
    [DownloadManager postNotification:DownloadingUpdateNotification andObject:downloadModel];
}

- (void)m3u8Downloader:(DownloadManager_M3U8 *)m3u8Downloader pauseDownload:(DownloadModel *)downloadModel resumeData:(NSData *)resumeData tsIndex:(NSInteger)tsIndex alreadyDownloadSize:(long long)alreadyDownloadSize
{
    [DownloadManager postNotification:DownloadingUpdateNotification andObject:downloadModel];
}

- (void)m3u8Downloader:(DownloadManager_M3U8 *)m3u8Downloader failedDownload:(DownloadModel *)downloadModel
{
    [DownloadManager postNotification:DownloadingUpdateNotification andObject:downloadModel];
    /*
    downloadModel.status = DownloadFailed;
    [self.downloadCacher updateDownloadModel:downloadModel];
    
    [DownloadManager postNotification:DownloadFailedNotification andObject:downloadModel];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [LocalNotificationManager sendNotificationNow:[[NSString alloc] initWithFormat:@"%@--下载出现错误",downloadModel.name]];
    });
*/
}

- (void)m3u8Downloader:(DownloadManager_M3U8 *)m3u8Downloader finishDownload:(DownloadModel *)downloadModel
{
    downloadModel.status = DownloadFinished;
    downloadModel.downloadPercent = 1.0;
    [self.downloadCacher updateDownloadModel:downloadModel];
    
    [self.downloadCacher deleteM3U8Record:downloadModel.url];
    
    [DownloadManager postNotification:DownloadFinishNotification andObject:downloadModel];
    dispatch_async(dispatch_get_main_queue(), ^{
        [LocalNotificationManager sendNotificationNow:[[NSString alloc] initWithFormat:@"%@%@",[downloadModel.name stringByURLDecode],NSLocalizedString(@"downloaded", nil)]];
//        [LocalNotificationManager sendNotificationNow:[[NSString alloc] initWithFormat:@"%@--download finished",downloadModel.name]];
        if ([[XYWADManager shareInstance].interstitialAd isAdValid]) {
            [[XYWADManager shareInstance]showAD];
        }
    });
     [self _tryToOpenNewDownloadTask];
//    if ([self canGoonOpenNewDownloadTask]) {
//       
//    }

}

- (void)m3u8Downloader:(DownloadManager_M3U8 *)m3u8Downloader dealModelFinished:(DownloadModel *)downloadModel
{
     [self _tryToOpenNewDownloadTask];
//    if ([self canGoonOpenNewDownloadTask]) {
//        [self _tryToOpenNewDownloadTask];
//    }
}

- (void)m3u8Downloader:(DownloadManager_M3U8 *)m3u8Downloader analyseFailed:(DownloadModel *)downloadModel
{
    [DownloadManager postNotification:DownloadM3U8AnalyseFailedNotification andObject:downloadModel];
}

















@end
