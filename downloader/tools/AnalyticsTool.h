//
//  AnalyticsTool.h
//  downloader
//
//  Created by xueyognwei on 2017/4/17.
//  Copyright © 2017年 xueyognwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AnalyticsTool : NSObject
+(void)analyCategory:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value;
+(void)setScreenName:(NSString *)screenName;
@end
