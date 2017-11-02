//
//  AppDelegate.h
//  downloader
//
//  Created by xueyognwei on 2017/3/24.
//  Copyright © 2017年 xueyognwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTPServer.h"
typedef void(^BackgroundSessionCompletionHandler)();
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,strong) HTTPServer *httpServer;
@property (copy, nonatomic) BackgroundSessionCompletionHandler backgroundSessionCompletionHandler;
@end

