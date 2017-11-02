//
//  UserDefaultManager.m
//  XYWProject
//
//  Created by xueyognwei on 2017/3/13.
//  Copyright © 2017年 薛永伟. All rights reserved.
//

#import "UserDefaultManager.h"
static NSString *const kSearchEngine = @"kSearchEngine";
static NSString *const kOnlyDownloadWhenWifi = @"kOnlyDownloadWhenWifi";
@implementation UserDefaultManager
/**
 搜索引擎设置
 */
+(SearchEngine)currentSearchEngine{
    NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
    return [usf integerForKey:kSearchEngine];
}
+(NSString *)searchEngineUrlWith:(NSString *)searchContent{
    searchContent = [searchContent stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    switch ([self currentSearchEngine]) {
        case SearchEngineGoogle:
        {
            return [@"https://www.google.com/#q=" stringByAppendingString:searchContent];
        }
            break;
        case SearchEngineYouTube:
        {
            return [@"https://www.youtube.com/results?search_query=" stringByAppendingString:searchContent];
        }
            break;case SearchEngineBing:
        {
            return [@"http://cn.bing.com/search?q=" stringByAppendingString:searchContent];
        }
            break;
        default:
            return nil;
            break;
    }
    return nil;
}
+(void)setSearchEngine:(SearchEngine)searchEngine{
    NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
    [usf setInteger:searchEngine forKey:kSearchEngine];
}
/**
 只在Wi-Fi下下载
 */
+(void)setOnlyDownloadWhenWIFI:(BOOL)only{
    NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
    [usf setBool:only forKey:kOnlyDownloadWhenWifi];
}
+(BOOL)isOnlyDownloadWhenWIFI{
    return [[NSUserDefaults standardUserDefaults]boolForKey:kOnlyDownloadWhenWifi];
}


/**
 用户退出时需要清理的信息
 */
+(void)CleanWithlogOut
{

}

//好评
+(BOOL)have5Stars{
    NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
    BOOL have5Stars = [usf boolForKey:@"user5stars"];
    return have5Stars;
}
+(void)set5StarsDone{
    NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
    [usf setBool:YES forKey:@"user5stars"];
    [usf synchronize];
}


//访问黑名单
+(NSDictionary *)visitBlackList{
    NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
    return [usf objectForKey:@"blackListDomains"];
}
+(void)setVisitBlackList:(NSDictionary *)visitBlackList{
    NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
    [usf setObject:visitBlackList forKey:@"blackListDomains"];
    [usf synchronize];
}

//IP信息
+(NSDictionary *)deviceIPInfo{
    NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
    return [usf objectForKey:@"deviceIPInfo"];
}
+(void)setdeviceIPInfo:(NSDictionary *)IPInfo{
    NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
    [usf setObject:IPInfo forKey:@"deviceIPInfo"];
    [usf synchronize];
}

//server广告
+(NSDictionary *)localServerAD{
    NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
    return [usf objectForKey:@"localServerAD"];
}
+(void)saveLocalServerAD:(NSDictionary *)dic{
    NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
    [usf setObject:dic forKey:@"localServerAD"];
    [usf synchronize];
}
//serverAD显示次数
+(BOOL)timeToShow5Stars{
    NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
    NSInteger times =[usf integerForKey:@"timesToShowAD"];
    times ++;
    if (times == 4) {
        times =0;
        [usf setInteger:times forKey:@"timesToShowAD"];
        [usf synchronize];
        return YES;
    }else{
        [usf setInteger:times forKey:@"timesToShowAD"];
        [usf synchronize];
        return NO;
    }
}
+(void)resetTimesOfShow5Stars{
    NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
    [usf setInteger:0 forKey:@"timesToShowAD"];
    [usf synchronize];
}
@end



