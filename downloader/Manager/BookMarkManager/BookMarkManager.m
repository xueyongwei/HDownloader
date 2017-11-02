//
//  BookMarkManager.m
//  downloader
//
//  Created by xueyognwei on 2017/3/30.
//  Copyright © 2017年 xueyognwei. All rights reserved.
//

#import "BookMarkManager.h"
#import "DBManager.h"
#define BookMarksTable @"bookMarksTable"
#define haveInitBookmarks @"haveInitBookmarks"
#define NormalBookmarks @"NormalBookmarks"
#define FavouroteBookmarks @"FavouroteBookmarks"
@implementation BookMarkManager
/**
 创建单例
 
 @return 返回实例
 */
+(instancetype)shareInstance
{
    static BookMarkManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc]init];
    });
    return sharedInstance;
}
- (id)init
{
    if (self = [super init])
    {
        
    }
    return self;
}
-(void)defauldConfig{
    [self initSqlite];
    DDLogInfo(@"initSqlite");
    //        [self usfInit];
}

- (void)insertBookMarkModel:(BookMarketModel *)model
{
    [self sqlInsertBookMarkModel:model];
}
- (void)deleteBookMarkModel:(BookMarketModel *)model
{
    [self sqlDeleteBookMarkModel:model];
    
}
- (void)updateBookMarkModel:(BookMarketModel *)model
{
    [self sqlUpdateBookMarkModel:model];
    
}
-(void)reSortBookMarkModels:(NSArray *)models{
    [self sqlReSortBookMarkModels:models];
    
}
-(NSArray *)queryAllbookMarksOfType:(BookMarketType)type{
    return [self sqlQueryAllbookMarksOfType:type];
}

