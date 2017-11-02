//
//  SettingViewController.m
//  downloader
//
//  Created by xueyognwei on 2017/3/24.
//  Copyright © 2017年 xueyognwei. All rights reserved.
//

#import "SettingViewController.h"
#import <MessageUI/MessageUI.h>
#import <StoreKit/StoreKit.h>
#import "UserDefaultManager.h"
#import <Social/Social.h>
#import "CoreStatus.h"
#import "DownloadManager.h"
#import <FBAudienceNetwork/FBAudienceNetwork.h>
#import "HYFileManager.h"
@interface SettingViewController ()<UITableViewDelegate,UITableViewDataSource,MFMailComposeViewControllerDelegate,SKStoreProductViewControllerDelegate,UIActionSheetDelegate,FBAdViewDelegate>
@property (nonatomic,strong)NSMutableArray *dataSource;
@property (nonatomic,strong)UIView *tableViewHeaderView;
@property (weak, nonatomic) IBOutlet UIView *adView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *adViewHeightConst;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *settingBarBtn;
@property (weak, nonatomic) IBOutlet UILabel *settingAppVersonLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
//@property (nonatomic,strong)UIView *tableViewFooterView;
@end

@implementation SettingViewController
-(UIView *)tableViewHeaderView
{
    if (!_tableViewHeaderView ) {
        _tableViewHeaderView = [[[NSBundle mainBundle]loadNibNamed:@"SettingTableHeaderView" owner:self options:nil]lastObject];
        _tableViewHeaderView.autoresizingMask = NO;
        self.settingAppVersonLabel.text = [NSString stringWithFormat:@"Super Saver V%@",[UIApplication sharedApplication].appVersion];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(reportBug:)];
        tap.numberOfTouchesRequired = 1;
        tap.numberOfTapsRequired = 10;
        [self.settingAppVersonLabel addGestureRecognizer:tap];
        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(reportAllInfo:)];
        tap1.numberOfTouchesRequired = 2;
        tap1.numberOfTapsRequired = 10;
        [self.settingAppVersonLabel addGestureRecognizer:tap];
        [self.settingAppVersonLabel addGestureRecognizer:tap1];
    }
    return _tableViewHeaderView;
}
-(void)reportAllInfo:(UITapGestureRecognizer *)tap{
    DDLogVerbose(@"aaa");
    MFMailComposeViewController *mailCompose = [[MFMailComposeViewController alloc] init];
    // 设置邮件代理
    [mailCompose setMailComposeDelegate:self];
    // 设置邮件主题
    [mailCompose setSubject:@"downloader debug"];
    // 设置收件人
    [mailCompose setToRecipients:@[@"xueyongwei@foxmail.com"]];
    
    NSString *mailBody = [NSString stringWithFormat:@"</br></br></br></br>My system is iOS %.2f,using Downloader v%@ ",[UIDevice systemVersion],[UIApplication sharedApplication].appVersion];
    [mailCompose setMessageBody:mailBody isHTML:YES];
    // 如使用HTML格式，则为以下代码
    //	[mailCompose setMessageBody:@"<html><body><p>Hello</p><p>World！</p></body></html>" isHTML:YES];
    /**
     *  添加附件
     */
    //    UIImage *image = [UIImage imageNamed:@"image"];
    //    NSData *imageData = UIImagePNGRepresentation(image);
    //    [mailCompose addAttachmentData:imageData mimeType:@"" fileName:@"custom.png"];
        NSString *dbPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"downloader.db"];
        NSData *db = [NSData dataWithContentsOfFile:dbPath];
    if (db) {
        [mailCompose addAttachmentData:db mimeType:@"" fileName:@"downloader.db"];
    }
    NSString *logDir = [[HYFileManager cachesDir] stringByAppendingPathComponent:@"Logs"];
    NSArray *files = [HYFileManager listFilesInDirectoryAtPath:logDir deep:NO];
    for (NSString *fileName in files) {
        NSData *pdf = [NSData dataWithContentsOfFile:[logDir stringByAppendingPathComponent:fileName]];
        if (pdf) {
            [mailCompose addAttachmentData:pdf mimeType:@"" fileName:fileName];
        }
    }
    // 弹出邮件发送视图
    [self presentViewController:mailCompose animated:YES completion:nil];
}

