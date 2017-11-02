//
//  FavouriteCollectionViewCell.m
//  downloader
//
//  Created by xueyognwei on 2017/3/29.
//  Copyright © 2017年 xueyognwei. All rights reserved.
//

#import "FavouriteCollectionViewCell.h"
@interface FavouriteCollectionViewCell ()

@property (nonatomic, strong) UIImageView *imageView;

@end
@implementation FavouriteCollectionViewCell
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self).offset(15);
//            make.centerX.equalTo(self);
//            make.width.height.mas_equalTo(60);
            make.edges.equalTo(self).with.insets(UIEdgeInsetsMake(10, 10, 20, 10));
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.imageView.mas_bottom).offset(7);
            make.bottom.equalTo(self.mas_bottom);
            make.left.and.right.equalTo(self);
        }];
        
        [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top);
            make.right.equalTo(self.mas_right);
            make.height.equalTo(@15);
            make.width.equalTo(@15);
        }];
        self.button.hidden = YES;
    }
    return self;
}

- (void)addMeaageLabel
{
    [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
}

- (void)setModel:(BookMarketModel *)model indexPaht:(NSIndexPath *)indexPath
{
    if (_model != model) {
        _model = model;
        self.titleLabel.text = model.title;
        NSDictionary *dict  =@{NSFontAttributeName:[UIFont systemFontOfSize:18] };
        [model.title drawInRect:self.imageView.frame withAttributes:dict];
//        [self.button setBackgroundImage:[UIImage imageNamed:@"life_reduce"] forState:UIControlStateNormal];
//        self.button.backgroundColor = [UIColor redColor];
        self.button.userInteractionEnabled = YES;
//        self.imageView.image = [UIImage imageWithEmoji:@"A" size:15];
        self.imageView.image = [self webIconImage];
    }
    
}

-(UIImage *)webIconImage{
    if ([self.model.url containsString:@"9gag.com"]) {
        return [UIImage imageNamed:@"9gag"];
    }else if ([self.model.url containsString:@"youtube.com"]){
        return [UIImage imageNamed:@"youtube"];
    }else if ([self.model.url containsString:@"viewster.com"]){
        return [UIImage imageNamed:@"viewster"];
    }else if ([self.model.url containsString:@"liveleak.com"]){
        return [UIImage imageNamed:@"liveleak"];
    }else if ([self.model.url containsString:@"vine.co"]){
        return [UIImage imageNamed:@"vine"];
    }else if ([self.model.url containsString:@"facebook.com"]){
        return [UIImage imageNamed:@"facebook"];
    }else if ([self.model.url containsString:@"instagram.com"]){
        return [UIImage imageNamed:@"instagram"];
    }else if ([self.model.url containsString:@"tumblr.com"]){
        return [UIImage imageNamed:@"tumblr"];
    }else{
        [self setNeedsLayout];
        [self layoutIfNeeded];
        __weak typeof(self) wkSelf = self;
        UIImage *defaultImg =  [UIImage imageWithSize:CGSizeMake(30, 30) drawBlock:^(CGContextRef  _Nonnull context) {
            NSMutableParagraphStyle *paragraph=[[NSMutableParagraphStyle alloc]init];
            paragraph.alignment=NSTextAlignmentCenter;//居中
            if (wkSelf.model.title.length>0) {
                [[[wkSelf.model.title substringToIndex:1] uppercaseString] drawInRect:CGRectMake(0, 5, 30, 30) withAttributes:@{ NSFontAttributeName :[UIFont fontWithName : @"Arial-BoldMT" size : 20 ], NSForegroundColorAttributeName :[ UIColor whiteColor] ,NSParagraphStyleAttributeName:paragraph}];
            }
            
            
//            [@"A" drawAtPoint : self.imageView.center withAttributes : @{ NSFontAttributeName :[ UIFont fontWithName : @"Arial-BoldMT" size : 30 ], NSForegroundColorAttributeName :[ UIColor whiteColor] } ];
        }];
        return defaultImg;
    }
    return nil;
}

#pragma mark - 是否处于编辑状态

- (void)setInEditState:(BOOL)inEditState
{
    if (inEditState && _inEditState != inEditState) {
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = [UIColor colorWithHexString:@"c1c1c1"].CGColor;
        self.button.hidden = NO;
    } else {
        self.layer.borderColor = [UIColor clearColor].CGColor;
        self.button.hidden = YES;
    }
}

#pragma mark - init

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.image = [UIImage imageNamed:@"Galaxy"];
        _imageView.backgroundColor = [UIColor colorWithHexString:@"dfdfdf"];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_imageView];
    }
    return _imageView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:12];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor colorWithHexString:@"797979"];
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UILabel *)messageLabel
{
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.font = [UIFont systemFontOfSize:12];
        _messageLabel.textColor = [UIColor colorWithHexString:@"797979"];
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.text = @" ";
        [self addSubview:_messageLabel];
    }
    return _messageLabel;
}

- (UIButton *)button
{
    if (!_button) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
        _button.layer.cornerRadius = 7.5;
        [self addSubview:_button];
    }
    return _button;
}

@end
