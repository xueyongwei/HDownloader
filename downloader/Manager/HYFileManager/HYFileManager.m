//
//  HYFileManager.m
//  HYFileManager
//
//  Created by work on 15/9/30.
//  Copyright © 2015年 Hyyy. All rights reserved.
//

#import "HYFileManager.h"
#import "DownloadManager+Utils.h"
@interface HYFileManager()

@property (strong, nonatomic) NSFileManager *manager;

@end

@implementation HYFileManager

#pragma mark - 沙盒目录相关
+ (NSString *)homeDir {
    return NSHomeDirectory();
}

+ (NSString *)documentsDir {
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}

+ (NSString *)libraryDir {
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];;
}

+ (NSString *)preferencesDir {
    NSString *libraryDir = [self libraryDir];
    return [libraryDir stringByAppendingPathComponent:@"Preferences"];
}

+ (NSString *)cachesDir {
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
}

+ (NSString *)tmpDir {
    return NSTemporaryDirectory();
}
#pragma mark - 遍历文件夹
+ (NSArray *)listFilesInDirectoryAtPath:(NSString *)path deep:(BOOL)deep {
    NSArray *listArr;
    NSError *error;
    NSFileManager *manager = [NSFileManager defaultManager];
    if (deep) {
        // 深遍历
        NSArray *deepArr = [manager subpathsOfDirectoryAtPath:path error:&error];
        if (!error) {
            listArr = deepArr;
        }else {
            listArr = nil;
        }
    }else {
        // 浅遍历
        NSArray *shallowArr = [manager contentsOfDirectoryAtPath:path error:&error];
        if (!error) {
            listArr = shallowArr;
        }else {
            listArr = nil;
        }
    }
    return listArr;
}

+ (NSArray *)listFilesInHomeDirectoryByDeep:(BOOL)deep {
    return [self listFilesInDirectoryAtPath:[self homeDir] deep:deep];
}

+ (NSArray *)listFilesInLibraryDirectoryByDeep:(BOOL)deep {
    return [self listFilesInDirectoryAtPath:[self libraryDir] deep:deep];
}

+ (NSArray *)listFilesInDocumentDirectoryByDeep:(BOOL)deep {
    return [self listFilesInDirectoryAtPath:[self documentsDir] deep:deep];
}

+ (NSArray *)listFilesInTmpDirectoryByDeep:(BOOL)deep {
    return [self listFilesInDirectoryAtPath:[self tmpDir] deep:deep];
}

+ (NSArray *)listFilesInCachesDirectoryByDeep:(BOOL)deep {
    return [self listFilesInDirectoryAtPath:[self cachesDir] deep:deep];
}

#pragma mark - 获取文件属性
+ (id)attributeOfItemAtPath:(NSString *)path forKey:(NSString *)key {
    return [[self attributesOfItemAtPath:path] objectForKey:key];
}

+ (id)attributeOfItemAtPath:(NSString *)path forKey:(NSString *)key error:(NSError *__autoreleasing *)error {
    return [[self attributesOfItemAtPath:path error:error] objectForKey:key];
}

+ (NSDictionary *)attributesOfItemAtPath:(NSString *)path {
    return [self attributesOfItemAtPath:path error:nil];
}

+ (NSDictionary *)attributesOfItemAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    return [[NSFileManager defaultManager] attributesOfItemAtPath:path error:error];
}

#pragma mark - 创建文件(夹)
+ (BOOL)createDirectoryAtPath:(NSString *)path {
    return [self createDirectoryAtPath:path error:nil];
}

+ (BOOL)createDirectoryAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isSuccess = [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:error];
    return isSuccess;
}

+ (BOOL)createFileAtPath:(NSString *)path {
    return [self createFileAtPath:path content:nil overwrite:YES error:nil];
}

+ (BOOL)createFileAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    return [self createFileAtPath:path content:nil overwrite:YES error:error];
}

+ (BOOL)createFileAtPath:(NSString *)path overwrite:(BOOL)overwrite {
    return [self createFileAtPath:path content:nil overwrite:overwrite error:nil];
}

