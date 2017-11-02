//
//  BrowserViewController.m
//  downloader
//
//  Created by xueyognwei on 2017/3/24.
//  Copyright © 2017年 xueyognwei. All rights reserved.
//

#import "BrowserViewController.h"
#import "UILeftSearchBar.h"
#import <AVFoundation/AVFoundation.h>
#import "FavouriteViewController.h"
#import "DownloadManager.h"
#import "ShareTool.h"
#import "AddBookmarkViewController.h"
#import "HYFileManager.h"
#import "UserDefaultManager.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>
#import "XYWhttpManager.h"
#import "AFHTTPSessionManager+SharedManager.h"
#import <AFNetworking.h>
#import "UIFAlertView.h"
#import "UIFActionSheet.h"
#import "M3U8TopSegmentInfo.h"
#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
//#define IOS_VPN       @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"
#define kAlertTagDownloadMp4 100
#define kAlertTagDownloadM3U8 200

@interface BrowserViewController ()<UISearchBarDelegate,UIWebViewDelegate,UIScrollViewDelegate,UIAlertViewDelegate,FavouriteViewControllerDelegate,FBAdViewDelegate,UIActionSheetDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic)UIProgressView *progressView;
@property (nonatomic,strong)UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forwardBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareBar;
@property (strong, nonatomic) UIView *adView;
@property (strong, nonatomic)FavouriteViewController *favouriteVC;
@property (nonatomic,copy) NSString *newstVideoUrlStr;
@property (nonatomic,assign)BOOL showAlert;
@property (nonatomic,assign)BOOL firstShowView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolBarlBottomConst;
@property (nonatomic,strong)UILabel *endEditBtn;
@property (nonatomic,strong)NSURL *requestURL;
@end
//UIWindowDidBecomeKeyNotification
//UIWindowDidBecomeHiddenNotification
//AVPlayerItemTimebaseChangedNotification
//AVPlayerItemTimeJumpedNotification
//AVPlayerItemNewAccessLogEntry
//static NSString *const kPlayerPlayNewVideo = @"AVPlayerItemBecameCurrentNotification";
static NSString *const kPlayerPlayNewVideo = @"AVPlayerItemTimeJumpedNotification";
static NSString *const kPlayerPlayBegin = @"UIWindowDidBecomeKeyNotification";
static NSString *const kPlayerPlayEnd = @"UIWindowDidBecomeHiddenNotification";

static NSString *const kobserveWebviewLiading = @"loading";


@implementation BrowserViewController
-(UILabel *)endEditBtn
{
    if (!_endEditBtn) {
        _endEditBtn = [[UILabel alloc]init];
        //        _endEditBtn.backgroundColor = [UIColor whiteColor];
        _endEditBtn.text = NSLocalizedString( @"Done", nil);
        _endEditBtn.textAlignment = NSTextAlignmentCenter;
        _endEditBtn.textColor = [UIColor colorWithHexString:@"0374f2"];
        _endEditBtn.font = [UIFont systemFontOfSize:14];
    }
    return _endEditBtn;
}
-(UIProgressView *)progressView{
    if (!_progressView) {
        _progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 64, YYScreenSize().width, 1)];
        _progressView.trackTintColor = [UIColor clearColor];
        _progressView.progressTintColor = [UIColor colorWithHexString:@"0374f2"];
        [self.view addSubview:_progressView];
    }
    return _progressView;
}
-(FavouriteViewController *)favouriteVC
{
    if (!_favouriteVC) {
        _favouriteVC =[[FavouriteViewController alloc]init];
        _favouriteVC.delegate = self;
    }
    return _favouriteVC;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //    self.tabBarItem.image = [[UIImage imageNamed:@"tabbar1"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    //    self.tabBarItem.selectedImage = [[UIImage imageNamed:@"tabbar1L"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    self.webView.scrollView.contentInset = UIEdgeInsetsMake(50, 0, 0, 0);
    //    self.webView.alignmentRectInsets = UIEdgeInsetsMake(50, 0, 0, 0);
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadRequestWithNoti:) name:kLoadUrlNoti object:nil];
    [self customSearchBar];
    [self customWebView];
    [self customADView];
    
    
    [AnalyticsTool setScreenName:self.navigationItem.title];
    // Do any additional setup after loading the view.
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self addNotificationCenter];
    if (!self.firstShowView) {
        //        [self.searchBar becomeFirstResponder];
        //        [self setFavouriteEditting:NO];
        //        [self.favouriteVC finishEdit];
        //
        //        [self.searchBar setShowsSearchResultsButton:NO];
        //        [self.searchBar setShowsCancelButton:YES animated:YES];
        if (!self.favouriteVC.view.superview) {
            [self.view addSubview:self.favouriteVC.view];
            CGRect rect = self.favouriteVC.view.frame;
            rect.size.height -= 44;
            self.favouriteVC.view.frame = rect;
        }
        [self showWebView];
        self.firstShowView = YES;
        [self.view bringSubviewToFront:self.toolBar];
    }
}
-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self removeNotificationCenter];
}
-(void)dealloc
{
    [self.webView removeObserver:self forKeyPath:kobserveWebviewLiading];
    [self removeNotificationCenter];
}

