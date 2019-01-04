//
//  MyLogFormatter.m
//  Coolog_Example
//
//  Created by Yao Li on 2018/5/21.
//  Copyright © 2018年 yao.li. All rights reserved.
//

#import "MyLogFormatter.h"

@implementation MyLogFormatter
- (NSString *)completeLogWithType:(COLLogType)type tag:(NSString *)tag message:(NSString *)message timeInterval:(NSTimeInterval)timeInterval {
    return [NSString stringWithFormat:@"tag=[%@], type=[%zd], message=[%@], date=[%@]", tag, type, message, @(timeInterval)];
}

@end