+ (BOOL)createFileAtPath:(NSString *)path overwrite:(BOOL)overwrite error:(NSError *__autoreleasing *)error {
    return [self createFileAtPath:path content:nil overwrite:overwrite error:error];
}

+ (BOOL)createFileAtPath:(NSString *)path content:(NSObject *)content {
    return [self createFileAtPath:path content:content overwrite:YES error:nil];
}

+ (BOOL)createFileAtPath:(NSString *)path content:(NSObject *)content error:(NSError *__autoreleasing *)error {
    return [self createFileAtPath:path content:content overwrite:YES error:error];
}

+ (BOOL)createFileAtPath:(NSString *)path content:(NSObject *)content overwrite:(BOOL)overwrite {
    return [self createFileAtPath:path content:content overwrite:overwrite];
}

+ (BOOL)createFileAtPath:(NSString *)path content:(NSObject *)content overwrite:(BOOL)overwrite error:(NSError *__autoreleasing *)error {
    // 如果文件夹路径不存在，那么先创建文件夹
    NSString *directoryPath = [self directoryAtPath:path];
    if (![self isExistsAtPath:directoryPath]) {
        // 创建文件夹
        if (![self createDirectoryAtPath:directoryPath error:error]) {
            return NO;
        }
    }
    // 如果文件存在，并不想覆盖，那么直接返回YES。
    if (!overwrite) {
        if ([self isExistsAtPath:path]) {
            return YES;
        }
    }
    // 创建文件
    BOOL isSuccess = [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
    if (content) {
        [self writeFileAtPath:path content:content error:error];
    }
    return isSuccess;
}

+ (NSDate *)creationDateOfItemAtPath:(NSString *)path {
    return [self creationDateOfItemAtPath:path error:nil];
}

+ (NSDate *)creationDateOfItemAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    return (NSDate *)[self attributeOfItemAtPath:path forKey:NSFileCreationDate error:error];
}

+ (NSDate *)modificationDateOfItemAtPath:(NSString *)path {
    return [self modificationDateOfItemAtPath:path error:nil];
}

+ (NSDate *)modificationDateOfItemAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    return (NSDate *)[self attributeOfItemAtPath:path forKey:NSFileModificationDate error:error];
}

#pragma mark - 删除文件(夹)
+ (BOOL)removeItemAtPath:(NSString *)path {
    return [self removeItemAtPath:path error:nil];
}

+ (BOOL)removeItemAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    return [[NSFileManager defaultManager] removeItemAtPath:path error:error];
}

+ (BOOL)clearCachesDirectory {
    NSArray *subFiles = [self listFilesInCachesDirectoryByDeep:NO];
    BOOL isSuccess = YES;
    
    for (NSString *file in subFiles) {
        NSString *absolutePath = [[self cachesDir] stringByAppendingPathComponent:file];
        isSuccess &= [self removeItemAtPath:absolutePath];
    }
    return isSuccess;
}

+ (BOOL)clearTmpDirectory {
    NSArray *subFiles = [self listFilesInTmpDirectoryByDeep:NO];
    BOOL isSuccess = YES;
    
    for (NSString *file in subFiles) {
        NSString *absolutePath = [[self tmpDir] stringByAppendingPathComponent:file];
        isSuccess &= [self removeItemAtPath:absolutePath];
    }
    return isSuccess;
}

#pragma mark - 复制文件(夹)
+ (BOOL)copyItemAtPath:(NSString *)path toPath:(NSString *)toPath {
    return [self copyItemAtPath:path toPath:toPath overwrite:NO error:nil];
}

+ (BOOL)copyItemAtPath:(NSString *)path toPath:(NSString *)toPath error:(NSError *__autoreleasing *)error {
    return [self copyItemAtPath:path toPath:toPath overwrite:NO error:error];
}

+ (BOOL)copyItemAtPath:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite {
    return [self copyItemAtPath:path toPath:toPath overwrite:overwrite error:nil];
}