#pragma mark == 绘制View
-(void)customADView{
    self.adView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, YYScreenSize().width, 50)];
    [self.view addSubview:self.adView];
    FBAdView *adView =
    [[FBAdView alloc] initWithPlacementID:self.placementID
                                   adSize:kFBAdSizeHeight50Banner
                       rootViewController:self];
    
    adView.delegate = self;
    [adView loadAd];
    [self.adView addSubview:adView];
}
-(void)customWebView{
    self.webView.delegate = self;
    self.webView.scrollView.delegate = self;
    self.webView.allowsInlineMediaPlayback = NO;
    self.webView.mediaPlaybackRequiresUserAction = YES;
    //    [self.webView addObserver:self forKeyPath:kobserveWebviewLiading options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    //    [self.webView addObserver:self forKeyPath:@"request" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    
    //    [self addChildViewController:self.favouriteVC];
    //    [self.searchBar becomeFirstResponder];
    //    NSURL *url =  [NSURL URLWithString:@"https://baidu.com"];
    //    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    //    [self.webView loadRequest:request];
}

-(void)customSearchBar{
    UILeftSearchBar *searchBar = [[UILeftSearchBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    searchBar.translucent = YES;
    searchBar.hasCentredPlaceholder = NO;
    searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
    searchBar.placeholder = NSLocalizedString(@"Search or type URL", nil) ;
    [searchBar setImage:[UIImage imageNamed:@"webreload"] forSearchBarIcon:UISearchBarIconResultsList state:UIControlStateNormal];
    [searchBar setImage:[UIImage imageNamed:@"webstop"] forSearchBarIcon:UISearchBarIconResultsList state:UIControlStateSelected];
    searchBar.showsSearchResultsButton = YES;
    searchBar.delegate = self;
    searchBar.keyboardType = UIKeyboardTypeURL;
    searchBar.returnKeyType = UIReturnKeyGo;
    //    searchBar.backgroundImage = [UIImage imageNamed:@"参加PKbtn"];
    {
        UITextField * searchField = [searchBar valueForKey:@"_searchField"];
        searchField.keyboardType = UIKeyboardTypeURL;
        searchField.leftView = [UIView new];
    }
    
    self.searchBar = searchBar;
    // 添加 searchbar 到 headerview
    self.navigationItem.titleView = searchBar;
}

#pragma mark == toolBar的点击事件
- (IBAction)onBackClick:(UIBarButtonItem *)sender {
    [self.webView goBack];
    self.forwardBar.enabled = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self checkBackOrForce];
    });
}
- (IBAction)onForwardClick:(UIBarButtonItem *)sender {
    [self.webView goForward];
    self.backBar.enabled = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self checkBackOrForce];
    });
}
- (IBAction)onShareClick:(UIBarButtonItem *)sender {
    //    __weak typeof(self)wkSelf = self;
    
    [AnalyticsTool analyCategory:@"Browser" action:@"浏览器【Share】按钮" label:nil value:nil];
    [[[ShareTool alloc] init] shareWithTitle:self.navigationItem.title description:nil url:self.webView.request.URL.absoluteString image:nil completionHandler:^(UIActivityType  _Nullable activityType, BOOL completed) {
        //        if (completed) {
        //            [wkSelf shareActionWithType:activityType];
        //        }
        DDLogInfo(@"%@  %d", activityType, completed);
    }];
    
    //    UIActivityViewController *activityViewController =
    //    [[UIActivityViewController alloc] initWithActivityItems:@[self.webView.request.URL.absoluteString]
    //                                      applicationActivities:nil];
    //    activityViewController.excludedActivityTypes = @[UIActivityTypeMessage,UIActivityTypeMail];
    //    [self presentViewController:activityViewController
    //                       animated:YES
    //                     completion:^{
    //
    //                     }];
}

