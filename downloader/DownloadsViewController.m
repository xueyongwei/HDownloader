//
//  DownloadsViewController.m
//  downloader
//
//  Created by xueyognwei on 2017/3/24.
//  Copyright © 2017年 xueyognwei. All rights reserved.
//

#import "DownloadsViewController.h"
#import "DownloadTaskTableViewCell.h"
#import <AVFoundation/AVFoundation.h>
#import "UserDefaultManager.h"
#import "CoreStatus.h"
#import "XYWADManager.h"

#define kAlertTagDeleteSeleted 100
#define kAlertTagStartAllWithCellular 200
//#define kAlertTagdeleteSeleted 300
@interface DownloadsViewController ()<UISearchBarDelegate, UISearchDisplayDelegate,UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,FBAdViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,strong) NSMutableArray *seletedSource;
@property (nonatomic,strong) UIButton *pauseAllBtn;
@property (nonatomic,strong) UIView *AdContentView;

@property (weak, nonatomic) IBOutlet UIButton *selectedAllBtn;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteBar;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolBarBottomConst;
@property (nonatomic,assign)BOOL adDidLoad;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottonConst;


@end

@implementation DownloadsViewController
-(UIView *)AdContentView
{
    if (!_AdContentView) {
        _AdContentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, YYScreenSize().width, 50)];
    }
    return _AdContentView;
}
-(NSMutableArray *)seletedSource{
    if (!_seletedSource) {
        _seletedSource = [NSMutableArray new];
    }
    return _seletedSource;
}

-(NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource =  [NSMutableArray new];
    }
    return _dataSource;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self refreshData];
    [self.tableView reloadData];
}
-(void)refreshData{
    self.dataSource = [NSMutableArray arrayWithArray:[[DownloadCacher shareInstance] allDownloadingModels]];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
//    self.navigationItem.title = @"Tasks";
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    
    [self customPauseAll];
    [self configureTableView:self.tableView];
    [self addObserver];
    FBAdView *adView =
    [[FBAdView alloc] initWithPlacementID:self.placementID
                                   adSize:kFBAdSizeHeight50Banner
                       rootViewController:self];
    
    adView.delegate = self;
    
    [adView loadAd];
    [self.AdContentView addSubview:adView];
//    FBAdView *adView =
//    [[FBAdView alloc] initWithPlacementID:@"491292214594434_492781944445461"
//                                   adSize:kFBAdSizeHeight50Banner
//                       rootViewController:self];
//    
//    adView.delegate = self;
//    
//    [adView loadAd];
//    [self.baseAdView addSubview:adView];
    [AnalyticsTool setScreenName:self.navigationItem.title];
}
-(void)customNavi{
    UIBarButtonItem *edit = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:nil action:nil];
    self.navigationItem.rightBarButtonItem = edit;
}
-(void)customPauseAll{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 60)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    UIButton *pauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.pauseAllBtn = pauseBtn;
    pauseBtn.frame = CGRectMake(15, 15, self.view.bounds.size.width-30, 30);
    pauseBtn.layer.borderColor = [UIColor colorWithHexString:@"007aff"].CGColor;
    pauseBtn.layer.cornerRadius = 5;
    pauseBtn.layer.borderWidth = 1;
    pauseBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [pauseBtn addTarget:self action:@selector(onPauseAllClick:) forControlEvents:UIControlEventTouchUpInside];
    [pauseBtn setTitle:NSLocalizedString(@"Download all", nil)  forState:UIControlStateNormal];
    [pauseBtn setTitleColor:[UIColor colorWithHexString:@"007aff"] forState:UIControlStateNormal];
    
    [pauseBtn setTitleColor:[UIColor colorWithHexString:@"00c0ff"] forState:UIControlStateHighlighted];
    
    [pauseBtn setTitle:NSLocalizedString(@"Pause all", nil)  forState:UIControlStateSelected];
    [pauseBtn setTitleColor:[UIColor colorWithHexString:@"007aff"] forState:UIControlStateSelected];
    [headerView addSubview:pauseBtn];
    
    self.tableView.tableHeaderView = headerView;
    [self.tableView reloadData];
}
- (void)configureTableView:(UITableView *)tableView {
    
    tableView.separatorInset = UIEdgeInsetsZero;
    
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellId"];
    
    UIView *tableFooterViewToGetRidOfBlankRows = [[UIView alloc] initWithFrame:CGRectZero];
    tableFooterViewToGetRidOfBlankRows.backgroundColor = [UIColor clearColor];
    tableView.tableFooterView = tableFooterViewToGetRidOfBlankRows;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark == AlertView 代理
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kAlertTagDeleteSeleted) {
        if (buttonIndex == 0) {//取消
            
        }else{
            [self deleteSeletedIndexPaths];
        }
    }else if (alertView.tag == kAlertTagStartAllWithCellular){
        if (buttonIndex ==1) {
            UITabBarController *tabVC = self.navigationController.tabBarController;
            [tabVC setSelectedIndex:3];
        }
    }
}
#pragma mark == 点击事件
- (IBAction)onEditClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.tabBarController.tabBar.hidden = sender.selected;
    self.selectedAllBtn.hidden = !sender.selected;
    if (sender.selected) {
        self.selectedAllBtn.selected = NO;
        [self.seletedSource removeAllObjects];
        self.deleteBar.enabled = NO;
    }
    
    [self.tableView setEditing:sender.selected animated:YES];
