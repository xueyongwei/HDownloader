//
//  XYWVersonManager.m
//  downloader
//
//  Created by xueyognwei on 2017/5/2.
//  Copyright © 2017年 xueyognwei. All rights reserved.
//

#import "XYWVersonManager.h"

@implementation XYWVersonManager

+(CGFloat)lastVersionInter{
    CGFloat lastVersionInter = [[NSUserDefaults standardUserDefaults] floatForKey:@"currentAppVersionIntegerValue"];
    if (lastVersionInter&&lastVersionInter>0) {
        DDLogVerbose(@"lastVersionInter = %lf",lastVersionInter);
        return lastVersionInter;
        
    }else{
        DDLogVerbose(@"first lanch after install");
        return 0;
    }
}
+(BOOL)firstLanchOnlyThisVersion:(BOOL)onlyThisVersion{
    if (onlyThisVersion) {
        return [self currentVersionInter] == [self lastVersionInter]?NO:YES;
    }else{
        return [self lastVersionInter]==0?YES:NO;
    }
}
+(CGFloat)currentVersionInter{
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSRange dotrange = [version rangeOfString:@"."];
    NSString *bigVersion = [version substringToIndex:dotrange.location];
    NSString *smallVersion = [version substringFromIndex:dotrange.location+dotrange.length];
    
    NSUserDefaults *usf = [NSUserDefaults standardUserDefaults];
    CGFloat currentVersion = bigVersion.integerValue*100+smallVersion.floatValue;
    [usf setFloat:currentVersion forKey:@"currentAppVersionIntegerValue"];
    return currentVersion;
}

@end
