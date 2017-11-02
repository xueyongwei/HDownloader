//
//  Cache2UserDefaultModel.h
//  XYWProject
//
//  Created by xueyognwei on 2017/3/13.
//  Copyright © 2017年 薛永伟. All rights reserved.
//

#import "BaseModel.h"

/**
 需要保存到userDefault的模型（需要编码解码,遵守NSCoding协议）
 */
@interface Cache2UserDefaultModel : BaseModel<NSCoding>

@end
