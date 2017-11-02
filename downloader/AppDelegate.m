//
//  AppDelegate.m
//  downloader
//
//  Created by xueyognwei on 2017/3/24.
//  Copyright © 2017年 xueyognwei. All rights reserved.
//

#import "AppDelegate.h"
#import "CoreStatus.h"

#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import "XYWADManager.h"
#import <Google/Analytics.h>
#import "BookMarkManager.h"
#import "XYWDDLogFormatter.h"
#import "CatchCrash.h"
#import "UserDefaultManager.h"
#import "XYWVersonManager.h"
@interface AppDelegate ()
@property (nonatomic,assign) NSInteger count;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [self defauleConfigInBackground];
    [self defaultConfigInMainThread];
    
    
    return YES;
}

/**
 主线程处理
 */
-(void)defaultConfigInMainThread{
    dispatch_async(dispatch_get_main_queue(), ^{
        [FBAdSettings setLogLevel:FBAdLogLevelError];
        [FBAdSettings addTestDevices:@[@"5e2e43d671ccaf6b0c8d9e081844f5d6298dc39d",
                                       @"2c4dd9c3de47ee216314b05301e4ba1247cf7b9a",
                                       @"b602d594afd2b0b327e07a06f36ca6a7e42546d0"]];
        
        NSError *configureError;
        [[GGLContext sharedInstance] configureWithError:&configureError];
        NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
        
        // Optional: configure GAI options.
        GAI *gai = [GAI sharedInstance];
        gai.trackUncaughtExceptions = YES;  // report uncaught exceptions
        gai.logger.logLevel = kGAILogLevelError;  // remove before app release
        
        
    });
}

/**
 后台线程处理
 */
-(void)defauleConfigInBackground{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //初始化日志系统
        [DDLog addLogger:[DDTTYLogger sharedInstance]]; // TTY = Xcode console
        //    [DDLog addLogger:[DDASLLogger sharedInstance]]; // ASL = Apple System Logs
        
        DDFileLogger *fileLogger = [[DDFileLogger alloc] init]; // File Logger
        fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
        [DDLog addLogger:fileLogger];
        [DDTTYLogger sharedInstance].logFormatter = [[XYWDDLogFormatter alloc] init];
        NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);//ddlog抓取崩溃日志
        //
        BOOL firstLanchThisVersion = [XYWVersonManager firstLanchOnlyThisVersion:YES];
        if (firstLanchThisVersion) {
            [UserDefaultManager resetTimesOfShow5Stars];
        }
        //初始化域名黑名单
        NSDictionary *defaultBlack =@{
                                      @"country_id" : @"ALL",
                                      @"domains" : @[
                                              @"youtube.com",
                                              ],
                                      };
        [UserDefaultManager setVisitBlackList:defaultBlack];
        
        //初始化书签
        [[BookMarkManager shareInstance] defauldConfig];
        
        
        self.httpServer = [[HTTPServer alloc] init];
        //  设置服务器类型为tcp
        [self.httpServer setType:@"_http._tcp."];
        //  设置本地服务器端口号，你可以随意设置端口号
        [self.httpServer setPort:6398];
        
        NSString *pathPrefix = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)objectAtIndex:0];
        
        NSString *webPath = [pathPrefix stringByAppendingPathComponent:@"download"];
        NSLog(@"Setting document root: %@", webPath);
        //  指定本地服务器播放的文件路径
        [self.httpServer setDocumentRoot:webPath];
        
        NSError *error;
        if(![self.httpServer start:&error])
        {
            NSLog(@"Error starting HTTP Server: %@", error);
        }
    });
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    if ([[XYWADManager shareInstance].interstitialAd isAdValid]) {
        [[XYWADManager shareInstance]showAD];
    }
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    self.count++;
    DDLogInfo(@"handleEventsForBackgroundURLSession   ===   %ld",(long)self.count);
    self.backgroundSessionCompletionHandler = completionHandler;
}

@end
