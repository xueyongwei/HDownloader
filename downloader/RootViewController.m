//
//  RootViewController.m
//  downloader
//
//  Created by xueyognwei on 2017/3/24.
//  Copyright © 2017年 xueyognwei. All rights reserved.
//

#import "RootViewController.h"
#import "DownloadsViewController.h"
#import "DownloadManager.h"
#import "CoreStatus.h"
#import "XYWADManager.h"
#import "UserDefaultManager.h"
#import "AFHTTPSessionManager+SharedManager.h"
#import <AdSupport/AdSupport.h>
#import <sys/utsname.h>
#import "ADModel.h"
#import "ADalertViewController.h"
@interface RootViewController ()<UIAlertViewDelegate,FBInterstitialAdDelegate>

@end
#define kalertTagDownload 100
#define kalertTag5Stars 200
@implementation RootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    DDLogInfo(@"%@",self.childViewControllers);
    [[XYWADManager shareInstance]loadAD];
    [self dealTheDownloadingTaskByKilled];
    [CoreStatus beginNotiNetwork:[DownloadManager shareInstance]];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if ([UserDefaultManager timeToShow5Stars]) {
            [self alert5Stars];
        }else{
//            if (![self showServerAD]) {
//                [self alert5Stars];
//            }
        }
        [self requestServerAD];
    });
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self requestBlackList];
        [self requestIPinfo];
    });
    
    UINavigationController *navi = self.childViewControllers[1];
    DownloadsViewController *downloadVC = navi.childViewControllers.firstObject;
    [downloadVC viewDidLoad];
}

/**
 处理上次kill时仍在下载的任务
 */
