//
//  XYWADManager.m
//  downloader
//
//  Created by xueyognwei on 2017/4/13.
//  Copyright © 2017年 xueyognwei. All rights reserved.
//

#import "XYWADManager.h"
#import "AppDelegate.h"
@implementation XYWADManager
/**
 创建单例
 
 @return 返回实例
 */
+(instancetype)shareInstance
{
    static XYWADManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc]init];
    });
    return sharedInstance;
}

-(void)loadAD{
    FBInterstitialAd *interstitialAd =
    [[FBInterstitialAd alloc] initWithPlacementID:@"491292214594434_492786231111699"];
    interstitialAd.delegate = self;
    
    [interstitialAd loadAd];
    self.interstitialAd = interstitialAd;
}
-(void)showAD{
    if (self.interstitialAd.isAdValid){
        AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [self.interstitialAd showAdFromRootViewController:app.window.rootViewController];
    }
}
// Now that you have added the code to load the ad, add the following functions
// to display the ad once it is loaded and to handle loading failures:
- (void)interstitialAdDidLoad:(FBInterstitialAd *)interstitialAd
{
    DDLogInfo(@"Interstitial ad is loaded and ready to be displayed");
}

- (void)interstitialAd:(FBInterstitialAd *)interstitialAd
      didFailWithError:(NSError *)error
{
    DDLogInfo(@"Interstitial ad is failed to load with error: %@", error);
}
-(void)interstitialAdWillClose:(FBInterstitialAd *)interstitialAd
{
    [self loadAD];
}
@end
