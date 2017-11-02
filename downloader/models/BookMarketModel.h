//
//  BookMarketModel.h
//  downloader
//
//  Created by xueyognwei on 2017/3/29.
//  Copyright © 2017年 xueyognwei. All rights reserved.
//

#import "BaseModel.h"
#import <NSObject+YYModel.h>
@interface BookMarketModel : BaseModel
@property (nonatomic, assign) NSInteger modelID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign) NSInteger isFavourite;
@property (nonatomic, assign) NSInteger index;
@end
