//
//  M3U8TopSegmentInfo.m
//  DownLoader
//
//  Created by xueyognwei on 2017/4/26.
//  Copyright © 2017年 com. All rights reserved.
//

#import "M3U8TopSegmentInfo.h"

@implementation M3U8TopSegmentInfo
-(NSString *)description
{
    return [NSString stringWithFormat:@"%@:bandwidth=%@,url=%@",self,self.BANDWIDTH,self.url];
}
@end
