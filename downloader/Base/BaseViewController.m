//
//  BaseViewController.m
//  XYWProject
//
//  Created by 薛永伟 on 2017/3/11.
//  Copyright © 2017年 薛永伟. All rights reserved.
//

#import "BaseViewController.h"
#import "FBADPlacementIDTool.h"
@interface BaseViewController ()
@end

@implementation BaseViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    //防止没有背景色导致的卡顿和黑屏
    self.navigationController.view.backgroundColor = [UIColor whiteColor];
    self.view.backgroundColor = [UIColor whiteColor];
    //[self setNavigationBarFont: [UIFont systemFontOfSize:16] ForegroundColor:[UIColor redColor]];
//    [self setNavigationBarBackgroundImage:[UIImage imageNamed:@"apple"] shadowImage:[UIImage imageWithColor:[UIColor redColor]]];
    
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString *)placementID{
    NSString *vc = NSStringFromClass([self class]);
    DDLogInfo(@"get placementID of %@",vc);
    if ([vc isEqualToString:@"SettingViewController"]) {
        return @"491292214594434_500961830294139";
    }else if ([vc isEqualToString:@"FilesViewController"]){
        return @"491292214594434_500960513627604";
    }else if ([vc isEqualToString:@"DownloadsViewController"]){
        return @"491292214594434_500961226960866";
    }else if ([vc isEqualToString:@"BrowserViewController"]){
        return @"491292214594434_492781944445461";
    }
    return @"491292214594434_492781944445461";
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