-(void)reportBug:(UITapGestureRecognizer *)tap{
    // 邮件服务器
    MFMailComposeViewController *mailCompose = [[MFMailComposeViewController alloc] init];
    // 设置邮件代理
    [mailCompose setMailComposeDelegate:self];
    // 设置邮件主题
    [mailCompose setSubject:@"downloader debug"];
    // 设置收件人
    [mailCompose setToRecipients:@[@"xueyongwei@foxmail.com"]];
    
    NSString *mailBody = [NSString stringWithFormat:@"</br></br></br></br>My system is iOS %.2f,using Downloader v%@ ",[UIDevice systemVersion],[UIApplication sharedApplication].appVersion];
    [mailCompose setMessageBody:mailBody isHTML:YES];

    NSString *errorLogPath = [NSString stringWithFormat:@"%@/Documents/error.log", NSHomeDirectory()];
    NSData *pdf = [NSData dataWithContentsOfFile:errorLogPath];
    if (pdf) {
        [mailCompose addAttachmentData:pdf mimeType:@"" fileName:@"crash.data"];
    }
    
    // 弹出邮件发送视图
    [self presentViewController:mailCompose animated:YES completion:nil];
    
}
//-(UIView *)tableViewFooterView
//{
//    if (!_tableViewFooterView) {
//        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, YYScreenSize().width, 50)];
//        view.backgroundColor = [UIColor redColor];
//        _tableViewFooterView = view;
//    }
//    return _tableViewFooterView;
//}
-(NSMutableArray *)dataSource
{
    if (!_dataSource ) {
        _dataSource = [NSMutableArray arrayWithObjects:@[
                                                         NSLocalizedString(@"Only use WiFi to download", nil) ,
                                                         NSLocalizedString(@"Search Engine", nil) ,
                                                         ],@[
                                                             NSLocalizedString(@"Rate us", nil) ,
                                                             NSLocalizedString(@"Share App", nil) ,
                                                             NSLocalizedString(@"Contact Developer", nil)  ,
                                                             ], nil];
    }
    return _dataSource;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self customTableView];
    FBAdView *adView =
    [[FBAdView alloc] initWithPlacementID:self.placementID
                                   adSize:kFBAdSizeHeight50Banner
                       rootViewController:self];
    
    adView.delegate = self;
    
    [adView loadAd];
    [self.adView addSubview:adView];
    [AnalyticsTool setScreenName:self.navigationItem.title];
    // Do any additional setup after loading the view.
}

-(void)customTableView{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableViewHeaderView.frame = CGRectMake(0, 0, YYScreenSize().width, 200);
    self.tableView.tableHeaderView = self.tableViewHeaderView;
    //    self.tableViewFooterView.frame = CGRectMake(0, 0, YYScreenSize().width, 50);
    //    self.tableView.tableFooterView = self.tableViewFooterView;
}
#pragma mark -- tableView代理
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arr = self.dataSource[section];
    return arr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell ;
    if (indexPath.section == 0 && indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"switchCellID"];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"switchCellID"];
            cell.accessoryType = UITableViewCellAccessoryNone;
            UISwitch *switchBtn = [[UISwitch alloc]init];
            switchBtn.onTintColor = [UIColor colorWithHexString:@"2d98ff"];
            [cell.contentView addSubview:switchBtn];
            [switchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(cell.contentView);
                make.right.equalTo(cell.contentView).offset(-15);
            }];
            [switchBtn addTarget:self action:@selector(wifiOnlyChanged:) forControlEvents:UIControlEventValueChanged];
            switchBtn.on = [UserDefaultManager isOnlyDownloadWhenWIFI];
        }
    }else{
        cell = [tableView dequeueReusableCellWithIdentifier:@"detailCellID"];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"detailCellID"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        
    }
    cell.textLabel.text = self.dataSource[indexPath.section][indexPath.row];
    if (indexPath.section == 0 && indexPath.row == 1) {
        if (![UserDefaultManager currentSearchEngine]) {
            cell.detailTextLabel.text = @"Google";
        }else{
            [self setCellSearchEngineText:[UserDefaultManager currentSearchEngine] inCell:cell];
        }
    }else{
        cell.detailTextLabel.text = @"";
    }
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    //    return 30;
    return section==1?40:30;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}
