//
//  M3U8SegmentListDownloader.m
//  DownLoader
//
//  Created by bfec on 17/3/9.
//  Copyright © 2017年 com. All rights reserved.
//

#import "M3U8SegmentListDownloader.h"
#import "M3U8SegmentDownloader.h"
#import "DownloadManager+Utils.h"
#import "HYFileManager.h"
static M3U8SegmentListDownloader *instance;

@interface M3U8SegmentListDownloader ()<M3U8SegmentDownloaderDelegate,NSStreamDelegate>

@property (nonatomic,strong) M3U8SegmentList *segmentList;
@property (nonatomic,strong) DownloadModel *downloadingModel;
@property (nonatomic,assign) NSInteger downloadingIndex;
@property (nonatomic,strong) M3U8SegmentDownloader *segmentDownloader;
@property (nonatomic,assign) long long alreadyDownloadSize;
@property (nonatomic,assign) long long tmpSize;

@end

@implementation M3U8SegmentListDownloader

+ (id)shareInstance
{
    static dispatch_once_t token2;
    dispatch_once(&token2, ^{
        instance = [[M3U8SegmentListDownloader alloc] init];
    });
    return instance;
}

- (M3U8SegmentDownloader *)segmentDownloader
{
    if (!_segmentDownloader)
    {
        _segmentDownloader = [M3U8SegmentDownloader shareInstance];
        _segmentDownloader.urlSession = self.urlSession;
        _segmentDownloader.delegate = self;
        _segmentDownloader.downloadCacher = self.downloadCacher;
    }
    return _segmentDownloader;
}


- (void)startDownload:(DownloadModel *)downloadModel andSegmentList:(M3U8SegmentList *)segmentList withInfo:(NSDictionary *)m3u8Info
{
    self.segmentList = segmentList;
    self.downloadingModel = downloadModel;

    self.alreadyDownloadSize = [m3u8Info[@"m3u8AlreadyDownloadSize"] integerValue];
    self.downloadingIndex = [m3u8Info[@"tsDownloadTSIndex"] integerValue];
    //NSString *resumeData = m3u8Info[@"resumeData"];
    
    if (self.downloadingIndex < [segmentList.segments count] && self.downloadingIndex > 0)
    {
        M3U8SegmentInfo *segment = [self.segmentList.segments objectAtIndex:self.downloadingIndex];
        [self _startDownload:segment withResumeData:nil];
    }
    else if (self.downloadingIndex == 0)
    {
        M3U8SegmentInfo *segment = [self.segmentList.segments firstObject];
       
        [self _startDownload:segment withResumeData:nil];
    }
}

- (void)pauseDownload:(DownloadModel *)downloadModel withResumeData:(NSData *)resumeData
{
    self.downloadingModel.status = DownloadPause;
    [self.segmentDownloader pauseDownloadWithResumeData:resumeData downloadIndex:self.downloadingIndex downloadSize:self.tmpSize url:self.downloadingModel.url];
}

- (void)_startDownload:(M3U8SegmentInfo *)segment withResumeData:(NSString *)resumeData
{
    [self.segmentDownloader startDownload:segment withResumeData:resumeData];
}



#pragma mark - SegmentDownloaderDelegate

- (void)m3u8SegmentDownloader:(M3U8SegmentDownloader *)m3u8SegmentDownloader downloadingBegin:(M3U8SegmentInfo *)segment task:(NSURLSessionDownloadTask *)task
{
    if ([self.delegate respondsToSelector:@selector(m3u8SegmentListDownloader:beginDownload:segment:task:)])
    {
        [self.delegate m3u8SegmentListDownloader:self beginDownload:nil segment:segment task:task];
    }
}

- (void)m3u8SegmentDownloader:(M3U8SegmentDownloader *)m3u8SegmentDownloader downloadingUpdateProgress:(NSProgress *)progress
{
    if (self.downloadingIndex==0) {
        if (self.downloadingModel.videoSize<1000) {
            int64_t thisTotal = progress.totalUnitCount;
            int64_t totalSize= thisTotal/(m3u8SegmentDownloader.segment.duration/self.segmentList.totalDurations);
            self.downloadingModel.videoSize = totalSize*1.2;
        }
    }
    
    self.tmpSize = self.alreadyDownloadSize + progress.completedUnitCount;
    CGFloat downloadProgress = (self.alreadyDownloadSize + progress.completedUnitCount) / (self.downloadingModel.videoSize * 1.0);
    
    if (progress.completedUnitCount == progress.totalUnitCount)
    {
        self.alreadyDownloadSize += progress.totalUnitCount;
    }
    if ([self.delegate respondsToSelector:@selector(m3u8SegmentListDownloader:updateDownload:progress:)])
    {
        [self.delegate m3u8SegmentListDownloader:self updateDownload:nil progress:downloadProgress];
    }
    
}

