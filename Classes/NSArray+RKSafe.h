//
//  NSArray+RKSafe.h
//
//  Created by 李沛倬 on 2018/6/3.
//  Copyright © 2018年 peizhuo. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 是否仅release模式执行集合类型安全的增删改查（不会crash）。
 建议设置为true：在开发过程中通过crash来捕获异常并修复bug，上线后自动开启安全模式，以保证程序不会因此crash
 */
static BOOL const onlyRelease = false;

/*
 此category的功能：
 1. 会使NSArray和NSDictionary以JSON格式打印，并可正常显示其中的中文字符
 2. 越界、赋空值等操作不会crash
 不用import，项目中存在即可
 */
@interface NSArray (RKSafe)

@end



@interface NSDictionary (RKSafe)

@end
