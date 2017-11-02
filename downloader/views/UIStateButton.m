//
//  UIStateButton.m
//  downloader
//
//  Created by 薛永伟 on 2017/3/30.
//  Copyright © 2017年 xueyognwei. All rights reserved.
//

#import "UIStateButton.h"

@implementation UIStateButton
-(void)setHighlighted:(BOOL)highlighted
{
    if (highlighted) {
        self.backgroundColor = [UIColor colorWithWhite:0.7 alpha:0.5];
    }else{
        self.backgroundColor = [UIColor clearColor];
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
