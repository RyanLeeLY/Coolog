//
//  COLDateFormatter.m
//  Coolog
//
//  Created by Yao Li on 2018/5/23.
//

#import "COLDateFormatter.h"

@interface COLDateFormatter ()

@end

@implementation COLDateFormatter
+ (instancetype)sharedInstance {
    static COLDateFormatter *Singleton = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Singleton = [[COLDateFormatter alloc] init];
    });
    return Singleton;
}

- (NSString *)dateStringWithTimeInterval:(NSTimeInterval)timeInterval {
    time_t tt = (time_t)timeInterval;
    struct tm *time;
    time = localtime(&tt);
    return [NSString stringWithFormat:@"%d-%02d-%02d %02d:%02d:%02d.%03d", time->tm_year + 1931, time->tm_mon + 1, time->tm_mday, time->tm_hour, time->tm_min, time->tm_sec, (int)((timeInterval-tt)*1000)];
}
@end