#pragma mark -- SQLITE
-(void)initSqlite
{
    [[DBManager shareInstance].dbQueue inDatabase:^(FMDatabase *db) {
        if ([db open])
        {
            DDLogInfo(@"open or create db successful...");
            NSString *createSql = [NSString stringWithFormat:@"create table if not exists %@ (id integer primary key autoincrement,webName text,webUrl text,isFavourite INTEGER,sortIndex INTEGER)",BookMarksTable];
            BOOL createResult = [db executeUpdate:createSql];
            if (createResult)
            {
                DDLogInfo(@"create downloadCacherTable successful...");
                NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
                if ([usf boolForKey:haveInitBookmarks]) {
                    DDLogInfo(@"已初始化，不再添加推荐网站");
                    return;
                }
                DDLogInfo(@"初始化，添加推荐网站..");
                
                {
                    NSString *insertSql = [NSString stringWithFormat:@"insert into %@(webName,webUrl,isFavourite,sortIndex) values ('%@','%@',1,1)",BookMarksTable,@"YouTube",@"https://youtube.com"];
                    BOOL result = [db executeUpdate:insertSql];
                    DDLogInfo(@"insert downloadCacherTable sucessful ?  %d",result);
                }
                {
                    NSString *insertSql = [NSString stringWithFormat:@"insert into %@(webName,webUrl,isFavourite,sortIndex) values ('%@','%@',1,2)",BookMarksTable,@"viewster",@"http://www.viewster.com"];
                    BOOL result = [db executeUpdate:insertSql];
                    DDLogInfo(@"insert downloadCacherTable sucessful ?  %d",result);
                }
                {
                    NSString *insertSql = [NSString stringWithFormat:@"insert into %@(webName,webUrl,isFavourite,sortIndex) values ('%@','%@',1,3)",BookMarksTable,@"LiveLeak",@"https://www.liveleak.com"];
                    BOOL result = [db executeUpdate:insertSql];
                    DDLogInfo(@"insert downloadCacherTable sucessful ?  %d",result);
                }
                {
                    NSString *insertSql = [NSString stringWithFormat:@"insert into %@(webName,webUrl,isFavourite,sortIndex) values ('%@','%@',1,4)",BookMarksTable,@"Vine",@"https://vine.co"];
                    BOOL result = [db executeUpdate:insertSql];
                    DDLogInfo(@"insert downloadCacherTable sucessful ?  %d",result);
                }
                {
                    NSString *insertSql = [NSString stringWithFormat:@"insert into %@(webName,webUrl,isFavourite,sortIndex) values ('%@','%@',1,5)",BookMarksTable,@"9GAG",@"http://9gag.com/tv"];
                    BOOL result = [db executeUpdate:insertSql];
                    DDLogInfo(@"insert downloadCacherTable sucessful ?  %d",result);
                }
                {
                    NSString *insertSql = [NSString stringWithFormat:@"insert into %@(webName,webUrl,isFavourite,sortIndex) values ('%@','%@',1,6)",BookMarksTable,@"Facebook",@"https://www.facebook.com"];
                    BOOL result = [db executeUpdate:insertSql];
                    DDLogInfo(@"insert downloadCacherTable sucessful ?  %d",result);
                }
                {
                    NSString *insertSql = [NSString stringWithFormat:@"insert into %@(webName,webUrl,isFavourite,sortIndex) values ('%@','%@',1,7)",BookMarksTable,@"Instagram",@"https://www.instagram.com"];
                    BOOL result = [db executeUpdate:insertSql];
                    DDLogInfo(@"insert downloadCacherTable sucessful ?  %d",result);
                }
                {
                    NSString *insertSql = [NSString stringWithFormat:@"insert into %@(webName,webUrl,isFavourite,sortIndex) values ('%@','%@',1,8)",BookMarksTable,@"Tumblr",@"https://www.tumblr.com"];
                    BOOL result = [db executeUpdate:insertSql];
                    DDLogInfo(@"insert downloadCacherTable sucessful ?  %d",result);
                }
                [usf setBool:YES forKey:haveInitBookmarks];
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
}
- (void)sqlInsertBookMarkModel:(BookMarketModel *)model
{
    NSString *countSql =@"";
    if (model.isFavourite) {
        countSql = [NSString stringWithFormat:@"select count(*) from %@ where isFavourite = %d",BookMarksTable,1];//fav的书签
    }else{
        countSql = [NSString stringWithFormat:@"select count(*) from %@ where isFavourite <> %d",BookMarksTable,1];//normal书签
    }
    [[DBManager shareInstance].dbQueue inDatabase:^(FMDatabase *db) {
        NSUInteger count = [db intForQuery:countSql];
        NSString *insertSql = [NSString stringWithFormat:@"insert into %@(webName,webUrl,isFavourite,sortIndex) values ('%@','%@',%ld,%lu)",BookMarksTable,model.title,model.url,model.isFavourite,count+1];
        BOOL result = [db executeUpdate:insertSql];
        DDLogInfo(@"insert downloadCacherTable sucessful ?  %d",result);
    }];
}
- (void)sqlDeleteBookMarkModel:(BookMarketModel *)model
{
    NSString *deleteSql = [NSString stringWithFormat:@"delete from %@ where id = %ld",BookMarksTable,(long)model.modelID];
    [[DBManager shareInstance].dbQueue inDatabase:^(FMDatabase *db) {
        BOOL result = [db executeUpdate:deleteSql];
        DDLogInfo(@"delete %@ ..",model);
        if (result)
        {
            DDLogInfo(@"delete downloadCacherTable sucessful...");
        }
        else
        {
            DDLogInfo(@"delete downloadCacherTable failed...");
        }
    }];
}
- (void)sqlUpdateBookMarkModel:(BookMarketModel *)model
{
    NSString *insertSql = [NSString stringWithFormat:@"update %@ set webName = '%@',webUrl = '%@',isFavourite = %ld ,sortIndex = %ld where id = %ld",BookMarksTable,model.title,model.url,(long)model.isFavourite,model.index,model.modelID];
    [[DBManager shareInstance].dbQueue inDatabase:^(FMDatabase *db) {
        BOOL result = [db executeUpdate:insertSql];
        DDLogInfo(@"insert %@",model);
        if (result)
        {
            DDLogInfo(@"update downloadCacherTable sucessful...");
        }
        else
        {
            DDLogInfo(@"update downloadCacherTable failed...");
        }
    }];
}

/**
 按照数组的顺序向数据库排序

 @param models 数组内容
 */
-(void)sqlReSortBookMarkModels:(NSArray *)models{
    [[DBManager shareInstance].dbQueue inDatabase:^(FMDatabase *db) {
        for (NSInteger i = 0; i<models.count; i++) {
            BookMarketModel *model = models[i];
            NSString *updateSql = [NSString stringWithFormat:@"update %@ set webName = '%@',webUrl = '%@',isFavourite = %ld ,sortIndex = %ld where id = %ld",BookMarksTable,model.title,model.url,(long)model.isFavourite,i,model.modelID];
            BOOL result = [db executeUpdate:updateSql];
            DDLogInfo(@"update downloadCacherTable sucessful ?  %d",result);
        }
    }];
}
-(NSArray *)sqlQueryAllbookMarksOfType:(BookMarketType)type{
    
    NSString *querySql = @"";
    // asc 升序 desc降序
    if (type == BookMarketTypeFavourite) {
        querySql = [NSString stringWithFormat:@"select * from %@ where isFavourite = %d ORDER BY sortIndex asc",BookMarksTable,1];//是fav
    }else if (type == BookMarketTypeNormal) {
        querySql = [NSString stringWithFormat:@"select * from %@ where isFavourite <> %d ORDER BY sortIndex asc",BookMarksTable,1];//不是fav
    } else if (type == (BookMarketTypeNormal|BookMarketTypeFavourite)) {
        querySql = [NSString stringWithFormat:@"select * from %@ ORDER BY sortIndex asc",BookMarksTable];//未完成的下载
    }
//    __block BookMarketModel *model = nil;
    __block NSMutableArray *resultArray = [NSMutableArray array];
    [[DBManager shareInstance].dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:querySql];
        if (result == nil)
        {
            DDLogInfo(@"no resultes ");
        }
        else
        {
            
            DDLogInfo(@"resulets %@ count %d",result,result.columnCount);
            while ([result next])
            {
                NSString *webName = [result stringForColumn:@"webName"];
                NSString *webUrl = [result stringForColumn:@"webUrl"];
                NSInteger isFavourite = [result longForColumn:@"isFavourite"];
                NSInteger modelID = [result longForColumn:@"id"];
                BookMarketModel *model = [[BookMarketModel alloc] init];
                model.title = webName;
                model.url = webUrl;
                model.isFavourite = isFavourite;
                model.modelID = modelID;
                [resultArray addObject:model];
                
                DDLogInfo(@"querySql = %@\nresultArray = %@",querySql,resultArray);
            }
        }
        [result close];
        
    }];
    DDLogInfo(@"querySql = %@\nresultArray = %@",querySql,resultArray);
    return resultArray;
}

#pragma mark -- USERDEFAULT
-(void)usfInit{
    NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
    if (![usf boolForKey:haveInitBookmarks]) {
        NSArray *favoutites = [self defaultFavouriteBookMark];
        [usf setObject:favoutites forKey:FavouroteBookmarks];
    }
}
-(NSArray *)defaultFavouriteBookMark
{
    NSMutableArray *arr = [NSMutableArray new];
    {
        BookMarketModel *model = [[BookMarketModel alloc]init];
        model.title = @"YouTube";
        model.url = @"https://youtube.com";
        model.isFavourite = 1;
        model.index = 1;
        [arr addObject:model];
    }
    {
        BookMarketModel *model = [[BookMarketModel alloc]init];
        model.title = @"viewster";
        model.url = @"http://www.viewster.com";
        model.isFavourite = 1;
        model.index = 2;
        [arr addObject:model];
    }
    {
        BookMarketModel *model = [[BookMarketModel alloc]init];
        model.title = @"LiveLeak";
        model.url = @"https://www.liveleak.com";
        model.isFavourite = 1;
        model.index = 3;
        [arr addObject:model];
    }
    {
        BookMarketModel *model = [[BookMarketModel alloc]init];
        model.title = @"Vine";
        model.url = @"https://vine.co";
        model.isFavourite = 1;
        model.index = 4;
        [arr addObject:model];
    }
    {
        BookMarketModel *model = [[BookMarketModel alloc]init];
        model.title = @"9GAG";
        model.url = @"http://9gag.com/tv";
        model.isFavourite = 1;
        model.index = 5;
        [arr addObject:model];
    }
    {
        BookMarketModel *model = [[BookMarketModel alloc]init];
        model.title = @"Facebook";
        model.url = @"https://www.facebook.com";
        model.isFavourite = 1;
        model.index = 6;
        [arr addObject:model];
    }
    {
        BookMarketModel *model = [[BookMarketModel alloc]init];
        model.title = @"Instagram";
        model.url = @"https://www.instagram.com";
        model.isFavourite = 1;
        model.index = 7;
        [arr addObject:model];
    }
    {
        BookMarketModel *model = [[BookMarketModel alloc]init];
        model.title = @"Tumblr";
        model.url = @"https://www.tumblr.com";
        model.isFavourite = 1;
        model.index = 8;
        [arr addObject:model];
    }
    
    return [NSArray arrayWithArray:arr];
}
-(void)usfInsertBookMarkModel:(BookMarketModel *)model{
//    NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
//    if (model.isFavourite) {
//        
//    }
}
@end
