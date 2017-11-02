//
//  FilesViewController.m
//  downloader
//
//  Created by xueyognwei on 2017/3/24.
//  Copyright © 2017年 xueyognwei. All rights reserved.
//

#import "FilesViewController.h"
#import "HYFileManager.h"
#import "FileModel.h"
#import "FilesTableViewCell.h"
#import "PlayerViewController.h"
#import <sys/sysctl.h>
#import <mach/mach.h>
#import <sys/mount.h>
//#import "UILeftSearchBar.h"
typedef NS_ENUM(NSInteger, FilesSortType) {
    FilesSortTypeDate,
    FilesSortTypeName,
    FilesSortTypeSize,
};
@interface FilesViewController ()<UISearchBarDelegate, UISearchDisplayDelegate,UIActionSheetDelegate,FilesTableViewCellDelegate,FBAdViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) UISearchBar *searchBar;
@property (nonatomic,strong) UISearchDisplayController *searchDisplayController;
@property (nonatomic,strong) NSMutableArray *dataSource;
@property (nonatomic,strong) NSMutableArray *seletedSource;
@property (nonatomic, strong) NSArray *searchResults;
@property (nonatomic, assign) FilesSortType currentSortType;
@property (weak, nonatomic) IBOutlet UIButton *selectedAllBtn;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolBarBottomConst;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConst;

@property (nonatomic,strong) FileModel *currentToDeleteFileModel;
@property (nonatomic,strong) NSIndexPath *currentToDeleteIndexPath;
@property (nonatomic,strong) UIView *tableFooterView;
@property (weak, nonatomic) IBOutlet UILabel *memorySizeLabel;
@property (nonatomic,strong) UIView *AdContentView;
@property (nonatomic,assign)BOOL adDidLoad;

@end

@implementation FilesViewController
#define kActionSheetDeleteModelTag 100
#define kActionSheetDeleteIndexPathTag 200
#define kActionSheetDeleteSelectedTag 300
#define kActionSheetSortTag 400
-(UIView *)AdContentView
{
    if (!_AdContentView) {
        _AdContentView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, YYScreenSize().width, 50)];
    }
    return _AdContentView;
}
-(UIView *)tableFooterView
{
    if (!_tableFooterView) {
        _tableFooterView = [[[NSBundle mainBundle]loadNibNamed:@"FilesVCFooterView" owner:self options:nil]lastObject];
    }
    return _tableFooterView;
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
        _dataSource = [NSMutableArray new];
    }
    return _dataSource;
}
-(NSArray *)allFilesDownloaded{
    NSString *downloadDir = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"download"];
    NSArray *files =  [HYFileManager listFilesInDirectoryAtPath:downloadDir deep:NO];
    if (files.count==0) {
        return nil;
    }
    NSMutableArray *filesArray = [NSMutableArray new];
    DDLogVerbose(@"files : %@",files);
    for (NSString *fileName in files) {
        if ([fileName.pathExtension isEqualToString:@"mp4"]||[fileName.pathExtension isEqualToString:@"m3u8"]) {
            NSString *filePath = [downloadDir stringByAppendingPathComponent:fileName];
            
            FileModel *file = [[FileModel alloc]init];
            file.fileName = fileName;
            file.filePath = downloadDir;
            if ([fileName.pathExtension isEqualToString:@"m3u8"]) {
                
                NSString *m2u8content = [NSString stringWithContentsOfFile:[downloadDir stringByAppendingPathComponent:fileName] encoding:NSUTF8StringEncoding error:nil];
                NSRange segmentRange = [m2u8content rangeOfString:@"#EXT-X-SIZE:"];
                m2u8content = [m2u8content substringFromIndex:segmentRange.location+segmentRange.length];
                NSRange nxtRange = [m2u8content rangeOfString:@"\n"];
                NSString *sizeStr = [m2u8content substringToIndex:nxtRange.location];
                file.fileSize = @(sizeStr.doubleValue);
                
            }else{
                file.fileSize = [HYFileManager sizeOfFileAtPath:filePath];
            }
            
            file.createDate = [HYFileManager modificationDateOfItemAtPath:filePath];
            NSString *imgName = [[fileName stringByDeletingPathExtension] stringByAppendingString:@".jpg"];
            file.thumPath = [downloadDir stringByAppendingPathComponent:imgName];
            [filesArray addObject:file];
        }
    }
    return filesArray;
}

