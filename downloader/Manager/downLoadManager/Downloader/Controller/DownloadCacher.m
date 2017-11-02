//
//  DownloadCacher.m
//  DownLoader
//
//  Created by bfec on 17/2/15.
//  Copyright © 2017年 com. All rights reserved.
//

#import "DownloadCacher.h"
#import "DownloadCacher+M3U8.h"
#import "DBManager.h"
static DownloadCacher *instance;
//#define DBName @"downloader.db"
#define DownloadCacherTable @"downloadCacherTable"

@interface DownloadCacher ()

@end

@implementation DownloadCacher

+ (id)shareInstance
{
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        instance = [[DownloadCacher alloc] init];
    });
    return instance;
}

- (id)init
{
    if (self = [super init])
    {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[DBManager shareInstance].dbQueue inDatabase:^(FMDatabase *db) {
                if ([db open])
                {
                    
                    DDLogInfo(@"open or create db successful...");
                    
                    NSString *createSql = [NSString stringWithFormat:@"create table if not exists %@ (id integer primary key autoincrement,downloadStatus integer,videoName text,videoUrl text,downloadPercent real,resumeData text,videoSize long)",DownloadCacherTable];
                    BOOL createResult = [db executeUpdate:createSql];
                    if (createResult)
                    {
                        DDLogInfo(@"create downloadCacherTable successful...");
                    }
                    else
                    {
                        DDLogInfo(@"uncreate downloadCacherTable...");
                    }
                }
                else
                {
                    DDLogInfo(@"unopen or uncreate db...");
                }
            }];
            
            [self createM3U8Table];
        });
    }
    return self;
}

- (DownloadStatus)queryDownloadStatusByModel:(DownloadModel *)downloadModel
{
    NSString *querySql = [NSString stringWithFormat:@"select downloadStatus from %@ where videoUrl = '%@'",DownloadCacherTable,downloadModel.url];
    __block BOOL isExist = NO;
    [[DBManager shareInstance].dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:querySql];
        if ([result next])
        {
            isExist = YES;
        }
        [result close];
    }];
    
    __block DownloadStatus status;
    __block DownloadModel *model = downloadModel;
    if (isExist)
    {
        [[DBManager shareInstance].dbQueue inDatabase:^(FMDatabase *db) {
            FMResultSet *result = [db executeQuery:querySql];
            while ([result next])
            {
                status = [result intForColumn:@"downloadStatus"];
                model.url = downloadModel.url;
                model.name = downloadModel.name;
                model.status = [result intForColumn:@"downloadStatus"];
                model.resumeData = [result stringForColumn:@"resumeData"];
                model.videoSize = [result intForColumn:@"videoSize"];
                break;
            }
            [result close];
        }];
    }
    else
        status = DownloadNotExist;
    
    return status;
}

- (void)insertDownloadModel:(DownloadModel *)downloadModel
{
    NSString *insertSql = [NSString stringWithFormat:@"insert into %@(downloadStatus,videoName,videoUrl,downloadPercent,resumeData,videoSize) values (%d,'%@','%@',%f,'%@',%ld)",DownloadCacherTable,downloadModel.status,downloadModel.name,downloadModel.url,downloadModel.downloadPercent,downloadModel.resumeData,downloadModel.videoSize];
    [[DBManager shareInstance].dbQueue inDatabase:^(FMDatabase *db) {
        BOOL result = [db executeUpdate:insertSql];
        if (result)
        {
            DDLogInfo(@"insert downloadCacherTable sucessful...");
        }
        else
        {
            DDLogInfo(@"insert downloadCacherTable failed...");
        }
        DDLogInfo(@"%@",downloadModel);
    }];
}

