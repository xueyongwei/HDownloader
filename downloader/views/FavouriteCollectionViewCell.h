//
//  FavouriteCollectionViewCell.h
//  downloader
//
//  Created by xueyognwei on 2017/3/29.
//  Copyright © 2017年 xueyognwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookMarketModel.h"
@interface FavouriteCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) BookMarketModel *model;

@property (nonatomic, assign) BOOL inEditState; //是否处于编辑状态

- (void)setModel:(BookMarketModel *)model indexPaht:(NSIndexPath *)indexPath;

@property (nonatomic, strong) UILabel *messageLabel;

- (void)addMeaageLabel;
@end
