//
//  ADalertViewController.m
//  downloader
//
//  Created by xueyognwei on 2017/4/14.
//  Copyright © 2017年 xueyognwei. All rights reserved.
//

#import "ADalertViewController.h"

@interface ADalertViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *iconImgV;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UIImageView *bannerImgV;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;

@end

@implementation ADalertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self customUI];
    self.view.backgroundColor = [UIColor colorWithHexString:@"BDBDBD"];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onInstallNowClick:)];
    [self.view addGestureRecognizer:tap];
}
-(void)customUI{
    self.titleLabel.text = self.model.title;
    self.descLabel.text = self.model.desc;
    [self.iconImgV setImageWithURL:[NSURL URLWithString:self.model.icon] options:YYWebImageOptionIgnoreAnimatedImage];
    [self.bannerImgV setImageWithURL:[NSURL URLWithString:self.model.banner] options:YYWebImageOptionIgnoreAnimatedImage];
    self.closeBtn.hidden = !self.model.closeable;
}
- (IBAction)onDisMissClcik:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)onInstallNowClick:(UIButton *)sender {
    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:self.model.url]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
