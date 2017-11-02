//
//  UIFActionSheet.h
//  downloader
//
//  Created by xueyognwei on 2017/4/26.
//  Copyright © 2017年 xueyognwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIFActionSheet : UIActionSheet
@property (nonatomic,copy)NSString *name;
@property (nonatomic,strong)NSDictionary *userInfo;
@end
