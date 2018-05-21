//
//  MyLogFormatter.m
//  Coolog_Example
//
//  Created by Yao Li on 2018/5/21.
//  Copyright © 2018年 yao.li. All rights reserved.
//

#import "MyLogFormatter.h"

@implementation MyLogFormatter
- (NSString *)completeLogWithType:(COLLogType)type tag:(NSString *)tag message:(NSString *)message date:(NSDate *)date thread:(NSThread *)thread {
    return [NSString stringWithFormat:@"tag=[%zd], type=[%@], message=[%@], date=[%@], thread=[%@]", type, tag, message, date, thread];
}
@end
