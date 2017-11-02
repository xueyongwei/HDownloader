//
//  DBManager.m
//  downloader
//
//  Created by xueyognwei on 2017/4/20.
//  Copyright © 2017年 xueyognwei. All rights reserved.
//

#import "DBManager.h"

@implementation DBManager
/**
 创建单例
 
 @return 返回实例
 */
+(instancetype)shareInstance
{
    static DBManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc]init];
        NSString *dbPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"downloader.db"];
        sharedInstance.dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    });
    return sharedInstance;
}

@end
