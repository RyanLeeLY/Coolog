//
//  MyLogger.m
//  Coolog_Example
//
//  Created by Yao Li on 2018/5/21.
//  Copyright © 2018年 yao.li. All rights reserved.
//

#import "MyLogger.h"
#import <os/log.h>

@implementation MyLogger
@synthesize formatterClass = _formatterClass;

+ (instancetype)logger {
    return [[MyLogger alloc] init];
}

- (void)log:(NSString *)logString {
    os_log(OS_LOG_DEFAULT, "%{public}s", [logString UTF8String]);
}
@end
