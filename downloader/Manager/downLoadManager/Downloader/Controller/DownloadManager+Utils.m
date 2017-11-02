//
//  DownloadManager+Utils.m
//  DownLoader
//
//  Created by bfec on 17/3/9.
//  Copyright © 2017年 com. All rights reserved.
//

#import "DownloadManager+Utils.h"

@implementation DownloadManager (Utils)

+ (void)postNotification:(NSString *)notificationName andObject:(id)object
{
    if (notificationName == nil || [notificationName isEqualToString:@""])
        return;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:object];
    });
}

+ (NSString *)getMP4LocalUrlWithVideoUrl:(NSString *)videoUrl
{
    if (videoUrl == nil || [videoUrl isEqualToString:@""])
    {
        DDLogError(@"videoUrl is nil or empty");
        return nil;
    }
    else
    {
        if ([videoUrl length] > 7)
        {
            NSURL *vdURL = [NSURL URLWithString:videoUrl];
            if (!vdURL) {
                return nil;
            }
            
            NSString *subStr = [vdURL.path stringByDeletingLastPathComponent];
            subStr = [subStr stringByReplacingOccurrencesOfString:@"/" withString:@""];
            subStr = [subStr stringByReplacingOccurrencesOfString:@"." withString:@""];
//            subStr = [subStr stringByURLEncode];
            if (subStr.length>100) {
                [subStr substringToIndex:100];
            }
            subStr = [@"download" stringByAppendingPathComponent:subStr];
            subStr = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:subStr];
            return subStr;
        }
        return nil;
    }
}
+ (NSString *)getMP4LocalUrlWithVideoName:(NSString *)videoName
{
    if (videoName == nil || [videoName isEqualToString:@""])
    {
        return nil;
    }
    else
    {
        NSString *downloadDir = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"download"];
        return [downloadDir stringByAppendingPathComponent:videoName];
        
//        return [self getLegalFileName:videoName];
        /*
        NSString *subStr = [subStr stringByReplacingOccurrencesOfString:@"_" withString:@""];
        subStr = [@"download" stringByAppendingPathComponent:subStr];
        subStr = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:subStr];
        if ([[NSFileManager defaultManager] fileExistsAtPath:subStr]) {
            
        }
        return subStr;
        if ([videoUrl length] > 7 && [videoUrl containsString:@"http://"])
        {
            NSString *subStr = [videoUrl substringFromIndex:7];
            subStr = [subStr stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
            subStr = [@"download" stringByAppendingPathComponent:subStr];
            subStr = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:subStr];
            return subStr;
        }
        return nil;
         */
    }
}
+(NSString *)getLegalFileName:(NSString *)fileName{
    NSString *subStr = [fileName stringByReplacingOccurrencesOfString:@"/" withString:@"_"];//有歧义的符号
    subStr = [@"download" stringByAppendingPathComponent:subStr];
    subStr = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:subStr];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[subStr stringByAppendingPathExtension:@".mp4"]]) {//检查带后缀后是否存在这个文件
        DDLogInfo(@"文件名 %@",[fileName stringByAppendingPathExtension:@".mp4"]);
        return [subStr stringByAppendingPathExtension:@".mp4"];//返回的是带后缀的
    }else{
        static NSInteger i = 1;
        NSString *newStr = [NSString stringWithFormat:@"%@(%ld)",fileName,(long)i++];
        return [self getLegalFileName:newStr];
    }
}
+ (NSString *)getM3U8LocalUrlWithVideoName:(NSString *)videoName
{
    NSString *m3u8Path = [self getMP4LocalUrlWithVideoName:videoName];
    m3u8Path = [m3u8Path stringByReplacingOccurrencesOfString:@"." withString:@"_"];
    BOOL isDirectory = YES;
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:m3u8Path isDirectory:&isDirectory];
    if (!exist)
    {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:m3u8Path withIntermediateDirectories:NO attributes:nil error:&error];
        if (!error)
        {
            return m3u8Path;
        }
    }
    else
    {
        return m3u8Path;
    }
    return nil;
}
+ (NSString *)getM3U8LocalUrlWithVideoUrl:(NSString *)videoUrl
{
    NSString *m3u8Path = [self getMP4LocalUrlWithVideoUrl:videoUrl];
    m3u8Path = [m3u8Path stringByReplacingOccurrencesOfString:@"." withString:@""];
    BOOL isDirectory = YES;
    BOOL exist = [[NSFileManager defaultManager] fileExistsAtPath:m3u8Path isDirectory:&isDirectory];
    if (!exist)
    {
        NSError *error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:m3u8Path withIntermediateDirectories:NO attributes:nil error:&error];
        if (!error)
        {
            return m3u8Path;
        }
    }
    else
    {
        return m3u8Path;
    }
    return nil;
}
























@end