//-(void)shareActionWithType:(NSString *)type{
////    NSString *url = self.webView.request.URL.absoluteString;
////    NSString *title = self.navigationItem.title;
//    if ([type isEqualToString: @"Farvorite"]) {
//        [self performSegueWithIdentifier:@"AddBookMark" sender:@"Farvorite"];
//    }else if ([type isEqualToString:@"Bookmark"]){
////        AddBookmarkViewController *adbkVC =
//        [self performSegueWithIdentifier:@"AddBookMark" sender:@"Bookmark"];
//    }else if ([type isEqualToString:@"Safari"]){
//        [[UIApplication sharedApplication] openURL:self.webView.request.URL];
//    }
//}
- (IBAction)onBookmarketClick:(UIBarButtonItem *)sender {
    
}

#pragma mark == webView的代理
-(void)webviewPrepareStartLoad{
    DDLogInfo(@"webviewPrepareStartLoad");
    [self.searchBar setShowsSearchResultsButton:YES];
    [self.searchBar setShowsCancelButton:NO animated:YES];
    [self.favouriteVC.view removeFromSuperview];
    self.searchBar.searchResultsButtonSelected = YES;
    self.progressView.alpha = 1;
    if (self.searchBar.text.length==0) {
        self.searchBar.text = @"loading...";
    }else{
    }
    [self.progressView setProgress:0 animated:NO];
    [UIView animateWithDuration:1.0 animations:^{
        [self.progressView setProgress:0.2 animated:YES];
    } completion:^(BOOL finished) {
    }];
    [self changeToolBarHidden:NO];
    
}
-(void)webViewDidStartLoad:(UIWebView *)webView
{
    DDLogInfo(@"webViewDidStartLoad");
    
    self.searchBar.searchResultsButtonSelected = YES;
    self.progressView.alpha = 1;
    self.searchBar.text = self.requestURL.absoluteString;
    
    [self.progressView.layer removeAllAnimations];
    
    self.progressView.progress = 0;
    [UIView animateWithDuration:2.0 animations:^{
        [self.progressView setProgress:0.8 animated:YES];
    }];
    //    [UIView animateWithDuration:1.0 animations:^{
    //        [self.progressView setProgress:0.3 animated:YES];
    //    } completion:^(BOOL finished) {
    //        if (finished) {
    //            self.progressView.progress = 0;
    //
    //        }
    //    }];
    [self changeToolBarHidden:NO];
    [self showWebView];
    [self checkBackOrForce];
}
-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    DDLogInfo(@"webViewDidFinishLoad");
    self.requestURL = webView.request.URL;
    self.navigationItem.title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    [self reqeuseProgressToEnd];
    [self checkBackOrForce];
    self.webView.allowsInlineMediaPlayback = NO;
    self.shareBar.enabled = YES;
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    DDLogInfo(@"didFailLoadWithError:%@",error.localizedDescription);
    [self reqeuseProgressToEnd];
    [self checkBackOrForce];
}
-(void)checkBackOrForce{
    DDLogInfo(@"%ld",self.webView.pageCount);
    DDLogInfo(@"%d %d",self.webView.canGoBack,self.webView.canGoForward);
    self.backBar.enabled = self.webView.canGoBack;
    self.forwardBar.enabled = self.webView.canGoForward;
    //    if ([[UIApplication sharedApplication]canOpenURL:self.webView.request.URL]) {
    //        DDLogInfo(@"ddd");
    //
    //    }
}
-(void)reqeuseProgressToEnd{
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.progressView setProgress:1.0 animated:YES];
        //        self.progressView.progress = 1;
    } completion:^(BOOL finished) {
        if (finished) {
            self.progressView.alpha = 0;
            self.progressView.progress = 0;
            self.searchBar.searchResultsButtonSelected = NO;
        }
    }];
}
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    [self checkBackOrForce];
    //    [self.progressView setProgress:0.2 animated:YES];
    if ([request.URL.absoluteString isEqualToString:@"about:blank"]) {
        return NO;
    }
    self.requestURL = request.URL;
    DDLogInfo(@"shouldStartLoadWithRequest");
    //    self.progressView.progress = 0.0;
    return YES;
}
#pragma mark == scrolView的代理
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if (velocity.y>0) {
        [self changeToolBarHidden:YES];
    }else if (velocity.y<0){
        [self changeToolBarHidden:NO];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.searchBar endEditing:YES];
}
-(void)changeToolBarHidden:(BOOL)hidden{
    self.toolBarlBottomConst.constant = hidden? -44:0;
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)hideTabBar {
    if (self.tabBarController.tabBar.hidden == YES) {
        return;
    }
    UIView *contentView;
    if ( [[self.tabBarController.view.subviews objectAtIndex:0] isKindOfClass:[UITabBar class]] )
        contentView = [self.tabBarController.view.subviews objectAtIndex:1];
    else
        contentView = [self.tabBarController.view.subviews objectAtIndex:0];
    contentView.frame = CGRectMake(contentView.bounds.origin.x,  contentView.bounds.origin.y,  contentView.bounds.size.width, contentView.bounds.size.height + self.tabBarController.tabBar.frame.size.height);
    self.tabBarController.tabBar.hidden = YES;
    
}
- (void)showTabBar