-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return section==0?@"":NSLocalizedString(@"Need help？Drop us a letter at hdownloaderapp@gmail.com", nil) ;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section ==0) {
        if (indexPath.row ==1) {
            [AnalyticsTool analyCategory:@"Settings" action:@"点击【Search Engine】" label:nil value:nil];
            UIActionSheet *action = [[UIActionSheet alloc]initWithTitle:NSLocalizedString(@"Search Engine", nil)  delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil)  destructiveButtonTitle:nil otherButtonTitles:@"Google",@"YouTube",@"Bing", nil];
            [action showInView:self.view];
        }
    }else if (indexPath.section == 1){
        if (indexPath.row == 0) {
            [AnalyticsTool analyCategory:@"Settings" action:@"点击【Rate us】" label:nil value:nil];
            
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=1226848385"]];
            [UserDefaultManager set5StarsDone];
        }else if (indexPath.row == 1){
            [self shareApp];
            [AnalyticsTool analyCategory:@"Settings" action:@"点击【Share app】" label:nil value:nil];
        }else if (indexPath.row == 2){
            [AnalyticsTool analyCategory:@"Settings" action:@"点击【Contact Developer】" label:nil value:nil];
            if ([MFMailComposeViewController canSendMail]) { // 用户已设置邮件账户
                [self sendEmailAction]; // 调用发送邮件的代码
            }
        }
    }
}
//触发的功能
-(void)wifiOnlyChanged:(UISwitch *)sender{
    [UserDefaultManager setOnlyDownloadWhenWIFI:sender.on];
    BOOL wifi = [CoreStatus isWifiEnable];
    if (!wifi) {
        if (sender.on) {//限制了网络下载
            [AnalyticsTool analyCategory:@"Files" action:@"点击只wifi下下载的开关" label:@"开" value:nil];
            [[DownloadManager shareInstance] wattingForNetwork];
        }else{
            [AnalyticsTool analyCategory:@"Files" action:@"点击只wifi下下载的开关" label:@"关" value:nil];
            [[DownloadManager shareInstance] _tryToOpenNewDownloadTask];
        }
    }
}
- (void)openAppWithIdentifier:(NSString *)appId {
    SKStoreProductViewController *storeProductVC = [[SKStoreProductViewController alloc] init];
    storeProductVC.delegate = self;
    
    NSDictionary *dict = [NSDictionary dictionaryWithObject:appId forKey:SKStoreProductParameterITunesItemIdentifier];
    [storeProductVC loadProductWithParameters:dict completionBlock:^(BOOL result, NSError *error) {
        if (result) {
            [self presentViewController:storeProductVC animated:YES completion:nil];
        }
    }];
}
- (void)productViewControllerDidFinish:(SKStoreProductViewController *)storeProductVC {
    [storeProductVC dismissViewControllerAnimated:YES completion:^{
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
}
- (void)sendEmailAction
{
    // 邮件服务器
    MFMailComposeViewController *mailCompose = [[MFMailComposeViewController alloc] init];
    if (!mailCompose) {
        return;
    }
    // 设置邮件代理
    [mailCompose setMailComposeDelegate:self];
    // 设置邮件主题
    [mailCompose setSubject:@"downloader report"];
    // 设置收件人
    [mailCompose setToRecipients:@[@"hdownloaderapp@gmail.com"]];
    //    // 设置抄送人
    //    [mailCompose setCcRecipients:@[@"xueyongwei@eoemarket.com"]];
    //    // 设置密抄送
    //    [mailCompose setBccRecipients:@[@"shana_happy@126.com"]];
    /**
     *  设置邮件的正文内容
     */
    //    NSString *emailContent = @"我是邮件内容";
    //    // 是否为HTML格式
    //    [mailCompose setMessageBody:emailContent isHTML:NO];
    NSString *mailBody = [NSString stringWithFormat:@"</br></br></br></br> iOS %.2f, Downloader v%@ ",[UIDevice systemVersion],[UIApplication sharedApplication].appVersion];
    [mailCompose setMessageBody:mailBody isHTML:YES];
    // 如使用HTML格式，则为以下代码
    //	[mailCompose setMessageBody:@"<html><body><p>Hello</p><p>World！</p></body></html>" isHTML:YES];
    /**
     *  添加附件
     */
    //    NSString *dbPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"downloader.db"];
    //    NSData *pdf = [NSData dataWithContentsOfFile:dbPath];
    //    [mailCompose addAttachmentData:pdf mimeType:@"" fileName:@"downloader.db"];
    //
    //    NSString *logDir = [[HYFileManager cachesDir] stringByAppendingPathComponent:@"Logs"];
    //    NSArray *files = [HYFileManager listFilesInDirectoryAtPath:logDir deep:NO];
    //    for (NSString *fileName in files) {
    //        NSData *pdf = [NSData dataWithContentsOfFile:[logDir stringByAppendingPathComponent:fileName]];
    //        [mailCompose addAttachmentData:pdf mimeType:@"" fileName:fileName];
    //    }
    
    
    
    // 弹出邮件发送视图
    [self presentViewController:mailCompose animated:YES completion:nil];
}
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled: // 用户取消编辑
            NSLog(@"Mail send canceled...");
            break;
        case MFMailComposeResultSaved: // 用户保存邮件
            NSLog(@"Mail saved...");
            break;
        case MFMailComposeResultSent: // 用户点击发送
            NSLog(@"Mail sent...");
            break;
        case MFMailComposeResultFailed: // 用户尝试保存或发送邮件失败
            NSLog(@"Mail send errored: %@...", [error localizedDescription]);
            break;
    }
    // 关闭邮件发送视图
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)shareApp{
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[[NSString stringWithFormat:@"%@ https://itunes.apple.com/us/app/hdownloader/id1226848385",NSLocalizedString(@"It's convenient to download video with this App,just try it!", nil)]] applicationActivities:nil];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:activityViewController animated:YES completion:NULL];
    }else {
        // Change Rect to position Popover
        activityViewController.popoverPresentationController.sourceView = self.view;
        UIPopoverController *popup = [[UIPopoverController alloc] initWithContentViewController:activityViewController];
        
        [popup presentPopoverFromRect:CGRectMake(self.view.frame.size.width/2, self.view.frame.size.height/4, 0, 0) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    
}
#pragma mark ---actionSheet代理
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != 3) {
        [UserDefaultManager setSearchEngine:buttonIndex];
        [self setCellSearchEngineText:buttonIndex inCell:nil];
    }
}
-(void)setCellSearchEngineText:(SearchEngine)engine inCell:(UITableViewCell *)cell
{
    if (!cell) {
        cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    }
    switch (engine) {
        case SearchEngineGoogle:
        {
            [AnalyticsTool analyCategory:@"Settings" action:@"点击【Search Engine】" label:@"Google" value:nil];
            cell.detailTextLabel.text = @"Google";
        }
            break;
        case SearchEngineYouTube:
        {
            [AnalyticsTool analyCategory:@"Settings" action:@"点击【Search Engine】" label:@"YouTube" value:nil];
            cell.detailTextLabel.text = @"YouTube";
        }
            break;
        case SearchEngineBing:
        {
            [AnalyticsTool analyCategory:@"Settings" action:@"点击【Search Engine】" label:@"Bing" value:nil];
            cell.detailTextLabel.text = @"Bing";
        }
            break;
        default:
            break;
    }
    
}
-(void)adViewDidLoad:(FBAdView *)adView
{
    self.adViewHeightConst.constant = 50;
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    }];
}
-(void)adViewDidClick:(FBAdView *)adView
{
    [AnalyticsTool analyCategory:@"Settings" action:@"点击【广告位4】" label:nil value:nil];
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