- (void)updateDownloadModel:(DownloadModel *)downloadModel
{
    NSString *updateSql;
    if (downloadModel.resumeData)
    {
        updateSql = [NSString stringWithFormat:@"update %@ set downloadStatus = %d,downloadPercent = %f,resumeData = '%@',videoSize = %ld where videoUrl = '%@'",DownloadCacherTable,downloadModel.status,downloadModel.downloadPercent,downloadModel.resumeData,downloadModel.videoSize,downloadModel.url];
    }
    else
    {
        updateSql = [NSString stringWithFormat:@"update %@ set downloadStatus = %d,downloadPercent = %f,videoSize = %ld where videoUrl = '%@'",DownloadCacherTable,downloadModel.status,downloadModel.downloadPercent,downloadModel.videoSize,downloadModel.url];
    }
    
    [[DBManager shareInstance].dbQueue inDatabase:^(FMDatabase *db) {
        BOOL result = [db executeUpdate:updateSql];
        if (result)
        {
            DDLogInfo(@"update downloadCacherTable sucessful...");
        }
        else
        {
            DDLogInfo(@"update downloadCacherTable failed...");
        }
        DDLogInfo(@"%@",downloadModel);
    }];
    
    NSString *querySql = [NSString stringWithFormat:@"select resumeData from %@ where videoUrl = '%@'",DownloadCacherTable,downloadModel.url];
    [[DBManager shareInstance].dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:querySql];
        while ([rs next])
        {
            //double percent = [rs doubleForColumn:@"downloadPercent"];
            //NSString *resumeData = [rs stringForColumn:@"resumeData"];
        }
        [rs close];
    }];
}

- (void)deleteDownloadModel:(DownloadModel *)downloadModel
{
    NSString *deleteSql = [NSString stringWithFormat:@"delete from %@ where videoUrl = '%@'",DownloadCacherTable,downloadModel.url];
    [[DBManager shareInstance].dbQueue inDatabase:^(FMDatabase *db) {
        BOOL result = [db executeUpdate:deleteSql];
        if (result)
        {
            DDLogInfo(@"delete downloadCacherTable sucessful...");
        }
        else
        {
            DDLogInfo(@"delete downloadCacherTable failed...");
        }
        DDLogInfo(@"%@",downloadModel);
    }];
}
- (DownloadModel *)queryTopDownloadingDownloadModel{
    NSString *querySql = [NSString stringWithFormat:@"select * from %@ where downloadStatus = %d",DownloadCacherTable,2];//正在进行的下载
    __block DownloadModel *downloadModel = nil;
    [[DBManager shareInstance].dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:querySql];
        if (result == nil)
        {
            
        }
        else
        {
            while ([result next])
            {
                DownloadStatus status = [result intForColumn:@"downloadStatus"];
                NSString *videoName = [result stringForColumn:@"videoName"];
                NSString *videoUrl = [result stringForColumn:@"videoUrl"];
                double downloadPercent = [result doubleForColumn:@"downloadPercent"];
                NSString *resumeData = [result stringForColumn:@"resumeData"];
                long videoSize = [result longForColumn:@"videoSize"];
                if ([resumeData isEqualToString:@"(null)"])
                {
                    resumeData = nil;
                }
                downloadModel = [[DownloadModel alloc] init];
                downloadModel.status = status;
                downloadModel.name = videoName;
                downloadModel.url = videoUrl;
                downloadModel.downloadPercent = downloadPercent;
                downloadModel.resumeData = resumeData;
                downloadModel.videoSize = videoSize;
                break;
            }
        }
        [result close];
    }];
    return downloadModel;
}
- (DownloadModel *)queryTopWaitingDownloadModel
{
    NSString *querySql = [NSString stringWithFormat:@"select * from %@ where downloadStatus = %d",DownloadCacherTable,0];//等待的下载
    __block DownloadModel *downloadModel = nil;
    [[DBManager shareInstance].dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:querySql];
        if (result == nil)
        {
            
        }
        else
        {
            while ([result next])
            {
                DownloadStatus status = [result intForColumn:@"downloadStatus"];
                NSString *videoName = [result stringForColumn:@"videoName"];
                NSString *videoUrl = [result stringForColumn:@"videoUrl"];
                double downloadPercent = [result doubleForColumn:@"downloadPercent"];
                NSString *resumeData = [result stringForColumn:@"resumeData"];
                long videoSize = [result longForColumn:@"videoSize"];
                if ([resumeData isEqualToString:@"(null)"])
                {
                    resumeData = nil;
                }
                downloadModel = [[DownloadModel alloc] init];
                downloadModel.status = status;
                downloadModel.name = videoName;
                downloadModel.url = videoUrl;
                downloadModel.downloadPercent = downloadPercent;
                downloadModel.resumeData = resumeData;
                downloadModel.videoSize = videoSize;
                break;
            }
        }
        [result close];
    }];
    return downloadModel;
}



//downloadStatus,videoName,videoUrl,downloadPercent,resumeData