{
    if (self.tabBarController.tabBar.hidden == NO)
    {
        return;
    }
    UIView *contentView;
    if ([[self.tabBarController.view.subviews objectAtIndex:0] isKindOfClass:[UITabBar class]])
        
        contentView = [self.tabBarController.view.subviews objectAtIndex:1];
    
    else
        
        contentView = [self.tabBarController.view.subviews objectAtIndex:0];
    contentView.frame = CGRectMake(contentView.bounds.origin.x, contentView.bounds.origin.y,  contentView.bounds.size.width, contentView.bounds.size.height - self.tabBarController.tabBar.frame.size.height);
    self.tabBarController.tabBar.hidden = NO;
    
}
#pragma mark == searchBar的代理
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self setFavouriteEditting:NO];
    [self.favouriteVC finishEdit];
    
    [searchBar setShowsSearchResultsButton:NO];
    [searchBar setShowsCancelButton:YES animated:YES];
    if (!self.favouriteVC.view.superview) {
        [self.view addSubview:self.favouriteVC.view];
        self.favouriteVC.view.frame = self.view.bounds;
    }
    return YES;
}
#pragma mark - 遍历改变搜索框 取消按钮的文字颜色

- (void)changeSearchBarCancelBtnTitleColor:(UISearchBar *)searchBar{
    UIButton *getBtn = [searchBar valueForKeyPath:@"cancelButton"];
    [getBtn setTitleColor:[UIColor colorWithHexString:@"0374f2"] forState:UIControlStateReserved];
    
    [getBtn setTitleColor:[UIColor blueColor] forState:UIControlStateDisabled];
    [getBtn setTitle:NSLocalizedString(@"Done", nil)  forState:UIControlStateDisabled];
    
}
-(UIButton *)cancleBtnOfSearchBar{
    UIButton *getBtn = [self.searchBar valueForKeyPath:@"cancelButton"];
    return getBtn;
}
- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self showWebView];
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    [self dealUserInputContent:searchBar.text];
    [self showWebView];
}
-(void)showWebView{
    [self.searchBar setShowsSearchResultsButton:YES];
    [self.searchBar setShowsCancelButton:NO animated:YES];
    
    if (!self.requestURL) {
        return;
    }
    [self.favouriteVC.view removeFromSuperview];
}
-(void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar
{
    if (searchBar.isSearchResultsButtonSelected) {//正在请求数据
        [self.webView stopLoading];
    }else{
        [self.webView reload];
    }
}
#pragma mark -- VC的代理,搜索及访问处理
-(void)loadRequestWithNoti:(NSNotification *)noti{
    NSString *url = noti.object;
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}
-(void)requelsBookmarkURlStr:(NSString *)content
{
    [self.searchBar resignFirstResponder];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:content]]];
}
-(void)dealUserInputContent:(NSString *)content
{
    [self.searchBar resignFirstResponder];
    [self webviewPrepareStartLoad];
    if (![content containsString:@"."]) {
        [self searchStr:content];
    }else{
        if (content.length<4) {
            [self searchStr:content];
        }else{
            if ([content containsString:@"http://"] || [content containsString:@"https://"]) {
                [self requestURLStr:content];
            }else{
                NSURL *url = [NSURL URLWithString:content];
                if (url) {
                    NSString *contentUrl = content;
                    contentUrl  = [NSString stringWithFormat:@"http://%@",content];
                    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:contentUrl]];
                    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
                    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                        NSLog(@"error %@",error);
                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
                        if (httpResponse && httpResponse.statusCode<500) {
                            DDLogInfo(@"是网址，请求:%@",contentUrl);
                            [self requestURLStr:contentUrl];
                        }else{
                            DDLogInfo(@" 不是网址，搜索：%@",content);
                            [self searchStr:content];
                        }
                    }];
                    [task resume];
                }else{
                    DDLogInfo(@"不可用");
                    [self searchStr:content];
                }
            }
        }
    }
    
}
-(void)setFavouriteEditting:(BOOL)editing
{
    if (editing) {
        if (![self.searchBar isFirstResponder]) {
            [self.searchBar setShowsCancelButton:YES animated:YES];
            [self.searchBar setShowsSearchResultsButton:NO];
            //            self.searchBar.showsCancelButton = YES;
        }
    }
    
    if (self.searchBar.isFirstResponder) {
        [self.searchBar resignFirstResponder];
    }
    UIButton *getBtn = [self.searchBar valueForKeyPath:@"cancelButton"];
    if (editing) {
        self.endEditBtn.frame = getBtn.frame;
        [self.navigationController.navigationBar addSubview:self.endEditBtn];
        [getBtn.superview addSubview:self.endEditBtn];
        getBtn.hidden = YES;
    }else{
        getBtn.hidden = NO;
        [self.endEditBtn removeFromSuperview];
    }
}
-(void)hiddenKeyboard{
    [self.searchBar resignFirstResponder];
    
    //    [self changeSearchBarCancelBtnTitleColor:self.searchBar];
    UIButton *getBtn = [self.searchBar valueForKeyPath:@"cancelButton"];
    getBtn.hidden = YES;
    self.endEditBtn.frame = getBtn.frame;
    [self.navigationController.navigationBar addSubview:self.endEditBtn];
    [getBtn.superview addSubview:self.endEditBtn];
}
//-(BOOL)isURLofaString:(NSString *)astr{
//    NSURL *url = [NSURL URLWithString:astr];
//    if (url) {
//        if (![astr containsString:@"http"]) {
//            astr  = [NSString stringWithFormat:@"http://%@",astr];
//        }
//        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:astr]];
//        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
//        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//            NSLog(@"error %@",error);
//            if (error) {
//                NSLog(@"不可用");
//            }else{
//                NSLog(@"可用");
//            }
//        }];
//        [task resume];
//        if ([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:astr]]) {
//            return YES;
//        }
//    }
//    return NO;
//}
-(void)searchStr:(NSString *)contentSrr{
    NSURL *requestUrl = [NSURL URLWithString:[UserDefaultManager searchEngineUrlWith:contentSrr]];
    [self.webView loadRequest:[NSURLRequest requestWithURL:requestUrl]];
    
}
-(void)requestURLStr:(NSString *)urlStr
{
    if (![urlStr containsString:@"http"]) {
        urlStr  = [NSString stringWithFormat:@"http://%@",urlStr];
    }
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:req];
}