-(void)reloadWithSortType:(FilesSortType) type{
    self.currentSortType = type;
    self.dataSource = [NSMutableArray arrayWithArray:[self sortFiles:[self allFilesDownloaded] by:type]];
    [self.tableView reloadData];
}
-(NSArray *)sortFiles:(NSArray *)files by:(FilesSortType)type
{
    NSArray *result = [files sortedArrayUsingComparator:^NSComparisonResult(FileModel *obj1, FileModel *obj2) {
        switch (type) {
            case FilesSortTypeDate:
            {
                [AnalyticsTool analyCategory:@"Files" action:@"点击【排序】按钮" label:@"by date" value:nil];
                return [obj1.createDate compare:obj2.createDate]; //升序
            }
                break;
            case FilesSortTypeName:
            {
                [AnalyticsTool analyCategory:@"Files" action:@"点击【排序】按钮" label:@"by name" value:nil];
                return [[obj1.fileName stringByURLDecode] localizedCompare:[obj2.fileName stringByURLDecode]]; //升序
            }
                break;
            case FilesSortTypeSize:
            {
                [AnalyticsTool analyCategory:@"Files" action:@"点击【排序】按钮" label:@"by size" value:nil];
                return [obj1.fileSize compare:obj2.fileSize]; //升序
            }
                break;
            default:
                return [obj1.createDate compare:obj2.createDate]; //升序
                break;
        }
    }];
    return result;
}
#pragma mark == viewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.navigationItem.title = @"Files";
    self.tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
    [self customSearchBar];
    
    [self configureTableView:self.tableView];
    self.currentSortType = FilesSortTypeDate;
    
    FBAdView *adView =
    [[FBAdView alloc] initWithPlacementID:self.placementID
                                   adSize:kFBAdSizeHeight50Banner
                       rootViewController:self];
    
    adView.delegate = self;
    
    [adView loadAd];
    [self.AdContentView addSubview:adView];
    [AnalyticsTool setScreenName:self.navigationItem.title];
//    [self reloadWithSortType:FilesSortTypeDate];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self reloadWithSortType:self.currentSortType];
   
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.searchBar sizeToFit];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark == custom
-(void)customSearchBar{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    searchBar.placeholder =NSLocalizedString(@"Search", nil) ;
    searchBar.searchBarStyle = UISearchBarStyleMinimal;
    searchBar.barStyle = UIBarStyleDefault;
    searchBar.delegate = self;
    searchBar.barTintColor = [UIColor whiteColor];
//    searchBar.autoresizingMask = NO;
    self.searchBar = searchBar;
//    searchBar.barTintColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:241/255.0 alpha:1.0];
//    [searchBar setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]]];
    
//    [searchBar setSearchFieldBackgroundImage:[UIImage imageWithColor:[UIColor colorWithHexString:@"ededed"]] forState:UIControlStateNormal];
    // 并把 searchDisplayController 和当前 controller 关联起来
    self.searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    self.searchDisplayController.delegate = self;
    // searchResultsDataSource 就是 UITableViewDataSource
    self.searchDisplayController.searchResultsDataSource = self;
    // searchResultsDelegate 就是 UITableViewDelegate
    self.searchDisplayController.searchResultsDelegate = self;
    [headerView addSubview:searchBar];
    self.tableView.tableHeaderView = headerView;
}

- (void)configureTableView:(UITableView *)tableView {
    
    tableView.separatorInset = UIEdgeInsetsZero;
    
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellId"];
    
//    UIView *tableFooterViewToGetRidOfBlankRows = [[UIView alloc] initWithFrame:CGRectZero];
//    tableFooterViewToGetRidOfBlankRows.backgroundColor = [UIColor clearColor];
//    if (tableView == self.tableView) {
//        tableView.tableFooterView = self.tableFooterView;
//    }else
        tableView.tableFooterView = tableView == self.tableView?self.tableFooterView:[[UIView alloc]initWithFrame:CGRectZero];
    tableView.delegate = self;
    tableView.dataSource = self;
}

