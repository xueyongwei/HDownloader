//
//  AddBookmarkViewController.m
//  downloader
//
//  Created by xueyognwei on 2017/3/30.
//  Copyright © 2017年 xueyognwei. All rights reserved.
//

#import "AddBookmarkViewController.h"
#import "BookMarketModel.h"
#import "BookMarkManager.h"
@interface AddBookmarkViewController ()<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *titleTF;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addBookmarkSepHeightConst;
@property (weak, nonatomic) IBOutlet UILabel *urlLabel;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@end

@implementation AddBookmarkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.addBookmarkSepHeightConst.constant = 1/[UIScreen mainScreen].scale;
    self.titleTF.delegate = self;
    if ([self.bkType isEqualToString:@"Farvorite"]) {
        self.navigationItem.title = NSLocalizedString(@"Add to Bookmark", nil);
    }else{
        self.navigationItem.title = NSLocalizedString(@"Add to Favorite", nil);
    }
    self.view.backgroundColor = [UIColor colorWithHexString:@"f4f4f4"];
    self.titleTF.text = self.webTitle;
    self.urlLabel.text = self.webUrl;
    self.saveButton.enabled = self.webTitle.length>0;
    [self.titleTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}
-(void)textFieldDidChange:(UITextField *)tf{
    self.saveButton.enabled = tf.text.length>0;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.titleTF resignFirstResponder];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.titleTF becomeFirstResponder];
}
- (IBAction)onCancleClick:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)onSaveClick:(UIButton *)sender {
    [self saveBookMark];
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)saveBookMark{
    BookMarketModel *model = [[BookMarketModel alloc]init];
    model.title = self.titleTF.text;
    model.url = self.urlLabel.text;
    model.isFavourite = [self.bkType isEqualToString:@"Farvorite"];
    [[BookMarkManager shareInstance] insertBookMarkModel:model];
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
