//
//  WebStartViewController.m
//  XYWProject
//
//  Created by xueyognwei on 2017/3/22.
//  Copyright © 2017年 薛永伟. All rights reserved.
//

#import "FavouriteViewController.h"
#import "XYWMDACollectionViewLayout.h"
#import "BookMarkManager.h"
#import "FavouriteCollectionViewCell.h"
#import "FavouriteHeaderView.h"
#import "FavouriteFooterView.h"

#define K_Cell @"cell"
#define K_No_Cell @"noCell"
#define K_Head_Cell @"headCell"
#define K_Foot_Cell @"footCell"

@interface FavouriteViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, XYWMDACollectionViewLayoutDelegate>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *dataSource;

@property (nonatomic, strong) XYWMDACollectionViewLayout *flowLayout;
@property (nonatomic, assign) BOOL inEditState; //是否处于编辑状态
@property (nonatomic, strong) UIButton *finishEditBtn;
@property (nonatomic, strong) UILabel *messageLabel; //删除完毕时
@end

@implementation FavouriteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    
    [self.view addSubview:self.collectionView];
    self.view.backgroundColor = [UIColor colorWithHexString:@"#f2f2f2"];
    
//    [self.view addSubview:self.finishEditBtn];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.dataSource = [NSMutableArray arrayWithArray:[[BookMarkManager shareInstance]queryAllbookMarksOfType:BookMarketTypeFavourite]];
    [self.collectionView reloadData];
}
#pragma mark - XYWMDACollectionViewLayoutDelegate

//处于编辑状态
- (void)didChangeEditState:(BOOL)inEditState
{
    self.inEditState = inEditState;
    if (inEditState) {
        
    }
    for (FavouriteCollectionViewCell *cell in self.collectionView.visibleCells) {
        cell.inEditState = inEditState;
    }
    [self.delegate setFavouriteEditting:inEditState];
//    if (inEditState) {
//        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//        btn.frame =CGRectMake(0, 0, 44, 44);
//        [self.navigationController.navigationBar addSubview:btn];
//        btn.backgroundColor = [UIColor redColor];
//        [btn setTitle:@"Done" forState:UIControlStateNormal];
//    }else{
//        
//    }
//    [self.delegate hiddenKeyboard];
}

//改变数据源中model的位置
- (void)moveItemAtIndexPath:(NSIndexPath *)formPath toIndexPath:(NSIndexPath *)toPath
{
    BookMarketModel *model = self.dataSource[formPath.item];
    //先把移动的这个model移除
    [self.dataSource removeObject:model];
    //再把这个移动的model插入到相应的位置
    [self.dataSource insertObject:model atIndex:toPath.item];
}

#pragma mark - 右边的编辑按钮方法

- (void)rightBarButtonItemAction:(UIButton *)barButton
{
    if (!self.inEditState) { //点击了管理
        self.inEditState = YES;
        self.collectionView.allowsSelection = NO;
    } else { //点击了完成
        self.inEditState = NO;
        self.collectionView.allowsSelection = YES;
        //此处可以调用网络请求，把排序完之后的传给服务端
        DDLogInfo(@"点击了完成按钮");
    }
    [self.flowLayout setInEditState:self.inEditState];
}

#pragma mark - 点击button的方法

- (void)btnClick:(UIButton *)sender event:(id)event
{
    //获取点击button的位置
    NSSet *touches = [event allTouches];
    UITouch *touch = [touches anyObject];
    CGPoint currentPoint = [touch locationInView:_collectionView];
    NSIndexPath *indexPath = [_collectionView indexPathForItemAtPoint:currentPoint];
    [self.collectionView performBatchUpdates:^{
        [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
        [self.dataSource removeObjectAtIndex:indexPath.item]; //删除
    } completion:^(BOOL finished) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    }];
}
-(void)finishEdit{
    [self onFinishEdit:nil];
}
-(void)onFinishEdit:(UIButton *)sender
{
    DDLogInfo(@"点击了完成按钮");
    self.inEditState = NO;
    self.collectionView.allowsSelection = YES;
    //此处排序完之后的顺序同步到数据库
     [[BookMarkManager shareInstance]reSortBookMarkModels:self.dataSource];
    [self.flowLayout setInEditState:self.inEditState];
    
}
#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//创建cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FavouriteCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:K_Cell forIndexPath:indexPath];
    
    //是否处于编辑状态，如果处于编辑状态，出现边框和按钮，否则隐藏
    BookMarketModel *model = self.dataSource[indexPath.item];
    cell.inEditState = self.inEditState;
    [cell setModel:model indexPaht:indexPath];
    [cell.button addTarget:self action:@selector(btnClick:event:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}

#pragma mark - 点击collectionView的方法

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.inEditState) { //如果不在编辑状态
        BookMarketModel *model = self.dataSource[indexPath.item];
        
        [self.delegate requelsBookmarkURlStr:model.url];
        
        [AnalyticsTool analyCategory:@"Browser" action:@"点击浏览器主屏【网址】" label:[NSURL URLWithString:model.url].host value:nil];
        DDLogInfo(@"点击了第%@个分区的第%@个cell", @(indexPath.section), @(indexPath.item));
    }
}