- (void)m3u8SegmentDownloader:(M3U8SegmentDownloader *)m3u8SegmentDownloader downloadingPause:(M3U8SegmentInfo *)segment resumeData:(NSData *)resumeData
{
    if ([self.delegate respondsToSelector:@selector(m3u8SegmentListDownloader:pauseDownload:resumeData:tsIndex:alreadyDownloadSize:)])
    {
        [self.delegate m3u8SegmentListDownloader:self pauseDownload:self.downloadingModel resumeData:resumeData tsIndex:self.downloadingIndex alreadyDownloadSize:self.alreadyDownloadSize];
    }
}

- (void)m3u8SegmentDownloader:(M3U8SegmentDownloader *)m3u8SegmentDownloader downloadFailed:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(m3u8SegmentListDownloader:failedDownload:)])
    {
        self.downloadingModel.error = error;
        [self.delegate m3u8SegmentListDownloader:self failedDownload:self.downloadingModel];
    }
}

- (void)m3u8SegmentDownloader:(M3U8SegmentDownloader *)m3u8SegmentDownloader downloadingFinished:(M3U8SegmentInfo *)segment
{
    self.downloadingIndex++;
    if (self.downloadingIndex < [self.segmentList.segments count])
    {
        M3U8SegmentInfo *nextSegment = [self.segmentList.segments objectAtIndex:self.downloadingIndex];
        [self.segmentDownloader startDownload:nextSegment withResumeData:nil];
    }
    else//所有的ts都下载完成
    {
        [self _createM3U8File];
//        [self mergeTsVideo];
        
    }
}
- (void)mergeTsVideo{
    NSString *savePath = [DownloadManager getM3U8LocalUrlWithVideoUrl:self.downloadingModel.url];
    NSString *downloadPath = [savePath stringByDeletingLastPathComponent];
    NSArray *files = [HYFileManager listFilesInDirectoryAtPath:savePath deep:NO];
    DDLogVerbose(@"files : %@",files);
//    NSMutableData *mergeData = [[NSMutableData alloc]init];
    
    NSString *videoName = [self.downloadingModel.name stringByAppendingPathExtension:@"ts"];
    NSString *videoLocalPath = [downloadPath stringByAppendingPathComponent:videoName];
    //打开文件
//    char const *cvideoPath = [videoLocalPath UTF8String];
//    FILE *megrefile = fopen(cvideoPath, "a+");
    NSOutputStream *outputStream = [[NSOutputStream alloc]initToFileAtPath:videoLocalPath append:YES];
    [outputStream open];
    DDLogVerbose(@"outputStream open!");
    for (NSString *fileName in files) {
        if ([fileName.pathExtension isEqualToString:@"ts"]) {
            
            NSString *filePath = [savePath stringByAppendingPathComponent:fileName];
//            NSError *error = nil;
            
            //通过流打开一个文件
            NSInputStream *inputStream = [[NSInputStream alloc] initWithFileAtPath: filePath];
             DDLogVerbose(@"inputStream open once!");
            [inputStream open];
            NSInteger maxLength = 1024;
            uint8_t readBuffer [maxLength];
            //是否已经到结尾标识
            BOOL endOfStreamReached = NO;
            // NOTE: this tight loop will block until stream ends
            while (! endOfStreamReached)
            {
                NSInteger bytesRead = [inputStream read: readBuffer maxLength:maxLength];
                if (bytesRead == 0)
                {//文件读取到最后
                    endOfStreamReached = YES;
                }
                else if (bytesRead == -1)
                {//文件读取错误
                    endOfStreamReached = YES;
                }
                else
                {
                    DDLogVerbose(@"add stream once!");
                    [outputStream write:readBuffer maxLength:maxLength];
                    //读取出来的数据写入文件
//                    fwrite(fileData.bytes, sizeof(char), fileData.length, megrefile);
                }
            }
            DDLogVerbose(@"inputStream close once!");
            [inputStream close];
        }
    }
    DDLogVerbose(@"megre finished!");
    [outputStream close];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        DDLogVerbose(@"after 2.. delete dir..");
        [HYFileManager removeItemAtPath:savePath];
    });
    
    if ([self.delegate respondsToSelector:@selector(m3u8SegmentListDownloader:finishDownload:)])
    {
        [self.delegate m3u8SegmentListDownloader:self finishDownload:self.downloadingModel];
    }
