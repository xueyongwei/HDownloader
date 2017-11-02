//
//  RootViewController.h
//  downloader
//
//  Created by xueyognwei on 2017/3/24.
//  Copyright © 2017年 xueyognwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ADModel.h"
@interface RootViewController : UITabBarController
-(void)requestIPinfo;
-(BOOL)showServerAD;
@end
