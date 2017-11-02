//
//  DownLoadButton.m
//  downloader
//
//  Created by xueyognwei on 2017/3/28.
//  Copyright © 2017年 xueyognwei. All rights reserved.
//

#import "DownLoadButton.h"

@interface DownLoadButton()
//进度圈
@property (nonatomic, strong) CAShapeLayer *realCircleLayer;
//箭头
@property (nonatomic, strong) CAShapeLayer *arrowLayer;
@end

@implementation DownLoadButton
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize{
    self.progressWidth = 1;
}
//下载圈
- (CAShapeLayer *)realCircleLayer{
    if (!_realCircleLayer) {
        _realCircleLayer = [self getOriginLayer];
        _realCircleLayer.strokeColor = [UIColor colorWithHexString:@"007aff"].CGColor;
        
        [self.imageView.layer addSublayer:self.realCircleLayer];
    }
    return _realCircleLayer;
}
- (CAShapeLayer *)getOriginLayer{
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    
//    CGRect frame = CGRectMake(self.center.x-12, self.center.y-12, 24, 24);
//    layer.frame = frame;
//    layer.frame = [self bounds];
//    layer.center = self.center;
    layer.frame = self.imageView.bounds;
    layer.lineWidth = self.progressWidth;
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.lineCap = kCALineCapRound;
    return layer;
}
- (void)setProgress:(CGFloat)progress{
    
    _progress = MAX( MIN(progress, 1.0), 0.0); // keep it between 0 and 1
    //进度
    self.realCircleLayer.path = [self getCirclePathWithProgress:_progress].CGPath;
}
- (UIBezierPath *)getCirclePathWithProgress:(CGFloat)progress
{
//    CGFloat squareW = CGRectGetWidth(self.realCircleLayer.frame)/2;
//    CGFloat squareH = CGRectGetHeight(self.realCircleLayer.frame)/2;
    CGFloat squareW = CGRectGetWidth(self.imageView.bounds)/2;
    CGFloat squareH = CGRectGetHeight(self.imageView.bounds)/2;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(squareW, squareH)
                                                        radius:squareW-1/[UIScreen mainScreen].scale
                                                    startAngle: - M_PI_2
                                                      endAngle: (M_PI * 2) * progress - M_PI_2
                                                     clockwise:YES];
    return path;
}
-(void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    self.realCircleLayer.hidden = !selected;
}
@end