//    self.toolBarBottomConst.constant = sender.selected?0:-44;
//    self.tableViewBottonConst.constant =self.toolBarBottomConst.constant+44;
//    [UIView animateWithDuration:0.3 animations:^{
//        [self.view layoutIfNeeded];
//    }];
//    [self.tableView reloadData];
}
- (IBAction)onSelectedClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.deleteBar.enabled = sender.selected;
    if (sender.selected) {
        for (int i = 0; i < self.dataSource.count; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionBottom];
            [self.seletedSource addObject:self.dataSource[i]];
        }
     
    }else{
        for (int i = 0; i < self.dataSource.count; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
        [self.seletedSource removeAllObjects];
    }
}
- (IBAction)onDeleteSelectedItms:(UIBarButtonItem *)sender {
    [AnalyticsTool analyCategory:@"Tasks" action:@"EDIT下的delete按钮" label:nil value:nil];
    UIAlertView *alv = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Are you sure to delete?", nil)  message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"Delete", nil) , nil];
    alv.tag = kAlertTagDeleteSeleted;
    [alv show];
}
-(void)deleteSeletedIndexPaths{
    NSArray *arr = self.tableView.indexPathsForSelectedRows;
    NSMutableArray *deleteModels = [NSMutableArray new];
    
    for (NSIndexPath *indexPath in arr) {
        DownloadModel *model = self.dataSource[indexPath.row];
        [deleteModels addObject:model];
//        [self.dataSource removeObject:model];
//        [[DownloadCacher shareInstance] deleteDownloadModels:@[model]];
    }
    [self deleteDownloadModels:deleteModels];
//    [self.tableView reloadData];
}
-(void)onPauseAllClick:(UIButton *)sender{
    if (!sender.selected) {//继续所有
        BOOL wifi = [CoreStatus isWifiEnable];
        BOOL onlyWifi = [UserDefaultManager isOnlyDownloadWhenWIFI];
        if ((!wifi) && onlyWifi) {
            UIAlertView *alv = [[UIAlertView alloc]initWithTitle:nil message:NSLocalizedString(@"No WiFi.You can go to the settings and turn off \"Only use WiFi to download\"button.", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Got it", nil)  otherButtonTitles:NSLocalizedString(@"Settings", nil) , nil];
            alv.tag = kAlertTagStartAllWithCellular;
            [alv show];
        }else{
            [[DownloadManager shareInstance]startAllDownload];
            sender.selected = !sender.selected;
        }
    }else{//暂停所有
        [[DownloadManager shareInstance]pauseAllDownload];
        sender.selected = !sender.selected;
    }
}
//===============================================
#pragma mark -
#pragma mark UITableView
//===============================================

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    __weak typeof(self) wkSelf = self;
    [self.dataSource enumerateObjectsUsingBlock:^(DownloadModel* obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.status == Downloading || obj.status == DownloadWating) {
            wkSelf.pauseAllBtn.selected = YES;
            *stop = YES;
        }
        if (idx == wkSelf.dataSource.count-1) {
            wkSelf.pauseAllBtn.selected = NO;
        }
    }];
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    [self setBagde];
    return [self.dataSource count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DownloadTaskTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DownloadTaskTableViewCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"DownloadTaskTableViewCell" owner:self options:nil]lastObject];
    }
    DownloadModel *model = self.dataSource[indexPath.row];
    cell.downloadModel = model;
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.editing) {
        return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
    }else{
        return UITableViewCellEditingStyleDelete;
    }
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [AnalyticsTool analyCategory:@"Tasks" action:@"左划删除" label:nil value:nil];
        DownloadModel *model = [self.dataSource objectAtIndex:indexPath.row];
        [self deleteDownloadModels:@[model]];
