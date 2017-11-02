//
//  ShareTool.m
//  dsaf
//
//  Created by 陈志超 on 2016/12/7.
//  Copyright © 2016年 huaban. All rights reserved.
//

#import "ShareTool.h"
#import <UIKit/UIKit.h>
#import "AppDelegate.h"
NSString * const ActivityServiceBookmark = @"Bookmark";
NSString * const ActivityServiceFarvorite = @"Farvorite";
NSString * const ActivityServiceSafari = @"Safari";
@interface HBShareBaseActivity : UIActivity
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *type;
@property (nonatomic) NSString *urlString;
@property (nonatomic) NSString *shareDescription;
@property (nonatomic) NSString *shareTitle;
@property (nonatomic) UIImage *image;

- (instancetype)initWithTitle:(NSString *)title type:(NSString *)type;
@end

@implementation HBShareBaseActivity
- (instancetype)initWithTitle:(NSString *)title type:(NSString *)type
{
    if (self = [super init]) {
        self.title = title;
        self.type = type;
    }
    return self;
}
- (NSString *)activityTitle{
    return self.title;
}

- (NSString *)activityType{
    return self.type;
}

- (UIImage *)activityImage
{
    NSString *imageName = [self imageNameWith:self.type];
    
    return [UIImage imageNamed:imageName];
}
-(NSString *)imageNameWith:(NSString *)type
{
    if ([type isEqualToString:ActivityServiceFarvorite]) {
        return @"bokmarkfavourite";
    }else if ([type isEqualToString:ActivityServiceBookmark]){
        return @"bookmark";
    }else if ([type isEqualToString:ActivityServiceSafari]){
        return @"websafari";
    }
    return nil;
}
- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems{
    return YES;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    
}

- (void)performActivity
{
    if ([self.type isEqualToString:ActivityServiceFarvorite]) {
        DDLogInfo(@"ActivityServiceFarvorite地址：%@",self.urlString);
        AppDelegate *tempAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UINavigationController *webNavi = tempAppDelegate.window.rootViewController.childViewControllers.firstObject;
        [webNavi.childViewControllers.firstObject performSegueWithIdentifier:@"AddBookMark" sender:ActivityServiceFarvorite];
    }else if ([self.type isEqualToString:ActivityServiceBookmark]){
        DDLogInfo(@"ActivityServiceBookmark地址：%@",self.urlString);
        AppDelegate *tempAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        UINavigationController *webNavi = tempAppDelegate.window.rootViewController.childViewControllers.firstObject;
        [webNavi.childViewControllers.firstObject performSegueWithIdentifier:@"AddBookMark" sender:ActivityServiceBookmark];
    }else if ([self.type isEqualToString:ActivityServiceSafari]){
        DDLogInfo(@"ActivityServiceSafari地址：%@",self.urlString);
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.urlString]];
    }
}
@end

@interface ShareTool()
@property (nonatomic, copy) UIActivityViewControllerCompletionHandler completionHandler;
@end
@implementation ShareTool
- (void)shareWithTitle:(NSString *)title description:(NSString *)description url:(NSString *)url image:(UIImage *)image completionHandler:(UIActivityViewControllerCompletionHandler)completionHandler
{
    NSMutableArray *items = [[NSMutableArray alloc] init];
//    [items addObject:title?:@""];
    if (image) {
        [items addObject:image];
    }
    if (url) {
        [items addObject:url];
    }
    NSMutableArray *activities = [[NSMutableArray alloc] init];
    HBShareBaseActivity *farvoriteActivity = [[HBShareBaseActivity alloc] initWithTitle:@"Add to Farvorite" type:ActivityServiceFarvorite];
    HBShareBaseActivity *bookMarkActivity = [[HBShareBaseActivity alloc] initWithTitle:@"Add Bookmark" type:ActivityServiceBookmark];
    HBShareBaseActivity *safariActivity = [[HBShareBaseActivity alloc] initWithTitle:@"Open in Safari" type:ActivityServiceSafari];
    [@[farvoriteActivity, bookMarkActivity,safariActivity] enumerateObjectsUsingBlock:^(HBShareBaseActivity *activity, NSUInteger idx, BOOL *stop) {
        activity.urlString = url;
        activity.shareDescription = description;
        activity.shareTitle = title;
        activity.image = image;
    }];
    [activities addObjectsFromArray:@[bookMarkActivity,farvoriteActivity,safariActivity]];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:items applicationActivities:activities];
    NSMutableArray *excludedActivityTypes =  [NSMutableArray arrayWithArray:@[UIActivityTypePrint, UIActivityTypePostToTencentWeibo]];

    activityViewController.excludedActivityTypes = excludedActivityTypes;
    AppDelegate *tempAppDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    
//    activityViewController.popoverPresentationController.sourceRect = tempAppDelegate.window.rootViewController.view.bounds;
//    activityViewController.popoverPresentationController.sourceView = tempAppDelegate.window.rootViewController.view;
    UIViewController *vc =tempAppDelegate.window.rootViewController.childViewControllers.firstObject;
    //if iPhone
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [vc presentViewController:activityViewController animated:YES completion:nil];
    }
    //if iPad
    else {
        // Change Rect to position Popover
        UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
        [popup presentPopoverFromRect:CGRectMake(vc.view.frame.size.width/3*2, vc.view.frame.size.height-95, 0, 0)inView:vc.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
    }

    activityViewController.completionHandler = ^(NSString *activityType, BOOL complted){
        if (completionHandler) {
            completionHandler(activityType, complted);
            self.completionHandler = nil;
        }
    };
}

@end
















