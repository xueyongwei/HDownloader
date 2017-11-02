//
//  DownloadTaskTableViewCell.h
//  downloader
//
//  Created by xueyognwei on 2017/3/27.
//  Copyright © 2017年 xueyognwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DownloadManager.h"
#import "DownLoadButton.h"
@interface DownloadTaskTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *videoNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *videoSizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *downloadSpeedLabel;
@property (weak, nonatomic) IBOutlet DownLoadButton *downLoadBtn;
@property (nonatomic,strong) DownloadModel *downloadModel;
//@property (strong, nonatomic) id downloader;
//-(void)setDownLoadSize:(int64_t)current total:(int64_t)total;
//-(void)setDownloadSpeed:(int64_t)speed;
@end
