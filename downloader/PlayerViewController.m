//
//  PlayerViewController.m
//  downloader
//
//  Created by xueyognwei on 2017/4/1.
//  Copyright © 2017年 xueyognwei. All rights reserved.
//

#import "PlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <Masonry/Masonry.h>

#import "ZFPlayer.h"

@interface PlayerViewController ()<ZFPlayerDelegate>
@property (strong, nonatomic) ZFPlayerView *playerView;
/** 离开页面时候是否在播放 */
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, strong) ZFPlayerModel *playerModel;
@property (nonatomic, strong) UIView *bottomView;
@end

@implementation PlayerViewController
- (void)dealloc
{
    NSLog(@"%@释放了",self.class);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    // pop回来时候是否自动播放
    if (self.navigationController.viewControllers.count == 2 && self.playerView && self.isPlaying) {
        self.isPlaying = NO;
        [self.playerView play];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    // push出下一级页面时候暂停
    if (self.navigationController.viewControllers.count == 3 && self.playerView && !self.playerView.isPauseByUser)
    {
        self.isPlaying = YES;
        [self.playerView pause];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    /*
     self.playerFatherView = [[UIView alloc] init];
     [self.view addSubview:self.playerFatherView];
     [self.playerFatherView mas_makeConstraints:^(MASConstraintMaker *make) {
     make.top.mas_equalTo(20);
     make.leading.trailing.mas_equalTo(0);
     // 这里宽高比16：9,可自定义宽高比
     make.height.mas_equalTo(self.playerFatherView.mas_width).multipliedBy(9.0f/16.0f);
     }];
     */
    self.playerView = [[ZFPlayerView alloc] init];
    
    /*****************************************************************************************
     *   // 指定控制层(可自定义)
     *   // ZFPlayerControlView *controlView = [[ZFPlayerControlView alloc] init];
     *   // 设置控制层和播放模型
     *   // 控制层传nil，默认使用ZFPlayerControlView(如自定义可传自定义的控制层)
     ******************************************************************************************/
    [self.playerView playerControlView:nil playerModel:self.playerModel];
    
    // 设置代理
    self.playerView.delegate = self;
    
    //（可选设置）可以设置视频的填充模式，内部设置默认（ZFPlayerLayerGravityResizeAspect：等比例填充，直到一个维度到达区域边界）
    // self.playerView.playerLayerGravity = ZFPlayerLayerGravityResizeAspect;
    
    // 打开下载功能（默认没有这个功能）
    self.playerView.hasDownload    = NO;
    // 打开预览图
    self.playerView.hasPreviewView = NO;
    
    // 是否自动播放，默认不自动播放
    [self.playerView autoPlayTheVideo];
    
}


#pragma mark - ZFPlayerDelegate

- (void)zf_playerBackAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)zf_playerDownload:(NSString *)url
{
    // 此处是截取的下载地址，可以自己根据服务器的视频名称来赋值
//    NSString *name = [url lastPathComponent];
//    [[ZFDownloadManager sharedDownloadManager] downFileUrl:url filename:name fileimage:nil];
//    // 设置最多同时下载个数（默认是3）
//    [ZFDownloadManager sharedDownloadManager].maxCount = 4;
}

#pragma mark - Getter

- (ZFPlayerModel *)playerModel
{
    if (!_playerModel) {
        _playerModel                  = [[ZFPlayerModel alloc] init];
        _playerModel.title            = [self.fileModel.fileName stringByURLDecode];
        if ([self.fileModel.fileName.pathExtension isEqualToString:@"m3u8"]) {
            NSString *urlStr = [NSString stringWithFormat:@"http://127.0.0.1:6398/%@",[self.fileModel.fileName stringByURLEncode]];
            _playerModel.videoURL  = [NSURL URLWithString:urlStr];
        }else{
            _playerModel.videoURL         = [[NSURL fileURLWithPath:self.fileModel.filePath] URLByAppendingPathComponent:self.fileModel.fileName];
        }
        
        _playerModel.placeholderImage = [UIImage imageNamed:@"loading_bgView1"];
        _playerModel.fatherView       = self.view;
    }
    return _playerModel;
}



//- (BOOL)shouldAutorotate
//
//{
//    
//    return NO;
//    
//}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations

{
    
    return UIInterfaceOrientationMaskLandscape;
    
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation

{
    
    return UIInterfaceOrientationLandscapeRight;
    
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