#pragma mark - HeaderAndFooter
/*
 //区头区尾视图
 - (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
 {
 if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
 FavouriteHeaderView *headView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:K_Head_Cell forIndexPath:indexPath];
 if (indexPath.section == 0) {
 headView.headLabel.text = @"我的应用";
 } else {
 headView.headLabel.text = @"便捷生活";
 }
 return headView;
 } else if ([kind isEqualToString:UICollectionElementKindSectionFooter]){
 FavouriteFooterView *footView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:K_Foot_Cell forIndexPath:indexPath];
 return footView;
 }
 return nil;
 }
 
 //头视图
 - (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
 {
 if (self.dataSource.count == 0) {
 if (section == 0) {
 CGFloat width = (YYScreenSize().width - 80) / 4;
 self.messageLabel.frame = CGRectMake(0, 30, YYScreenSize().width, width);
 //显示没有更多的提示
 [self.collectionView addSubview:self.messageLabel];
 return CGSizeMake(YYScreenSize().width, 25 + width);
 } else {
 return CGSizeMake(YYScreenSize().width, 25);
 }
 } else {
 [self.messageLabel removeFromSuperview];
 return CGSizeMake(YYScreenSize().width, 25);
 }
 }
 
 //尾视图
 - (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
 {
 if (section == 0) {
 return CGSizeMake(YYScreenSize().width, 10);
 } else {
 return CGSizeMake(YYScreenSize().width, 0.5);
 }
 }
 */
#pragma mark - init

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 49-64) collectionViewLayout:self.flowLayout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor colorWithHexString:@"#f2f2f2"];
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _collectionView.bounces = YES;
//        _collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        //给集合视图注册一个cell
        [_collectionView registerClass:[FavouriteCollectionViewCell class] forCellWithReuseIdentifier:K_Cell];
        //注册一个区头视图
        [_collectionView registerClass:[FavouriteHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:K_Head_Cell];
        //注册一个区尾视图
        [_collectionView registerClass:[FavouriteFooterView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:K_Foot_Cell];
        _collectionView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    }
    return _collectionView;
}

- (XYWMDACollectionViewLayout *)flowLayout
{
    if (!_flowLayout) {
        CGFloat width = (YYScreenSize().width - 80) / 4;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            width = (YYScreenSize().width - 200) / 6;
        }
        
        _flowLayout = [[XYWMDACollectionViewLayout alloc] init];
        _flowLayout.delegate = self;
        //设置每个图片的大小
        _flowLayout.itemSize = CGSizeMake(width, width + 9);
        //设置滚动方向的间距
        _flowLayout.minimumLineSpacing = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad?50:10;
        //设置上方的反方向
        _flowLayout.minimumInteritemSpacing = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad?10:0;
        _flowLayout.sectionInset = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad?UIEdgeInsetsMake(40, 40, 40, 40):UIEdgeInsetsMake(15, 20, 20, 20);
        
        //设置collectionView整体的上下左右之间的间距
//        UIEdgeInsets inset =UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad?inset =UIEdgeInsetsMake(15, 100, 20, 100):UIEdgeInsetsMake(15, 20, 20, 20);
//        
//        _flowLayout.sectionInset = inset;
        //设置滚动方向
        _flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    return _flowLayout;
}
//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
//    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad?UIEdgeInsetsMake(40, 40, 40, 40):UIEdgeInsetsMake(15, 20, 20, 20);
//}
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
//    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad?10:40;
//}
- (NSMutableArray *)dataSource
{
    if (_dataSource == nil) {
        _dataSource = [NSMutableArray arrayWithCapacity:1];
    }
    return _dataSource;
}


//没有应用的提示
- (UILabel *)messageLabel
{
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.font = [UIFont systemFontOfSize:12];
        _messageLabel.numberOfLines = 0;
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.text = @"no favourite in bookmarket \n you can add bookmarket to favourite";
    }
    return _messageLabel;
}
-(UIButton *)finishEditBtn{
    if (!_finishEditBtn) {
        _finishEditBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _finishEditBtn.backgroundColor = [UIColor lightGrayColor];
        _finishEditBtn.frame = CGRectMake(0, YYScreenSize().height-44-49, YYScreenSize().width, 44);
        [_finishEditBtn setTitle:NSLocalizedString(@"Done", nil)  forState:UIControlStateNormal];
        [_finishEditBtn addTarget:self action:@selector(onFinishEdit:) forControlEvents:UIControlEventTouchUpInside];
        [_finishEditBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    return _finishEditBtn;
}
@end