+ (BOOL)copyItemAtPath:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite error:(NSError *__autoreleasing *)error {
    // 先要保证源文件路径存在，不然抛出异常
    if (![self isExistsAtPath:path]) {
        [NSException raise:@"非法的源文件路径" format:@"源文件路径%@不存在，请检查源文件路径", path];
        return NO;
    }
    NSString *toDirPath = [self directoryAtPath:toPath];
    if (![self isExistsAtPath:toDirPath]) {
        // 创建复制路径
        if (![self createDirectoryAtPath:toDirPath error:error]) {
            return NO;
        }
    }
    // 如果覆盖，那么先删掉原文件
    if (overwrite) {
        if ([self isExistsAtPath:toPath]) {
            [self removeItemAtPath:toPath error:error];
        }
    }
    // 复制文件
    BOOL isSuccess = [[NSFileManager defaultManager] copyItemAtPath:path toPath:toPath error:error];
    
    return isSuccess;
}

#pragma mark - 移动文件(夹)
+ (BOOL)moveItemAtPath:(NSString *)path toPath:(NSString *)toPath {
    return [self moveItemAtPath:path toPath:toPath overwrite:NO error:nil];
}

+ (BOOL)moveItemAtPath:(NSString *)path toPath:(NSString *)toPath error:(NSError *__autoreleasing *)error {
    return [self moveItemAtPath:path toPath:toPath overwrite:NO error:error];
}

+ (BOOL)moveItemAtPath:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite {
    return [self moveItemAtPath:path toPath:toPath overwrite:overwrite error:nil];
}

+ (BOOL)moveItemAtPath:(NSString *)path toPath:(NSString *)toPath overwrite:(BOOL)overwrite error:(NSError *__autoreleasing *)error {
    // 先要保证源文件路径存在，不然抛出异常
    if (![self isExistsAtPath:path]) {
        [NSException raise:@"非法的源文件路径" format:@"源文件路径%@不存在，请检查源文件路径", path];
        return NO;
    }
    NSString *toDirPath = [self directoryAtPath:toPath];
    if (![self isExistsAtPath:toDirPath]) {
        // 创建移动路径
        if (![self createDirectoryAtPath:toDirPath error:error]) {
            return NO;
        }
    }
    // 如果覆盖，那么先删掉原文件
    if ([self isExistsAtPath:toPath]) {
        if (overwrite) {
            [self removeItemAtPath:toPath error:error];
        }else {
            [self removeItemAtPath:path error:error];
            return YES;
        }
    }
    
    // 移动文件
    BOOL isSuccess = [[NSFileManager defaultManager] moveItemAtPath:path toPath:toPath error:error];
    
    return isSuccess;
}

#pragma mark - 根据URL获取文件名
+ (NSString *)fileNameAtPath:(NSString *)path suffix:(BOOL)suffix {
    NSString *fileName = [path lastPathComponent];
    if (!suffix) {
        fileName = [fileName stringByDeletingPathExtension];
    }
    return fileName;
}

+ (NSString *)directoryAtPath:(NSString *)path {
    return [path stringByDeletingLastPathComponent];
}

+ (NSString *)suffixAtPath:(NSString *)path {
    return [path pathExtension];
}

#pragma mark - 判断文件(夹)是否存在
+ (BOOL)isExistsAtPath:(NSString *)path {
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+ (BOOL)isEmptyItemAtPath:(NSString *)path {
    return [self isEmptyItemAtPath:path error:nil];
}

+ (BOOL)isEmptyItemAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    return ([self isFileAtPath:path error:error] &&
            [[self sizeOfItemAtPath:path error:error] intValue] == 0) ||
    ([self isDirectoryAtPath:path error:error] &&
     [[self listFilesInDirectoryAtPath:path deep:NO] count] == 0);
}

+ (BOOL)isDirectoryAtPath:(NSString *)path {
    return [self isDirectoryAtPath:path error:nil];
}

+ (BOOL)isDirectoryAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    return ([self attributeOfItemAtPath:path forKey:NSFileType error:error] == NSFileTypeDirectory);
}

