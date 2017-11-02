//
//  BookMarketTableViewCell.m
//  downloader
//
//  Created by xueyognwei on 2017/3/30.
//  Copyright © 2017年 xueyognwei. All rights reserved.
//

#import "BookMarketTableViewCell.h"

@implementation BookMarketTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void)setModel:(BookMarketModel *)model
{
    _model = model;
//    self.accessoryType = model.isFavourite ? UITableViewCellAccessoryDisclosureIndicator:UITableViewCellAccessoryNone;
    self.bookMarkTitle.text = model.title;
//    self.bookMarkImageView.image = [UIImage imageNamed:@"Galaxy"];
    
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
