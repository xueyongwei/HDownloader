//
//  DownloadTaskTableViewCell.m
//  downloader
//
//  Created by xueyognwei on 2017/3/27.
//  Copyright © 2017年 xueyognwei. All rights reserved.
//

#import "DownloadTaskTableViewCell.h"
#import "UserDefaultManager.h"
#import "CoreStatus.h"
#import "AppDelegate.h"

@interface DownloadTaskTableViewCell ()<UIAlertViewDelegate>
@property (nonatomic,copy)NSString *totalSizeStr;
@property (nonatomic,assign)long lastDownloadSize;
@property (nonatomic,strong)NSTimer *myTimer;
@end

@implementation DownloadTaskTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.myTimer = [NSTimer timerWithTimeInterval:2.0 target:self selector:@selector(timerFired)userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop]addTimer:self.myTimer forMode:NSDefaultRunLoopMode];
    // Initialization code
}
-(void)dealloc
{
    [self.myTimer invalidate];
    self.myTimer = nil;
    
}
-(void)timerFired{
    if (self.downloadModel) {//正在下载呢，需要计算网速
        if (self.downloadModel.status == Downloading) {
            long currentSize = self.downloadModel.videoSize*self.downloadModel.downloadPercent;
            long downloadedSize = currentSize - self.lastDownloadSize;
            self.downloadSpeedLabel.text = [NSString stringWithFormat:@"%@/S",[self stringForVideoSize:downloadedSize]];
            self.lastDownloadSize = currentSize;
//            self.downloadSpeedLabel.hidden = NO;
        }else if (self.downloadModel.status == DownloadWating){
            self.downloadSpeedLabel.text = NSLocalizedString(@"waiting...", nil) ;
        }else if (self.downloadModel.status == DownloadFailed){
            self.downloadSpeedLabel.text = NSLocalizedString(@"download failed", nil) ;
        }
//        else if (self.downloadModel.status == DownloadPause){
//            self.downloadSpeedLabel.text = NSLocalizedString(@"pause", nil) ;
//        }
        else{
            self.downloadSpeedLabel.text = @" ";
        }
        
    }
}
-(void)setDownloadModel:(DownloadModel *)downloadModel
{
    DDLogInfo(@"setDownloadModel %d",downloadModel.status);
    _downloadModel = downloadModel;
    self.videoNameLabel.text =  [downloadModel.name stringByURLDecode];
//    if (!_totalSizeStr) {
//        if (downloadModel.videoSize>0) {
//            
//        }
//    }
    _totalSizeStr = [self stringForVideoSize:downloadModel.videoSize];
    int64_t currentSize = downloadModel.videoSize*downloadModel.downloadPercent;
    self.videoSizeLabel.text =  [NSString stringWithFormat:@"%@/%@",[self stringForVideoSize:currentSize],_totalSizeStr];
    self.downLoadBtn.selected = (downloadModel.status == DownloadWating) ||(downloadModel.status == Downloading) ;
    self.downLoadBtn.progress = downloadModel.downloadPercent;
//    [self timerFired]; 
    if (downloadModel.status == Downloading) {
        if ([self.downloadSpeedLabel.text isEqualToString:NSLocalizedString(@"waiting...", nil) ]) {
            self.downloadSpeedLabel.text = @"0K/S";
        }
    }else if (downloadModel.status == DownloadWating){
        self.downloadSpeedLabel.text = NSLocalizedString(@"waiting...", nil);
    }else{
        self.downloadSpeedLabel.text = @" ";
    }
//    if (downloadModel.status != Downloading) {
//        self.downloadSpeedLabel.text = @" ";
//    }
    
    /*
    if (downloadModel.status == Downloading) {
        if (!_totalSizeStr) {
            if (downloadModel.videoSize>0) {
                _totalSizeStr = [self stringForVideoSize:downloadModel.videoSize];
            }
        }
        int64_t currentSize = downloadModel.videoSize*downloadModel.downloadPercent;
        self.videoSizeLabel.text =  [NSString stringWithFormat:@"%@/%@",[self stringForVideoSize:currentSize],_totalSizeStr];
        self.downLoadBtn.selected = YES;
        self.downLoadBtn.progress = downloadModel.downloadPercent;
    }else if (downloadModel.status == DownloadWating){
        if (!_totalSizeStr) {
            if (downloadModel.videoSize>0) {
                _totalSizeStr = [self stringForVideoSize:downloadModel.videoSize];
            }
        }
        int64_t currentSize = downloadModel.videoSize*downloadModel.downloadPercent;
        self.videoSizeLabel.text =  [NSString stringWithFormat:@"%@/%@",[self stringForVideoSize:currentSize],_totalSizeStr];
        self.downloadSpeedLabel.text =
        self.downLoadBtn.selected = NO;
    }
    NSString *stateStr =[self downloadStateStr:downloadModel.status];
    if ([stateStr isEqualToString:@"downloading"]) {
        if (!_totalSizeStr) {
            if (downloadModel.videoSize>0) {
                _totalSizeStr = [self stringForVideoSize:downloadModel.videoSize];
            }
        }
        int64_t currentSize = downloadModel.videoSize*downloadModel.downloadPercent;
        self.videoSizeLabel.text =  [NSString stringWithFormat:@"%@/%@",[self stringForVideoSize:currentSize],_totalSizeStr];
        self.downLoadBtn.selected = YES;
        self.downLoadBtn.progress = downloadModel.downloadPercent;
    }else if ([stateStr isEqualToString:@"downloading"]){
        
    }else{
        self.videoSizeLabel.text = stateStr;
        self.downloadSpeedLabel.hidden = YES;
        self.downLoadBtn.selected = NO;
    }
    */
}

