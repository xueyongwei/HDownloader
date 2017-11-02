//
//  XYWMDACollectionViewLayout.h
//  downloader
//
//  Created by xueyognwei on 2017/3/29.
//  Copyright © 2017年 xueyognwei. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol XYWMDACollectionViewLayoutDelegate <NSObject>

/**
 * 更新数据源
 */
- (void)moveItemAtIndexPath:(NSIndexPath *)formPath toIndexPath:(NSIndexPath *)toPath;

/**
 * 改变编辑状态
 */
- (void)didChangeEditState:(BOOL)inEditState;

@end

@interface XYWMDACollectionViewLayout : UICollectionViewFlowLayout
@property (nonatomic, assign) BOOL inEditState; //检测是否处于编辑状态
@property (nonatomic, weak) id<XYWMDACollectionViewLayoutDelegate> delegate;
@end