#pragma mark == 通知中心
-(void)addNotificationCenter
{
    //    AVPlayerItemNewAccessLogEntry
    //    AVPlayerItemTimebaseChangedNotification
    //    AVURLAssetDownloadCompleteSuccessNotification
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleNotification:) name:kPlayerPlayNewVideo object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleNotification:) name:kPlayerPlayBegin object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleNotification:) name:kPlayerPlayEnd object:nil];
    //    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleNoti:) name:nil object:nil];
    //    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleTimebaseChangedNoti:) name:@"AVPlayerItemTimebaseChangedNotification" object:nil];
    
}
-(void)removeNotificationCenter
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
-(void)handleNoti:(NSNotification *)noti{
    DDLogVerbose(@"%@,%@",noti.name,noti.object?:@"nil");
}
//-(void)handleTimebaseChangedNoti:(NSNotification *)noti{
//    DDLogVerbose(@"%@",noti.name);
//}
-(void)handleNotification:(NSNotification *)noti
{
    DDLogInfo(@"%@",noti.name);
    if ([noti.name isEqualToString:kPlayerPlayNewVideo]) {
        
        [AnalyticsTool analyCategory:@"Browser" action:@"点击浏览器主屏【网址】" label:self.webView.request.URL.host value:nil];
        if (!self.showAlert) {
            AVURLAsset *asset = (AVURLAsset *)(((AVPlayerItem *)noti.object).asset);
            NSString *urlStr = asset.URL.absoluteString;
            DDLogVerbose(@"检测到的视频地址：%@",urlStr);
            [self dealDownloadUrl:urlStr];
            self.showAlert = YES;
        }else{//关闭时
            
        }
    }else if ([noti.name isEqualToString:kPlayerPlayBegin]){
        
    }else if ([noti.name isEqualToString:kPlayerPlayEnd]){
        if (![noti.object isKindOfClass:NSClassFromString(@"_UIAlertControllerShimPresenterWindow")]) {
            self.showAlert = NO;
        }
    }
}


