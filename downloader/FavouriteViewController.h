//
//  WebStartViewController.h
//  XYWProject
//
//  Created by xueyognwei on 2017/3/22.
//  Copyright © 2017年 薛永伟. All rights reserved.
//

#import "BaseViewController.h"
@protocol FavouriteViewControllerDelegate <NSObject> // 代理传值方法
-(void)setFavouriteEditting:(BOOL)editing;
-(void)hiddenKeyboard;
-(void)requelsBookmarkURlStr:(NSString *)content;
@end
@interface FavouriteViewController : BaseViewController
@property (nonatomic,weak) id<FavouriteViewControllerDelegate> delegate;
-(void)finishEdit;
@end