+ (BOOL)isFileAtPath:(NSString *)path {
    return [self isFileAtPath:path error:nil];
}

+ (BOOL)isFileAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    return ([self attributeOfItemAtPath:path forKey:NSFileType error:error] == NSFileTypeRegular);
}

+ (BOOL)isExecutableItemAtPath:(NSString *)path {
    return [[NSFileManager defaultManager] isExecutableFileAtPath:path];
}

+ (BOOL)isReadableItemAtPath:(NSString *)path {
    return [[NSFileManager defaultManager] isReadableFileAtPath:path];
}
+ (BOOL)isWritableItemAtPath:(NSString *)path {
    return [[NSFileManager defaultManager] isWritableFileAtPath:path];
}

#pragma mark - 获取文件(夹)大小
+ (NSNumber *)sizeOfItemAtPath:(NSString *)path {
    return [self sizeOfItemAtPath:path error:nil];
}

+ (NSNumber *)sizeOfItemAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    return (NSNumber *)[self attributeOfItemAtPath:path forKey:NSFileSize error:error];
}

+ (NSNumber *)sizeOfFileAtPath:(NSString *)path {
    return [self sizeOfFileAtPath:path error:nil];
}

+ (NSNumber *)sizeOfFileAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    if ([self isFileAtPath:path error:error]) {
        return [self sizeOfItemAtPath:path error:error];
    }
    return nil;
}

+ (NSNumber *)sizeOfDirectoryAtPath:(NSString *)path {
    return [self sizeOfDirectoryAtPath:path error:nil];
}

+ (NSNumber *)sizeOfDirectoryAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    if ([self isDirectoryAtPath:path error:error]) {
        NSNumber *size = [self sizeOfItemAtPath:path error:error];
        double sizeValue = [size doubleValue];
        
        NSArray *subPaths = [self listFilesInDirectoryAtPath:path deep:YES];
        for (NSUInteger i = 0; i < subPaths.count; i++) {
            NSString *subPath = [subPaths objectAtIndex:i];
            NSNumber *subPathSize = [self sizeOfItemAtPath:subPath error:error];
            sizeValue += [subPathSize doubleValue];
        }
        return [NSNumber numberWithDouble:sizeValue];
    }
    return nil;
}

+ (NSString *)sizeFormattedOfItemAtPath:(NSString *)path {
    return [self sizeFormattedOfItemAtPath:path error:nil];
}

+ (NSString *)sizeFormattedOfItemAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    NSNumber *size = [self sizeOfItemAtPath:path error:error];
    if (!size) {
        return [self sizeFormatted:size];
    }
    return nil;
}

+ (NSString *)sizeFormattedOfFileAtPath:(NSString *)path {
    return [self sizeFormattedOfFileAtPath:path error:nil];
}

+ (NSString *)sizeFormattedOfFileAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    NSNumber *size = [self sizeOfFileAtPath:path error:error];
    if (!size) {
        return [self sizeFormatted:size];
    }
    return nil;
}

+ (NSString *)sizeFormattedOfDirectoryAtPath:(NSString *)path {
    return [self sizeFormattedOfDirectoryAtPath:path error:nil];
}

+ (NSString *)sizeFormattedOfDirectoryAtPath:(NSString *)path error:(NSError *__autoreleasing *)error {
    NSNumber *size = [self sizeOfDirectoryAtPath:path error:error];
    if (!size) {
        return [self sizeFormatted:size];
    }
    return nil;
}

#pragma mark - 写入文件内容
+ (BOOL)writeFileAtPath:(NSString *)path content:(NSObject *)content {
    return [self writeFileAtPath:path content:content error:nil];
}

