//
//  BookMarketTableViewCell.h
//  downloader
//
//  Created by xueyognwei on 2017/3/30.
//  Copyright © 2017年 xueyognwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BookMarketModel.h"
@interface BookMarketTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *bookMarkTitle;
@property (weak, nonatomic) IBOutlet UIImageView *bookMarkImageView;
@property (nonatomic,weak) BookMarketModel *model;
@end
