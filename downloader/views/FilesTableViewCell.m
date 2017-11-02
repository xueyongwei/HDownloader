//
//  FilesTableViewCell.m
//  downloader
//
//  Created by xueyognwei on 2017/4/1.
//  Copyright © 2017年 xueyognwei. All rights reserved.
//

#import "FilesTableViewCell.h"
#import "ShareTool.h"
#import "HYFileManager.h"

@implementation FilesTableViewCell
#define kActionSheetMoreTag 100
//#define kActionSheetDeleteTag 200
#define kAlertRenameTag 300

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
-(void)setModel:(FileModel *)model
{
    _model = model;
    self.fileNameLabel.text = [model.fileName stringByURLDecode];
    self.fileIconImgV.image = [UIImage imageWithContentsOfFile:model.thumPath]?:[UIImage imageNamed:@"default"];
    self.fileSizeLabel.text = [self stringForVideoSize:model.fileSize.longValue];
}
- (IBAction)onMoreClikc:(UIButton *)sender {
    [AnalyticsTool analyCategory:@"Files" action:@"点击【More】" label:nil value:nil];
    UIActionSheet *act = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Open in", nil) ,NSLocalizedString(@"Rename", nil),NSLocalizedString(@"Delete", nil), nil];
    act.tag = kActionSheetMoreTag;
    [act showInView:self.superview];
}
#pragma mark == actionSheet
//-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    DDLogInfo(@"%ld",buttonIndex);
//    if (buttonIndex == 0) {
//        [[[ShareTool alloc] init] shareWithTitle:@"分享的title" description:@"描述信息" url:@"http://www.baidu.com" image:nil completionHandler:^(UIActivityType  _Nullable activityType, BOOL completed) {
//            //        if (completed) {
//            //            [wkSelf shareActionWithType:activityType];
//            //        }
//            DDLogInfo(@"%@  %d", activityType, completed);
//        }];
//    }else if (buttonIndex ==1){
//
//    }else if (buttonIndex ==2){
//
//        if ([self.delegate respondsToSelector:@selector(filesTableViewCellDeleteModel:)]) {
//            [self.delegate filesTableViewCellDeleteModel:self.model];
//        }
//    }
//}
-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == kActionSheetMoreTag) {
        
        if (buttonIndex == 0) {
            //            [AnalyticsTool analyCategory:@"Files" action:@"点击【More】" label:@"share" value:nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSURL *fileURL = [[NSURL fileURLWithPath:self.model.filePath] URLByAppendingPathComponent:self.model.fileName];
                documentController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
                UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController.childViewControllers.firstObject;
//                [documentController presentOptionsMenuFromRect:self.view.bounds  inView:self.view animated:YES];
//                [documentController presentOpenInMenuFromBarButtonItem:[[UIBarButtonItem alloc]initWithCustomView:self.moreBtn]  animated:YES];
//                [documentController presentOptionsMenuFromBarButtonItem:[[UIBarButtonItem alloc]initWithCustomView:self.moreBtn]  animated:YES];
                
                [documentController presentOptionsMenuFromRect:CGRectMake(YYScreenSize().width/2, 60, YYScreenSize().width, YYScreenSize().height)  inView:vc.view animated:YES];
            });
            
            //            self.documentController.delegate = self;
            //
            //            UIActivityViewController *activity = [[UIActivityViewController alloc] initWithActivityItems:@[fileURL] applicationActivities:nil];
            //            UIViewController *vc = (UIViewController *)self.delegate;
            //            [vc presentViewController:activity animated:YES completion:nil];
            //            [self.navigationController pushViewController:activity animated:YES];
            //            [[[ShareTool alloc] init] shareWithTitle:@"分享的title" description:@"描述信息" url:@"http://www.baidu.com" image:nil completionHandler:^(UIActivityType  _Nullable activityType, BOOL completed) {
            //                //        if (completed) {
            //                //            [wkSelf shareActionWithType:activityType];
            //                //        }
            //                DDLogInfo(@"%@  %d", activityType, completed);
            //            }];
        }else if (buttonIndex ==1){
            [AnalyticsTool analyCategory:@"Files" action:@"点击【More】" label:@"rename" value:nil];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Rename", nil)  message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil)  otherButtonTitles:NSLocalizedString(@"OK", nil) , nil];
            [alert setAlertViewStyle:UIAlertViewStylePlainTextInput];
            
            alert.tag =  kAlertRenameTag;
            UITextField *txtName = [alert textFieldAtIndex:0];
            txtName.placeholder = NSLocalizedString(@"New name", nil) ;
            [txtName addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventValueChanged];
            [alert show];
        }else if (buttonIndex ==2){
            [AnalyticsTool analyCategory:@"Files" action:@"点击【More】" label:@"delete" value:nil];
            if ([self.delegate respondsToSelector:@selector(filesTableViewCellDeleteModel:)]) {
                [self.delegate filesTableViewCellDeleteModel:self.model];
            }
        }else{
            [AnalyticsTool analyCategory:@"Files" action:@"点击【More】" label:@"cancel" value:nil];
        }
    }
    
}
#pragma mark == alertView
-(BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    UITextField *txt = [alertView textFieldAtIndex:0];
    if (txt.text.length>0) {
        return YES;
    }
    return NO;
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    UITextField *txt = [alertView textFieldAtIndex:0];
    [txt endEditing:YES];
    if (buttonIndex == 1) {
        //        self.model.fileName = [txt.text stringByAppendingString:@".mp4"];
        //        NSString *dirPath = [HYFileManager directoryAtPath:self.model.filePath];
        NSString *ext = self.model.fileName.pathExtension;
        
        if ([[txt.text stringByAppendingPathExtension:ext] isEqualToString:self.model.fileName]||[txt.text isEqualToString:self.model.fileName]) {//输入带后缀不带后缀的同名的都直接返回
            return;
        }
        NSString *leaglName = [HYFileManager getLegalFileName:[txt.text stringByAppendingPathExtension:ext]];
        NSString *newPath = [self.model.filePath stringByAppendingPathComponent:leaglName];
        [HYFileManager moveItemAtPath:[self.model.filePath stringByAppendingPathComponent:self.model.fileName] toPath:newPath];
        if ([ext isEqualToString:@"mp4"]) {//只有mp4的视频有缩略图
            NSString *imageName = [[self.model.fileName stringByDeletingPathExtension]stringByAppendingString:@".jpg"];
            NSString *newImageName = [[leaglName stringByDeletingPathExtension]stringByAppendingString:@".jpg"];
            [HYFileManager moveItemAtPath:[self.model.filePath stringByAppendingPathComponent:imageName] toPath:[self.model.filePath stringByAppendingPathComponent:newImageName]];
        }
        
        if ([self.delegate respondsToSelector:@selector(filesTableViewCellReloadTableView)]) {
            self.model.fileName = leaglName;
            [self.delegate filesTableViewCellReloadTableView];
        }
    }
}
- (void)textFieldDidChange:(UITextField *)textField
{  if (textField.text.length > 250) {
    textField.text = [textField.text substringToIndex:250];
}
}
-(void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    self.moreWidthConst.constant = editing ?0:50;
    [UIView animateWithDuration:0.3 animations:^{
        [self layoutIfNeeded];
    }];
    
    //    self.moreBtn.hidden = editing;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
-(NSString *)stringForVideoSize:(int64_t)total{
    NSString *totalStr = @"";
    if (total >= 0 && total < 1024) {
        //B
        totalStr = [NSString stringWithFormat:@"%ldB", (long)total];
    } else if (total >= 1024 && total < 1024 * 1024) {
        //KB
        totalStr = [NSString stringWithFormat:@"%ldK", (long)total / 1024];
    } else if (total >= 1024 * 1024 && total < 1024 * 1024 *1024) {
        //MB
        totalStr = [NSString stringWithFormat:@"%.2lfM", (double)total / 1024.0 / 1024.0];
    } else if (total >= 1024 * 1024 *1024) {
        //GB
        totalStr = [NSString stringWithFormat:@"%.2lfG", (double)total / 1024.0 / 1024.0];
    }
    return totalStr;
}
-(void)deleteFile{
    
}
@end