#pragma mark == 视频解析下载
//下载视频
-(void)dealDownloadUrl:(NSString *)urlStr{
    
    NSDictionary *ipInfo = [UserDefaultManager deviceIPInfo];
    if (ipInfo) {
        NSString *country_id = ipInfo[@"country_id"];
        if ([self domain:urlStr isInblacklist:country_id]) {
            DDLogInfo(@"在该地区不允许访问");
            UIAlertView *alv = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"The file can not be downloaded according to relevant laws, regulations and policies.", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles: nil];
            [alv show];
        }else{
            DDLogVerbose(@"开始下载视频");
            if ([urlStr hasSuffix:@".m3u8"] || [urlStr containsString:@".m3u8?"]) {//m3u8
                DDLogVerbose(@"下载m3u8");
                [self warningUserDownloadM3u8:urlStr];
            }else{//mp4(normal)
                DDLogVerbose(@"下载mp4");
                [self warningUserDownload:urlStr];
            }
        }
    }else{
        DDLogVerbose(@"没有请求到IP信息");
        if ([urlStr hasSuffix:@".m3u8"] || [urlStr containsString:@".m3u8?"]) {//m3u8
            DDLogVerbose(@"下载m3u8");
            [self warningUserDownloadM3u8:urlStr];
        }else{//mp4(normal)
            DDLogVerbose(@"下载Mp4");
            [self warningUserDownload:urlStr];
        }
    }
}
//检查国家黑名单
-(BOOL)domain:(NSString *)domin isInblacklist:(NSString *)country_id
{
    domin = self.webView.request.URL.host;
    NSDictionary *blackList = [UserDefaultManager visitBlackList];
    NSArray *allCountry = [blackList objectForKey:@"ALL"];//先检查所有国家都禁止的
    if (allCountry.count>0) {
        for (NSString *balck in allCountry) {
            if (domin) {
                if ([domin containsString:balck]) {
                    return YES;
                }
            }
        }
    }
    NSArray *list = [blackList objectForKey:country_id];//再检查当前国家禁止的
    if (list.count>0) {
        for (NSString *balck in list) {
            NSURL *url = [NSURL URLWithString:domin];
            if (url) {
                if ([url.host containsString:balck]) {
                    return YES;
                }
            }
        }
    }
    DDLogInfo(@"check %@ ",country_id);
    return NO;
}
//m3u8下载提醒
-(void)warningUserDownloadM3u8:(NSString *)videoUrlstr{
    [AnalyticsTool analyCategory:@"Browser" action:@"视频下载的格式" label:@"m3u8" value:nil];
    self.newstVideoUrlStr = videoUrlstr;
    //    The file can not be downloaded according to relevant laws, regulations and policies.
    if ([[DownloadCacher shareInstance]checkIsExistOfUrl:videoUrlstr]) {
        
        UIAlertView *alv = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"The file already exists.", nil)  message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil)  otherButtonTitles:nil];
        [alv show];
    }else{
        NSArray *segments = [self segmentsInM3u8Url:videoUrlstr];
        NSArray *result = segments;
        if (segments) {
            if (segments.count>3) {
                result = @[segments.firstObject,segments[segments.count/2],segments.lastObject];
            }
            NSString *videoTitle = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
            NSArray *btnTitles = @[NSLocalizedString(@"Download SD", nil),NSLocalizedString(@"Download HD", nil),NSLocalizedString(@"Download Full HD", nil)];
            UIFActionSheet *acs = [[UIFActionSheet alloc]initWithTitle:videoTitle delegate:self cancelButtonTitle:NSLocalizedString(@"Later", nil) destructiveButtonTitle:nil otherButtonTitles: nil];
            for (NSString *btitle in btnTitles) {
                [acs addButtonWithTitle:btitle] ;
            }
            //            for (M3U8TopSegmentInfo *segmentInfo in result) {
            //                [acs addButtonWithTitle:[videoTitle stringByAppendingString:segmentInfo.BANDWIDTH]] ;
            //            }
            acs.name = @"selectM3U8";
            acs.userInfo = @{@"segments":result};
            [acs showInView:self.view];
            //        UIFAlertView *alv = [[UIFAlertView alloc]initWithTitle:NSLocalizedString(@"The file can not be downloaded according to relevant laws, regulations and policies.", nil)  message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil)  otherButtonTitles: nil];
            //        alv.userInfo = @{@"url":videoUrlstr};
            //        [alv show];
        }else{
            UIFAlertView *alv = [[UIFAlertView alloc]initWithTitle:NSLocalizedString(@"The file can not be downloaded according to relevant laws, regulations and policies.", nil)  message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil)  otherButtonTitles: nil];
            alv.userInfo = @{@"url":videoUrlstr};
            [alv show];
        }
    }
    
    
    /*
     NSString *videoTitle = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
     UIAlertView *alv = [[UIAlertView alloc]initWithTitle:@"Download m3u8 file?" message:videoTitle delegate:self cancelButtonTitle:@"Not now" otherButtonTitles:@"Download", nil];
     alv.tag = kAlertTagDownloadM3U8;
     [alv show];
     */
}
- (NSArray *)segmentsInM3u8Url:(NSString *)videoUrl
{
    if ([videoUrl isEqualToString:@""] || videoUrl == nil)
    {
        return nil;
    }
    NSURL *url = [NSURL URLWithString:videoUrl];
    NSError *err = nil;
    NSString *m3u8Str = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:&err];
    if (err)
    {
        return nil;
    }
    NSRange topSegmentRange = [m3u8Str rangeOfString:@"#EXT-X-STREAM-INF:"];
    if (topSegmentRange.location != NSNotFound) {//这是顶级m3u8，需要继续解析
        NSString *remainData = m3u8Str;
        NSMutableArray *segments = [NSMutableArray array];
        NSRange segmentRange = [remainData rangeOfString:@"#EXT-X-STREAM-INF:"];
        NSInteger segmentIndex = 0;
        while (segmentRange.location != NSNotFound)
        {
            M3U8TopSegmentInfo *segment = [[M3U8TopSegmentInfo alloc] init];
            //读取带宽
            NSRange bandRange = [remainData rangeOfString:@"BANDWIDTH="];
            //读过的，截取一下
            remainData = [remainData substringFromIndex:bandRange.location+bandRange.length];
            NSRange commaRange = [remainData  rangeOfString:@","];
            
            NSString *bandValue = [remainData substringWithRange:NSMakeRange(0, commaRange.location)];
            //读过的，截取一下
            remainData = [remainData substringFromIndex:commaRange.location];
            //读取片段url
            NSRange linkRangeBegin = [remainData rangeOfString:@"\n"];
            //            NSRange linkRangeBegin = NSMakeRange([remainData rangeOfString:@"\n"].location + 1, [remainData rangeOfString:@","].length - 1) ;
            //读过的，截取一下
            remainData = [remainData substringFromIndex:linkRangeBegin.location+linkRangeBegin.length];//从url开头位置截取
            NSRange linkRangeEnd = [remainData rangeOfString:@"\n"];//到下一个换行
            NSString *linkurl = [remainData substringWithRange:NSMakeRange(0, linkRangeEnd.location)];
            
            segment.url = linkurl;
            segment.BANDWIDTH = bandValue;
            //        segment.localUrl = [DownloadManager getM3U8LocalUrlWithVideoUrl:linkurl];
            segmentIndex++;
            [segments addObject:segment];
            remainData = [remainData substringFromIndex:linkRangeEnd.location];
            segmentRange = [remainData rangeOfString:@"#EXT-X-STREAM-INF:"];
        }
        //        M3U8TopSegmentInfo *segment = segments.firstObject;
        NSArray *result = [segments sortedArrayUsingComparator:^NSComparisonResult(M3U8TopSegmentInfo *obj1, M3U8TopSegmentInfo *obj2) {
            return [obj1.BANDWIDTH compare:obj2.BANDWIDTH]; //升序
        }
                           ];
        return result;
    }else{
        return nil;
    }
    
}
-(void)warningUserDownload:(NSString *)videoUrlstr{
    [AnalyticsTool analyCategory:@"Browser" action:@"视频下载的格式" label:@"mp4" value:nil];
    if ([[DownloadCacher shareInstance]checkIsExistOfUrl:videoUrlstr]) {
        
        UIAlertView *alv = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"The file already exists.", nil)  message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil)  otherButtonTitles:nil];
        [alv show];
    }else{
        //         NSString *lJs = @"document.documentElement.innerHTML";//获取当前网页的html
        //        DDLogVerbose(@"html %@",lJs);
        self.newstVideoUrlStr = videoUrlstr;
        NSString *videoTitle = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
        UIAlertView *alv = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Download file?", nil)  message:videoTitle delegate:self cancelButtonTitle:NSLocalizedString(@"Later", nil)  otherButtonTitles:NSLocalizedString(@"Download", nil), nil];
        alv.tag = kAlertTagDownloadMp4;
        [alv show];
    }
    
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kAlertTagDownloadMp4) {
        if (buttonIndex == 0) {//取消下载
            
        }else{
            [self downLoadWithUrlStr:self.newstVideoUrlStr];
        }
    }
    
}
-(void)actionSheet:(UIFActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([actionSheet.name isEqualToString:@"selectM3U8"] && buttonIndex>0) {
        NSDictionary *userInfo = actionSheet.userInfo;
        NSArray *segments = userInfo[@"segments"];
        M3U8TopSegmentInfo *info = segments[buttonIndex-1];
        DDLogVerbose(@"%@",info.url);
        DownloadModel *downloadModel = [[DownloadModel alloc] init];
        NSString *webName = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
        //防止出现获取不到title出现的没有文件名情况
        NSString *extion = [NSURL URLWithString:info.url].path.pathExtension;
        if (extion.length<1) {
            extion = @"m3u8";
        }
        NSString *fileName = webName.length>0?webName:@"video";
        fileName = [fileName stringByAppendingPathExtension:extion];
        downloadModel.name = [HYFileManager getLegalFileName:fileName];
        downloadModel.url = info.url;
        [[DownloadManager shareInstance] dealDownloadModel:downloadModel];
        
        [[NSNotificationCenter defaultCenter]postNotificationName:DownloadingAddedNotification object:downloadModel];
    }
}
-(void)actionSheetCancel:(UIFActionSheet *)actionSheet
{
    
}
-(void)downLoadWithUrlStr:(NSString *)urlStr{
    DDLogInfo(@"要下载的视频地址：%@",urlStr);
    DownloadModel *downloadModel = [[DownloadModel alloc] init];
    NSString *webName = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    //防止出现获取不到title出现的没有文件名情况
    NSString *extion = [NSURL URLWithString:urlStr].path.pathExtension;
    if (extion.length<1) {
        extion = @"mp4";
    }
    NSString *fileName = webName.length>0?webName:@"video";
    fileName = [fileName stringByAppendingPathExtension:extion];
    downloadModel.name = [HYFileManager getLegalFileName:fileName];
    downloadModel.url = urlStr;
    [[DownloadManager shareInstance] dealDownloadModel:downloadModel];
    
    [[NSNotificationCenter defaultCenter]postNotificationName:DownloadingAddedNotification object:downloadModel];
    
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"AddBookMark"]) {
        UINavigationController *navi = segue.destinationViewController;
        AddBookmarkViewController *adbkVC = navi.childViewControllers.firstObject;
        adbkVC.webTitle = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
        DDLogInfo(@"%@ \n %@",self.requestURL.absoluteString,self.webView.request.URL.absoluteString);
        adbkVC.webUrl = self.webView.request.URL.absoluteString;
        adbkVC.bkType = sender;
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

-(void)adViewDidLoad:(FBAdView *)adView
{
    //    self.adViewHeightConst.constant = 50;
    //    [UIView animateWithDuration:0.2 animations:^{
    //        [self.view layoutIfNeeded];
    //    }];
}
-(void)adViewDidClick:(FBAdView *)adView
{
    [AnalyticsTool analyCategory:@"Browser" action:@"点击【广告位1】" label:nil value:nil];
}
@end
