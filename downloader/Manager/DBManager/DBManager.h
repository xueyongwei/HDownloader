//
//  DBManager.h
//  downloader
//
//  Created by xueyognwei on 2017/4/20.
//  Copyright © 2017年 xueyognwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"
@interface DBManager : NSObject
+(instancetype)shareInstance;
@property (nonatomic,strong) FMDatabaseQueue *dbQueue;
@end
