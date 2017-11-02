//
//  XYWVersonManager.h
//  downloader
//
//  Created by xueyognwei on 2017/5/2.
//  Copyright © 2017年 xueyognwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XYWVersonManager : NSObject
+(CGFloat)lastVersionInter;
+(CGFloat)currentVersionInter;
+(BOOL)firstLanchOnlyThisVersion:(BOOL)onlyThisVersion;
@end