//        [[DownloadManager shareInstance] deleteDownloadModelArr:@[model]];
//        [self.dataSource removeObject:model];
//        [self.tableView reloadData];
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.editing) {
        [self.seletedSource addObject:indexPath];
        self.deleteBar.enabled = YES;
        if (self.seletedSource.count == self.dataSource.count) {
            self.selectedAllBtn.selected = YES;
        }
    }else{
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.editing) {
        [self.seletedSource removeObject:indexPath];
        self.deleteBar.enabled = self.seletedSource.count>0;
        self.selectedAllBtn.selected = NO;
    }
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return self.adDidLoad?50:0.1;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return self.AdContentView;
//    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, YYScreenSize().width, 50)];
//    view.backgroundColor = [UIColor lightGrayColor];
//    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, YYScreenSize().width, 50)];
//    label.text = @"AD there";
//    label.textColor = [UIColor orangeColor];
//    label.textAlignment = NSTextAlignmentCenter;
//    [view addSubview:label];
//    return view;
}
#pragma mark == 删除任务
-(void)deleteDownloadModels:(NSArray *)downloadModels
{
    [[DownloadManager shareInstance] deleteDownloadModelArr:downloadModels];
    [self.dataSource removeObjectsInArray:downloadModels];
    [self.tableView reloadData];
}
#pragma mark - 通知中心
- (void)addObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDownload:) name:DownloadingUpdateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addDownload:) name:DownloadingAddedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginDownload:) name:DownloadBeginNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishDownload:) name:DownloadFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failedDownload:) name:DownloadFailedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseDownload:) name:DownloadingPauseNotification object:nil];
    
}

-(void)refreshTableView{
    [self.tableView reloadData];
}
-(void)setBagde{
    
    UITabBarItem * item=[self.tabBarController.tabBar.items objectAtIndex:1];
    NSInteger num = 0;
    [self refreshData];
    for (DownloadModel *model in self.dataSource) {
        if (model.status == Downloading || model.status == DownloadWating) {
            num ++;
        }
    }
    if (num<=0) {
        item.badgeValue = nil;
    }else{
        item.badgeValue = [NSString stringWithFormat:@"%ld",(long)num];
    }
    
}
- (void)removeObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DownloadingUpdateNotification object:nil];
     [[NSNotificationCenter defaultCenter] removeObserver:self name:DownloadingAddedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DownloadBeginNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DownloadFinishNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DownloadFailedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DownloadingPauseNotification object:nil];
}
#pragma mark - 下载通知
-(void)addDownload:(NSNotification *)noti
{
    [self setBagde];
//    DownloadModel *tempModel = noti.object;
//    [[DownloadManager shareInstance] dealDownloadModel:tempModel];
//    [self.dataSource addObject:tempModel];
//    [self.tableView reloadData];
}
- (void)updateDownload:(NSNotification *)noti
{
    DownloadModel *tempModel = noti.object;
    DownloadTaskTableViewCell *cell = [self findCellWithModel:tempModel];
    cell.downloadModel = tempModel;
//    for (NSInteger i=0; i<self.dataSource.count; i++) {
//        DownloadModel *model = self.dataSource[i];
//        if (model.status == Downloading) {
//            
//        }
//    }
}

- (void)failedDownload:(NSNotification *)noti
{
    [self setBagde];
    DownloadModel *tempModel = noti.object;
    DownloadTaskTableViewCell *cell = [self findCellWithModel:tempModel];
    cell.downloadModel = tempModel;
    self.pauseAllBtn.selected = NO;
}

- (void)beginDownload:(NSNotification *)noti
{
    [AnalyticsTool analyCategory:@"Tasks" action:@"开始下载数" label:nil value:nil];
    [self setBagde];
    DownloadModel *tempModel = noti.object;
    DownloadTaskTableViewCell *cell = [self findCellWithModel:tempModel];
    cell.downloadModel = tempModel;
    self.pauseAllBtn.selected = YES;
}

