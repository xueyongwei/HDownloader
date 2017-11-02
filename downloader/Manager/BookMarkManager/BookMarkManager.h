//
//  BookMarkManager.h
//  downloader
//
//  Created by xueyognwei on 2017/3/30.
//  Copyright © 2017年 xueyognwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BookMarketModel.h"
typedef NS_OPTIONS(NSUInteger, BookMarketType) {
    BookMarketTypeNormal       = 0,
    BookMarketTypeFavourite  = 1 << 0,
};
@interface BookMarkManager : NSObject
+(instancetype)shareInstance;
-(void)defauldConfig;

- (void)insertBookMarkModel:(BookMarketModel *)model;
- (void)deleteBookMarkModel:(BookMarketModel *)model;
- (void)updateBookMarkModel:(BookMarketModel *)model;
-(void)reSortBookMarkModels:(NSArray *)models;
-(NSArray *)queryAllbookMarksOfType:(BookMarketType)type;
@end
