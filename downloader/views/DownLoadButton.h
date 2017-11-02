//
//  DownLoadButton.h
//  downloader
//
//  Created by xueyognwei on 2017/3/28.
//  Copyright © 2017年 xueyognwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownLoadButton : UIButton
/**
 *  进度:0~1
 */
@property (nonatomic, assign) CGFloat progress;
/**
 *  进度宽
 */
@property (nonatomic, assign) CGFloat progressWidth;
/**
 *  是否下载成功
 */
@property (nonatomic, assign) BOOL isSuccess;
@end