// 获取当前设备可用内存(单位：MB）
- (double)availableMemory
{
    struct statfs buf;
    unsigned long long freeSpace = -1;
    if (statfs("/var", &buf) >= 0)
    {
        freeSpace = (unsigned long long)(buf.f_bsize * buf.f_bavail);
    }
    return freeSpace;
    
//    vm_statistics_data_t vmStats;
//    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
//    kern_return_t kernReturn = host_statistics(mach_host_self(),
//                                               HOST_VM_INFO,
//                                               (host_info_t)&vmStats,
//                                               &infoCount);
//    
//    if (kernReturn != KERN_SUCCESS) {
//        return NSNotFound;
//    }
//    return vm_page_size *vmStats.free_count;
//    return ((vm_page_size *vmStats.free_count) / 1024.0) / 1024.0;
}
-(NSString *)stringForVideoSize{
    long total = [self availableMemory];
//    [NSString stringWithFormat:@"%ldfiles,%fM free",self.dataSource.count,[self availableMemory]]
    NSString *totalStr = @"0B";
    if (total >= 0 && total < 1024) {
        //B
        totalStr = [NSString stringWithFormat:@"%ld %@,%ld B %@",self.dataSource.count,NSLocalizedString(@"Files", nil) ,(long)total,NSLocalizedString(@"freesize", nil)];
    } else if (total >= 1024 && total < 1024 * 1024) {
        //KB
        totalStr = [NSString stringWithFormat:@"%ld %@,%ld KB %@",self.dataSource.count, NSLocalizedString(@"Files", nil) ,(long)total / 1024,NSLocalizedString(@"freesize", nil)];
    } else if (total >= 1024 * 1024 && total < 1024 * 1024 *1024) {
        //MB
        totalStr = [NSString stringWithFormat:@"%ld %@,%.2lf MB %@",self.dataSource.count, NSLocalizedString(@"Files", nil) ,(long)total / 1024.0 / 1024.0,NSLocalizedString(@"freesize", nil)];
    } else if (total >= 1024 * 1024 *1024) {
        //GB
        totalStr = [NSString stringWithFormat:@"%ld %@,%.2lf GB %@",self.dataSource.count,NSLocalizedString(@"Files", nil) ,(long)total / 1024.0 / 1024.0 /1024.0 ,NSLocalizedString(@"freesize", nil)];
    }
    return totalStr;
}
// 获取当前任务所占用的内存（单位：MB）
- (double)usedMemory
{
    task_basic_info_data_t taskInfo;
    mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(),
                                         TASK_BASIC_INFO,
                                         (task_info_t)&taskInfo,
                                         &infoCount);
    
    if (kernReturn != KERN_SUCCESS
        ) {
        return NSNotFound;
    }
    
    return taskInfo.resident_size / 1024.0 / 1024.0;
}
#pragma mark == 点击事件
- (IBAction)onEditClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.tabBarController.tabBar.hidden = sender.selected;
//    self.selectedAllBtn.highlighted = !sender.selected;
    [self resetSelectAllBtn:sender.selected];
    if (sender.selected) {
        self.selectedAllBtn.selected = NO;
        [self.seletedSource removeAllObjects];
        self.deleteBar.enabled = NO;
    }
//    self.selectedAllBtn.hidden = !sender.selected;
    [self.tableView setEditing:sender.selected animated:YES];
//    self.toolBarBottomConst.constant = sender.selected?0:-44;
//    self.tableViewBottomConst.constant = self.toolBarBottomConst.constant+44;
//    [UIView animateWithDuration:0.3 animations:^{
//        [self.view layoutIfNeeded];
//    }];
}
-(void)resetSelectAllBtn:(BOOL)Edit{
    self.selectedAllBtn.selected = NO;
    if (Edit) {
        [self.selectedAllBtn setTitle:NSLocalizedString(@"Select All", nil)  forState:UIControlStateNormal];
        [self.selectedAllBtn setTitle:NSLocalizedString(@"Deselect All", nil)  forState:UIControlStateSelected];
        
    }else{
        [self.selectedAllBtn setTitle:NSLocalizedString(@"Sort", nil)  forState:UIControlStateNormal];
        
    }
}