- (void)finishDownload:(NSNotification *)noti
{
    [AnalyticsTool analyCategory:@"Tasks" action:@"下载完成数" label:nil value:nil];
    [self setBagde];
    DownloadModel *tempModel = noti.object;
    DownloadTaskTableViewCell *cell = [self findCellWithModel:tempModel];
    cell.downloadModel = tempModel;
    [self thumbVideoOf:tempModel];
    [self.dataSource removeObject:tempModel];
    [self.tableView reloadData];
    self.pauseAllBtn.selected = NO;
}
-(void)pauseDownload:(NSNotification *)noti{
    [self setBagde];
    self.pauseAllBtn.selected = NO;
}
-(void)thumbVideoOf:(DownloadModel *)downloadModel{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *imgName = [[downloadModel.name stringByDeletingPathExtension] stringByAppendingString:@".jpg"];
        NSString *downloadDir = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"download"];
        NSString *thumPath = [downloadDir stringByAppendingPathComponent:imgName];
        if (![[NSFileManager defaultManager] fileExistsAtPath:thumPath]) {
            NSURL *videoUrl = [NSURL fileURLWithPath:[downloadDir stringByAppendingPathComponent:downloadModel.name]];
            UIImage *thumImg = [self thumbnailImageForVideo:videoUrl atTime:2];
            if (thumImg) {
                [UIImageJPEGRepresentation(thumImg, 0.8) writeToFile:thumPath atomically:YES];
            }
        }
//        NSRange range = [downloadModel.name rangeOfString:@"." options:NSBackwardsSearch];
//        if (range.location>0){
//            NSString *downloadDir = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"download"];
//            NSString *imgName=[[downloadModel.name substringToIndex:range.location] stringByAppendingString:@".jpg"];
//            DDLogInfo(@"%@ fileNamenew %@",downloadModel.name,imgName);
//            NSString *imgPath = [downloadDir stringByAppendingPathComponent:imgName];
////            NSURL *imgUrl = [NSURL fileURLWithPath:imgPath];
//            
//            if (![[NSFileManager defaultManager] fileExistsAtPath:imgPath]) {
//                NSURL *videoUrl = [NSURL fileURLWithPath:[downloadDir stringByAppendingPathComponent:downloadModel.name]];
//                UIImage *thumImg = [self thumbnailImageForVideo:videoUrl atTime:3]?:[UIImage imageNamed:@"Galaxy"];
//                [UIImageJPEGRepresentation(thumImg, 0.8) writeToFile:imgPath atomically:YES];
//            }
//        }
    });

    
    
}
- (UIImage*) thumbnailImageForVideo:(NSURL *)videoURL atTime:(NSTimeInterval)time {
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    NSParameterAssert(asset);
    AVAssetImageGenerator *assetImageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    CGImageRef thumbnailImageRef = NULL;
    CFTimeInterval thumbnailImageTime = time;
    NSError *thumbnailImageGenerationError = nil;
    
    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMakeWithSeconds(thumbnailImageTime, 60) actualTime:NULL error:&thumbnailImageGenerationError];
    
    if (!thumbnailImageRef)
        DDLogInfo(@"thumbnailImageGenerationError %@", thumbnailImageGenerationError);
    UIImage *thumbnailImage = thumbnailImageRef ? [[UIImage alloc] initWithCGImage:thumbnailImageRef] : nil;
    return thumbnailImage;
}
- (DownloadTaskTableViewCell *)findCellWithModel:(DownloadModel *)tempModel
{
    for (DownloadTaskTableViewCell *cell in self.tableView.visibleCells) {
        
        if ([cell.downloadModel.url isEqualToString:tempModel.url]) {
//            [self.dataSource replaceObjectAtIndex:[self.dataSource indexOfObject:cell.downloadModel] withObject:tempModel];
            return cell;
        }
    }
    return nil;
    /*
    int index = 0;
    
    for (DownloadModel *model in self.dataSource)
    {
        if ([model.url isEqualToString:tempModel.url])
        {
            [self.dataSource replaceObjectAtIndex:index withObject:tempModel];
            break;
        }
        index++;
    }
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    DownloadTaskTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    return cell;
    */
}

- (void)dealloc
{
    DDLogInfo(@"下载器被释放");
    [self removeObserver];
}
-(void)adViewDidLoad:(FBAdView *)adView
{
    self.adDidLoad = YES;
    [self.tableView reloadSection:0 withRowAnimation:UITableViewRowAnimationMiddle];
//    [self.tableView reloadData];
}
-(void)adView:(FBAdView *)adView didFailWithError:(NSError *)error
{
    DDLogInfo(@"%@",error.localizedDescription);;
}
-(void)adViewDidClick:(FBAdView *)adView
{
    [AnalyticsTool analyCategory:@"Tasks" action:@"点击【广告位2】" label:nil value:nil];
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