- (void)getNewFromCacherWithModel:(DownloadModel *)downloadModel
{
    NSString *querySql = [NSString stringWithFormat:@"select downloadStatus,downloadPercent,resumeData,videoSize from %@ where videoUrl = '%@'",DownloadCacherTable,downloadModel.url];
    __block BOOL isExist = NO;
    [[DBManager shareInstance].dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:querySql];
        if ([result next])
        {
            isExist = YES;
        }
    }];
    
    __block DownloadModel *model = downloadModel;
    if (isExist)
    {
        [[DBManager shareInstance].dbQueue inDatabase:^(FMDatabase *db) {
            FMResultSet *result = [db executeQuery:querySql];
            while ([result next])
            {
                model.url = downloadModel.url;
                model.name = downloadModel.name;
                model.status = [result intForColumn:@"downloadStatus"];
                model.resumeData = [result stringForColumn:@"resumeData"];
                model.videoSize = [result longForColumn:@"videoSize"];
                break;
            }
            [result close];
        }];
    }
}



- (NSArray *)startAllDownloadModels
{
    NSString *updateSql = [NSString stringWithFormat:@"update %@ set downloadStatus = %d where downloadStatus = %d",DownloadCacherTable,0,1];
    NSString *updateFaildSql = [NSString stringWithFormat:@"update %@ set downloadStatus = %d where downloadStatus = %d",DownloadCacherTable,0,4];
    [[DBManager shareInstance].dbQueue inDatabase:^(FMDatabase *db) {
        BOOL result = [db executeUpdate:updateSql];
        [db executeUpdate:updateFaildSql];//开启失败的任务，加入等待状态
        if (result)
        {
            DDLogInfo(@"startAllDownloadModels successful...");
        }
        else
        {
            DDLogInfo(@"startAllDownloadModels failure...");
        }
    }];
    
    NSString *querySql = [NSString stringWithFormat:@"select * from %@ where downloadStatus = %d",DownloadCacherTable,0];//等待的下载
//    __block DownloadModel *downloadModel = nil;
    __block NSMutableArray *resultArray = [NSMutableArray array];
    [[DBManager shareInstance].dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:querySql];
        if (result == nil)
        {
            
        }
        else
        {
            while ([result next])
            {
                DownloadStatus status = [result intForColumn:@"downloadStatus"];
                NSString *videoName = [result stringForColumn:@"videoName"];
                NSString *videoUrl = [result stringForColumn:@"videoUrl"];
                double downloadPercent = [result doubleForColumn:@"downloadPercent"];
                NSString *resumeData = [result stringForColumn:@"resumeData"];
                long videoSize = [result longForColumn:@"videoSize"];
                if ([resumeData isEqualToString:@"(null)"])
                {
                    resumeData = nil;
                }
                DownloadModel *downloadModel = [[DownloadModel alloc] init];
                downloadModel.status = status;
                downloadModel.name = videoName;
                downloadModel.url = videoUrl;
                downloadModel.downloadPercent = downloadPercent;
                downloadModel.resumeData = resumeData;
                downloadModel.videoSize = videoSize;
                [resultArray addObject:downloadModel];
            }
        }
        [result close];
    }];
    
    return resultArray;
}
-(NSArray *)allDownloadingModels{
    NSString *querySql = [NSString stringWithFormat:@"select * from %@ where downloadStatus <> %d",DownloadCacherTable,3];//未完成的下载
//    __block DownloadModel *downloadModel = nil;
    __block NSMutableArray *resultArray = [NSMutableArray array];
    [[DBManager shareInstance].dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:querySql];
        if (result == nil)
        {
            
        }
        else
        {
            while ([result next])
            {
                DownloadStatus status = [result intForColumn:@"downloadStatus"];
                NSString *videoName = [result stringForColumn:@"videoName"];
                NSString *videoUrl = [result stringForColumn:@"videoUrl"];
                double downloadPercent = [result doubleForColumn:@"downloadPercent"];
                NSString *resumeData = [result stringForColumn:@"resumeData"];
                long videoSize = [result longForColumn:@"videoSize"];
                if ([resumeData isEqualToString:@"(null)"])
                {
                    resumeData = nil;
                }
                DownloadModel *downloadModel = [[DownloadModel alloc] init];
                downloadModel.status = status;
                downloadModel.name = videoName;
                downloadModel.url = videoUrl;
                downloadModel.downloadPercent = downloadPercent;
                downloadModel.resumeData = resumeData;
                downloadModel.videoSize = videoSize;
                [resultArray addObject:downloadModel];
            }
        }
        [result close];
    }];
    
    return resultArray;
}
- (NSArray *)pauseAllDownloadModels
{
    NSString *updateSql = [NSString stringWithFormat:@"update %@ set downloadStatus = %d where downloadStatus = %d",DownloadCacherTable,1,0];
    [[DBManager shareInstance].dbQueue inDatabase:^(FMDatabase *db) {
        BOOL result = [db executeUpdate:updateSql];
        if (result)
        {
            DDLogInfo(@"pauseAllDownloadModels successful...");
        }
        else
        {
            DDLogInfo(@"pauseAllDownloadModels failure...");
        }
    }];
    
    NSString *querySql = [NSString stringWithFormat:@"select * from %@ where downloadStatus = %d",DownloadCacherTable,1];//暂停的下载
//    __block DownloadModel *downloadModel = nil;
    __block NSMutableArray *resultArray = [NSMutableArray array];
    [[DBManager shareInstance].dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:querySql];
        if (result == nil)
        {
            
        }
        else
        {
            while ([result next])
            {
                DownloadStatus status = [result intForColumn:@"downloadStatus"];
                NSString *videoName = [result stringForColumn:@"videoName"];
                NSString *videoUrl = [result stringForColumn:@"videoUrl"];
                double downloadPercent = [result doubleForColumn:@"downloadPercent"];
                NSString *resumeData = [result stringForColumn:@"resumeData"];
                long videoSize = [result longForColumn:@"videoSize"];
                if ([resumeData isEqualToString:@"(null)"])
                {
                    resumeData = nil;
                }
                DownloadModel *downloadModel = [[DownloadModel alloc] init];
                downloadModel.status = status;
                downloadModel.name = videoName;
                downloadModel.url = videoUrl;
                downloadModel.downloadPercent = downloadPercent;
                downloadModel.resumeData = resumeData;
                downloadModel.videoSize = videoSize;
                [resultArray addObject:downloadModel];
            }
        }
        [result close];
    }];

    return resultArray;
}

