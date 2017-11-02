//
//  ADModel.h
//  downloader
//
//  Created by xueyognwei on 2017/4/19.
//  Copyright © 2017年 xueyognwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ADModel : NSObject
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *banner;
@property (nonatomic,copy) NSString *desc;
@property (nonatomic,copy) NSString *icon;
@property (nonatomic,copy) NSString *url;
@property (nonatomic,assign) CGFloat rating;
@property (nonatomic,assign) BOOL closeable;
@property (nonatomic,copy) NSString *price;
@end