-(NSString *)downloadStateStr:(DownloadStatus) status{
    switch (status)
    {
        case DownloadWating:
            return NSLocalizedString(@"waiting...", nil);
            break;
            
        case DownloadPause:
            return @"pause";
            break;
            
        case Downloading:
            return @"downloading";
            break;
            
        case DownloadFinished:
            return @"done";
            break;
            
        case DownloadFailed:
            return @"fail";
            break;
            
        default:
            return @" ";
            break;
    }

}
/*
-(void)setDownloader:(ZYLSingleDownloader *)downloader
{
    _downloader = downloader;
    self.videoNameLabel.text = downloader.filename;
    [self setDownLoadSize:downloader.currentWriten total:downloader.totalToWriten];
    self.downloadSpeedLabel.text = @"";
    if (downloader.downloaderState == ZYLDownloaderStateRunning) {
        self.downLoadBtn.selected = YES;
    }else{
        self.downLoadBtn.selected = NO;
    }
}

-(void)setDownLoadSize:(int64_t)current total:(int64_t)total{
    NSString *currentStr = [self stringForSize:current];
    NSString *totalStr = [self stringForSize:total];
    self.videoSizeLabel.text = [NSString stringWithFormat:@"%@ / %@",currentStr,totalStr];
}
-(void)setDownloadSpeed:(int64_t)speed{
    self.downloadSpeedLabel.text = [NSString stringWithFormat:@"%@/S",[self stringForSize:speed]];
}
 */
- (IBAction)onDownloadBtnClick:(DownLoadButton *)sender {
    if (sender.selected) {
        sender.selected = !sender.selected;
        [[DownloadManager shareInstance]dealDownloadModel:self.downloadModel];
    }else{//wanna 下载
        BOOL wifi = [CoreStatus isWifiEnable];
        BOOL onlyWifi = [UserDefaultManager isOnlyDownloadWhenWIFI];
        
        if (!wifi && onlyWifi) {
            UIAlertView *alv = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"No WiFi.You can go to the settings and turn off \"Only use WiFi to download\"button.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Got it", nil)  otherButtonTitles:NSLocalizedString(@"Settings", nil) , nil];
            [alv show];
        }else{
            [[DownloadManager shareInstance]dealDownloadModel:self.downloadModel];
        }
    }
    
    
//    [[DownloadManager shareInstance]dealDownloadModel:self.downloadModel];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex ==0) {
        self.downLoadBtn.selected = NO;
    }else if (buttonIndex ==1){
        
        UITabBarController *tabVC = (UITabBarController*)((AppDelegate *)[UIApplication sharedApplication].delegate).window.rootViewController;
        [tabVC setSelectedIndex:3];
//        self.downLoadBtn.selected = YES;
//        [[DownloadManager shareInstance]dealDownloadModel:self.downloadModel];
    }
}
-(NSString *)stringForVideoSize:(int64_t)total{
    NSString *totalStr = @"0B";
    if (total >= 0 && total < 1024) {
        //B
        totalStr = [NSString stringWithFormat:@"%ldB", (long)total];
    } else if (total >= 1024 && total < 1024 * 1024) {
        //KB
        totalStr = [NSString stringWithFormat:@"%ldK", (long)total / 1024];
    } else if (total >= 1024 * 1024 && total < 1024 * 1024 *1024) {
        //MB
        totalStr = [NSString stringWithFormat:@"%.2lfM", (double)total / 1024.0 / 1024.0];
    } else if (total >= 1024 * 1024 *1024) {
        //GB
        totalStr = [NSString stringWithFormat:@"%.2lfG", (double)total / 1024.0 / 1024.0];
    }
    return totalStr;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    self.downLoadBtn.hidden = editing;
}

@end
