//
//  FilesTableViewCell.h
//  downloader
//
//  Created by xueyognwei on 2017/4/1.
//  Copyright © 2017年 xueyognwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FileModel.h"
@protocol FilesTableViewCellDelegate <NSObject>
- (void)filesTableViewCellReloadTableView;
- (void)filesTableViewCellDeleteModel:(FileModel *)model;
@end

@interface FilesTableViewCell : UITableViewCell <UIActionSheetDelegate,UIAlertViewDelegate>{
    UIDocumentInteractionController * documentController;
}
@property (weak, nonatomic) IBOutlet UIImageView *fileIconImgV;
@property (weak, nonatomic) IBOutlet UILabel *fileNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *fileSizeLabel;
@property (weak, nonatomic) IBOutlet UIButton *moreBtn;
@property (strong, nonatomic) FileModel  *model;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *moreWidthConst;
@property (weak, nonatomic)id <FilesTableViewCellDelegate> delegate;
@end
