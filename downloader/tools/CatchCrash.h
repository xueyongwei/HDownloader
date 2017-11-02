//
//  CatchCrash.h
//  downloader
//
//  Created by xueyognwei on 2017/4/21.
//  Copyright © 2017年 xueyognwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CatchCrash : NSObject
void uncaughtExceptionHandler(NSException *exception);
@end
