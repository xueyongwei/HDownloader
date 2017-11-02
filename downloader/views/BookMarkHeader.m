//
//  BookMarkHeader.m
//  downloader
//
//  Created by 薛永伟 on 2017/3/30.
//  Copyright © 2017年 xueyognwei. All rights reserved.
//

#import "BookMarkHeader.h"

@interface BookMarkHeader()
@property (weak, nonatomic) IBOutlet UIImageView *iconImgV;

@end
@implementation BookMarkHeader

- (void)awakeFromNib {
    [super awakeFromNib];
    self.autoresizingMask = UIViewAutoresizingNone;
   
}
-(void)setUserInteractionEnabled:(BOOL)userInteractionEnabled
{
    [super setUserInteractionEnabled:userInteractionEnabled];
    self.iconImgV.image = userInteractionEnabled? [UIImage imageNamed:@"bokmarkfavouriteL"]:[UIImage imageNamed:@"bokmarkfavouriteD"];
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha =userInteractionEnabled?1:0.5;
//        self.corverView.alpha = userInteractionEnabled?0:1;
    }];
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