-(void)dealTheDownloadingTaskByKilled{
    //    DownloadModel *downloadingModel =  [[DownloadCacher shareInstance] queryTopDownloadingDownloadModel];
    //    DDLogInfo(@"maybe to download : %@",downloadingModel);
    [[DownloadManager shareInstance] resetDownloading];
    //    if (downloadingModel) {
    //        UIAlertView *alv = [[UIAlertView alloc]initWithTitle:@"有正在下载的内容" message:@"是否恢复下载？" delegate:self cancelButtonTitle:@"不用" otherButtonTitles:@"是的", nil];
    //        alv.tag = kalertTagDownload;
    //        [alv show];
    //    }

}
//-(void)listenNetworkState{
//     [CoreStatus beginNotiNetwork:self];
//}
-(void)requestServerAD{
//    /ad/v1.0/ios/dialog_ads
    NSString *bundle_id = [UIApplication sharedApplication].appBundleID;
    NSString *version = [UIApplication sharedApplication].appVersion;
    NSString *uid = @"";
    if ([ASIdentifierManager sharedManager].isAdvertisingTrackingEnabled) {
        uid = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    }else{
        uid = [[NSUUID UUID] UUIDString];
    }
    
    NSString *network = [self newWorkString];
    NSString *os_version = [NSString stringWithFormat:@"%.1f",[UIDevice systemVersion]];
    NSString *model = [self iphoneType];
    NSString *sign = [NSString stringWithFormat:@"bundle_id=%@&model=%@&network=%@&os_version=%@&uid=%@&version=%@%@",bundle_id,model,network,os_version,uid,version,bundle_id];
    
//    NSDictionary *param =@{@"bundle_id":bundle_id,@"version":version,@"uid":uid,@"network":network,@"os_version":os_version,@"model":model,@"sign":sign.md5String.uppercaseString};
    NSString *urlstr = [NSString stringWithFormat:@"https://api.tools.superlabs.info/ad/v1.0/ios/dialog_ads?bundle_id=%@&model=%@&network=%@&os_version=%@&uid=%@&version=%@&sign=%@",bundle_id,model,network,os_version,uid,version,sign.md5String.uppercaseString];
    DDLogInfo(@"sign = %@",sign);
    DDLogInfo(@"url = %@",urlstr);
    
    [[AFHTTPSessionManager sharedManager] GET:urlstr parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        DDLogInfo(@"%@",responseObject);
        [UserDefaultManager saveLocalServerAD:nil];
        if ([responseObject isKindOfClass:[NSArray class]]) {
            NSArray *ads = responseObject;
            if (ads.count>0) {
                NSDictionary *dic = ads.firstObject;
                [UserDefaultManager saveLocalServerAD:dic];
                [self prepareADdate:dic];
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogInfo(@"%@",error.localizedDescription);
    }];
}
-(void)prepareADdate:(NSDictionary *)dic{
    ADModel *model = [ADModel modelWithDictionary:dic];
    DDLogInfo(@"%@",model);
    [[YYWebImageManager sharedManager] requestImageWithURL:[NSURL URLWithString:model.icon] options:YYWebImageOptionRefreshImageCache progress:nil transform:nil completion:nil];
    [[YYWebImageManager sharedManager] requestImageWithURL:[NSURL URLWithString:model.banner] options:YYWebImageOptionRefreshImageCache progress:nil transform:nil completion:nil];
}

-(BOOL)showServerAD{
    NSDictionary *dic = [UserDefaultManager localServerAD];
    if (!dic) {
        return NO;
    }
    ADModel *model = [ADModel modelWithDictionary:dic];
    if ([NSThread isMainThread]) {
        ADalertViewController *alv = [[ADalertViewController alloc]initWithNibName:@"ADalertViewController" bundle:nil];
        alv.model = model;
        [self presentViewController:alv animated:YES completion:nil];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            ADalertViewController *alv = [[ADalertViewController alloc]initWithNibName:@"ADalertViewController" bundle:nil];
            alv.model = model;
            [self presentViewController:alv animated:YES completion:nil];
        });
    }
    return YES;
}
-(NSString *)newWorkString{
    switch ([CoreStatus currentNetWorkStatus]) {
        case CoreNetWorkStatusWifi:
            return @"WIFI";
            break;
        case CoreNetWorkStatus2G:
            return @"4G";
            break;
        case CoreNetWorkStatus3G:
            return @"3G";
            break;
        case CoreNetWorkStatus4G:
            return @"4G";
            break;
        default:
            return @"unknown";
            break;
    }
    
}
- (NSString *)iphoneType {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
    return platform;
}
-(void)alert5Stars{
    
    if ([UserDefaultManager have5Stars]) {
        
    }else{
        UIAlertView *alv = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Please rate us to support developers and get more cool features！", nil)  message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Later", nil)  otherButtonTitles:NSLocalizedString(@"5 stars", nil), nil];
        alv.tag = kalertTag5Stars;
        [alv show];
    }
}
-(void)requestBlackList{
    
    [[AFHTTPSessionManager sharedManager] GET:@"https://api.tools.superlabs.info/video/v1.0/domain_blacklist" parameters:@{@"app_id":[UIApplication sharedApplication].appBundleID} progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        DDLogInfo(@"%@",responseObject);
        NSArray *list = (NSArray *)responseObject;
       
        NSMutableDictionary *blackList = [NSMutableDictionary new];
        for (NSDictionary *dic in list) {
            [blackList setObject:dic[@"domains"] forKey:dic[@"country_id"]];
        }
        [UserDefaultManager setVisitBlackList:blackList];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogInfo(@"%@",error.localizedDescription);
    }];
}
-(void)requestIPinfo{
    [[AFHTTPSessionManager sharedManager] GET:@"http://ip.taobao.com/service/getIpInfo.php?ip=myip" parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        DDLogInfo(@"%@",responseObject);
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSNumber *nb =[responseObject objectForKey:@"code"];
            if (nb&&nb.integerValue ==0) {//成功获取IP信息
                NSDictionary *data = [responseObject objectForKey:@"data"];
                [UserDefaultManager setdeviceIPInfo:data];
            }else{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self requestIPinfo];
                });
            }
        }else{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self requestIPinfo];
            });
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DDLogInfo(@"%@",error.localizedDescription);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self requestIPinfo];
        });
    }];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kalertTag5Stars) {
        if (buttonIndex ==1) {
            [AnalyticsTool analyCategory:@"Settings" action:@"点击弹窗上的【5 stars】" label:nil value:nil];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=1226848385"]];
            [UserDefaultManager set5StarsDone];
        }else{
            
        }
    }else if (alertView.tag == kalertTagDownload){
        if (buttonIndex ==1) {
            [[DownloadManager shareInstance]recoverDownloading];
        }else{
            [[DownloadManager shareInstance]resetDownloading];
        }
    }
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
