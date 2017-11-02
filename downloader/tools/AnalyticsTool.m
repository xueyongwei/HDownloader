//
//  AnalyticsTool.m
//  downloader
//
//  Created by xueyognwei on 2017/4/17.
//  Copyright © 2017年 xueyognwei. All rights reserved.
//

#import "AnalyticsTool.h"
#import <Google/Analytics.h>
@implementation AnalyticsTool
+(void)analyCategory:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category
                                                          action:action
                                                           label:label
                                                           value:value] build]];
}
+(void)setScreenName:(NSString *)screenName
{
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:kGAIScreenName
           value:screenName];
    
    // Previous V3 SDK versions
    // [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    // New SDK versions
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}
@end