+ (BOOL)writeFileAtPath:(NSString *)path content:(NSObject *)content error:(NSError *__autoreleasing *)error {
    if (!content) {
        [NSException raise:@"非法的文件内容" format:@"文件内容不能为nil"];
        return NO;
    }
    if ([self isExistsAtPath:path]) {
        if ([content isKindOfClass:[NSMutableArray class]]) {
            [(NSMutableArray *)content writeToFile:path atomically:YES];
        }else if ([content isKindOfClass:[NSArray class]]) {
            [(NSArray *)content writeToFile:path atomically:YES];
        }else if ([content isKindOfClass:[NSMutableData class]]) {
            [(NSMutableData *)content writeToFile:path atomically:YES];
        }else if ([content isKindOfClass:[NSData class]]) {
            [(NSData *)content writeToFile:path atomically:YES];
        }else if ([content isKindOfClass:[NSMutableDictionary class]]) {
            [(NSMutableDictionary *)content writeToFile:path atomically:YES];
        }else if ([content isKindOfClass:[NSDictionary class]]) {
            [(NSDictionary *)content writeToFile:path atomically:YES];
        }else if ([content isKindOfClass:[NSJSONSerialization class]]) {
            [(NSDictionary *)content writeToFile:path atomically:YES];
        }else if ([content isKindOfClass:[NSMutableString class]]) {
            [[((NSString *)content) dataUsingEncoding:NSUTF8StringEncoding] writeToFile:path atomically:YES];
        }else if ([content isKindOfClass:[NSString class]]) {
            [[((NSString *)content) dataUsingEncoding:NSUTF8StringEncoding] writeToFile:path atomically:YES];
        }else if ([content isKindOfClass:[UIImage class]]) {
            [UIImagePNGRepresentation((UIImage *)content) writeToFile:path atomically:YES];
        }else if ([content conformsToProtocol:@protocol(NSCoding)]) {
            [NSKeyedArchiver archiveRootObject:content toFile:path];
        }else {
            [NSException raise:@"非法的文件内容" format:@"文件类型%@异常，无法被处理。", NSStringFromClass([content class])];
            
            return NO;
        }
    }else {
        return NO;
    }
    return YES;
}

#pragma mark - private methods
+ (BOOL)isNotError:(NSError **)error {
    return ((error == nil) || ((*error) == nil));
}

+(NSString *)sizeFormatted:(NSNumber *)size {
    double convertedValue = [size doubleValue];
    int multiplyFactor = 0;
    
    NSArray *tokens = @[@"bytes", @"KB", @"MB", @"GB", @"TB"];
    
    while(convertedValue > 1024){
        convertedValue /= 1024;
        
        multiplyFactor++;
    }
    
    NSString *sizeFormat = ((multiplyFactor > 1) ? @"%4.2f %@" : @"%4.0f %@");
    
    return [NSString stringWithFormat:sizeFormat, convertedValue, tokens[multiplyFactor]];
}

/**
 获取合法的文件名,传来的文件名必须包含后缀

 @param fileName 原始文件名
 @return 合法的文件名
 */
