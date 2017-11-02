//
//  PlayerViewController.h
//  downloader
//
//  Created by xueyognwei on 2017/4/1.
//  Copyright © 2017年 xueyognwei. All rights reserved.
//

#import "BaseViewController.h"
#import "FileModel.h"
@interface PlayerViewController : BaseViewController
/** 视频URL */

@property (nonatomic, strong) FileModel *fileModel;
@end
