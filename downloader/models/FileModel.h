//
//  FileModel.h
//  downloader
//
//  Created by xueyognwei on 2017/3/31.
//  Copyright © 2017年 xueyognwei. All rights reserved.
//

#import "BaseModel.h"

@interface FileModel : BaseModel
@property (nonatomic,strong)NSDate *createDate;
@property (nonatomic,copy)NSString *fileName;
@property (nonatomic,copy)NSString *thumPath;
@property (nonatomic,copy)NSString *filePath;
@property (nonatomic,strong)NSNumber *fileSize;
@end