+(NSString *)getLegalFileName:(NSString *)fileName{
    fileName = [fileName stringByReplacingOccurrencesOfString:@"/" withString:@""];
    fileName = [fileName stringByReplacingOccurrencesOfString:@"|" withString:@""];
    fileName = [fileName stringByReplacingOccurrencesOfString:@" " withString:@""];
    fileName = [fileName stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    fileName = [fileName stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    fileName = [fileName stringByReplacingOccurrencesOfString:@"’" withString:@""];
    fileName = [fileName stringByReplacingOccurrencesOfString:@":" withString:@""];
    fileName = [fileName stringByReplacingOccurrencesOfString:@"?" withString:@""];
    fileName = [fileName stringByReplacingOccurrencesOfString:@"@" withString:@""];
    fileName = [fileName stringByReplacingOccurrencesOfString:@"=" withString:@""];
    fileName = [fileName stringByReplacingOccurrencesOfString:@"+" withString:@""];
    fileName = [fileName stringByReplacingOccurrencesOfString:@"&" withString:@""];
    
    
    //文件名的后缀，方便过会拼接
    NSString *fileExtension = fileName.pathExtension;
    NSString *namePam = [fileName stringByDeletingPathExtension];
    if (namePam.length>50) {
        namePam = [namePam substringToIndex:50];
    }
    if (fileExtension.length<1) {//没有后缀
        fileExtension = @"data";
    }
//    if (![fileName containsString:@".mp4"]) {
//        fileName = [fileName stringByAppendingString:@".mp4"];
//    }
    NSString *downloadDir = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"download"];
    NSMutableArray *files =  [NSMutableArray arrayWithArray:[HYFileManager listFilesInDirectoryAtPath:downloadDir deep:NO]];
    
    NSArray *downloads = [[DownloadCacher shareInstance] allDownloadingModels];
    for (DownloadModel *model in downloads) {
        [files addObject:model.name];
    }

    if ([files containsObject:[fileName stringByURLEncode]]) {
        //不带后缀的文件名
        
        //文件名的后缀，方便过会拼接
        NSString *fileExtension = fileName.pathExtension;
        for (NSInteger i = 1; i<1000; i++) {
            NSString *legalName = [NSString stringWithFormat:@"%@(%ld).%@",namePam,i,fileExtension];
            if (![files containsObject:[legalName stringByURLEncode]]) {
//                return legalName;
                return [legalName stringByURLEncode];
            }
        }
    }
    return [[namePam stringByAppendingPathExtension:fileExtension] stringByURLEncode];
    /*
    NSString *subStr = [fileName stringByReplacingOccurrencesOfString:@"/" withString:@"_"];//有歧义的符号
    NSString *dirPath =[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"download"];
    subStr = [@"download" stringByAppendingPathComponent:subStr];
    //    subStr = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:subStr];
    NSString *newStr = [NSString stringWithFormat:@"%@.mp4",fileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:[dirPath stringByAppendingPathComponent:newStr]]) {//检查带后缀后是否存在这个文件
        DDLogInfo(@"文件名 %@",fileName);
        DDLogInfo(@"filename %@",newStr);
        return [fileName stringByAppendingString:@".mp4"];
        //        return [subStr stringByAppendingPathExtension:@".mp4"];//返回的是带后缀的
    }else{
        //这个文件已经存在了
        for (NSInteger i =1; i<1000; i++) {
            newStr = [NSString stringWithFormat:@"%@(%ld).mp4",fileName,(long)i];
            DDLogInfo(@"filename %@",newStr);
            if (![[NSFileManager defaultManager] fileExistsAtPath:[dirPath stringByAppendingPathComponent:newStr]]) {
                return newStr;
            }
            
        }
        return [fileName stringByAppendingString:@"_other.mp4"];
        //        do {
        //
        //        } while (<#condition#>);
        //        static NSInteger i = 1;
        //        NSString *newStr = [NSString stringWithFormat:@"%@(%ld)",fileName,(long)i++];
        //        return [self getLegalFileName:newStr];
    }
     */
}
+(NSString *)getLegalFileName:(NSString *)fileName pathExtension:(NSString *)extension{
    
    fileName = [fileName stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@／：；（）¥「」＂、[]{} #%-*+=_\\|~＜＞$€^•'@#$%^&*()_+'\""]];
    if (fileName.length>20) {
        fileName = [fileName substringToIndex:20];
    }
    
    //    if (![fileName containsString:@".mp4"]) {
    //        fileName = [fileName stringByAppendingString:@".mp4"];
    //    }
    NSString *downloadDir = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"download"];
    NSMutableArray *files =  [NSMutableArray arrayWithArray:[HYFileManager listFilesInDirectoryAtPath:downloadDir deep:NO]];
    
    NSArray *downloads = [[DownloadCacher shareInstance] allDownloadingModels];
    for (DownloadModel *model in downloads) {
        [files addObject:model.name];
    }
    
    if ([files containsObject:[fileName stringByURLEncode]]) {
        NSString *namePam = [fileName stringByDeletingPathExtension];
        NSString *ext = [fileName pathExtension];
        for (NSInteger i = 1; i<1000; i++) {
            
            NSString *legalName = [NSString stringWithFormat:@"%@(%ld).%@",namePam,i,ext];
            if (![files containsObject:[legalName stringByURLEncode]]) {
                //                return legalName;
                return [legalName stringByURLEncode];
            }
        }
    }
    return [fileName stringByURLEncode];
}


@end
