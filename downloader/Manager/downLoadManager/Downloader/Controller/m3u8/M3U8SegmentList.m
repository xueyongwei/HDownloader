//
//  M3U8SegmentList.m
//  DownLoader
//
//  Created by bfec on 17/3/8.
//  Copyright © 2017年 com. All rights reserved.
//

#import "M3U8SegmentList.h"
#import "DownloadManager+Utils.h"

@implementation M3U8SegmentList

- (id)initWithSegments:(NSMutableArray *)segments
{
    if (self = [super init])
    {
        self.segments = segments;
    }
    return self;
}

- (M3U8SegmentInfo *)getSegmentByIndex:(int)index
{
    if (index < [self.segments count] && index >= 0)
    {
        return [self.segments objectAtIndex:index];
    }
    return nil;
}

- (void)setVideoUrl:(NSString *)videoUrl
{
    _videoUrl = [videoUrl copy];
    
    NSString *tsFullPath = [[NSURL URLWithString:videoUrl] URLByDeletingLastPathComponent].absoluteString;
    
    NSString *m3u8Path = [DownloadManager getM3U8LocalUrlWithVideoUrl:videoUrl];
//    NSString *m3u8Path = [DownloadManager getM3U8LocalUrlWithVideoName:self];
    
    NSString *tsPath;
    NSString *tmpTsFullPath;
    for (M3U8SegmentInfo *segment in self.segments)
    {
        
        tsPath = nil;
        tsPath = [NSString stringWithFormat:@"%@/%@",m3u8Path,segment.url.lastPathComponent];
        tsPath = [tsPath stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        segment.localUrl = tsPath;
        
        tmpTsFullPath = nil;
        tmpTsFullPath = [NSString stringWithFormat:@"%@%@",tsFullPath,segment.url.lastPathComponent];
        tmpTsFullPath = [tmpTsFullPath stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        segment.url = tmpTsFullPath;
    }
}

@end
