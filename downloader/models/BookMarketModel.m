//
//  BookMarketModel.m
//  downloader
//
//  Created by xueyognwei on 2017/3/29.
//  Copyright © 2017年 xueyognwei. All rights reserved.
//

#import "BookMarketModel.h"

@implementation BookMarketModel
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [self modelEncodeWithCoder:aCoder];
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    return [self modelInitWithCoder:aDecoder];
}
@end