- (IBAction)onSelectedClick:(UIButton *)sender {
    if ([sender.titleLabel.text isEqualToString:NSLocalizedString(@"Sort", nil)]) {
        [AnalyticsTool analyCategory:@"Files" action:@"点击【排序】按钮" label:nil value:nil];
//        NSArray *itmes = @[NSLocalizedString(@"Sort by Date", nil),NSLocalizedString(@"Sort by Name", nil),NSLocalizedString(@"Sort by Size", nil)];
        
        UIActionSheet *act = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil)  destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Sort by Date", nil) ,NSLocalizedString(@"Sort by Name", nil),NSLocalizedString(@"Sort by Size", nil), nil];
        act.tag = kActionSheetSortTag;
        [act showInView:self.view];
        
        return;
    }
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
- (IBAction)onDeleteClick:(id)sender {
    UIActionSheet *deleteAcSheet = [[UIActionSheet alloc]initWithTitle:NSLocalizedString(@"Are you sure to delete?", nil)  delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel" , nil) destructiveButtonTitle:NSLocalizedString(@"Delete", nil)  otherButtonTitles: nil];
    deleteAcSheet.tag = kActionSheetDeleteSelectedTag;
    [deleteAcSheet showInView:self.view];
    
}
#pragma mark == actionSheet
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == kActionSheetSortTag) {
        DDLogInfo(@"%ld",buttonIndex);
        [self reloadWithSortType:buttonIndex];
    }else if (actionSheet.tag == kActionSheetDeleteSelectedTag){
        if (buttonIndex ==0) {
            [self deleteSeletedFiles];
        }
    }else if (actionSheet.tag == kActionSheetDeleteModelTag){
        if (buttonIndex ==0) {
            [self sureDeleteCurrentModel];
        }
    }else if (actionSheet.tag == kActionSheetDeleteIndexPathTag){
        if (buttonIndex ==0) {
            [self deleteFileAnIndexPath:self.currentToDeleteIndexPath];
        }
    }
}
#pragma mark == 删除数据
-(void)sureDeleteCurrentModel
{
    [self.dataSource removeObject:self.currentToDeleteFileModel];
    [self.tableView reloadData];
}
-(void)deleteSeletedFiles{
    NSArray *arr = self.tableView.indexPathsForSelectedRows;
    NSMutableArray *deleteModels = [NSMutableArray new];
    
    for (NSIndexPath *indexPath in arr) {
        FileModel *model = self.dataSource[indexPath.row];
        [HYFileManager removeItemAtPath:[model.filePath stringByAppendingPathComponent:model.fileName]];
        [deleteModels addObject:model];
    }
    [self.dataSource removeObjectsInArray:deleteModels];
    [self.tableView reloadData];
//    NSArray *indexArr = [self.tableView indexPathsForSelectedRows];
//    [self.tableView deleteRowsAtIndexPaths:indexArr withRowAnimation:UITableViewRowAnimationLeft];
//    for (NSIndexPath *indexPath in indexArr) {
//        [self.dataSource removeObjectAtIndex:indexPath.row];
//    }
}
-(void)deleteFileAnIndexPath:(NSIndexPath *)indexPath{
    
    FileModel *model = self.dataSource[indexPath.row];
    [HYFileManager removeItemAtPath:[model.filePath stringByAppendingPathComponent:model.fileName]];
    [self.dataSource removeObject:model];
    // 刷新
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

#pragma mark == filesTableViewCell代理
-(void)filesTableViewCellReloadTableView{
    [self reloadWithSortType:self.currentSortType];
    //    [self.tableView reloadData];
}

-(void)filesTableViewCellDeleteModel:(FileModel *)model
{
    UIActionSheet *deleteAcSheet = [[UIActionSheet alloc]initWithTitle:NSLocalizedString(@"Are you sure to delete?", nil)  delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel" , nil) destructiveButtonTitle:NSLocalizedString(@"Delete", nil)  otherButtonTitles: nil];
    deleteAcSheet.tag = kActionSheetDeleteModelTag;
    [deleteAcSheet showInView:self.view];
    self.currentToDeleteFileModel = model;
}

//===============================================
#pragma mark -
#pragma mark == UITableView
//===============================================

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    self.memorySizeLabel.text =  [self stringForVideoSize];
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == self.tableView) {
        return [self.dataSource count];
    }
    else {
        return [self.searchResults count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FilesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FilesTableViewCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"FilesTableViewCell" owner:self options:nil]lastObject];
        cell.delegate = self;
    }
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId" forIndexPath:indexPath];
    FileModel *file =tableView == self.tableView ?self.dataSource[indexPath.row] : self.searchResults[indexPath.row];
    cell.model = file;
    return cell;
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.editing) {
        return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
    }else{
        return UITableViewCellEditingStyleDelete;
    }
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        UIActionSheet *deleteAcSheet = [[UIActionSheet alloc]initWithTitle:NSLocalizedString(@"Are you sure to delete?", nil)  delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel" , nil) destructiveButtonTitle:NSLocalizedString(@"Delete", nil)  otherButtonTitles: nil];
        deleteAcSheet.tag = kActionSheetDeleteIndexPathTag;
        [deleteAcSheet showInView:self.view];
        self.currentToDeleteIndexPath = indexPath;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.editing) {
        [self.seletedSource addObject:indexPath];
        self.deleteBar.enabled = YES;
        if (self.seletedSource.count == self.dataSource.count) {
            self.selectedAllBtn.selected = YES;
        }
        return;
    }else{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        PlayerViewController *player = [[PlayerViewController alloc]initWithNibName:@"PlayerViewController" bundle:nil];
        FileModel *file = tableView== self.tableView? self.dataSource[indexPath.row]:self.searchResults[indexPath.row];
        player.fileModel =file;
        //    player.videoURL = [NSURL fileURLWithPath:file.filePath];
        //    FixedViewController *fix = [[FixedViewController alloc]init];
        //    fix.fileModel = file;
        [self presentViewController:player animated:YES completion:nil];
        //    [self presentViewController:fix animated:YES completion:nil];
    }
    
}
-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [AnalyticsTool analyCategory:@"Files" action:@"点击文件" label:nil value:nil];
    if (tableView.editing) {
        [self.seletedSource removeObject:indexPath];
        self.deleteBar.enabled = self.seletedSource.count>0;
        self.selectedAllBtn.selected = NO;
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.tableView == tableView) {
        return self.AdContentView;
    }
    return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        if (self.adDidLoad) {
            return 50;
        }else{
            return 0.1;
        }
    }
    return 0.1;