//            NSData *fileData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:filePath] options:NSDataReadingMappedIfSafe error:&error];
//            if (error) {
//                DDLogError(@"mergeTsVideo error :%@",error.localizedDescription);
//            }else{
//                fwrite(fileData.bytes, sizeof(char), fileData.length, megrefile);
//                DDLogVerbose(@"appendData once");
//            }
//        }
//    }
    
//    NSData *rep = [NSData new];
//    
//    FILE *file = fopen(cvideoPath, "a+");
//    
//    for (NSString *fileName in files) {
//        if ([fileName.pathExtension isEqualToString:@"ts"]) {
//            NSString *filePath = [savePath stringByAppendingPathComponent:fileName];
//            NSError *error = nil;
//            NSData *fileData = [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:filePath] options:NSDataReadingMappedIfSafe error:&error];
//            if (error) {
//                DDLogError(@"mergeTsVideo error :%@",error.localizedDescription);
//            }else{
//                [mergeData appendData: fileData];
//                DDLogVerbose(@"appendData once");
//            }
//        }
//    }
//    NSString *videoName = [self.downloadingModel.name stringByAppendingPathExtension:@"mp4"];
//    NSString *videoLocalPath = [savePath stringByAppendingPathComponent:videoName];
//    [mergeData writeToFile:videoLocalPath atomically:YES];

}
//-(void)test{
//    char const *cvideoPath = [@"aaa" UTF8String];
//    NSData *rep = [NSData new];
//    
//    FILE *file = fopen(cvideoPath, "a+");
//    if (file) {
//        const int bufferSize = 11024 * 1024;
//        // 初始化一个1M的buffer
//        Byte *buffer = (Byte*)malloc(bufferSize);
//        NSUInteger read = 0, offset = 0, written = 0;
//        NSError* err = nil;
//        if (rep.length != 0)
//        {
//            do {
//                [rep getBytes:buffer length:bufferSize];
////                read = [rep getBytes:buffer fromOffset:offset length:bufferSize error:&err];
//                written = fwrite(buffer, sizeof(char), read, file);
//                offset += read;
//            } while (read != 0 && !err);//没到结尾，没出错，ok继续
//        }
//        // 释放缓冲区，关闭文件
//        free(buffer);
//        buffer = NULL;
//        fclose(file);
//        file = NULL;
//}
- (void)_createM3U8File
{

    NSString *savePath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"download"];
//    NSString *savePath = [DownloadManager getM3U8LocalUrlWithVideoUrl:self.downloadingModel.url];
    if (self.downloadingModel.name.pathExtension.length<1) {//没有后缀
        savePath = [savePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.m3u8",self.downloadingModel.name]];
    }else{//有后缀就不要加了
        savePath = [savePath stringByAppendingPathComponent:self.downloadingModel.name];
    }
    
    DDLogVerbose(@"true m3u8 path %@",savePath);
    //创建文件头部
    NSString* head = [NSString stringWithFormat:@"#EXTM3U\n#EXT-X-TARGETDURATION:30\n#EXT-X-VERSION:2\n#EXT-X-DISCONTINUITY\n#EXT-X-SIZE:%ld\n",self.downloadingModel.videoSize];;
    NSInteger count = [self.segmentList.segments count];
    //填充片段数据
    for(int i = 0;i<count;i++)
    {
        M3U8SegmentInfo *segInfo = [self.segmentList getSegmentByIndex:i];
        NSString *length = [NSString stringWithFormat:@"#EXTINF:%ld,\n",(long)segInfo.duration];
//        NSString *url = [NSString stringWithFormat:@"%@",segInfo.shortUrl];
        
        NSString *url = [NSString stringWithFormat:@"http://127.0.0.1:6398/%@/%@",[segInfo.localUrl stringByDeletingLastPathComponent].lastPathComponent,segInfo.shortUrl.lastPathComponent];
        head = [NSString stringWithFormat:@"%@%@%@\n",head,length,url];
        DDLogVerbose(@"true url %@",url);
    }
    //创建尾部
    NSString* end = @"#EXT-X-ENDLIST";
    head = [head stringByAppendingString:end];
    NSMutableData *writer = [[NSMutableData alloc] init];
    [writer appendData:[head dataUsingEncoding:NSUTF8StringEncoding]];
    [writer writeToFile:savePath atomically:YES];
    if ([self.delegate respondsToSelector:@selector(m3u8SegmentListDownloader:finishDownload:)])
    {
        [self.delegate m3u8SegmentListDownloader:self finishDownload:self.downloadingModel];
    }
}


























@end
