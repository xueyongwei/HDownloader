//
//  BookMarketViewController.m
//  downloader
//
//  Created by xueyognwei on 2017/3/30.
//  Copyright © 2017年 xueyognwei. All rights reserved.
//

#import "BookMarketViewController.h"
#import "BookMarketModel.h"
#import "BookMarkManager.h"
#import "BookMarketTableViewCell.h"
#import "BookMarkHeader.h"
@interface BookMarketViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIButton *naviDoneButton;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong)NSMutableArray *dataSource;
@property (nonatomic,strong)BookMarkHeader *header;
@end

@implementation BookMarketViewController
-(BookMarkHeader *)header
{
    if (!_header) {
        _header = [[[NSBundle mainBundle]loadNibNamed:@"BookMarkHeader" owner:self options:nil]lastObject];
//        _header.frame = CGRectMake(0, 0, YYScreenSize().width, 50);
    }
    return _header;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *books = nil;
    if (self.noDir) {
        books =[[BookMarkManager shareInstance] queryAllbookMarksOfType:BookMarketTypeFavourite];
        self.navigationItem.title = NSLocalizedString(@"Favourites", nil) ;
    }else{
        books =[[BookMarkManager shareInstance] queryAllbookMarksOfType:BookMarketTypeNormal];
        self.header.frame = CGRectMake(0, 0, YYScreenSize().width, 50);
        self.tableView.tableHeaderView = self.header;
        
    }
    self.dataSource = [NSMutableArray arrayWithArray:books];
    [self customTableView];
}
#pragma mark -- 点击事件
- (IBAction)onNaviDoneClick:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)onToolbarEditClick:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    self.naviDoneButton.hidden = sender.selected;
    [self.tableView setEditing:sender.selected animated:YES];
    self.tableView.tableHeaderView.userInteractionEnabled = !sender.selected;
    if (sender.selected == NO) {//取消编辑
        [[BookMarkManager shareInstance]reSortBookMarkModels:self.dataSource];
    }
}
- (IBAction)onFavouriteClick:(UIButton *)sender {
    [self showFaVC];
}

-(void )customTableView{
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - tableViewDelegage
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    if (self.noDir) {
        return self.dataSource.count;
//    }
//    return self.dataSource.count +1;
}
//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
////    return self.header;
//    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, YYScreenSize().width, 50)];
//    view.backgroundColor = [UIColor redColor];
//        return view;
//}
//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 50;
//}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    BookMarketTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BookMarketTableViewCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"BookMarketTableViewCell" owner:self options:nil]lastObject];
    }
//    if ((!self.noDir) && (indexPath.row ==0)) {
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//        cell.bookMarkTitle.text = @"Favorites";
//        cell.bookMarkImageView.image = [UIImage imageNamed:@"shareFa"];
//    }else{
        [self setBookMarketTableViewCell:cell WithIndexPath:indexPath];
//    }

    return cell;
}
-(void)setBookMarketTableViewCell:(BookMarketTableViewCell *)cell WithIndexPath:(NSIndexPath *)indexPath
{
//    cell.accessoryType = UITableViewCellAccessoryNone;
//    if (self.noDir) {
        BookMarketModel *bookMark = self.dataSource[indexPath.row];
        cell.model = bookMark;
//    }else{
//        BookMarketModel *bookMark = self.dataSource[indexPath.row-1];
//        cell.model = bookMark;
//    }
}
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.row == 0 && !self.noDir) {
//        return NO;
//    }
    return YES;
}
-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (indexPath.row == 0 && !self.noDir) {
//        return NO;
//    }
    return YES;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{

    return UITableViewCellEditingStyleDelete;
    
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteModelAtIndexPath:indexPath];
    }
}
-(void)deleteModelAtIndexPath:(NSIndexPath *)indexPath
{
    // 删除模型
    BookMarketModel *model = self.dataSource[indexPath.row];
    [[BookMarkManager shareInstance]deleteBookMarkModel:model];
    [self.dataSource removeObject:model];
    // 刷新
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    
}
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    // 取出要拖动的模型数据
    BookMarketModel *model = self.dataSource[sourceIndexPath.row];
    //删除之前行的数据
    [self.dataSource removeObject:model];
    // 插入数据到新的位置
    [self.dataSource insertObject:model atIndex:destinationIndexPath.row];
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView.editing) {
        
    }else{
        BookMarketModel *model = self.dataSource[indexPath.row];
        [[NSNotificationCenter defaultCenter]postNotificationName:kLoadUrlNoti object:model.url];
        [self dismissViewControllerAnimated:YES completion:nil];
//        if (indexPath.row == 0) {
//            
//        }else{
//            
//        }
    }
}
-(void)showFaVC{
    UIStoryboard *story = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    BookMarketViewController *fvc = [story instantiateViewControllerWithIdentifier:@"BookMarketViewController"];
    fvc.noDir = YES;
    [self.navigationController pushViewController:fvc animated:YES];
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
