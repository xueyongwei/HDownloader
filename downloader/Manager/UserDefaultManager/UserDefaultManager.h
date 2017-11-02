//
//  UserDefaultManager.h
//  XYWProject
//
//  Created by xueyognwei on 2017/3/13.
//  Copyright © 2017年 薛永伟. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SearchEngine) {
    SearchEngineGoogle ,
    SearchEngineYouTube ,
    SearchEngineBing ,
};
@interface UserDefaultManager : NSObject

//搜索引擎
+(SearchEngine)currentSearchEngine;
+(void)setSearchEngine:(SearchEngine)searchEngine;
+(NSString *)searchEngineUrlWith:(NSString *)searchContent;

//Wi-Fi自动下载
+(void)setOnlyDownloadWhenWIFI:(BOOL)only;
+(BOOL)isOnlyDownloadWhenWIFI;

//5星好评
+(BOOL)have5Stars;
+(void)set5StarsDone;

//访问黑名单
+(NSDictionary *)visitBlackList;
+(void)setVisitBlackList:(NSDictionary *)visitBlackList;

//IP信息
+(NSDictionary *)deviceIPInfo;
+(void)setdeviceIPInfo:(NSDictionary *)IPInfo;

//server广告
+(NSDictionary *)localServerAD;
+(void)saveLocalServerAD:(NSDictionary *)dic;

//serverAD显示次数

/**
 serverAD显示次数，每次启动仅可调用一次

 @return 是否该显示5星弹窗
 */
+(BOOL)timeToShow5Stars;

/**
 重制显示5星弹窗的此时
 */
+(void)resetTimesOfShow5Stars;

/**
 用户退出时需要清理的信息
 */
+(void)CleanWithlogOut;
@end