- (void)deleteDownloadModels:(NSArray *)downloadModels
{
    for (DownloadModel *downloadModel in downloadModels)
    {
        [self deleteDownloadModel:downloadModel];
    }
}




- (void)initializeDownloadModelFromDBCahcher:(DownloadModel *)downloadModel
{
    NSString *querySql = [NSString stringWithFormat:@"select * from %@ where videoUrl = '%@'",DownloadCacherTable,downloadModel.url];//暂停的下载
    __block DownloadModel *weakModel = downloadModel;
    [[DBManager shareInstance].dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:querySql];
        if (result == nil)
        {
            
        }
        else
        {
            while ([result next])
            {
                DownloadStatus status = [result intForColumn:@"downloadStatus"];
                NSString *videoName = [result stringForColumn:@"videoName"];
                NSString *videoUrl = [result stringForColumn:@"videoUrl"];
                double downloadPercent = [result doubleForColumn:@"downloadPercent"];
                NSString *resumeData = [result stringForColumn:@"resumeData"];
                if ([resumeData isEqualToString:@"(null)"])
                {
                    resumeData = nil;
                }
                weakModel.status = status;
                weakModel.name = videoName;
                weakModel.url = videoUrl;
                weakModel.downloadPercent = downloadPercent;
                weakModel.resumeData = resumeData;
                break;
            }
        }
        [result close];
    }];

}

- (BOOL)checkIsExistOfUrl:(NSString *)urlStr{
    NSString *querySql = [NSString stringWithFormat:@"select * from %@ where videoUrl = '%@'",DownloadCacherTable,urlStr];//是否有这个下载
    __block BOOL exist = NO;
    [[DBManager shareInstance].dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:querySql];
        if (result == nil) {
            exist = NO;
        }
        while ([result next])
        {
            exist = YES;
        }
        [result close];
    }];
    return exist;
}


- (BOOL)checkIsExistDownloading
{
    NSString *querySql = [NSString stringWithFormat:@"select * from %@ where downloadStatus = %d",DownloadCacherTable,2];//正在下载
    __block BOOL exist = NO;
    [[DBManager shareInstance].dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:querySql];
       
        while ([result next])
        {
            exist = YES;
        }
        [result close];
    }];
    return exist;
}













@end