//    return self.adDidLoad?50:0.1;
//    if (self.adDidLoad) {
//        
//    }
}
//===============================================
#pragma mark -
#pragma mark == UISearchDisplayDelegate
//===============================================

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller {
    [AnalyticsTool analyCategory:@"Files" action:@"点击【搜索框】" label:nil value:nil];
    NSLog(@"🔦 | will begin search");
}
- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller {
    NSLog(@"🔦 | did begin search");
}
- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    NSLog(@"🔦 | will end search");
}
- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    NSLog(@"🔦 | did end search");
}
- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView {
    NSLog(@"🔦 | did load table");
    [self configureTableView:tableView];
}
- (void)searchDisplayController:(UISearchDisplayController *)controller willUnloadSearchResultsTableView:(UITableView *)tableView {
    NSLog(@"🔦 | will unload table");
}
- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView {
    NSLog(@"🔦 | will show table");
}
- (void)searchDisplayController:(UISearchDisplayController *)controller didShowSearchResultsTableView:(UITableView *)tableView {
    NSLog(@"🔦 | did show table");
}
- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView {
    NSLog(@"🔦 | will hide table");
}
- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView {
    NSLog(@"🔦 | did hide table");
}
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    NSLog(@"🔦 | should reload table for search string?");
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fileName CONTAINS[cd] %@", searchString];
    self.searchResults = [self.dataSource filteredArrayUsingPredicate:predicate];
    
    return YES;
}
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    NSLog(@"🔦 | should reload table for search scope?");
    return YES;
}
-(void)adViewDidLoad:(FBAdView *)adView
{
    self.adDidLoad = YES;
    [self.tableView reloadSection:0 withRowAnimation:UITableViewRowAnimationMiddle];
//    [self.tableView reloadData];
}
-(void)adViewDidClick:(FBAdView *)adView
{
    [AnalyticsTool analyCategory:@"Files" action:@"点击【广告位3】" label:nil value:nil];
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
