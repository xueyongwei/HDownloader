//
//  XYWADManager.h
//  downloader
//
//  Created by xueyognwei on 2017/4/13.
//  Copyright © 2017年 xueyognwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FBAudienceNetwork/FBAudienceNetwork.h>
@interface XYWADManager : NSObject <FBInterstitialAdDelegate>
+(instancetype)shareInstance;
@property (nonatomic,strong)FBInterstitialAd *interstitialAd;
-(void)loadAD;
-(void)showAD;
@end
